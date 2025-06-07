# Tiles

## Pick up Weight

The pickup weight is the weight of the item in **hectograms**, so a 1kg item should be `10`.
This is presumably done because items are displayed in kilograms and often are fractional,
whereas the input is an integer only.

## Facing

The direction the item is **facing**, which is the opposite of the wall it is attached to.

ie: a North-facing item will be attached to the south wall.

## Item (full name)

This maps to the `Item` key in the respective Items_*.txt file, including the namespace.

ie: `item TireRackUnpainted { ... }` within the `module VNGarage { ... }` module will have the Item Name
of `VNGarage.TireRackUnpainted`.  This is critical for picking up the item later, as it is used
to remap the destination object in the player's inventory back to the item definition.

## ContainerType

This maps to the `type` of container, used in the title and icon.

To name the title, in `IG_UI_EN.txt`:

```
IGUI_EN = {
	IGUI_ContainerTitle_CONTAINERTYPE = "I18N title of your container",
}
```

The icon can be defined via `ContainerButtonIcons` in lua:

```lua
ContainerButtonIcons = ContainerButtonIcons or {}
ContainerButtonIcons.CONTAINERTYPE = getTexture("media/textures/filename_of_icon.png")
```