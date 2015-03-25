//
//  SwiftViewController.swift
//  SCTYCameraView
//
//  Created by Kurt Werle on 3/24/15.
//  Copyright (c) 2015 Kurt Werle. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController, SCTYCameraViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pictureTaken(image: UIImage) {
        println("Picture taken: \(image)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
