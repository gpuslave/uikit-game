//
//  GameEngine.swift
//  SpaceInvaders
//
//  Created on iOS Space Invaders Game
//

import UIKit

// MARK: - Game State Management (Single Responsibility Principle)

enum GameState {
    case playing
    case gameOver
    case gameWon
    case paused
}

// MARK: - Game Engine Protocol (Dependency Inversion Principle)

protocol GameEngineDelegate: AnyObject {
    func gameDidEnd(won: Bool)
    func gameStateDidChange(_ state: GameState)
    func scoreDidUpdate(_ score: Int)
    func healthDidUpdate(_ health: Int)
}

// MARK: - Collision Detection Service (Single Responsibility Principle)

protocol CollisionDetectionService {
    func checkCollisions(player: Player, enemies: [Enemy], playerProjectiles: [Projectile], enemyProjectiles: [Projectile]) -> CollisionResult
}

struct CollisionResult {
    let destroyedEnemies: [Enemy]
    let destroyedPlayerProjectiles: [Projectile]
    let destroyedEnemyProjectiles: [Projectile]
    let playerHit: Bool
}

class DefaultCollisionDetectionService: CollisionDetectionService {
    func checkCollisions(player: Player, enemies: [Enemy], playerProjectiles: [Projectile], enemyProjectiles: [Projectile]) -> CollisionResult {
        var destroyedEnemies: [Enemy] = []
        var destroyedPlayerProjectiles: [Projectile] = []
        var destroyedEnemyProjectiles: [Projectile] = []
        var playerHit = false

        // Use sets to avoid duplicates
        var destroyedEnemySet = Set<ObjectIdentifier>()
        var destroyedPlayerProjectileSet = Set<ObjectIdentifier>()
        var destroyedEnemyProjectileSet = Set<ObjectIdentifier>()

        // Check player projectiles vs enemies
        for projectile in playerProjectiles {
            // If this projectile already destroyed something this frame, skip
            if destroyedPlayerProjectileSet.contains(ObjectIdentifier(projectile)) {
                continue
            }

            for enemy in enemies {
                // Skip enemies already destroyed this frame or previously
                if enemy.isDestroyed || destroyedEnemySet.contains(ObjectIdentifier(enemy)) {
                    continue
                }

                if projectile.intersects(with: enemy) {
                    enemy.takeDamage(projectile.damage)

                    // Mark projectile destroyed exactly once
                    if destroyedPlayerProjectileSet.insert(ObjectIdentifier(projectile)).inserted {
                        destroyedPlayerProjectiles.append(projectile)
                    }

                    // If enemy died from this hit, mark it
                    if enemy.isDestroyed && destroyedEnemySet.insert(ObjectIdentifier(enemy)).inserted {
                        destroyedEnemies.append(enemy)
                    }

                    // Stop checking this projectile against other enemies in this frame
                    break
                }
            }
        }

        // Check enemy projectiles vs player
        for projectile in enemyProjectiles {
            if destroyedEnemyProjectileSet.contains(ObjectIdentifier(projectile)) {
                continue
            }

            if projectile.intersects(with: player) && !player.isDestroyed {
                player.takeDamage(projectile.damage)

                if destroyedEnemyProjectileSet.insert(ObjectIdentifier(projectile)).inserted {
                    destroyedEnemyProjectiles.append(projectile)
                }
                playerHit = true
            }
        }

        return CollisionResult(
            destroyedEnemies: destroyedEnemies,
            destroyedPlayerProjectiles: destroyedPlayerProjectiles,
            destroyedEnemyProjectiles: destroyedEnemyProjectiles,
            playerHit: playerHit
        )
    }
}

// MARK: - Enemy Spawner (Single Responsibility Principle)

protocol EnemySpawnerService {
    func generateEnemies(for screenSize: CGSize, count: Int) -> [Enemy]
}

class DefaultEnemySpawnerService: EnemySpawnerService {
    func generateEnemies(for screenSize: CGSize, count: Int) -> [Enemy] {
        var enemies: [Enemy] = []
        let enemyWidth: CGFloat = 30
        let enemyHeight: CGFloat = 25
        let spacing: CGFloat = 10
        let topMargin: CGFloat = 50

        let enemiesPerRow = Int((screenSize.width - 20) / (enemyWidth + spacing))
        let rows = (count + enemiesPerRow - 1) / enemiesPerRow // Ceiling division

        for row in 0..<rows {
            for col in 0..<enemiesPerRow {
                let index = row * enemiesPerRow + col
                guard index < count else { break }

                let x = 10 + CGFloat(col) * (enemyWidth + spacing)
                let y = topMargin + CGFloat(row) * (enemyHeight + spacing)

                let enemy = Enemy(position: CGPoint(x: x, y: y))
                enemies.append(enemy)
            }
        }

        return enemies
    }
}

// MARK: - Game Engine (Open/Closed Principle - extensible via delegates and services)

class GameEngine {

    // MARK: - Dependencies (Dependency Inversion Principle)
    weak var delegate: GameEngineDelegate?
    private let collisionService: CollisionDetectionService
    private let enemySpawner: EnemySpawnerService

    // MARK: - Game State
    private(set) var gameState: GameState = .playing {
        didSet {
            delegate?.gameStateDidChange(gameState)
        }
    }

    private(set) var score: Int = 0 {
        didSet {
            delegate?.scoreDidUpdate(score)
        }
    }

    // MARK: - Game Entities
    private(set) var player: Player
    private(set) var enemies: [Enemy] = []
    private(set) var playerProjectiles: [Projectile] = []
    private(set) var enemyProjectiles: [Projectile] = []

    // MARK: - Game Configuration
    private let screenSize: CGSize
    private let initialEnemyCount = 12

    // MARK: - Initialization (Dependency Injection)

    init(screenSize: CGSize,
         collisionService: CollisionDetectionService = DefaultCollisionDetectionService(),
         enemySpawner: EnemySpawnerService = DefaultEnemySpawnerService()) {

        self.screenSize = screenSize
        self.collisionService = collisionService
        self.enemySpawner = enemySpawner

        // Initialize player at bottom center
        let playerPosition = CGPoint(
            x: screenSize.width / 2 - 20,
            y: screenSize.height - 50
        )
        self.player = Player(position: playerPosition)

        setupGame()
    }

    // MARK: - Game Setup

    private func setupGame() {
        enemies = enemySpawner.generateEnemies(for: screenSize, count: initialEnemyCount)
        gameState = .playing
    }

    // MARK: - Game Loop

    func update() {
        guard gameState == .playing else { return }

        updateEntities()
        handleShooting()
        checkCollisions()
        cleanupEntities()
        checkWinLoseConditions()
    }

    private func updateEntities() {
        // Update all entities
        player.move()

        enemies.forEach { $0.move() }
        playerProjectiles.forEach { $0.move() }
        enemyProjectiles.forEach { $0.move() }
    }

    private func handleShooting() {
        // Player automatic shooting
        if let projectile = player.shoot() {
            playerProjectiles.append(projectile)
        }

        // Enemy shooting
        for enemy in enemies where !enemy.isDestroyed {
            if let projectile = enemy.shoot() {
                enemyProjectiles.append(projectile)
            }
        }
    }

    private func checkCollisions() {
        let result = collisionService.checkCollisions(
            player: player,
            enemies: enemies,
            playerProjectiles: playerProjectiles,
            enemyProjectiles: enemyProjectiles
        )

        // Remove destroyed entities
        if !result.destroyedEnemies.isEmpty {
            enemies = enemies.filter { !result.destroyedEnemies.contains($0) }
        }
        if !result.destroyedPlayerProjectiles.isEmpty {
            playerProjectiles = playerProjectiles.filter { !result.destroyedPlayerProjectiles.contains($0) }
        }
        if !result.destroyedEnemyProjectiles.isEmpty {
            enemyProjectiles = enemyProjectiles.filter { !result.destroyedEnemyProjectiles.contains($0) }
        }

        // Update score
        if !result.destroyedEnemies.isEmpty {
            score += result.destroyedEnemies.count * 10
        }

        // Update health display
        if result.playerHit {
            delegate?.healthDidUpdate(player.health)
        }
    }

    private func cleanupEntities() {
        // Remove out-of-bounds projectiles
        playerProjectiles.removeAll(where: { $0.isOutOfBounds(screenHeight: screenSize.height) })
        enemyProjectiles.removeAll(where: { $0.isOutOfBounds(screenHeight: screenSize.height) })
    }

    private func checkWinLoseConditions() {
        if player.isDestroyed {
            gameState = .gameOver
            delegate?.gameDidEnd(won: false)
            return
        }

        if enemies.isEmpty {
            gameState = .gameWon
            delegate?.gameDidEnd(won: true)
            return
        }

        // lose condition: enemy reaches player's line
        for enemy in enemies {
            if enemy.position.y >= player.position.y {
                gameState = .gameOver
                delegate?.gameDidEnd(won: false)
                return // No need to check other enemies
            }
        }
    }

    // MARK: - Player Controls

    func movePlayerLeft() {
        guard gameState == .playing else { return }
        player.moveLeft(screenWidth: screenSize.width)
    }

    func movePlayerRight() {
        guard gameState == .playing else { return }
        player.moveRight(screenWidth: screenSize.width)
    }

    // MARK: - Game Control

    func restartGame() {
        score = 0
        player.reset()

        // Reset player position
        let playerPosition = CGPoint(
            x: screenSize.width / 2 - 20,
            y: screenSize.height - 50
        )
        player.position = playerPosition

        // Clear projectiles
        playerProjectiles.removeAll()
        enemyProjectiles.removeAll()

        // Respawn enemies
        setupGame()

        delegate?.scoreDidUpdate(score)
        delegate?.healthDidUpdate(player.health)
    }

    func pauseGame() {
        gameState = .paused
    }

    func resumeGame() {
        gameState = .playing
    }

    // MARK: - Entity Access (for view updates)

    func getAllEntities() -> [GameEntity] {
        var entities: [GameEntity] = [player]
        entities.append(contentsOf: enemies)
        entities.append(contentsOf: playerProjectiles)
        entities.append(contentsOf: enemyProjectiles)
        return entities
    }
}
