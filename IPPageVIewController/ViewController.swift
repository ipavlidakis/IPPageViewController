//
//  ViewController.swift
//  IPPageVIewController
//
//  Created by Ilias Pavlidakis on 12/03/2019.
//  Copyright © 2019 Ilias Pavlidakis. All rights reserved.
//

import UIKit

extension UIView {
    
    func pinToSuperView() {
        
        guard let superview = superview else { return }
        
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    func pinToSafeArea() {
        
        guard let superview = superview else { return }
        
        guard #available(iOS 11, *) else {
            
            pinToSuperView()
            
            return
        }
        
        leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

class ViewController: UIViewController {

    private let stackView = UIStackView()
    private let headerView = UIView()
    private let pageViewController = IPPageViewController()
    private let pageControl = UIPageControl(frame: .zero)
    
    private var viewControllers: [UIViewController] = [] {
        
        didSet {
            
            pageControl.numberOfPages = viewControllers.count
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.pinToSuperView()
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .red
        headerView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        headerView.setContentHuggingPriority(.required, for: .vertical)
        
        headerView.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pinToSafeArea()
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(pageViewController.view)
        
        let v1 = UIViewController()
        v1.view.backgroundColor = .yellow
        
        let v2 = UIViewController()
        v2.view.backgroundColor = .brown
        
        let v3 = UIViewController()
        v3.view.backgroundColor = .purple
        
        viewControllers = [v1, v2, v3]
        
        pageViewController.datasource = self
        pageViewController.delegate = self
        
        pageViewController.willMove(toParent: self)
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
    }
}

extension ViewController: IPPageViewControllerDatasource {
    
    func numberOfPages() -> Int {
        
        return viewControllers.count
    }
    
    func viewController(
        for index: Int) -> UIViewController {
        
        return viewControllers[index]
    }
}

extension ViewController: IPPageViewControllerDelegate {
    
    func willDisplay(page: Int) {
    
    }
    
    func didDisplay(page: Int) {
     
        pageControl.currentPage = page
    }
}
