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
        // Do any additional setup after loading the view, typically from a nib.
        // Add an inset for the status bar.
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 22.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.height, height: self.view.frame.size.height * 2)
        
        let image = UIImage(named: "SampleImage")!
        scrollView.imageView!.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

