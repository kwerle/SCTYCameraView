//
//  ViewController.swift
//  Camera
//
//  Created by Kurt.Werle on 3/12/15.
//  Copyright (c) 2015 Kurt.Werle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tempButton: UIButton!
    @IBOutlet weak var cameraView: CameraView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

