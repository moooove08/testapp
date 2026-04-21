//  testAPP
//
//  Created by moooove on 21.04.2026.
//

import UIKit

protocol PauseViewDelegate: AnyObject {
    func onResumeTapped()
    func onRestartTapped()
    func onSoundTapped()
}

final class PauseView: UIView {
    weak var delegate: PauseViewDelegate?

    private let dimView = UIView()
    private let resumeButton = UIButton(type: .custom)
    private let restartButton = UIButton(type: .custom)
    private let soundButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dimView)

        resumeButton.setImage(UIImage(named: "play"), for: .normal)
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        resumeButton.addTarget(self, action: #selector(resumeTapped), for: .touchUpInside)
        addSubview(resumeButton)

        restartButton.setImage(UIImage(named: "restart"), for: .normal)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        addSubview(restartButton)

        
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        soundButton.addTarget(self, action: #selector(soundTapped), for: .touchUpInside)
        addSubview(soundButton)
        updateSoundButtonImage()

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),

            resumeButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -60),
            resumeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            resumeButton.widthAnchor.constraint(equalToConstant: 100),
            resumeButton.heightAnchor.constraint(equalToConstant: 100),

            restartButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 60),
            restartButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 100),
            restartButton.heightAnchor.constraint(equalToConstant: 100),

            soundButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            soundButton.topAnchor.constraint(equalTo: resumeButton.bottomAnchor, constant: 22),
            soundButton.widthAnchor.constraint(equalToConstant: 100),
            soundButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    func updateSoundButtonImage() {
        let imageName = GameAudioSettings.isSoundEnabled ? "son" : "soff"
        soundButton.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc private func resumeTapped() {
        delegate?.onResumeTapped()
    }

    @objc private func restartTapped() {
        delegate?.onRestartTapped()
    }

    @objc private func soundTapped() {
        delegate?.onSoundTapped()
    }
}
