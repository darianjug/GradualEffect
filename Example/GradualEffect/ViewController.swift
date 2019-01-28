//
//  ViewController.swift
//  GradualEffect
//
//  Created by Darian Jug on 06/25/2016.
//  Copyright (c) 2016 Darian Jug. All rights reserved.
//

import UIKit

import GradualEffect

class ViewController: UIViewController {
    @IBOutlet weak var scrollView: GradualEffect.BlurringScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: 0.0,
                                        height: self.view.bounds.size.height * 2)
        
        let image = UIImage(named: "SampleImage")!
        scrollView.imageView!.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

