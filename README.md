# iOS Space Invaders Game

Welcome! This project is a classic Space Invaders-style arcade game built for iOS. It's designed to be a clear and practical example of clean architecture, modern Swift practices, and fundamental game development concepts on the iOS platform.

Whether you're a beginner looking to learn or an experienced developer curious about the architecture, this project has something for you. The game features a player-controlled ship, waves of descending enemies, and projectile-based combat.

> **Note**: All the source code for the game is located in the `test/` directory.

## Architecture

This project uses a clean architecture based on the Model-View-Controller (MVC) pattern. The core idea is to separate concerns, making the code easier to understand, test, and maintain. It strongly adheres to the **SOLID** principles of object-oriented design.

*   **Model**: Contains the core game logic and data, completely independent of the user interface.
    *   `test/GameEngine.swift`: The central hub of the game's logic. It manages the game state, orchestrates the game loop, and handles interactions between game objects. It has no knowledge of the UI layer (e.g., `UIKit`).
    *   `test/GameEntity.swift` (and its subclasses): These represent the individual objects in the game, like the `Player`, `Enemy`, and `Projectile`. Each entity manages its own state and behavior (e.g., how it moves or shoots).
    *   `test/Constants.swift`: A single place for all static configuration data, such as entity stats, UI dimensions, and color themes. This makes tweaking the game's balance and feel much easier.

*   **View**: Responsible for everything the user sees. It renders the game state on the screen.
    *   `test/Base.lproj/Main.storyboard`: Defines the static UI layout, including the game area, labels for score and health, control buttons, and the game-over screen.
    *   `UIView` instances: Each `GameEntity` is represented on screen by a `UIView`. These views are managed by the `GameViewController`.

*   **Controller**: Acts as the bridge between the Model and the View.
    *   `test/GameViewController.swift`: This class owns the `GameEngine` and is responsible for:
        *   Setting up the game and initializing the `GameEngine`.
        *   Translating user input (like button presses) into actions within the `GameEngine`.
        *   Driving the main game loop using a `CADisplayLink` (a timer synced with the screen's refresh rate).
        *   Updating the views on screen based on the latest state from the `GameEngine`.
        *   Listening for game events (like score changes or game-over) from the `GameEngine` through the `GameEngineDelegate` protocol.

## Primary Loops

The game's continuous action is driven by a few key loops:

1.  **The Main Game Loop (`CADisplayLink`)**
    *   **Location**: `test/GameViewController.swift`
    *   **Mechanism**: A `CADisplayLink` syncs the game's frame rate with the display's refresh rate (typically 60 FPS), ensuring smooth animation.
    *   **Function**: On each tick, it calls the `gameLoop()` method. This is the "heartbeat" of the game, triggering the core logic update and a UI refresh.

2.  **The Core Logic Loop (`GameEngine.update()`)**
    *   **Location**: `test/GameEngine.swift`
    *   **Mechanism**: Called by the main game loop every frame.
    *   **Function**: Executes the fundamental sequence of game events for that frame in a specific order:
        1.  **Update Entities**: Move all active game objects.
        2.  **Handle Shooting**: Check if any entity should fire a projectile.
        3.  **Check Collisions**: Detect and process intersections between projectiles and ships.
        4.  **Cleanup Entities**: Remove objects that have gone off-screen.
        5.  **Check Win/Lose Conditions**: Determine if the game has ended.

3.  **The User Input Loop (`Timer`)**
    *   **Location**: `test/GameViewController.swift`
    *   **Mechanism**: To handle continuous movement when a player holds down a button, a `Timer` is scheduled on `touchDown` and invalidated on `touchUp`.
    *   **Function**: While the timer is active, it repeatedly tells the `GameEngine` to move the player. This creates a smooth, responsive feel for the controls.

## Key Classes and Responsibilities

*   `GameViewController`: Manages the view lifecycle, user input, and the main game loop. It delegates all game logic to the `GameEngine`.
*   `GameEngine`: The brain of the game. It manages game state (`playing`, `gameOver`, etc.), all game entities, and the core rules of interaction (scoring, collisions, win/loss). It communicates back to the `GameViewController` using a delegate pattern, ensuring the two are decoupled.
*   `GameEntity`: The base class for all objects in the game. It uses a **protocol-oriented** design to define what an entity *can do*:
    *   `Movable`: For entities that can change position.
    *   `Shootable`: For entities that can create projectiles.
    *   `Destructible`: For entities that can take damage.
    *   `Renderable`: For entities that can be drawn on screen.
*   `Player`, `Enemy`, `Projectile`: Concrete implementations of `GameEntity` that define the specific behaviors and properties for each type of object.
*   `CollisionDetectionService` & `EnemySpawnerService`: These are not separate files, but **protocols** defined inside `test/GameEngine.swift`. This design choice is a great example of the Single Responsibility Principle.
    *   `CollisionDetectionService`: Has the single job of detecting collisions between game entities.
    *   `EnemySpawnerService`: Has the single job of generating the initial positions of the enemies.
    *   By injecting these services into the `GameEngine`, we keep the engine's code focused and make it easy to swap in different collision or spawning logic later. The file includes `DefaultCollisionDetectionService` and `DefaultEnemySpawnerService` as the default implementations.

## Design Principles

This project was built with a strong emphasis on creating maintainable, scalable, and testable code.

*   **SOLID Principles**:
    *   **Single Responsibility Principle**: Each class has one job. `GameEngine` handles logic, `CollisionDetectionService` handles collisions, and `GameViewController` handles UI.
    *   **Open/Closed Principle**: The `GameEngine` is open to extension (e.g., via new services) but closed for modification. We could add a new enemy type without changing the engine's source code.
    *   **Interface Segregation Principle**: Small, specific protocols (`Movable`, `Shootable`) mean that classes only implement behaviors they actually need.
    *   **Dependency Inversion Principle**: The `GameEngine` depends on abstractions (protocols like `GameEngineDelegate`), not on concrete classes. This allows us to "inject" dependencies, making the system highly modular and testable.
*   **Protocol-Oriented Programming (POP)**: We favor composition over inheritance by using Swift's protocols to define capabilities and contracts.
*   **Delegate Pattern**: Used for clean, one-way communication from the `GameEngine` (model) back to the `GameViewController` (controller) without creating tight coupling.
*   **Centralized Constants**: All "magic numbers" and configuration values are stored in `Constants.swift`, making the game easy to tweak and maintain.
