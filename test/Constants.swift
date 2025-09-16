
//
//  Constants.swift
//  SpaceInvaders
//
//  Created on iOS Space Invaders Game
//

import UIKit

// MARK: - Game Constants (Single Responsibility Principle)

struct GameConstants {

    // MARK: - Player Configuration
    struct Player {
        static let size = CGSize(width: 40, height: 30)
        static let color = UIColor.green
        static let initialHealth = 3
        static let moveSpeed: CGFloat = 5
        static let shootingInterval: TimeInterval = 0.5
    }

    // MARK: - Enemy Configuration
    struct Enemy {
        static let size = CGSize(width: 30, height: 25)
        static let color = UIColor.red
        static let moveSpeed: CGFloat = 0.5
        static let shootingInterval = (min: 2.0, max: 4.0)
        static let initialCount = 12
    }

    // MARK: - Projectile Configuration
    struct Projectile {
        static let size = CGSize(width: 4, height: 8)
        static let playerColor = UIColor.cyan
        static let enemyColor = UIColor.red
        static let playerSpeed: CGFloat = -8
        static let enemySpeed: CGFloat = 4
        static let damage = 1
    }

    // MARK: - Game Settings
    struct Game {
        static let scorePerEnemy = 10
        static let frameRate = 60.0
        static let topMargin: CGFloat = 50
        static let bottomMargin: CGFloat = 50
    }

    // MARK: - UI Constants
    struct UI {
        static let controlAreaHeight: CGFloat = 100
        static let labelFontSize: CGFloat = 18
        static let titleFontSize: CGFloat = 32
        static let buttonFontSize: CGFloat = 20
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 8
    }
}

// MARK: - Color Theme (Open/Closed Principle - easily extendable)

struct GameTheme {
    static let background = UIColor.black
    static let text = UIColor.black
    static let accent = UIColor.systemBlue
    static let success = UIColor.systemGreen
    static let danger = UIColor.systemRed
    static let controlArea = UIColor.white.withAlphaComponent(0.1)
    static let border = UIColor.white.withAlphaComponent(0.3)
    static let gameOverOverlay = UIColor.black.withAlphaComponent(0.8)
}

// MARK: - Audio Configuration (Future Enhancement)

struct AudioConstants {
    static let shootSound = "shoot.wav"
    static let explosionSound = "explosion.wav"
    static let gameOverSound = "gameover.wav"
    static let victorySound = "victory.wav"
}
