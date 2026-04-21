//
//  ViewController.swift
//  testAPP


import UIKit

class MainTestViewController: UIViewController {
    
    
    private let backgroundImageView = UIImageView()
    private let overlayImageView = UIImageView()
    private let titleImageView = UIImageView()
    private let startButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // MARK: Elements
        backgroundImageView.image = UIImage(named: "backgroundmain")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
       
        overlayImageView.image = UIImage(named: "basecat")
        overlayImageView.contentMode = .scaleAspectFill
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayImageView)
        
        
        titleImageView.image = UIImage(named: "title")
        titleImageView.contentMode = .scaleToFill
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleImageView)
        
        
        startButton.setImage(.startgame, for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
    
        
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        
        view.addSubview(startButton)
        
        // MARK: - Constraints
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            overlayImageView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            titleImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            startButton.heightAnchor.constraint(equalTo: startButton.widthAnchor, multiplier: 0.8)
        ])
    }
    
    @objc private func startTapped() {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
}
