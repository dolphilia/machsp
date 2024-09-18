#include "Base.h"
#include "Material.h"
#include "FileSystem.h"
#include "Effect.h"
#include "Technique.h"
#include "Pass.h"
#include "Properties.h"
#include "Node.h"



namespace gameplay
{

Material::Material() :
    _currentTechnique(NULL)
{
}

Material::~Material()
{
    // Destroy all the techniques.
    for (size_t i = 0, count = _techniques.size(); i < count; ++i)
    {
        Technique* technique = _techniques[i];
        SAFE_RELEASE(technique);
    }
}

Material* Material::create(const char* url)
{
    return create(url, (PassCallback)NULL, NULL);
}

Material* Material::create(const char* url, PassCallback callback, void* cookie)
{
    // Load the material properties from file.
    Properties* properties = Properties::create(url);
    if (properties == NULL)
    {
        GP_WARN("Failed to create material from file: %s", url);
        return NULL;
    }

	//GP_WARN("file: %s", url);
	Material* material = create((strlen(properties->getNamespace()) > 0) ? properties : properties->getNextNamespace(), callback, cookie);
    SAFE_DELETE(properties);

    return material;
}

Material* Material::create(Properties* materialProperties)
{
    return create(materialProperties, (PassCallback)NULL, NULL);
}

Material* Material::create(Properties* materialProperties, PassCallback callback, void* cookie)
{
    // Check if the Properties is valid and has a valid namespace.
    if (!materialProperties || !(strcmp(materialProperties->getNamespace(), "material") == 0))
    {
        GP_ERROR("Properties object must be non-null and have namespace equal to 'material'.");
        return NULL;
    }

    // Create new material from the file passed in.
    Material* material = new Material();
	//GP_WARN("NewMaterial[%s][%s][%x]", materialProperties->getNamespace(), materialProperties->getId(),callback);
    material->setName(materialProperties->getId());

    // Load uniform value parameters for this material.
    loadRenderState(material, materialProperties);

    // Go through all the material properties and create techniques under this material.
    Properties* techniqueProperties = NULL;
    while ((techniqueProperties = materialProperties->getNextNamespace()))
    {
        if (strcmp(techniqueProperties->getNamespace(), "technique") == 0)
        {
            if (!loadTechnique(material, techniqueProperties, callback, cookie))
            {
                GP_ERROR("Failed to load technique for material.");
                SAFE_RELEASE(material);
                return NULL;
            }
        }
    }

    // Set the current technique to the first found technique.
    if (material->getTechniqueCount() > 0)
    {
        Technique* t = material->getTechniqueByIndex(0);
        if (t)
        {
            material->_currentTechnique = t;
        }
    }
    return material;
}

Material* Material::create(Effect* effect)
{
    GP_ASSERT(effect);

    // Create a new material with a single technique and pass for the given effect.
    Material* material = new Material();

    Technique* technique = new Technique(NULL, material);
    material->_techniques.push_back(technique);

    Pass* pass = new Pass(NULL, technique);
    pass->_effect = effect;
    technique->_passes.push_back(pass);
    effect->addRef();

    material->_currentTechnique = technique;

    return material;
}

Material* Material::create(const char* vshPath, const char* fshPath, const char* defines)
{
    GP_ASSERT(vshPath);
    GP_ASSERT(fshPath);

    // Create a new material with a single technique and pass for the given effect
    Material* material = new Material();

    Technique* technique = new Technique(NULL, material);
    material->_techniques.push_back(technique);

    Pass* pass = new Pass(NULL, technique);
	if (!pass->initialize(vshPath, fshPath, defines))
    {
		GP_WARN("Failed to create pass for material: vertexShader = %s, fragmentShader = %s, defines = %s", vshPath, fshPath, defines ? defines : "");
        SAFE_RELEASE(pass);
        SAFE_RELEASE(material);
        return NULL;
    }
    technique->_passes.push_back(pass);

    material->_currentTechnique = technique;

	return material;
}

unsigned int Material::getTechniqueCount() const
{
    return (unsigned int)_techniques.size();
}

Technique* Material::getTechniqueByIndex(unsigned int index) const
{
    GP_ASSERT(index < _techniques.size());
    return _techniques[index];
}

Technique* Material::getTechnique(const char* id) const
{
    GP_ASSERT(id);
    for (size_t i = 0, count = _techniques.size(); i < count; ++i)
    {
        Technique* t = _techniques[i];
        GP_ASSERT(t);
        if (strcmp(t->getId(), id) == 0)
        {
            return t;
        }
    }

    return NULL;
}

Technique* Material::getTechnique() const
{
    return _currentTechnique;
}

void Material::setTechnique(const char* id)
{
    Technique* t = getTechnique(id);
    if (t)
    {
        _currentTechnique = t;
    }
}

void Material::setNodeBinding(Node* node)
{
    RenderState::setNodeBinding(node);

    for (size_t i = 0, count = _techniques.size(); i < count; ++i)
    {
        _techniques[i]->setNodeBinding(node);
    }
}

Material* Material::clone(NodeCloneContext &context) const
{
    Material* material = new Material();
    RenderState::cloneInto(material, context);

    for (std::vector<Technique*>::const_iterator it = _techniques.begin(); it != _techniques.end(); ++it)
    {
        const Technique* technique = *it;
        GP_ASSERT(technique);
        Technique* techniqueClone = technique->clone(material, context);
        material->_techniques.push_back(techniqueClone);
        if (_currentTechnique == technique)
        {
            material->_currentTechnique = techniqueClone;
        }
    }
    return material;
}

bool Material::loadTechnique(Material* material, Properties* techniqueProperties, PassCallback callback, void* cookie)
{
    GP_ASSERT(material);
    GP_ASSERT(techniqueProperties);

    // Create a new technique.
    Technique* technique = new Technique(techniqueProperties->getId(), material);

    // Load uniform value parameters for this technique.
    loadRenderState(technique, techniqueProperties);

    // Go through all the properties and create passes under this technique.
    techniqueProperties->rewind();
    Properties* passProperties = NULL;
    while ((passProperties = techniqueProperties->getNextNamespace()))
    {
        if (strcmp(passProperties->getNamespace(), "pass") == 0)
        {
            // Create and load passes.
            if (!loadPass(technique, passProperties, callback, cookie))
            {
                GP_ERROR("Failed to create pass for technique.");
                SAFE_RELEASE(technique);
                return false;
            }
        }
    }

    // Add the new technique to the material.
    material->_techniques.push_back(technique);

    return true;
}

bool Material::loadPass(Technique* technique, Properties* passProperties, PassCallback callback, void* cookie)
{
    GP_ASSERT(passProperties);
    GP_ASSERT(technique);

    // Fetch shader info required to create the effect of this technique.
    const char* vertexShaderPath = passProperties->getString("vertexShader");
    GP_ASSERT(vertexShaderPath);
    const char* fragmentShaderPath = passProperties->getString("fragmentShader");
    GP_ASSERT(fragmentShaderPath);
    const char* passDefines = passProperties->getString("defines");

    // Create the pass
    Pass* pass = new Pass(passProperties->getId(), technique);

    // Load render state.
    loadRenderState(pass, passProperties);

    // If a pass callback was specified, call it and add the result to our list of defines
    std::string allDefines = passDefines ? passDefines : "";
    if (callback)
    {
        std::string customDefines = callback(pass, cookie, allDefines.c_str());
        if (customDefines.length() > 0)
        {
            if (allDefines.length() > 0)
                allDefines += ';';
            allDefines += customDefines;
        }
    }
	//GP_WARN("NewPass[%s][%s]CB:%x", technique->getId(), allDefines.c_str(), callback);
	
	// Initialize/compile the effect with the full set of defines
    if (!pass->initialize(vertexShaderPath, fragmentShaderPath, allDefines.c_str()))
    {
        GP_WARN("Failed to create pass for technique.");
        SAFE_RELEASE(pass);
        return false;
    }

    // Add the new pass to the technique.
    technique->_passes.push_back(pass);

    return true;
}

static bool isMaterialKeyword(const char* str)
{
    GP_ASSERT(str);

    #define MATERIAL_KEYWORD_COUNT 3
    static const char* reservedKeywords[MATERIAL_KEYWORD_COUNT] =
    {
        "vertexShader",
        "fragmentShader",
        "defines"
    };
    for (unsigned int i = 0; i < MATERIAL_KEYWORD_COUNT; ++i)
    {
        if (strcmp(reservedKeywords[i], str) == 0)
        {
            return true;
        }
    }
    return false;
}

static Texture::Filter parseTextureFilterMode(const char* str, Texture::Filter defaultValue)
{
    if (str == NULL || strlen(str) == 0)
    {
        GP_ERROR("Texture filter mode string must be non-null and non-empty.");
        return defaultValue;
    }
    else if (strcmp(str, "NEAREST") == 0)
    {
        return Texture::NEAREST;
    }
    else if (strcmp(str, "LINEAR") == 0)
    {
        return Texture::LINEAR;
    }
    else if (strcmp(str, "NEAREST_MIPMAP_NEAREST") == 0)
    {
        return Texture::NEAREST_MIPMAP_NEAREST;
    }
    else if (strcmp(str, "LINEAR_MIPMAP_NEAREST") == 0)
    {
        return Texture::LINEAR_MIPMAP_NEAREST;
    }
    else if (strcmp(str, "NEAREST_MIPMAP_LINEAR") == 0)
    {
        return Texture::NEAREST_MIPMAP_LINEAR;
    }
    else if (strcmp(str, "LINEAR_MIPMAP_LINEAR") == 0)
    {
        return Texture::LINEAR_MIPMAP_LINEAR;
    }
    else
    {
        GP_ERROR("Unsupported texture filter mode string ('%s').", str);
        return defaultValue;
    }
}

static Texture::Wrap parseTextureWrapMode(const char* str, Texture::Wrap defaultValue)
{
    if (str == NULL || strlen(str) == 0)
    {
        GP_ERROR("Texture wrap mode string must be non-null and non-empty.");
        return defaultValue;
    }
    else if (strcmp(str, "REPEAT") == 0)
    {
        return Texture::REPEAT;
    }
    else if (strcmp(str, "CLAMP") == 0)
    {
        return Texture::CLAMP;
    }
    else
    {
        GP_ERROR("Unsupported texture wrap mode string ('%s').", str);
        return defaultValue;
    }
}

void Material::loadRenderState(RenderState* renderState, Properties* properties)
{
    GP_ASSERT(renderState);
    GP_ASSERT(properties);

    // Rewind the properties to start reading from the start.
    properties->rewind();

    const char* name;
    while ((name = properties->getNextProperty()))
    {
        if (isMaterialKeyword(name))
            continue; // keyword - skip

        switch (properties->getType())
        {
        case Properties::NUMBER:
            GP_ASSERT(renderState->getParameter(name));
            renderState->getParameter(name)->setValue(properties->getFloat());
            break;
        case Properties::VECTOR2:
            {
                Vector2 vector2;
                if (properties->getVector2(NULL, &vector2))
                {
                    GP_ASSERT(renderState->getParameter(name));
                    renderState->getParameter(name)->setValue(vector2);
                }
            }
            break;
        case Properties::VECTOR3:
            {
                Vector3 vector3;
                if (properties->getVector3(NULL, &vector3))
                {
                    GP_ASSERT(renderState->getParameter(name));
                    renderState->getParameter(name)->setValue(vector3);
                }
            }
            break;
        case Properties::VECTOR4:
            {
                Vector4 vector4;
                if (properties->getVector4(NULL, &vector4))
                {
                    GP_ASSERT(renderState->getParameter(name));
                    renderState->getParameter(name)->setValue(vector4);
                }
            }
            break;
        case Properties::MATRIX:
            {
                Matrix matrix;
                if (properties->getMatrix(NULL, &matrix))
                {
                    GP_ASSERT(renderState->getParameter(name));
                    renderState->getParameter(name)->setValue(matrix);
                }
            }
            break;
        default:
            {
                // Assume this is a parameter auto-binding.
                renderState->setParameterAutoBinding(name, properties->getString());
            }
            break;
        }
    }

    // Iterate through all child namespaces searching for samplers and render state blocks.
    Properties* ns;
    while ((ns = properties->getNextNamespace()))
    {
        if (strcmp(ns->getNamespace(), "sampler") == 0)
        {
            // Read the texture uniform name.
            name = ns->getId();
            if (strlen(name) == 0)
            {
                GP_ERROR("Texture sampler is missing required uniform name.");
                continue;
            }

            // Get the texture path.
            std::string path;
            if (!ns->getPath("path", &path))
            {
                const char* value = ns->getString("path");
                if (value != NULL) {
                    GP_WARN("Texture sampler '%s' is missing required image file path (%s).", name, value);
                }
                continue;
            }

            // Read texture state (booleans default to 'false' if not present).
            bool mipmap = ns->getBool("mipmap");
            Texture::Wrap wrapS = parseTextureWrapMode(ns->getString("wrapS"), Texture::REPEAT);
            Texture::Wrap wrapT = parseTextureWrapMode(ns->getString("wrapT"), Texture::REPEAT);
            Texture::Wrap wrapR = Texture::REPEAT;
            if(ns->exists("wrapR"))
            {
                wrapR = parseTextureWrapMode(ns->getString("wrapR"), Texture::REPEAT);
            }
            Texture::Filter minFilter = parseTextureFilterMode(ns->getString("minFilter"), mipmap ? Texture::NEAREST_MIPMAP_LINEAR : Texture::LINEAR);
            Texture::Filter magFilter = parseTextureFilterMode(ns->getString("magFilter"), Texture::LINEAR);

            // Set the sampler parameter.
            GP_ASSERT(renderState->getParameter(name));
            Texture::Sampler* sampler = renderState->getParameter(name)->setValue(path.c_str(), mipmap);
            if (sampler)
            {
                sampler->setWrapMode(wrapS, wrapT, wrapR);
                sampler->setFilterMode(minFilter, magFilter);
            }
        }
        else if (strcmp(ns->getNamespace(), "renderState") == 0)
        {
            while ((name = ns->getNextProperty()))
            {
                GP_ASSERT(renderState->getStateBlock());
                renderState->getStateBlock()->setState(name, ns->getString());
            }
        }
    }
}

}
