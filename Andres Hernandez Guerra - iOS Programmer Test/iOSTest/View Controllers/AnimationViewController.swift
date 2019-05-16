//
//  AnimationViewController.swift
//  iOSTest
//
//  Created by D & A Technologies on 1/22/18.
//  Copyright © 2018 D & A Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class AnimationViewController: UIViewController, UIGestureRecognizerDelegate {
    
    /**
     * =========================================================================================
     * INSTRUCTIONS
     * =========================================================================================
     * 1) Make the UI look like it does in the mock-up.
     *
     * 2) Logo should fade out or fade in when the user hits the Fade In or Fade Out button
     *
     * 3) User should be able to drag the logo around the screen with his/her fingers
     *
     * 4) Add a bonus to make yourself stick out. Music, color, fireworks, explosions!!! Have Swift experience? Why not write the Animation 
     *    section in Swfit to show off your skills. Anything your heart desires!
     *
     **/
    
    // MARK: - Outlets
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var buttonFade: UIButton!
    
    // MARK: - Properties
    var logoStatus = "opaque"
    var logoOriginalCenter: CGPoint!
    var soundPlayer = AVAudioPlayer()
    let fireEmitter = CAEmitterLayer() //Emitter layer declared with this scope for easy removal later
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Animation"
        self.extendedLayoutIncludesOpaqueBars = true
        self.view.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)

        // Creating three gesture recognizers for our logo imageView, and calling the appropriate actions
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(sender:)))
        pinchGestureRecognizer.delegate = self
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(sender:)))

        // Setting initial position for logo, enabling user interaction, and adding all gesture recognizers
        logo.center = CGPoint(x: UIScreen.main.bounds.midX, y: 175)
        logo.isUserInteractionEnabled = true
        logo.addGestureRecognizer(panGestureRecognizer)
        logo.addGestureRecognizer(pinchGestureRecognizer)
        logo.addGestureRecognizer(rotateGestureRecognizer)
    }
   
    // MARK: - Gesture Recognizer Functions
    @objc func didPinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }
    
    @objc func didRotate(sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.rotated(by: rotation)
        sender.rotation = 0
    }
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            // Getting current logo center
            logoOriginalCenter = logo.center
        }
        else if sender.state == .changed {
            // Checking to make sure that the user does not attempt to move logo off the screen
            if logoOriginalCenter.x + translation.x >= UIScreen.main.bounds.minX &&
               logoOriginalCenter.x + translation.x <= UIScreen.main.bounds.width &&
               logoOriginalCenter.y + translation.y >=  UIScreen.main.bounds.minY + 80 &&
               logoOriginalCenter.y + translation.y <= UIScreen.main.bounds.height - 120 {
                // Updating new logo position according to user dragging
                logo.center = CGPoint(x: logoOriginalCenter.x + translation.x, y: logoOriginalCenter.y + translation.y)
            }
        } else if sender.state == .ended {
            // This state does not perform any actions now, but was mostly used for debugging
            //print("Gesture ended")
        }
    }

    // Function to allow for rotation and scaling of image simultaneously
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    
    // MARK: - Actions
    @IBAction func didPressFade(_ sender: Any) {
        // Checking logo status and calling functions accordingly when the button is pressed, then updating logo status and button title variables
        if logoStatus == "opaque" {
            playSoundEffect(named: "fireSound.mp3")
            createFire()
            UIView.animate(withDuration: 4.25, animations: {
                self.logo.alpha = 0.0
            })
            logoStatus = "faded"
            buttonFade.setTitle("FADE IN", for: .normal)
        }
        else if logoStatus == "faded" {
            self.fireEmitter.removeFromSuperlayer()
            playSoundEffect(named: "harpSound.mp3")
            UIView.animate(withDuration: 4.25, animations: {
                self.logo.alpha = 1.0
            })
            logoStatus = "opaque"
            buttonFade.setTitle("FADE OUT", for: .normal)
        }
        
    }
    
    // MARK: - Sound Player Function
    func playSoundEffect(named: String) {
        let path = Bundle.main.path(forResource: named, ofType: nil)!
        // Attempting to play the desired sound effect
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            soundPlayer.play()
        }
        catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Custom Animation Functions
    func createFire() {
        // Defining previously declared CALayer with desired properties, tied to the logo
        fireEmitter.emitterPosition = CGPoint(x: logo.center.x, y: logo.center.y + 100)
        fireEmitter.emitterSize = CGSize(width: logo.frame.width, height: 20)
        fireEmitter.renderMode = kCAEmitterLayerAdditive
        fireEmitter.emitterShape = kCAEmitterLayerLine
        fireEmitter.emitterCells = [createFireCell()];
        
        // After the emitter cells are received from function call they are added to the view
        self.view.layer.addSublayer(fireEmitter)

        // Removing CALayer created after a delay according to the duration of the custom animation
        // NOTE: Because this happens asynchronously, the delay has to be shorter than animation duration to achieve a nice simultaneous effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.75) {
            self.fireEmitter.removeFromSuperlayer()
        }
    }
    
    func createFireCell() -> CAEmitterCell {
        // Creating emitter cells with custom property values, and base image for fire particles from assets
        let fire = CAEmitterCell();
        fire.birthRate = 550;
        fire.lifetime = 200.0;
        fire.alphaSpeed = -0.50
        fire.lifetimeRange = 0.90
        fire.color = UIColor(red:0.05, green:0.36, blue:0.54, alpha:1.0).cgColor
        fire.contents = UIImage(named: "fireParticle")?.cgImage
        fire.emissionLongitude = CGFloat(Double.pi);
        fire.velocity = 90;
        fire.velocityRange = 25;
        fire.emissionRange = 0.5;
        fire.yAcceleration = -200;
        fire.scaleSpeed = 0.3;
        
        return fire
    }
}
