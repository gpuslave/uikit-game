# iOS Space Invaders Game

This project is a classic Space Invaders-style arcade game built for iOS. It serves as a demonstration of clean architecture, modern Swift practices, and fundamental game development concepts on the iOS platform. The game features a player-controlled ship, waves of descending enemies, and projectile-based combat.

## Architecture

The project follows a clean and decoupled architectural pattern that is a variation of Model-View-Controller (MVC), with strong adherence to the **SOLID** principles of object-oriented design.

*   **Model**: The "Model" layer contains the core game logic and data, completely independent of the UI.
    *   `GameEngine.swift`: The central hub of the game's logic. It manages the game state, orchestrates the game loop, and handles interactions between game objects. It is designed to be completely unaware of the UI layer (e.g., `UIKit`).
    *   `GameEntity.swift` (and its subclasses): These represent the individual objects within the game, such as the `Player`, `Enemy`, and `Projectile`. Each entity is responsible for its own state and behavior (e.g., how it moves or shoots).
    *   `Constants.swift`: A centralized file for all static configuration data, such as entity stats, UI dimensions, and color themes.

*   **View**: The "View" layer is responsible for rendering the game state on the screen.
    *   `Main.storyboard`: Defines the static UI layout, including the game area, labels for score and health, control buttons, and the game-over screen.
    *   `UIView` instances: Each `GameEntity` has a corresponding `UIView` property that represents it on the screen. These views are managed by the `GameViewController`.

*   **Controller**: The "Controller" layer acts as the bridge between the Model and the View.
    *   `GameViewController.swift`: This class owns the `GameEngine` and is responsible for:
        *   Setting up the game and initializing the `GameEngine`.
        *   Receiving user input from the UI (e.g., button presses) and translating it into actions within the `GameEngine`.
        *   Driving the main game loop using a `CADisplayLink`.
        *   Updating the on-screen views based on the state provided by the `GameEngine`.
        *   Conforming to the `GameEngineDelegate` protocol to receive events like score changes or game-over notifications.

## Primary Loops

The game's continuous action is driven by a few key loops:

1.  **The Main Game Loop (`CADisplayLink`)**
    *   **Location**: `GameViewController.swift`
    *   **Mechanism**: A `CADisplayLink` is used to synchronize the game's frame rate with the display's refresh rate (typically 60 FPS).
    *   **Function**: On each tick, it calls the `gameLoop()` method, which triggers the core logic update and a subsequent UI refresh. This is the primary "heartbeat" of the game.

2.  **The Core Logic Loop (`GameEngine.update()`)**
    *   **Location**: `GameEngine.swift`
    *   **Mechanism**: This method is called by the main game loop in every frame.
    *   **Function**: It executes the fundamental sequence of game events for that frame in a specific order:
        1.  **Update Entities**: Move all active game objects (player, enemies, projectiles).
        2.  **Handle Shooting**: Check if any entity should fire a projectile.
        3.  **Check Collisions**: Detect and process intersections between projectiles and ships.
        4.  **Cleanup Entities**: Remove objects that have gone off-screen.
        5.  **Check Win/Lose Conditions**: Determine if the game has been won or lost.

3.  **The User Input Loop (`Timer`)**
    *   **Location**: `GameViewController.swift`
    *   **Mechanism**: To handle continuous movement when the player holds down a button, a `Timer` is scheduled on `touchDown` and invalidated on `touchUp`.
    *   **Function**: While the timer is active, it repeatedly calls the `gameEngine.movePlayerLeft()` or `gameEngine.movePlayerRight()` method, creating a smooth, continuous motion effect that is independent of the main game loop's update cycle but provides a responsive feel.

## Key Classes and Responsibilities

*   `GameViewController`: Manages the overall view lifecycle, user input, and the primary game loop. It delegates all game logic to the `GameEngine`.
*   `GameEngine`: The brain of the game. It manages game state (`playing`, `gameOver`, etc.), all game entities, and the core rules of interaction (scoring, collisions, win/loss conditions). It communicates back to the `GameViewController` via a delegate pattern.
*   `GameEntity`: The base class for all objects in the game. It uses a **protocol-oriented** design to define capabilities:
    *   `Movable`: For entities that can change position.
    *   `Shootable`: For entities that can create projectiles.
    *   `Destructible`: For entities that can take damage.
    *   `Renderable`: For entities that can be drawn on screen.
*   `Player`, `Enemy`, `Projectile`: Concrete implementations of `GameEntity` that define the specific behaviors and properties for each type of object.
*   `CollisionDetectionService`: A dedicated service, injected into the `GameEngine`, whose single responsibility is to detect collisions between game entities. This keeps the `GameEngine` cleaner and more focused.
*   `EnemySpawnerService`: A service responsible for generating the initial positions of the enemies, promoting separation of concerns.

## Design Principles

This project was built with a strong emphasis on creating maintainable, scalable, and testable code.

*   **SOLID Principles**:
    *   **Single Responsibility Principle**: Each class has a single, well-defined purpose (e.g., `GameEngine` for logic, `CollisionDetectionService` for collisions, `GameViewController` for UI coordination).
    *   **Open/Closed Principle**: The `GameEngine` is open to extension via services and delegates but closed for modification. For example, a new type of enemy or a different collision logic could be added without changing the engine's source code.
    *   **Interface Segregation Principle**: The use of small, specific protocols (`Movable`, `Shootable`) ensures that classes only implement the behaviors they actually need.
    *   **Dependency Inversion Principle**: The `GameEngine` depends on abstractions (protocols like `GameEngineDelegate` and `CollisionDetectionService`), not on concrete implementations. This allows for dependencies to be injected, making the system highly modular and testable.
*   **Protocol-Oriented Programming (POP)**: Swift's protocols are used to define capabilities and contracts, favoring composition over inheritance where appropriate.
*   **Delegate Pattern**: Used for clean, one-way communication from the `GameEngine` (the model) back to the `GameViewController` (the controller) without creating tight coupling.
*   **Centralized Constants**: All magic numbers and configuration values are stored in the `Constants.swift` file, making the game easy to tweak and maintain.
