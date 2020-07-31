//
//  PhotoViewController.swift
//  Tinder
//
//  Created by Peter Bassem on 7/31/20.
//  Copyright © 2020 Peter Bassem. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoViewController: UIViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    init(imageUrl: String) {
        imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: #imageLiteral(resourceName: "photo_placeholder").withRenderingMode(.alwaysOriginal), options: .continueInBackground)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(imageView)
        imageView.fillSuperview()
    }
}
