
//
//  GameViewController.swift
//  SpaceInvaders
//
//  Created on iOS Space Invaders Game
//

import UIKit

class GameViewController: UIViewController {

    // MARK: - UI Elements (Storyboard Outlets)

    @IBOutlet weak var gameContainerView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var restartLabel: UILabel!
    

    // MARK: - Game Components

    private var gameEngine: GameEngine!
    private var gameTimer: CADisplayLink?

    // Continuous movement timers
    private var leftHoldTimer: Timer?
    private var rightHoldTimer: Timer?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGame()
        setupControllers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the game loop only if it's not already running
        if gameTimer == nil {
            startGameLoop()
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = GameTheme.background

        // Hide game over view initially
        gameOverView?.isHidden = true

        // Configure labels
        scoreLabel?.textColor = GameTheme.text
        healthLabel?.textColor = GameTheme.text

        // Configure buttons (appearance can be customized in storyboard too)
        leftButton?.setTitle("◀", for: .normal)
        rightButton?.setTitle("▶", for: .normal)
        [leftButton, rightButton].forEach {
            $0?.setTitleColor(GameTheme.text, for: .normal)
            $0?.backgroundColor = GameTheme.controlArea
            $0?.layer.borderColor = GameTheme.border.cgColor
            $0?.layer.borderWidth = 1
        }

        // Game over UI
        gameOverView?.backgroundColor = GameTheme.gameOverOverlay
        gameOverLabel?.textColor = GameTheme.text
        restartButton?.setTitleColor(.white, for: .normal)
        restartButton?.backgroundColor = GameTheme.accent
        restartButton?.layer.cornerRadius = GameConstants.UI.cornerRadius
    }

    // MARK: - Game Setup

    private func setupGame() {
        // Ensure layout is up to date to get correct container size
        view.layoutIfNeeded()
        let gameArea = gameContainerView?.bounds ?? view.bounds
        gameEngine = GameEngine(screenSize: gameArea.size)
        gameEngine.delegate = self
        gameEngine.initEntities()
        // Add all entity views to game container
        updateEntityViews()
    }

    private func setupControllers() {
        // Button taps (single-step move)
        leftButton?.addTarget(self, action: #selector(leftTap), for: .primaryActionTriggered)
        rightButton?.addTarget(self, action: #selector(rightTap), for: .primaryActionTriggered)

        // Press-and-hold continuous movement
        leftButton?.addTarget(self, action: #selector(leftHoldBegan), for: .touchDown)
        leftButton?.addTarget(self, action: #selector(holdEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        rightButton?.addTarget(self, action: #selector(rightHoldBegan), for: .touchDown)
        rightButton?.addTarget(self, action: #selector(holdEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Game Loop

    private func startGameLoop() {
        gameTimer = CADisplayLink(target: self, selector: #selector(gameLoop))
        gameTimer?.add(to: .main, forMode: .default)
    }

    @objc private func gameLoop() {
        gameEngine.update()
        updateEntityViews()
    }

    private func updateEntityViews() {
        // Remove all existing entity views
        gameContainerView?.subviews.forEach { $0.removeFromSuperview() }

        // Add all current entities
        for entity in gameEngine.getAllEntities() {
            gameContainerView?.addSubview(entity.view)
        }
    }

    // MARK: - Control Handlers (Buttons)

    // Single-tap movement
    @objc private func leftTap() {
        gameEngine.movePlayerLeft()
    }

    @objc private func rightTap() {
        gameEngine.movePlayerRight()
    }

    // Press-and-hold movement
    @objc private func leftHoldBegan() {
        invalidateHoldTimers()
        leftHoldTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / GameConstants.Game.frameRate, repeats: true) { [weak self] _ in
            self?.gameEngine.movePlayerLeft()
        }
        RunLoop.current.add(leftHoldTimer!, forMode: .common)
    }

    @objc private func rightHoldBegan() {
        invalidateHoldTimers()
        rightHoldTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / GameConstants.Game.frameRate, repeats: true) { [weak self] _ in
            self?.gameEngine.movePlayerRight()
        }
        RunLoop.current.add(rightHoldTimer!, forMode: .common)
    }

    @objc private func holdEnded() {
        invalidateHoldTimers()
    }

    private func invalidateHoldTimers() {
        leftHoldTimer?.invalidate()
        leftHoldTimer = nil
        rightHoldTimer?.invalidate()
        rightHoldTimer = nil
    }

    @IBAction private func restartButtonTapped() {
        gameEngine.restartGame()
        gameOverView.isHidden = true
    }

    // MARK: - Memory Management
    
    deinit {
        gameTimer?.invalidate()
        gameTimer = nil
        invalidateHoldTimers()
    }
}

// MARK: - GameEngineDelegate

extension GameViewController: GameEngineDelegate {

    func gameDidEnd(won: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.gameOverLabel.text = won ? "🎉 You Won! 🎉" : "💀 Game Over 💀"
            self?.gameOverLabel.textColor = won ? GameTheme.success : GameTheme.danger
            self?.restartButton.backgroundColor = won ? GameTheme.success : GameTheme.danger
            self?.restartLabel?.textColor = .white
            self?.restartLabel?.text = won ? "Play Again" : "Try Again"
            self?.gameOverView.isHidden = false
        }
    }

    func gameStateDidChange(_ state: GameState) {
        switch state {
        case .paused:
            gameTimer?.isPaused = true
        case .playing:
            gameTimer?.isPaused = false
        default:
            break
        }
    }

    func scoreDidUpdate(_ score: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.scoreLabel.text = "Score: \(score)"
        }
    }

    func healthDidUpdate(_ health: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.healthLabel.text = "Health: \(health)"
        }
    }
}

