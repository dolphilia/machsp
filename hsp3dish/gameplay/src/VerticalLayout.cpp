#include "Base.h"
#include "VerticalLayout.h"

namespace gameplay
{

VerticalLayout::VerticalLayout() : _bottomToTop(false), _spacing(0)
{
}

VerticalLayout::~VerticalLayout()
{
}

VerticalLayout* VerticalLayout::create()
{
    return new VerticalLayout();
}

void VerticalLayout::setBottomToTop(bool bottomToTop)
{
    _bottomToTop = bottomToTop;
}

bool VerticalLayout::getBottomToTop()
{
    return _bottomToTop;
}

Layout::Type VerticalLayout::getType()
{
    return Layout::LAYOUT_VERTICAL;
}

int VerticalLayout::getSpacing() const
{
    return _spacing;
}

void VerticalLayout::setSpacing(int spacing)
{
    _spacing = spacing;
}

void VerticalLayout::update(const Container* container)
{
    GP_ASSERT(container);

    // Need border, padding.
    Theme::Border border = container->getBorder(container->getState());
    Theme::Padding padding = container->getPadding();

    float yPosition = 0;

    const std::vector<Control*>& controls = container->getControls();

    int i, end, iter;
    if (_bottomToTop)
    {
        i = (int)controls.size() - 1;
        end = -1;
        iter = -1;
    }
    else
    {
        i = 0;
        end = (int)controls.size();
        iter = 1;
    }

    while (i != end)
    {
        Control* control = controls.at(i);
        GP_ASSERT(control);

        if (control->isVisible())
        {
            const Rectangle& bounds = control->getBounds();
            const Theme::Margin& margin = control->getMargin();

            yPosition += margin.top;

            control->setPosition(margin.left, yPosition);

            yPosition += bounds.height + margin.bottom + _spacing;
        }

        i += iter;
    }
}

}