//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    // MARK: - Views
    private var skView: SKView!
    private weak var pauseView: PauseView?
    private var didPresentInitialScene = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let skView = SKView(frame: .zero)
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.ignoresSiblingOrder = true
        skView.backgroundColor = .black
        view.addSubview(skView)
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        self.skView = skView
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Scene presentation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didPresentInitialScene, view.bounds.width > 0, view.bounds.height > 0 {
            didPresentInitialScene = true
            presentNewScene()
        }
    }

    private func presentNewScene() {
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameDelegate = self
        skView.presentScene(scene, transition: .fade(withDuration: 0.2))
    }

    // MARK: - Pause overlay
    private func showPauseOverlay() {
        guard pauseView == nil else { return }
        guard let scene = skView.scene as? GameScene else { return }

        let pv = PauseView(frame: view.bounds)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.delegate = self
        view.addSubview(pv)
        NSLayoutConstraint.activate([
            pv.topAnchor.constraint(equalTo: view.topAnchor),
            pv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        pauseView = pv

        scene.isPaused = true
    }

    private func hidePauseOverlay() {
        pauseView?.removeFromSuperview()
        (skView.scene as? GameScene)?.isPaused = false
    }
}

extension GameViewController: GameSceneDelegate {
    func gameSceneDidRequestPause(_ scene: GameScene) {
        showPauseOverlay()
    }

    func gameSceneDidRequestExitToMenu(_ scene: GameScene) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    func gameSceneDidRequestReplay(_ scene: GameScene) {
        presentNewScene()
    }
}

extension GameViewController: PauseViewDelegate {
    func onResumeTapped() {
        hidePauseOverlay()
    }

    func onRestartTapped() {
        pauseView?.removeFromSuperview()
        presentNewScene()
    }

    func onSoundTapped() {
        GameAudioSettings.isSoundEnabled.toggle()
        pauseView?.updateSoundButtonImage()
    }
}
