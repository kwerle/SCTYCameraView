//
//  CameraView.swift
//  SiteSurvey
//
//  Created by Kurt.Werle on 3/10/15.
//  Copyright (c) 2015 Kurt.Werle. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

@objc protocol SCTYCameraViewDelegate {
    // This may be outside the main thread
    func pictureTaken(image: UIImage)
}

@objc class SCTYCameraView: UIView, UIGestureRecognizerDelegate {

    let captureSession = AVCaptureSession()
    
    // The current capture device if there is one
    @objc var captureDevice: AVCaptureDevice?
    // The capture layer - does not changes
    @objc var previewLayer: AVCaptureVideoPreviewLayer?
    
    // The button used to snap a picture!
    @objc @IBOutlet var snapButtonView: UIView!
    // The button used to swap front/back view
    @objc @IBOutlet var reverseButton: UIView?
    
    @objc @IBOutlet var delegate: SCTYCameraViewDelegate?
    
    var captureOutput: AVCaptureStillImageOutput?
    
    lazy var devices: [AVCaptureDevice] = (AVCaptureDevice.devices() as [AVCaptureDevice]).filter {
        return $0.hasMediaType(AVMediaTypeVideo)
    }
    
    override init() {
        super.init()
        sharedInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    func sharedInit() {
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        if (devices.count > 0) {
            captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            addFocusGesture()
            addSnapButtonView()
            if (devices.count > 1) {
                addReverseButton()
            }
        } else {
            addNoCameraLabel()
        }
    }
    
    
    func addFocusGesture() {
        let touchGestureRecognizer = UITapGestureRecognizer(target: self, action: "setFocus:")
        addGestureRecognizer(touchGestureRecognizer)
        touchGestureRecognizer.delegate = self
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        for subview in subviews as [UIView] {
            println("checking \(subview.frame)")
            subview.setNeedsDisplay()
            if touch.view.isDescendantOfView(subview) {
                println("returning false")
                return false;
            }
        }
        return true
    }
    
    func addSnapButtonView() {
        if (snapButtonView == nil) {
            let newView = SnapButtonView()
            newView.setTranslatesAutoresizingMaskIntoConstraints(false)
            let constraintDict = ["snapButton": newView]
            addSubview(newView)
            var horizontalConstraints = [NSLayoutConstraint(item: newView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)] +
            NSLayoutConstraint.constraintsWithVisualFormat("[snapButton(30)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: constraintDict)
            
            let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[snapButton(30)]-|", options: nil, metrics: nil, views: constraintDict)
            NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints)
            snapButtonView = newView
            newView.addTarget(self, action: "takePicture:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func addReverseButton() {
        var button = UIButton.buttonWithType(UIButtonType.System) as UIButton
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle("🔄", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(40)
        button.sizeToFit()
        addSubview(button)
        let constraintDict = ["button": button]
        var horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[button]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: constraintDict)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[button]", options: nil, metrics: nil, views: constraintDict)
        NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints)
        button.addTarget(self, action: "switchCamera:", forControlEvents: UIControlEvents.TouchUpInside)
        reverseButton = button
    }
    
    func addNoCameraLabel() {
//        newView.attributedText = NSAttributedString(string: "📷⃠") Why doesn't this work?  Prints camera followed by /
        let cameraLabel = UILabel()
        cameraLabel.text = "📷"
        cameraLabel.font = UIFont.systemFontOfSize(50)
        let slashLabel = UILabel()
        slashLabel.text = " ⃠"
        slashLabel.font = UIFont.systemFontOfSize(80)
        slashLabel.textColor = UIColor.redColor()
        for label in [cameraLabel, slashLabel] {
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            let constraintDict = ["snapButton": label]
            addSubview(label)
            var horizontalConstraints = [NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)] +
                NSLayoutConstraint.constraintsWithVisualFormat("[snapButton]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: constraintDict)
            
            let verticalConstraints = [NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)] +
                NSLayoutConstraint.constraintsWithVisualFormat("V:[snapButton]", options: nil, metrics: nil, views: constraintDict)
            NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints)
        }
    }
    
    func switchCamera(button: UIButton) {
        let currentIndex = find(devices, captureDevice!) ?? 0
        captureDevice = devices[(currentIndex + 1) % devices.count]
        beginSession()
    }
    
    func takePicture(button: UIButton) {
        captureOutput!.captureStillImageAsynchronouslyFromConnection(captureOutput?.connectionWithMediaType(AVMediaTypeVideo)) { (buffer, error) -> Void in
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            let image = UIImage(data: imageData)
            self.delegate?.pictureTaken(image!)
        }
    }
    
    override func translatesAutoresizingMaskIntoConstraints() -> Bool {
        return false
    }
    
    override func drawRect(rect: CGRect) {
        beginSession()
        super.drawRect(rect)
    }

    func beginSession() {
        if (captureDevice == nil) {
            return
        }
        
        var error : NSError? = nil
        captureSession.beginConfiguration()
        captureSession.removeInput(captureSession.inputs?.first as AVCaptureDeviceInput?)
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))
        if error != nil {
            println("error: \(error?.localizedDescription)")
        }
        
        captureOutput = AVCaptureStillImageOutput()
        if (captureSession.canAddOutput(captureOutput)) {
            captureOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            captureSession.addOutput(captureOutput)
        }
        
        if (previewLayer == nil) {
            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.layer.addSublayer(layer)
            layer.frame = self.layer.bounds
            previewLayer = layer
        } else {
            captureSession.stopRunning()
        }
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func setFocus(sender: UITapGestureRecognizer) {
        println("\(sender)")
        var error: NSErrorPointer = NSErrorPointer()
        if let camera = captureDevice {
            if (camera.focusPointOfInterestSupported) {
                let point = sender.locationInView(self)
                showFocusPoint(point)
                if (camera.lockForConfiguration(error)) {
                    let calculatedPointOfInterest = previewLayer!.captureDevicePointOfInterestForPoint(point)
                    
                    if (camera.isFocusModeSupported(AVCaptureFocusMode.AutoFocus)) {
                        camera.focusPointOfInterest = calculatedPointOfInterest
                        camera.focusMode = AVCaptureFocusMode.AutoFocus
                    }
                    if (camera.exposurePointOfInterestSupported && camera.isExposureModeSupported(AVCaptureExposureMode.AutoExpose)) {
                        camera.exposurePointOfInterest = calculatedPointOfInterest
                        camera.exposureMode = AVCaptureExposureMode.AutoExpose
                    }
                    //                println("camera.focusPointOfInterest: \(calculatedPointOfInterest)")
                    camera.unlockForConfiguration()
                }
            }
        }
    }
    

    func showFocusPoint(focusPoint: CGPoint) {
        let focusRadius: CGFloat = 10.0
        let centerRect = CGRectMake(focusPoint.x - focusRadius, focusPoint.y - focusRadius, focusRadius * 2.0, focusRadius * 2.0)
        
        let focusView = FocusView(frame: centerRect)
        
        addSubview(focusView)
        
        focusView.frame = centerRect // Why do I need to do this again?  Because it resets after adding it?
//        focusView.setNeedsDisplay()
    }
}

// Contains the snap button.  Used for drawing.
// I could probably prefab an imageview for the button, but .. this feels more natural.
@objc class SnapButtonView: UIButton {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        var buttonPath = UIBezierPath(ovalInRect: self.bounds.rectByInsetting(dx: 3, dy: 3))
        buttonPath.lineWidth = 3
        UIColor.yellowColor().set()
        buttonPath.stroke()
        UIColor.yellowColor().colorWithAlphaComponent(0.1).set()
        buttonPath.fill()
    }
    
}

@objc class FocusView: UIView {
    
    var color = UIColor.blackColor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.0)
        self.color = UIColor.blackColor()
        FocusView.animateWithDuration(1.5, animations: { () -> Void in
            self.bounds.size = CGSizeMake(0, 0)
            self.color = UIColor.whiteColor()
            }) { (bool) -> Void in
                self.removeFromSuperview()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let path = UIBezierPath(ovalInRect: self.bounds.rectByInsetting(dx: 3, dy: 3))
        self.color.set()
        path.stroke()
    }
}
