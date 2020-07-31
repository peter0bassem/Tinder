//
//  SwipingPhotosPageViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/31/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit

class SwipingPhotosPageViewController: UIPageViewController {

    // MARK: - UI Components
    private lazy var barsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Variables
    var controllers = [UIViewController]()
    var cardViewModel: CardViewModel! {
        didSet {
            controllers = cardViewModel.imageUrls.map { return PhotoViewController(imageUrl: $0) }
            setViewControllers([controllers[0]], direction: .forward, animated: false)
            setupBarViews()
        }
    }
    private var deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    private let isCardViewMode: Bool

    // MARK: - Initializers
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController Lifecycycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        dataSource = self
        delegate = self

        if isCardViewMode {
            view.subviews.forEach { ($0 as? UIScrollView)?.isScrollEnabled = false }
        }

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlesTap(_:))))
    }

    // MARK: - Helpers
    private func setupBarViews() {
        if cardViewModel.imageUrls.count <= 1 { return }
        cardViewModel.imageUrls.forEach { _ in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 2
            barsStackView.addArrangedSubview(barView)
        }
        barsStackView.arrangedSubviews.first?.backgroundColor = .white
        view.addSubview(barsStackView)
        let statusBarHeight = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let paddinTop = isCardViewMode ? 8 : statusBarHeight + 8
        barsStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddinTop, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }

    // MARK: - Actions
    @objc private func handlesTap(_ sender: UITapGestureRecognizer) {
        if cardViewModel.imageUrls.count <= 1 { return }
        let currentController = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentController) {

            barsStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
            if sender.location(in: view).x > (view.frame.size.width / 2) {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            } else {
                let previousIndex = max(0, index - 1)
                let previousController = controllers[previousIndex]
                setViewControllers([previousController], direction: .forward, animated: false)
                barsStackView.arrangedSubviews[previousIndex].backgroundColor = .white
            }
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension SwipingPhotosPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex { $0 == viewController } ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex { $0 == viewController } ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension SwipingPhotosPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoViewController = viewControllers?.first
        if let index = controllers.firstIndex(where: { $0 == currentPhotoViewController }) {
            barsStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectedBarColor }
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }

    }
}
