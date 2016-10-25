//
//  InfiniteScrollActivityView.swift
//  TumblrFeed
//
//  Created by Jonathan Cheng on 10/14/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 80.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    // Initialize and add the loading indicator to the tableView's view hierarchy.
    // Then add new insets to allow room for seeing the loadingindicator at the bottom of the tableView
    convenience init(for scrollView: UIScrollView) {
        let frame = CGRect(x: 0, y:scrollView.contentSize.height, width: scrollView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
        self.init(frame: frame)
        self.isHidden = true
        scrollView.addSubview(self)
        
        var insets = scrollView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        scrollView.contentInset = insets
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
