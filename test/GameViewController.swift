
//
//  GameViewController.swift
//  SpaceInvaders
//
//  Created on iOS Space Invaders Game
//

import UIKit

class GameViewController: UIViewController {

    // MARK: - UI Elements

    @IBOutlet weak var gameContainerView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var leftControlArea: UIView!
    @IBOutlet weak var rightControlArea: UIView!

    // MARK: - Game Components

    private var gameEngine: GameEngine!
    private var gameTimer: CADisplayLink?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGame()
        setupControllers()
        startGameLoop()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Create UI elements programmatically if not using storyboard
        if gameContainerView == nil {
            createUIElementsProgrammatically()
        }
    }

    // MARK: - UI Setup

    private func createUIElementsProgrammatically() {
        view.backgroundColor = .black

        // Game container
        gameContainerView = UIView()
        gameContainerView.backgroundColor = .clear
        gameContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameContainerView)

        // Score label
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)

        // Health label
        healthLabel = UILabel()
        healthLabel.text = "Health: 3"
        healthLabel.textColor = .white
        healthLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        healthLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(healthLabel)

        // Game Over View
        gameOverView = UIView()
        gameOverView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        gameOverView.isHidden = true
        gameOverView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameOverView)

        // Game Over Label
        gameOverLabel = UILabel()
        gameOverLabel.text = "Game Over"
        gameOverLabel.textColor = .white
        gameOverLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        gameOverLabel.textAlignment = .center
        gameOverLabel.translatesAutoresizingMaskIntoConstraints = false
        gameOverView.addSubview(gameOverLabel)

        // Restart Button
        restartButton = UIButton(type: .system)
        restartButton.setTitle("Restart Game", for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        restartButton.setTitleColor(.white, for: .normal)
        restartButton.backgroundColor = .systemBlue
        restartButton.layer.cornerRadius = 8
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
        gameOverView.addSubview(restartButton)

        // Control Areas
        leftControlArea = UIView()
        leftControlArea.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        leftControlArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftControlArea)

        rightControlArea = UIView()
        rightControlArea.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        rightControlArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightControlArea)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // Game Container
            gameContainerView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
            gameContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameContainerView.bottomAnchor.constraint(equalTo: leftControlArea.topAnchor),

            // Score Label
            scoreLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // Health Label
            healthLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            healthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Control Areas
            leftControlArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftControlArea.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            leftControlArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftControlArea.heightAnchor.constraint(equalToConstant: 100),

            rightControlArea.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            rightControlArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightControlArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightControlArea.heightAnchor.constraint(equalToConstant: 100),

            // Game Over View
            gameOverView.topAnchor.constraint(equalTo: view.topAnchor),
            gameOverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameOverView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameOverView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Game Over Label
            gameOverLabel.centerXAnchor.constraint(equalTo: gameOverView.centerXAnchor),
            gameOverLabel.centerYAnchor.constraint(equalTo: gameOverView.centerYAnchor, constant: -50),

            // Restart Button
            restartButton.centerXAnchor.constraint(equalTo: gameOverView.centerXAnchor),
            restartButton.topAnchor.constraint(equalTo: gameOverLabel.bottomAnchor, constant: 30),
            restartButton.widthAnchor.constraint(equalToConstant: 150),
            restartButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupUI() {
        view.backgroundColor = .black

        // Hide game over view initially
        gameOverView?.isHidden = true

        // Style control areas
        leftControlArea?.layer.borderWidth = 1
        leftControlArea?.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        rightControlArea?.layer.borderWidth = 1
        rightControlArea?.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        // Add labels to control areas
        addControlLabels()
    }

    private func addControlLabels() {
        // Left control label
        let leftLabel = UILabel()
        leftLabel.text = "◀ MOVE LEFT"
        leftLabel.textColor = .white
        leftLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        leftLabel.textAlignment = .center
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftControlArea.addSubview(leftLabel)

        // Right control label
        let rightLabel = UILabel()
        rightLabel.text = "MOVE RIGHT ▶"
        rightLabel.textColor = .white
        rightLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        rightLabel.textAlignment = .center
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightControlArea.addSubview(rightLabel)

        NSLayoutConstraint.activate([
            leftLabel.centerXAnchor.constraint(equalTo: leftControlArea.centerXAnchor),
            leftLabel.centerYAnchor.constraint(equalTo: leftControlArea.centerYAnchor),
            rightLabel.centerXAnchor.constraint(equalTo: rightControlArea.centerXAnchor),
            rightLabel.centerYAnchor.constraint(equalTo: rightControlArea.centerYAnchor)
        ])
    }

    // MARK: - Game Setup

    private func setupGame() {
        let gameArea = gameContainerView?.bounds ?? view.bounds
        gameEngine = GameEngine(screenSize: gameArea.size)
        gameEngine.delegate = self

        // Add all entity views to game container
        updateEntityViews()
    }

    private func setupControllers() {
        // Setup touch handlers for control areas
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(leftAreaTapped))
        leftControlArea?.addGestureRecognizer(leftTapGesture)

        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(rightAreaTapped))
        rightControlArea?.addGestureRecognizer(rightTapGesture)

        // Continuous touch for smoother control
        let leftLongPress = UILongPressGestureRecognizer(target: self, action: #selector(leftAreaPressed(_:)))
        leftLongPress.minimumPressDuration = 0.1
        leftControlArea?.addGestureRecognizer(leftLongPress)

        let rightLongPress = UILongPressGestureRecognizer(target: self, action: #selector(rightAreaPressed(_:)))
        rightLongPress.minimumPressDuration = 0.1
        rightControlArea?.addGestureRecognizer(rightLongPress)
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

    // MARK: - Control Handlers

    @objc private func leftAreaTapped() {
        gameEngine.movePlayerLeft()
    }

    @objc private func rightAreaTapped() {
        gameEngine.movePlayerRight()
    }

    @objc private func leftAreaPressed(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            gameEngine.movePlayerLeft()
        default:
            break
        }
    }

    @objc private func rightAreaPressed(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            gameEngine.movePlayerRight()
        default:
            break
        }
    }

    @objc private func restartButtonTapped() {
        gameEngine.restartGame()
        gameOverView.isHidden = true
    }

    // MARK: - Memory Management

    deinit {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}

// MARK: - GameEngineDelegate

extension GameViewController: GameEngineDelegate {

    func gameDidEnd(won: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.gameOverLabel.text = won ? "🎉 You Won! 🎉" : "💀 Game Over 💀"
            self?.gameOverLabel.textColor = won ? .systemGreen : .systemRed
            self?.gameOverView.isHidden = false
        }
    }

    func gameStateDidChange(_ state: GameState) {
        // Handle game state changes if needed
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
