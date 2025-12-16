# Faction Module

A Prism module for managing factions and their relationships. This module allows you to create groups of actors that share relationships with other factions, automatically managing Friend and Foe relations between faction members based on faction-level relationship strengths.

## Overview

The faction module provides:
- **Faction entities**: Actors that represent factions in your game
- **Membership tracking**: Components to assign actors to factions
- **Relationship management**: Automatic propagation of faction relationships to individual actors
- **Dynamic relationships**: Friend/Foe relations updated based on faction relationship strength

### How It Works

1. Create faction actors with the `Faction` component
2. Assign actors to factions using the `BelongsToFaction` component
3. Define relationships between factions using `FactionRelationshipRelation`
4. The `FactionSystem` automatically manages individual actor relationships based on faction relationships

Faction relationships use a strength value from -100 (hostile) to 100 (friendly):
- Strength >= 50: Members become Friends
- Strength <= -50: Members become Foes
- Between -50 and 50: Neutral (no automatic relations)

## Components

### Faction
Marks an actor as a faction entity. Faction actors typically have a `Name` component to identify them.

```lua
prism.components.Faction()
```

### BelongsToFaction
Assigns an actor to one or more factions by name.

```lua
prism.components.BelongsToFaction({ "FactionName1", "FactionName2" })
```

## Relations

### FactionRelationshipRelation
Defines the relationship strength between two factions. Applied to faction actors.

```lua
prism.relations.FactionRelationshipRelation(strength)
```
- `strength`: Number from -100 (hostile) to 100 (friendly)

### BelongsToFactionRelation
Automatically created to link actors to their faction entities. Inverse of `FactionContainsRelation`.

### FactionContainsRelation
Automatically created to link faction entities to their members. Inverse of `BelongsToFactionRelation`.

## System

### FactionSystem
Manages faction membership and propagates faction relationships to individual actors.

```lua
prism.systems.FactionSystem(factions)
```
- `factions`: Optional table of faction actors to add to the level

## Generic Example

Here's a basic example of adding factions to a level:

```lua
-- Define faction actors
local humanFaction = prism.Actor.fromComponents({
    prism.components.Name("Humans"),
    prism.components.Faction(),
})

local orcFaction = prism.Actor.fromComponents({
    prism.components.Name("Orcs"),
    prism.components.Faction(),
})

-- Set faction relationship (hostile)
humanFaction:addRelation(
    prism.relations.FactionRelationshipRelation(-100),
    orcFaction
)

-- Create actors that belong to factions
local warrior = prism.Actor.fromComponents({
    prism.components.Name("Warrior"),
    prism.components.BelongsToFaction({ "Humans" }),
    -- ... other components
})

local orcRaider = prism.Actor.fromComponents({
    prism.components.Name("Orc Raider"),
    prism.components.BelongsToFaction({ "Orcs" }),
    -- ... other components
})

-- Build the level
local builder = prism.LevelBuilder(prism.cells.Floor)
builder:addSystems(prism.systems.FactionSystem({ humanFaction, orcFaction }))
builder:addActor(warrior, 5, 5)
builder:addActor(orcRaider, 10, 10)
local level = builder:build()

-- The FactionSystem will automatically make the warrior and orc enemies
```

### Advanced: Multiple Factions

Actors can belong to multiple factions:

```lua
prism.registerActor("HalfOrc", function()
    return prism.Actor.fromComponents({
        prism.components.Name("Half-Orc"),
        -- Belongs to both human and orc factions
        prism.components.BelongsToFaction({ "Humans", "Orcs" }),
    })
end)
```

### Advanced: Changing Relationships

You can modify faction relationships at runtime:

```lua
-- Change relationship from hostile to friendly
local humanFaction = Game.factions.PlayerFaction
local orcFaction = Game.factions.KoboldFaction

-- Remove old relationship
humanFaction:removeRelation(prism.relations.FactionRelationshipRelation, orcFaction)

-- Add new friendly relationship
humanFaction:addRelation(
    prism.relations.FactionRelationshipRelation(75),
    orcFaction
)

```

## Notes

- Faction entities are automatically added to the level by the FactionSystem if provided in the constructor
- The system uses the `BelongsToFaction` component's faction names to match against faction entity `Name` components
- Faction relationships are bidirectional - setting a relationship automatically creates the inverse
- The FactionSystem runs on every turn to ensure relationships stay synchronized
- Friend and Foe relations are mutually exclusive - setting one removes the other
