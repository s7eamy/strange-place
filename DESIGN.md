# Strange Place - Project Outline

A 2D side-view physics stacking game. The player places objects one by one using the cursor, trying to keep the structure stable. Objects start normal (sofa, microwave) and get progressively stranger (starfish, palm tree). The game is endless survival — score equals objects placed.

## Game Loop

```
PLACING ──(click)──> SETTLING ──(stable)──> PLACING
                        │
                     (collapsed)
                        │
                        v
                     GAME_OVER
```

1. **ObjectQueue** picks a random object based on the current strangeness level
2. **PlacementController** shows a ghost preview at the cursor; player can rotate and flip
3. Player clicks — a **PlaceableObject** is spawned with physics enabled
4. **StabilityChecker** monitors all placed objects for a few seconds
5. If everything settles — score increments, strangeness may increase, next object appears
6. If anything falls into the **DeathZone** or doesn't settle — game over

## Directory Structure

```
scenes/
  menu/                             # Main menu (existing)
  gameplay/
    gameplay.tscn / .gd             # Main game scene, orchestrates state machine
    placeable-object.tscn / .gd     # Generic RigidBody2D, configured from ObjectData
    placement-controller.tscn / .gd # Cursor ghost, rotate/flip input, spawns objects
    stability-checker.tscn / .gd    # Timer + velocity monitoring after placement
    object-queue.tscn / .gd         # Random object selection, strangeness progression
    ground.tscn                     # StaticBody2D platform to stack on
    death-zone.tscn / .gd           # Area2D below screen, detects fallen objects
    hud.tscn / .gd                  # Score display, next object preview
    pause-layer/                    # Pause overlay (existing)
  game-over/
    game-over.tscn / .gd            # Final score, restart and menu buttons

resources/
  objects/
    object-data.gd                  # ObjectData resource class definition
    tomato.tres                     # Object definitions (one .tres per object type)
    sofa.tres
    starfish.tres
    ...
  theme/                            # UI theme (existing)

assets/
  sprites/
    objects/                        # Object textures (one .png per object type)
  fonts/                            # Fonts (existing)
```

### What each piece does

**`ObjectData`** — Custom `Resource`. Fields: `name`, `texture`, `collision_shape`, `weight`, `friction`, `bounce`, `strangeness_level`. Adding a new object means creating a `.tres` file and assigning a sprite and shape. No code needed.

**`PlaceableObject`** — One reusable scene for all objects. A `RigidBody2D` with `Sprite2D` and `CollisionShape2D`. Has an `init(data: ObjectData)` method that configures everything from the resource. Spawned frozen during placement, unfrozen once placed.

**`PlacementController`** — Owns a semi-transparent ghost `Sprite2D` that follows the cursor. Handles rotate/flip input. On click, spawns a real `PlaceableObject` at that position and rotation.

**`StabilityChecker`** — After an object is placed, starts a timer. Checks whether all placed objects have `linear_velocity.length() < threshold`. If the timer expires and everything is still, the structure is stable.

**`ObjectQueue`** — Holds a pool of all `ObjectData` resources. Filters by `strangeness_level <= current_level`. Picks randomly from the filtered pool. The strangeness threshold increases as the player places more objects.

**`DeathZone`** — `Area2D` positioned below the visible area. If any `RigidBody2D` enters it, the structure has collapsed.

**`HUD`** — `CanvasLayer` showing the current score and a preview of the next object.

**`Gameplay`** — The orchestrator. Manages the `PLACING → SETTLING → PLACING / GAME_OVER` state machine. Wires all child systems together via signals.

## Signal Flow

```
ObjectQueue
  │
  ├──object_selected(ObjectData)──> PlacementController
  │                                   │
  │                          object_placed(PlaceableObject)
  │                                   │
  │                                   v
  │                               Gameplay
  │                                   │
  │                          starts settling check
  │                                   │
  │                                   v
  │                           StabilityChecker
  │                             │           │
  │                          settled      collapsed
  │                             │           │
  │                             v           v
  │                         Gameplay    Gameplay
  │                      (next object)  (game over)
  │
  DeathZone
    │
    ├──body_entered──> StabilityChecker (instant collapse)
```

No custom autoloads. All communication happens through signals between sibling nodes within the gameplay scene.
