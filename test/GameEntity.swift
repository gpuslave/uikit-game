
//
//  GameEntity.swift
//  SpaceInvaders
//
//  Created on iOS Space Invaders Game
//

import UIKit

// MARK: - Protocols (Interface Segregation Principle)

protocol Movable {
    var position: CGPoint { get set }
    var velocity: CGPoint { get set }
    func move()
}

protocol Shootable {
    func shoot() -> Projectile?
}

protocol Destructible {
    var health: Int { get set }
    var isDestroyed: Bool { get }
    func takeDamage(_ damage: Int)
}

protocol Renderable {
    var view: UIView { get }
    func updateView()
}

// MARK: - Base Game Entity

class GameEntity: Movable, Renderable {
    var position: CGPoint {
        didSet {
            updateView()
        }
    }
    var velocity: CGPoint
    let view: UIView
    let size: CGSize

    init(position: CGPoint, size: CGSize, color: UIColor) {
        self.position = position
        self.velocity = CGPoint.zero
        self.size = size
        self.view = UIView(frame: CGRect(origin: position, size: size))
        self.view.backgroundColor = color
        self.view.layer.cornerRadius = min(size.width, size.height) / 4
    }

    func move() {
        position = CGPoint(x: position.x + velocity.x, y: position.y + velocity.y)
    }

    func updateView() {
        view.frame.origin = position
    }

    func intersects(with other: GameEntity) -> Bool {
        let selfRect = CGRect(origin: position, size: size)
        let otherRect = CGRect(origin: other.position, size: other.size)
        return selfRect.intersects(otherRect)
    }
}

// MARK: - Projectile Class

class Projectile: GameEntity {
    let damage: Int
    let owner: ProjectileOwner

    enum ProjectileOwner {
        case player
        case enemy
    }

    init(position: CGPoint, velocity: CGPoint, owner: ProjectileOwner, damage: Int = 1) {
        self.damage = damage
        self.owner = owner

        let color: UIColor = owner == .player ? .cyan : .red
        let size = CGSize(width: 4, height: 8)

        super.init(position: position, size: size, color: color)
        self.velocity = velocity
    }

    func isOutOfBounds(screenHeight: CGFloat) -> Bool {
        return position.y < -size.height || position.y > screenHeight + size.height
    }
}

// MARK: - Player Class (Single Responsibility Principle)

class Player: GameEntity, Shootable, Destructible {
    private(set) var health: Int
    private let maxHealth: Int
    private var lastShotTime: TimeInterval = 0
    private let shootingInterval: TimeInterval = 0.5

    var isDestroyed: Bool {
        return health <= 0
    }

    init(position: CGPoint, health: Int = 3) {
        self.health = health
        self.maxHealth = health

        let size = CGSize(width: 40, height: 30)
        super.init(position: position, size: size, color: .green)
    }

    func takeDamage(_ damage: Int) {
        health = max(0, health - damage)
        updateHealthDisplay()
    }

    private func updateHealthDisplay() {
        // Visual feedback for health changes
        let alpha = CGFloat(health) / CGFloat(maxHealth)
        view.alpha = max(0.3, alpha)
    }

    func shoot() -> Projectile? {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastShotTime >= shootingInterval else { return nil }

        lastShotTime = currentTime
        let projectilePosition = CGPoint(
            x: position.x + size.width / 2 - 2,
            y: position.y - 8
        )
        let projectileVelocity = CGPoint(x: 0, y: -8)

        return Projectile(position: projectilePosition, velocity: projectileVelocity, owner: .player)
    }

    func moveLeft(screenWidth: CGFloat) {
        let newX = max(0, position.x - 5)
        position = CGPoint(x: newX, y: position.y)
    }

    func moveRight(screenWidth: CGFloat) {
        let newX = min(screenWidth - size.width, position.x + 5)
        position = CGPoint(x: newX, y: position.y)
    }

    func reset() {
        health = maxHealth
        updateHealthDisplay()
    }
}

// MARK: - Enemy Class

class Enemy: GameEntity, Shootable, Destructible {
    private(set) var health: Int = 1
    private var lastShotTime: TimeInterval = 0
    private let shootingInterval: TimeInterval

    var isDestroyed: Bool {
        return health <= 0
    }

    init(position: CGPoint) {
        // Random shooting interval between 2-4 seconds
        self.shootingInterval = TimeInterval.random(in: 2.0...4.0)

        let size = CGSize(width: 30, height: 25)
        super.init(position: position, size: size, color: .red)

        // Enemies move downward slowly
        self.velocity = CGPoint(x: 0, y: 0.5)
    }

    func takeDamage(_ damage: Int) {
        health = max(0, health - damage)
    }

    func shoot() -> Projectile? {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastShotTime >= shootingInterval else { return nil }

        lastShotTime = currentTime
        let projectilePosition = CGPoint(
            x: position.x + size.width / 2 - 2,
            y: position.y + size.height
        )
        let projectileVelocity = CGPoint(x: 0, y: 4)

        return Projectile(position: projectilePosition, velocity: projectileVelocity, owner: .enemy)
    }
}
