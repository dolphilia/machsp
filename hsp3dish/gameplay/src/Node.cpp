#include "Base.h"
#include "Node.h"
#include "AudioSource.h"
#include "Scene.h"
#include "Joint.h"
#include "PhysicsRigidBody.h"
#include "PhysicsVehicle.h"
#include "PhysicsVehicleWheel.h"
#include "PhysicsGhostObject.h"
#include "PhysicsCharacter.h"
#include "Terrain.h"
#include "Game.h"
#include "Drawable.h"
#include "Form.h"
#include "Ref.h"

// Node dirty flags
#define NODE_DIRTY_WORLD 1
#define NODE_DIRTY_BOUNDS 2
#define NODE_DIRTY_HIERARCHY 4
#define NODE_DIRTY_ALL (NODE_DIRTY_WORLD | NODE_DIRTY_BOUNDS | NODE_DIRTY_HIERARCHY)

namespace gameplay
{

Node::Node(const char* id)
    : _scene(NULL), _firstChild(NULL), _nextSibling(NULL), _prevSibling(NULL), _parent(NULL), _childCount(0), _enabled(true), _tags(NULL),
    _drawable(NULL), _camera(NULL), _light(NULL), _audioSource(NULL), _collisionObject(NULL), _agent(NULL), _userObject(NULL),
      _dirtyBits(NODE_DIRTY_ALL)
{
	GP_REGISTER_SCRIPT_EVENTS();
    if (id)
    {
        _id = id;
    }
}

Node::~Node()
{
    removeAllChildren();
    if (_drawable)
        _drawable->setNode(NULL);
#ifndef HSPDISH
    if (_audioSource)
        _audioSource->setNode(NULL);
#endif
    Ref* ref = dynamic_cast<Ref*>(_drawable);
    SAFE_RELEASE(ref);
    SAFE_RELEASE(_camera);
    SAFE_RELEASE(_light);
#ifndef HSPDISH
    SAFE_RELEASE(_audioSource);
#endif
    SAFE_DELETE(_collisionObject);
    SAFE_RELEASE(_userObject);
    SAFE_DELETE(_tags);
    setAgent(NULL);
}

Node* Node::create(const char* id)
{
    return new Node(id);
}

const char* Node::getTypeName() const
{
    return "Node";
}

const char* Node::getId() const
{
    return _id.c_str();
}

void Node::setId(const char* id)
{
    if (id)
    {
        _id = id;
    }
}

Node::Type Node::getType() const
{
    return Node::NODE;
}

void Node::addChild(Node* child)
{
    GP_ASSERT(child);

    if (child->_parent == this)
    {
        // This node is already present in our hierarchy
        return;
    }
    child->addRef();

    // If the item belongs to another hierarchy, remove it first.
    if (child->_parent)
    {
        child->_parent->removeChild(child);
    }
    else if (child->_scene)
    {
        child->_scene->removeNode(child);
    }
    // Add child to the end of the list.
    // NOTE: This is different than the original behavior which inserted nodes
    // into the beginning of the list. Although slightly slower to add to the
    // end of the list, it makes scene traversal and drawing order more
    // predictable, so I've changed it.
    if (_firstChild)
    {
        Node* n = _firstChild;
        while (n->_nextSibling)
            n = n->_nextSibling;
        n->_nextSibling = child;
        child->_prevSibling = n;
    }
    else
    {
        _firstChild = child;
    }
    child->_parent = this;
    ++_childCount;
    setBoundsDirty();

    if (_dirtyBits & NODE_DIRTY_HIERARCHY)
    {
        hierarchyChanged();
    }
}

void Node::removeChild(Node* child)
{
    if (child == NULL || child->_parent != this)
    {
        // The child is not in our hierarchy.
        return;
    }
    // Call remove on the child.
    child->remove();
    SAFE_RELEASE(child);
}

void Node::removeAllChildren()
{
    _dirtyBits &= ~NODE_DIRTY_HIERARCHY;
    while (_firstChild)
    {
        removeChild(_firstChild);
    }
    _dirtyBits |= NODE_DIRTY_HIERARCHY;
    hierarchyChanged();
}

void Node::remove()
{
    // Re-link our neighbours.
    if (_prevSibling)
    {
        _prevSibling->_nextSibling = _nextSibling;
    }
    if (_nextSibling)
    {
        _nextSibling->_prevSibling = _prevSibling;
    }
    // Update our parent.
    Node* parent = _parent;
    if (parent)
    {
        if (this == parent->_firstChild)
        {
            parent->_firstChild = _nextSibling;
        }
        --parent->_childCount;
    }
    _nextSibling = NULL;
    _prevSibling = NULL;
    _parent = NULL;

    if (parent && parent->_dirtyBits & NODE_DIRTY_HIERARCHY)
    {
        parent->hierarchyChanged();
    }
}

Node* Node::getFirstChild() const
{
    return _firstChild;
}

Node* Node::getNextSibling() const
{
    return _nextSibling;
}

Node* Node::getPreviousSibling() const
{
    return _prevSibling;
}

Node* Node::getParent() const
{
    return _parent;
}

unsigned int Node::getChildCount() const
{
    return _childCount;
}

Node* Node::getRootNode() const
{
    Node* n = const_cast<Node*>(this);
    while (n->getParent())
    {
        n = n->getParent();
    }
    return n;
}

Node* Node::findNode(const char* id, bool recursive, bool exactMatch) const
{
    GP_ASSERT(id);

	// If the drawable is a model with a mesh skin, search the skin's hierarchy as well.
    Node* rootNode = NULL;
    Model* model = dynamic_cast<Model*>(_drawable);
    if (model)
    {
        if (model->getSkin() != NULL && (rootNode = model->getSkin()->_rootNode) != NULL)
        {
            if ((exactMatch && rootNode->_id == id) || (!exactMatch && rootNode->_id.find(id) == 0))
                return rootNode;

            Node* match = rootNode->findNode(id, true, exactMatch);
            if (match)
            {
                return match;
            }
        }
    }
    // Search immediate children first.
    for (Node* child = getFirstChild(); child != NULL; child = child->getNextSibling())
    {

		// Does this child's ID match?
        if ((exactMatch && child->_id == id) || (!exactMatch && child->_id.find(id) == 0))
        {
            return child;
        }
    }
	// Recurse.
    if (recursive)
    {
        for (Node* child = getFirstChild(); child != NULL; child = child->getNextSibling())
        {
            Node* match = child->findNode(id, true, exactMatch);
            if (match)
            {
                return match;
            }
        }
    }
    return NULL;
}

unsigned int Node::findNodes(const char* id, std::vector<Node*>& nodes, bool recursive, bool exactMatch) const
{
    GP_ASSERT(id);

    // If the drawable is a model with a mesh skin, search the skin's hierarchy as well.
    unsigned int count = 0;
    Node* rootNode = NULL;
    Model* model = dynamic_cast<Model*>(_drawable);
    if (model)
    {
        if (model->getSkin() != NULL && (rootNode = model->getSkin()->_rootNode) != NULL)
        {
            if ((exactMatch && rootNode->_id == id) || (!exactMatch && rootNode->_id.find(id) == 0))
            {
                nodes.push_back(rootNode);
                ++count;
            }
            count += rootNode->findNodes(id, nodes, true, exactMatch);
        }
    }
    // Search immediate children first.
    for (Node* child = getFirstChild(); child != NULL; child = child->getNextSibling())
    {
        // Does this child's ID match?
        if ((exactMatch && child->_id == id) || (!exactMatch && child->_id.find(id) == 0))
        {
            nodes.push_back(child);
            ++count;
        }
    }
    // Recurse.
    if (recursive)
    {
        for (Node* child = getFirstChild(); child != NULL; child = child->getNextSibling())
        {
            count += child->findNodes(id, nodes, true, exactMatch);
        }
    }

    return count;
}

Scene* Node::getScene() const
{
    if (_scene)
        return _scene;

    // Search our parent for the scene
    if (_parent)
    {
        Scene* scene = _parent->getScene();
        if (scene)
            return scene;
    }
    return NULL;
}

bool Node::hasTag(const char* name) const
{
    GP_ASSERT(name);
    return (_tags ? _tags->find(name) != _tags->end() : false);
}

const char* Node::getTag(const char* name) const
{
    GP_ASSERT(name);

    if (!_tags)
        return NULL;

    std::map<std::string, std::string>::const_iterator itr = _tags->find(name);
    return (itr == _tags->end() ? NULL : itr->second.c_str());
}

void Node::setTag(const char* name, const char* value)
{
    GP_ASSERT(name);

    if (value == NULL)
    {
        // Removing tag
        if (_tags)
        {
            _tags->erase(name);
            if (_tags->size() == 0)
            {
                SAFE_DELETE(_tags);
            }
        }
    }
    else
    {
        // Setting tag
        if (_tags == NULL)
        {
            _tags = new std::map<std::string, std::string>();
        }
        (*_tags)[name] = value;
    }
}

void Node::setEnabled(bool enabled)
{
    if (_enabled != enabled)
    {
        if (_collisionObject)
        {
            _collisionObject->setEnabled(enabled);
        }
        _enabled = enabled;
    }
}

bool Node::isEnabled() const
{
    return _enabled;
}

bool Node::isEnabledInHierarchy() const
{
    if (!_enabled)
       return false;

   Node* node = _parent;
   while (node)
   {
       if (!node->_enabled)
       {
           return false;
       }
       node = node->_parent;
   }
   return true;
}

void Node::update(float elapsedTime)
{
    for (Node* node = _firstChild; node != NULL; node = node->_nextSibling)
    {
        if (node->isEnabled())
        {
            node->update(elapsedTime);
        }
    }
    fireScriptEvent<void>(GP_GET_SCRIPT_EVENT(Node, update), dynamic_cast<void*>(this), elapsedTime);
}

bool Node::isStatic() const
{
    return (_collisionObject && _collisionObject->isStatic());
}

const Matrix& Node::getWorldMatrix() const
{
    if (_dirtyBits & NODE_DIRTY_WORLD)
    {
        // Clear our dirty flag immediately to prevent this block from being entered if our
        // parent calls our getWorldMatrix() method as a result of the following calculations.
        _dirtyBits &= ~NODE_DIRTY_WORLD;

        if (!isStatic())
        {
            // If we have a parent, multiply our parent world transform by our local
            // transform to obtain our final resolved world transform.
            Node* parent = getParent();
            if (parent && (!_collisionObject || _collisionObject->isKinematic()))
            {
                Matrix::multiply(parent->getWorldMatrix(), getMatrix(), &_world);
            }
            else
            {
                _world = getMatrix();
            }

            // Our world matrix was just updated, so call getWorldMatrix() on all child nodes
            // to force their resolved world matrices to be updated.
            //for (Node* child = getFirstChild(); child != NULL; child = child->getNextSibling())
            //{
            //    child->getWorldMatrix();
            //}
		}
    }
	return _world;
}

const Matrix& Node::getWorldViewMatrix() const
{
    static Matrix worldView;
    Matrix::multiply(getViewMatrix(), getWorldMatrix(), &worldView);
    return worldView;
}

const Matrix& Node::getInverseTransposeWorldViewMatrix() const
{
    static Matrix invTransWorldView;
    Matrix::multiply(getViewMatrix(), getWorldMatrix(), &invTransWorldView);
    invTransWorldView.invert();
    invTransWorldView.transpose();
    return invTransWorldView;
}

const Matrix& Node::getInverseTransposeWorldMatrix() const
{
    static Matrix invTransWorld;
    invTransWorld = getWorldMatrix();
    invTransWorld.invert();
    invTransWorld.transpose();
    return invTransWorld;
}

const Matrix& Node::getViewMatrix() const
{
    Scene* scene = getScene();
    Camera* camera = scene ? scene->getActiveCamera() : NULL;
    if (camera)
    {
        return camera->getViewMatrix();
    }
    else
    {
        return Matrix::identity();
    }
}

const Matrix& Node::getInverseViewMatrix() const
{
    Scene* scene = getScene();
    Camera* camera = scene ? scene->getActiveCamera() : NULL;
    if (camera)
    {
        return camera->getInverseViewMatrix();
    }
    else
    {
        return Matrix::identity();
    }
}

const Matrix& Node::getProjectionMatrix() const
{
    Scene* scene = getScene();
    Camera* camera = scene ? scene->getActiveCamera() : NULL;
    if (camera)
    {
        return camera->getProjectionMatrix();
    }
    else
    {
        return Matrix::identity();
    }
}

const Matrix& Node::getViewProjectionMatrix() const
{
    Scene* scene = getScene();
    Camera* camera = scene ? scene->getActiveCamera() : NULL;
    if (camera)
    {
        return camera->getViewProjectionMatrix();
    }
    else
    {
        return Matrix::identity();
    }
}

const Matrix& Node::getInverseViewProjectionMatrix() const
{
    Scene* scene = getScene();
    Camera* camera = scene ? scene->getActiveCamera() : NULL;
    if (camera)
    {
        return camera->getInverseViewProjectionMatrix();
    }
    return Matrix::identity();
}

const Matrix& Node::getWorldViewProjectionMatrix() const
{
    // Always re-calculate worldViewProjection matrix since it's extremely difficult
    // to track whether the camera has changed (it may frequently change every frame).
    static Matrix worldViewProj;
    Matrix::multiply(getViewProjectionMatrix(), getWorldMatrix(), &worldViewProj);
    return worldViewProj;
}

Vector3 Node::getTranslationWorld() const
{
    Vector3 translation;
    getWorldMatrix().getTranslation(&translation);
    return translation;
}

Vector3 Node::getTranslationView() const
{
    Vector3 translation;
    getWorldMatrix().getTranslation(&translation);
    getViewMatrix().transformPoint(&translation);
    return translation;
}

Vector3 Node::getForwardVectorWorld() const
{
    Vector3 vector;
    getWorldMatrix().getForwardVector(&vector);
    return vector;
}

Vector3 Node::getForwardVectorView() const
{
    Vector3 vector;
    getWorldMatrix().getForwardVector(&vector);
    getViewMatrix().transformVector(&vector);
    return vector;
}

Vector3 Node::getRightVectorWorld() const
{
    Vector3 vector;
    getWorldMatrix().getRightVector(&vector);
    return vector;
}

Vector3 Node::getUpVectorWorld() const
{
    Vector3 vector;
    getWorldMatrix().getUpVector(&vector);
    return vector;
}

Vector3 Node::getActiveCameraTranslationWorld() const
{
    Scene* scene = getScene();
    if (scene)
    {
        Camera* camera = scene->getActiveCamera();
        if (camera)
        {
            Node* cameraNode = camera->getNode();
            if (cameraNode)
            {
                return cameraNode->getTranslationWorld();
            }
        }
    }
    return Vector3::zero();
}

Vector3 Node::getActiveCameraTranslationView() const
{
    Scene* scene = getScene();
    if (scene)
    {
        Camera* camera = scene->getActiveCamera();
        if (camera)
        {
            Node* cameraNode = camera->getNode();
            if (cameraNode)
            {
                return cameraNode->getTranslationView();
            }
        }
    }
    return Vector3::zero();
}


#ifdef HSPDISH
Vector3 Node::getLightColor(void) const
{
    if (_light == NULL) {
        return Vector3::zero();
    }
    Vector3 vector = _light->getColor();
    return vector;
}

#endif


void Node::hierarchyChanged()
{
    // When our hierarchy changes our world transform is affected, so we must dirty it.
    _dirtyBits |= NODE_DIRTY_HIERARCHY;
    transformChanged();
}

void Node::transformChanged()
{
    // Our local transform was changed, so mark our world matrices dirty.
    _dirtyBits |= NODE_DIRTY_WORLD | NODE_DIRTY_BOUNDS;

    // Notify our children that their transform has also changed (since transforms are inherited).
    for (Node* n = getFirstChild(); n != NULL; n = n->getNextSibling())
    {
        if (Transform::isTransformChangedSuspended())
        {
            // If the DIRTY_NOTIFY bit is not set
            if (!n->isDirty(Transform::DIRTY_NOTIFY))
            {
                n->transformChanged();
                suspendTransformChange(n);
            }
        }
        else
        {
            n->transformChanged();
        }
    }
    Transform::transformChanged();
}

void Node::setBoundsDirty()
{
    // Mark ourself and our parent nodes as dirty
    _dirtyBits |= NODE_DIRTY_BOUNDS;

    // Mark our parent bounds as dirty as well
    if (_parent)
        _parent->setBoundsDirty();
}

Animation* Node::getAnimation(const char* id) const
{
    Animation* animation = ((AnimationTarget*)this)->getAnimation(id);
    if (animation)
        return animation;
    
    // See if this node has a model, then drill down.
    Model* model = dynamic_cast<Model*>(_drawable);
    if (model)
    {
        // Check to see if there's any animations with the ID on the joints.
        MeshSkin* skin = model->getSkin();
        if (skin)
        {
            Node* rootNode = skin->_rootNode;
            if (rootNode)
            {
                animation = rootNode->getAnimation(id);
                if (animation)
                    return animation;
            }
        }

        // Check to see if any of the model's material parameter's has an animation
        // with the given ID.
        Material* material = model->getMaterial();
        if (material)
        {
            // How to access material parameters? hidden on the Material::RenderState.
            std::vector<MaterialParameter*>::iterator itr = material->_parameters.begin();
            for (; itr != material->_parameters.end(); itr++)
            {
                GP_ASSERT(*itr);
                animation = ((MaterialParameter*)(*itr))->getAnimation(id);
                if (animation)
                    return animation;
            }
        }
    }

    // look through form for animations.
    Form* form = dynamic_cast<Form*>(_drawable);
    if (form)
    {
        animation = form->getAnimation(id);
        if (animation)
            return animation;
    }

    // Look through this node's children for an animation with the specified ID.
    for (Node* child = getFirstChild(); child != NULL; child = child->getNextSibling())
    {
        animation = child->getAnimation(id);
        if (animation)
            return animation;
    }
    
    return NULL;
}

Camera* Node::getCamera() const
{
    return _camera;
}

void Node::setCamera(Camera* camera)
{
    if (_camera == camera)
        return;

    if (_camera)
    {
        _camera->setNode(NULL);
        SAFE_RELEASE(_camera);
    }

    _camera = camera;

    if (_camera)
    {
        _camera->addRef();
        _camera->setNode(this);
    }
}

Light* Node::getLight() const
{
    return _light;
}

void Node::setLight(Light* light)
{
    if (_light == light)
        return;

    if (_light)
    {
        _light->setNode(NULL);
        SAFE_RELEASE(_light);
    }

    _light = light;

    if (_light)
    {
        _light->addRef();
        _light->setNode(this);
    }

    setBoundsDirty();
}

Drawable* Node::getDrawable() const
{
    return _drawable;
}

void Node::setDrawable(Drawable* drawable)
{
    if (_drawable != drawable)
    {
        if (_drawable)
        {
            _drawable->setNode(NULL);
            Ref* ref = dynamic_cast<Ref*>(_drawable);
            if (ref)
                ref->release();
        }

        _drawable = drawable;

        if (_drawable)
        {
            Ref* ref = dynamic_cast<Ref*>(_drawable);
            if (ref)
                ref->addRef();
            _drawable->setNode(this);
        }
    }
    setBoundsDirty();
}

const BoundingSphere& Node::getBoundingSphere() const
{
    if (_dirtyBits & NODE_DIRTY_BOUNDS)
    {
        _dirtyBits &= ~NODE_DIRTY_BOUNDS;

        const Matrix& worldMatrix = getWorldMatrix();

        // Start with our local bounding sphere
        // TODO: Incorporate bounds from entities other than mesh (i.e. particleemitters, audiosource, etc)
        bool empty = true;
        Terrain* terrain = dynamic_cast<Terrain*>(_drawable);
        if (terrain)
        {
            _bounds.set(terrain->getBoundingBox());
            empty = false;
        }
        Model* model = dynamic_cast<Model*>(_drawable);
        if (model && model->getMesh())
        {
            if (empty)
            {
                _bounds.set(model->getMesh()->getBoundingSphere());
                empty = false;
            }
            else
            {
                _bounds.merge(model->getMesh()->getBoundingSphere());
            }
        }
        if (_light)
        {
            switch (_light->getLightType())
            {
            case Light::POINT:
                if (empty)
                {
                    _bounds.set(Vector3::zero(), _light->getRange());
                    empty = false;
                }
                else
                {
                    _bounds.merge(BoundingSphere(Vector3::zero(), _light->getRange()));
                }
                break;
            case Light::SPOT:
                // TODO: Implement spot light bounds
                break;
            }
        }
        if (empty)
        {
            // Empty bounding sphere, set the world translation with zero radius
            worldMatrix.getTranslation(&_bounds.center);
            _bounds.radius = 0;
        }

        // Transform the sphere (if not empty) into world space.
        if (!empty)
        {
            bool applyWorldTransform = true;
            if (model && model->getSkin())
            {
                // Special case: If the root joint of our mesh skin is parented by any nodes, 
                // multiply the world matrix of the root joint's parent by this node's
                // world matrix. This computes a final world matrix used for transforming this
                // node's bounding volume. This allows us to store a much smaller bounding
                // volume approximation than would otherwise be possible for skinned meshes,
                // since joint parent nodes that are not in the matrix palette do not need to
                // be considered as directly transforming vertices on the GPU (they can instead
                // be applied directly to the bounding volume transformation below).
                GP_ASSERT(model->getSkin()->getRootJoint());
                Node* jointParent = model->getSkin()->getRootJoint()->getParent();
                if (jointParent)
                {
                    // TODO: Should we protect against the case where joints are nested directly
                    // in the node hierachy of the model (this is normally not the case)?
                    Matrix boundsMatrix;
                    Matrix::multiply(getWorldMatrix(), jointParent->getWorldMatrix(), &boundsMatrix);
                    _bounds.transform(boundsMatrix);
                    applyWorldTransform = false;
                }
            }
            if (applyWorldTransform)
            {
                _bounds.transform(getWorldMatrix());
            }
        }

        // Merge this world-space bounding sphere with our childrens' bounding volumes.
        for (Node* n = getFirstChild(); n != NULL; n = n->getNextSibling())
        {
            const BoundingSphere& childSphere = n->getBoundingSphere();
            if (!childSphere.isEmpty())
            {
                if (empty)
                {
                    _bounds.set(childSphere);
                    empty = false;
                }
                else
                {
                    _bounds.merge(childSphere);
                }
            }
        }
    }

    return _bounds;
}

Node* Node::clone() const
{
    NodeCloneContext context;
    return cloneRecursive(context);
}

Node* Node::cloneSingleNode(NodeCloneContext &context) const
{
    Node* copy = Node::create(getId());
    context.registerClonedNode(this, copy);
    cloneInto(copy, context);
    return copy;
}

Node* Node::cloneRecursive(NodeCloneContext &context) const
{
    Node* copy = cloneSingleNode(context);
    GP_ASSERT(copy);

    // Add child nodes
    for (Node* child = getFirstChild(); child != NULL; child = child->getNextSibling())
    {
        Node* childCopy = child->cloneRecursive(context);
        GP_ASSERT(childCopy);
        copy->addChild(childCopy);
        childCopy->release();
    }

    return copy;
}

void Node::cloneInto(Node* node, NodeCloneContext& context) const
{
    GP_ASSERT(node);

    Transform::cloneInto(node, context);

    if (Drawable* drawable = getDrawable())
    {
        Drawable* clone = drawable->clone(context);
        node->setDrawable(clone);
        Ref* ref = dynamic_cast<Ref*>(clone);
        if (ref)
            ref->release();
    }
    if (Camera* camera = getCamera())
    {
        Camera* clone = camera->clone(context);
        node->setCamera(clone);
        Ref* ref = dynamic_cast<Ref*>(clone);
        if (ref)
            ref->release();
    }
    if (Light* light = getLight())
    {
        Light* clone = light->clone(context);
        node->setLight(clone);
        Ref* ref = dynamic_cast<Ref*>(clone);
        if (ref)
            ref->release();
    }
#ifndef HSPDISH
    if (AudioSource* audio = getAudioSource())
    {
        AudioSource* clone = audio->clone(context);
        node->setAudioSource(clone);
        Ref* ref = dynamic_cast<Ref*>(clone);
        if (ref)
            ref->release();
    }
#endif
    if (_tags)
    {
        node->_tags = new std::map<std::string, std::string>(_tags->begin(), _tags->end());
    }

    node->_world = _world;
    node->_bounds = _bounds;

    // TODO: Clone the rest of the node data.
}

AudioSource* Node::getAudioSource() const
{
#ifndef HSPDISH
    return _audioSource;
#else
	return NULL;
#endif
}

void Node::setAudioSource(AudioSource* audio)
{
#ifndef HSPDISH
    if (_audioSource == audio)
        return;

    if (_audioSource)
    {
        _audioSource->setNode(NULL);
        SAFE_RELEASE(_audioSource);
    }
        
    _audioSource = audio;

    if (_audioSource)
    {
        _audioSource->addRef();
        _audioSource->setNode(this);
    }
#endif
}

PhysicsCollisionObject* Node::getCollisionObject() const
{
    return _collisionObject;
}

PhysicsCollisionObject* Node::setCollisionObject(PhysicsCollisionObject::Type type, const PhysicsCollisionShape::Definition& shape, PhysicsRigidBody::Parameters* rigidBodyParameters, int group, int mask)
{
    SAFE_DELETE(_collisionObject);

    switch (type)
    {
    case PhysicsCollisionObject::RIGID_BODY:
        {
            _collisionObject = new PhysicsRigidBody(this, shape, rigidBodyParameters ? *rigidBodyParameters : PhysicsRigidBody::Parameters(), group, mask);
        }
        break;

    case PhysicsCollisionObject::GHOST_OBJECT:
        {
            _collisionObject = new PhysicsGhostObject(this, shape, group, mask);
        }
        break;

    case PhysicsCollisionObject::CHARACTER:
        {
            _collisionObject = new PhysicsCharacter(this, shape, rigidBodyParameters ? rigidBodyParameters->mass : 1.0f);
        }
        break;

    case PhysicsCollisionObject::VEHICLE:
        {
            _collisionObject = new PhysicsVehicle(this, shape, rigidBodyParameters ? *rigidBodyParameters : PhysicsRigidBody::Parameters());
        }
        break;

    case PhysicsCollisionObject::VEHICLE_WHEEL:
        {
            //
            // PhysicsVehicleWheel is special because this call will traverse up the scene graph for the
            // first ancestor node that is shared with another node of collision type VEHICLE, and then
            // proceed to add itself as a wheel onto that vehicle. This is by design, and allows the
            // visual scene hierarchy to be the sole representation of the relationship between physics
            // objects rather than forcing that upon the otherwise-flat ".physics" (properties) file.
            //
            // IMPORTANT: The VEHICLE must come before the VEHICLE_WHEEL in the ".scene" (properties) file!
            //
            _collisionObject = new PhysicsVehicleWheel(this, shape, rigidBodyParameters ? *rigidBodyParameters : PhysicsRigidBody::Parameters());
        }
        break;

    case PhysicsCollisionObject::NONE:
        break;  // Already deleted, Just don't add a new collision object back.
    }

    return _collisionObject;
}

PhysicsCollisionObject* Node::setCollisionObject(const char* url)
{
    // Load the collision object properties from file.
    Properties* properties = Properties::create(url);
    if (properties == NULL)
    {
        GP_ERROR("Failed to load collision object file: %s", url);
        return NULL;
    }

    PhysicsCollisionObject* collisionObject = setCollisionObject((strlen(properties->getNamespace()) > 0) ? properties : properties->getNextNamespace());
    SAFE_DELETE(properties);

    return collisionObject;
}

PhysicsCollisionObject* Node::setCollisionObject(Properties* properties)
{
    SAFE_DELETE(_collisionObject);

    // Check if the properties is valid.
    if (!properties || !(strcmp(properties->getNamespace(), "collisionObject") == 0))
    {
        GP_ERROR("Failed to load collision object from properties object: must be non-null object and have namespace equal to 'collisionObject'.");
        return NULL;
    }

    if (const char* type = properties->getString("type"))
    {
        if (strcmp(type, "CHARACTER") == 0)
        {
            _collisionObject = PhysicsCharacter::create(this, properties);
        }
        else if (strcmp(type, "GHOST_OBJECT") == 0)
        {
            _collisionObject = PhysicsGhostObject::create(this, properties);
        }
        else if (strcmp(type, "RIGID_BODY") == 0)
        {
            _collisionObject = PhysicsRigidBody::create(this, properties);
        }
        else if (strcmp(type, "VEHICLE") == 0)
        {
            _collisionObject = PhysicsVehicle::create(this, properties);
        }
        else if (strcmp(type, "VEHICLE_WHEEL") == 0)
        {
            //
            // PhysicsVehicleWheel is special because this call will traverse up the scene graph for the
            // first ancestor node that is shared with another node of collision type VEHICLE, and then
            // proceed to add itself as a wheel onto that vehicle. This is by design, and allows the
            // visual scene hierarchy to be the sole representation of the relationship between physics
            // objects rather than forcing that upon the otherwise-flat ".physics" (properties) file.
            //
            // IMPORTANT: The VEHICLE must come before the VEHICLE_WHEEL in the ".scene" (properties) file!
            //
            _collisionObject = PhysicsVehicleWheel::create(this, properties);
        }
        else
        {
            GP_ERROR("Unsupported collision object type '%s'.", type);
            return NULL;
        }
    }
    else
    {
        GP_ERROR("Failed to load collision object from properties object; required attribute 'type' is missing.");
        return NULL;
    }

    return _collisionObject;
}

AIAgent* Node::getAgent() const
{
    // Lazily create a new Agent for this Node if we don't have one yet.
    // Basically, all Nodes by default can have an Agent, we just won't
    // waste the memory unless they request one.
    if (!_agent)
    {
        _agent = AIAgent::create();
        _agent->_node = const_cast<Node*>(this);
        Game::getInstance()->getAIController()->addAgent(_agent);
    }

    return _agent;
}

void Node::setAgent(AIAgent* agent)
{
    if (agent == _agent)
        return;

    if (_agent)
    {
        Game::getInstance()->getAIController()->removeAgent(_agent);
        _agent->setNode(NULL);
        SAFE_RELEASE(_agent);
    }

    _agent = agent;

    if (_agent)
    {
        _agent->addRef();
        _agent->setNode(this);
        Game::getInstance()->getAIController()->addAgent(_agent);
    }
}

Ref* Node::getUserObject() const
{
    return _userObject;
}

void Node::setUserObject(Ref* obj)
{
    _userObject = obj;
}

NodeCloneContext::NodeCloneContext()
{
}

NodeCloneContext::~NodeCloneContext()
{
}

Animation* NodeCloneContext::findClonedAnimation(const Animation* animation)
{
    GP_ASSERT(animation);

    std::map<const Animation*, Animation*>::iterator it = _clonedAnimations.find(animation);
    return it != _clonedAnimations.end() ? it->second : NULL;
}

void NodeCloneContext::registerClonedAnimation(const Animation* original, Animation* clone)
{
    GP_ASSERT(original);
    GP_ASSERT(clone);

    _clonedAnimations[original] = clone;
}

Node* NodeCloneContext::findClonedNode(const Node* node)
{
    GP_ASSERT(node);

    std::map<const Node*, Node*>::iterator it = _clonedNodes.find(node);
    return it != _clonedNodes.end() ? it->second : NULL;
}

void NodeCloneContext::registerClonedNode(const Node* original, Node* clone)
{
    GP_ASSERT(original);
    GP_ASSERT(clone);

    _clonedNodes[original] = clone;
}

}
