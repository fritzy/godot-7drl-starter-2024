# Godot 7DRL Starter 2024

This is a roguelike template project made in perperation for [2024 7DRL](https://itch.io/jam/7drl-challenge-2024).

While I'm writing this for myself, I hope to continue improving it even after the Jam so that others may find it useful.

It's a little different a typical Godot Project in that all of the game info is contained in Godot Resources (like ECS components) and organized by an Entity ID.

This has a few advantages:

- easily separates logic to systems (the S in ECS) rather than spread out in embedded classes
- Saves and loads are trivial (components have standup and teardown functions that act on engine objects if necessary)
- emergent gameplay through data integration is likely

This does not have a performance advantage, unlike dedicated low level ECS libraries. This is a simple applied pattern.

The goals are:
- Basic ECS-like pattern
- menus, settings, window management
- handy level generators
- basic roguelike features like creatures, equipment, inventory, weapons
- POV and lighting system
- dev console / combat log (press \`)
- web, windows, linux, mac builds parity

This is not a full roguelike. Just enough to have everything in place to build one.

-- Nathan Fritz
