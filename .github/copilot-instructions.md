# Copilot Instructions for Koi-Koi

This is a traditional Japanese card game implementation in Godot 4.5 using GDScript.

## Project Architecture

- **Godot 4.5 Project**: Standard Godot project structure with `project.godot` as entry point
- **Resolution**: 1920x1080 with canvas_items stretch mode for consistent scaling
- **Main Scene**: `scenes/main.tscn` contains the root Node2D for the game
- **Scripts**: Modular GDScript files in `scripts/` directory
- **Assets**: Game resources in `assets/` with Godot import files

## Card Game Structure

The core game data is defined in `scripts/cards_db.gd`:

### Card System

- **48-card Hanafuda deck**: 12 months × 4 cards per month
- **Card Types**: `PLAIN`, `ANIMAL`, `RIBBON`, `BRIGHT` (enum CardType)
- **Card Structure**: Dictionary with `month`, `number`, `type` fields
- **Month-based Organization**: Cards 1-4 for each month (January=1 to December=12)

### Card Distribution Pattern

- Most months: 2 PLAIN + 1 RIBBON + 1 special (ANIMAL/BRIGHT)
- August: 2 PLAIN + 1 ANIMAL + 1 BRIGHT (no ribbon)
- November: 1 PLAIN + 1 RIBBON + 1 ANIMAL + 1 BRIGHT
- December: 3 PLAIN + 1 BRIGHT (no ribbon, no animal)

## Development Conventions

### File Organization

- Scene files (`.tscn`) in `scenes/`
- Script files (`.gd`) in `scripts/`
- Use Godot's UID system for resource references (`.uid` files)
- Assets organized in `assets/` with corresponding `.import` files

### GDScript Patterns

- Use `enum` for card types and game states
- Define game data as `const` arrays/dictionaries
- Follow Godot's snake_case naming convention
- Use dictionary literals for structured data

### Scene Structure

- Root node as `Node2D` for 2D game layout
- Minimal scene tree initially - expand as needed for UI/gameplay

## Key Implementation Notes

- This implements traditional Koi-Koi (花札) rules with authentic Hanafuda cards
- Card matching is based on month groupings (4 cards per month)
- Different card types have different point values in traditional scoring
- The DECK constant in `deck.gd` represents the complete 48-card set

## Common Operations

When adding new features:

- Create new scripts in `scripts/` directory
- Reference card data from `deck.cards` variable
- Use `CardType` enum for type checking
- Follow month-based card organization (1-12)
- Maintain Godot's resource import system for assets
