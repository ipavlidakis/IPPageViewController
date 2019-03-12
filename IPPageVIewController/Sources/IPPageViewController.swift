//
//  IPPageViewController.swift
//  IPPageVIewController
//
//  Created by Ilias Pavlidakis on 12/03/2019.
//  Copyright © 2019 Ilias Pavlidakis. All rights reserved.
//

import Foundation
import UIKit

final class IPPageCollectionViewCell: UICollectionViewCell {
    
    class var reuseIdentifier: String { return String(describing: IPPageCollectionViewCell.self) }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func configure(
        _ view: UIView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

protocol IPPageViewControllerDatasource: class {
    
    func numberOfPages() -> Int
    
    func viewController(for index: Int) -> UIViewController
}

protocol IPPageViewControllerDelegate: class {
    
    func willDisplay(page: Int)
    
    func didDisplay(page: Int)
}

final class IPPageViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    weak var datasource: IPPageViewControllerDatasource?
    weak var delegate: IPPageViewControllerDelegate?
}

private extension IPPageViewController {
    
    var visibleViewController: UIViewController? {
        
        guard
            let indexPath = collectionView.indexPathsForVisibleItems.first,
            let viewController = datasource?.viewController(for: indexPath.item) else {
            
            return nil
        }
        
        return viewController
    }
}

extension IPPageViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView.backgroundColor = .clear
        
        collectionView.register(IPPageCollectionViewCell.self, forCellWithReuseIdentifier: IPPageCollectionViewCell.reuseIdentifier)
        
        collectionView.isPagingEnabled = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        
        if #available(iOS 11, *) {
            
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = collectionView.contentOffset;
        let width = collectionView.bounds.size.width;
        
        let index = round(offset.x / width);
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        coordinator.animate(alongsideTransition: { (context) in
            
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.setContentOffset(newOffset, animated: false)
            
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        visibleViewController?.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        visibleViewController?.viewDidAppear(animated)
    }
}

extension IPPageViewController {
    
    func reloadData() {
        
        collectionView.reloadData()
    }
}

extension IPPageViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        
        return datasource?.numberOfPages() ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let viewController = datasource?.viewController(for: indexPath.row) else {
            fatalError("Datasource wasn't set for \(String(describing: self))")
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IPPageCollectionViewCell.reuseIdentifier, for: indexPath) as? IPPageCollectionViewCell else {
             
                assertionFailure("Invalid cell found. Only instances of IPPageCollectionViewCell are valid")
                
                let errorCell = UICollectionViewCell()
                errorCell.backgroundColor = .red
                return errorCell
        }
        
        cell.configure(viewController.view)
        
        return cell
    }
}

extension IPPageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath) {
        
        datasource?.viewController(for: indexPath.item).viewDidAppear(true)
        
        delegate?.willDisplay(page: indexPath.item)
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}

extension IPPageViewController {
    
    func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView) {
        
        guard let topVisibleIndex = collectionView.indexPathsForVisibleItems.first else {
            
            return
        }
        
        visibleViewController?.viewDidAppear(true)
        delegate?.didDisplay(page: topVisibleIndex.item)
    }
}
