-- Table of vendor type data, as authentic to San Andreas as possible.
_vendorTypes = {
    sprunk_machine_clean = {
        modelID = 1775,                                     -- modelID of vendor object i.e the vending machine or stall
        objectOffset = Vector3(0, 0, 0),                    -- offset of object position relative to the base element
        markerOffset = Vector3(0.2, -1, -1.1),              -- offset of marker position relative to the base element
        markerRotation = Vector3(0, 0, 0),                  -- offset of marker rotation relative to the base element
        --pedData = {264, Vector3(-1, -0.35, 0), 270},      -- ped data for vendor attendant i.e the ice cream clown or noodle guy (optional)
                                                            --      {modelID, offset, rotZ}
        animationSequence = {                               -- sequence of animations for players using the vending machine (optional)
            {"VENDING", "VEND_Use", 2650},                  --      {blockName, animationName, duration}
            {"VENDING", "VEND_Use_pt2", 100},
            {"VENDING", "VEND_Drink_P", 1400}
        },
        sfxData = {"script", "203", "0"},                   -- SFX data for vending machines of this type (optional)
        productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}  -- product data used by bone_attach (optional)
                                                            --      {modelID, boneID, xOffset, yOffset, zOffset, xRot, yRot, zRot}
    },
    sprunk_machine_dirty = {
        modelID = 955,
        objectOffset = Vector3(0, 0, 0.39),
        markerOffset = Vector3(0.2, -1, 0),
        markerRotation = Vector3(0, 0, 0),
        animationSequence = {
            {"VENDING", "VEND_Use", 2650},
            {"VENDING", "VEND_Use_pt2", 100},
            {"VENDING", "VEND_Drink_P", 1400}
        },
        sfxData = {"script", "203", "0"},
        productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    },
    candy_machine_clean = {
        modelID = 956,
        objectOffset = Vector3(0, 0, 0.39),
        markerOffset = Vector3(0.2, -1, 0),
        markerRotation = Vector3(0, 0, 0),
        animationSequence = {
            {"VENDING", "VEND_Use", 2650},
            {"VENDING", "VEND_Use_pt2", 100},
            {"VENDING", "VEND_Eat_P", 1700}
        },
        sfxData = {"script", "203", "1"},
        -- TODO: find a candybar model
        --productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    },
    candy_machine_dirty = {
        modelID = 1776,
        objectOffset = Vector3(0, 0, 0),
        markerOffset = Vector3(0.2, -1, -1.1),
        markerRotation = Vector3(0, 0, 0),
        animationSequence = {
            {"VENDING", "VEND_Use", 2650},
            {"VENDING", "VEND_Use_pt2", 100},
            {"VENDING", "VEND_Eat_P", 1700}
        },
        sfxData = {"script", "203", "1"},
        -- TODO: find a candybar model
        --productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    },
    soda_machine = {
        modelID = 1209,
        objectOffset = Vector3(0, 0, 0),
        markerOffset = Vector3(0.2, -1, 0),
        markerRotation = Vector3(0, 0, 0),
        animationSequence = {
            {"VENDING", "VEND_Use", 2650},
            {"VENDING", "VEND_Use_pt2", 100},
            {"VENDING", "VEND_Drink_P", 1400}
        },
        sfxData = {"script", "203", "0"},
        productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    },
    soda_machine2 = {
        modelID = 1302,
        objectOffset = Vector3(0, 0, 0),
        markerOffset = Vector3(0.2, -1, 0),
        markerRotation = Vector3(0, 0, 0),
        animationSequence = {
            {"VENDING", "VEND_Use", 2650},
            {"VENDING", "VEND_Use_pt2", 100},
            {"VENDING", "VEND_Drink_P", 1400}
        },
        sfxData = {"script", "203", "0"},
        productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    },
    chilli_dog_cart = {
        modelID = 1340,
        objectOffset = Vector3(0, 0, 0),
        markerOffset = Vector3(1, 0, -1.1),
        markerRotation = Vector3(0, 0, 90),
        pedData = {168, Vector3(-1, 0, -0.2), 270},
        animationSequence = {
            {"FOOD", "EAT_Burger", 5000}
        },
        sfxData = {"script", "151", "0"},
        -- TODO: find a chillidog model
        --productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    },
    ice_cream_cart = {
        modelID = 1341,
        objectOffset = Vector3(0, 0, 0),
        markerOffset = Vector3(1, -0.35, -1.1),
        markerRotation = Vector3(0, 0, 90),
        pedData = {264, Vector3(-1, -0.35, 0), 270},
        animationSequence = {
            {"FOOD", "EAT_Burger", 5000}
        },
        sfxData = {"script", "151", "0"},
        -- TODO: find an ice cream model
        --productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    },
    noodle_cart = {
        modelID = 1342,
        objectOffset = Vector3(0, 0, 0),
        markerOffset = Vector3(1, -0.1, -1.1),
        markerRotation = Vector3(0, 0, 90),
        pedData = {209, Vector3(-1, -0.1, -0.2), 270},
        animationSequence = {
            {"FOOD", "EAT_Burger", 5000}
        },
        sfxData = {"script", "151", "0"},
        -- TODO: find a noodle bowl model
        --productData = {2601, 11, 0, 0.05, 0.075, 0, 90, 0}
    }
}
