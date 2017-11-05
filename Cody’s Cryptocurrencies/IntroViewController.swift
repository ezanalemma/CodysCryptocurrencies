//
//  IntroViewController.swift
//  Cody's Cryptocurrencies
//
//  Created by Ezana Lemma on 4/18/17.
//  Copyright © 2017 Ezana Lemma. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import LocalAuthentication

class IntroViewController: UIViewController {
    
    var playerController : AVPlayerViewController!
    var player: AVPlayer!
    
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var videoView: UIView!
    

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    
    /* TOUCH ID METHOD BELOW */
    
/*    @IBAction func signInButton(_ sender: UIButton) {
  
        let myContext = LAContext()
     let myLocalizedReasonString = "Verify user"
     
        var authError: NSError? = nil
       if #available(iOS 8.0, OSX 10.12, *) {
        if myContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
     myContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify user") { (success, evaluateError) in
                    if (success) {
                     User authenticated successfully, take
                        self.performSegue(withIdentifier: "signedInVC", sender: self)
     
                   } else {
                User did not authenticate successfully, look at error and take appropriate action
                        let alertController = UIAlertController(title: "Access denied", message: "Please try again", preferredStyle: UIAlertControllerStyle.alert)
                   }
              }
          } else {
         Could not evaluate policy; look at authError and present an appropriate message to user
           }
       } else {
           Fallback on earlier versions
}
    
 }*/
    
    
    
    
    override func viewDidLoad() {
        
        //runs the setup funtion to set up a coupel UI things
        setup()
        //Plays video in another thread
        DispatchQueue.main.async {
            self.playVideo()
        }
        //auth()
        
        super.viewDidLoad()
    }
    
    
    
    func auth() {
        let myContext = LAContext()
            let myLocalizedReasonString = "Verify user"
        
        var authError: NSError? = nil
         if #available(iOS 8.0, OSX 10.12, *) {
           if myContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                        myContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify user") { (success, evaluateError) in
                          if (success) {
        //                    // User authenticated successfully, take
        //                  self.performSegue(withIdentifier: "signedInVC", sender: self)
        
                  } else {
        // User did not authenticate successfully, look at error and take appropriate action
                    let alertController = UIAlertController(title: "Access denied", message: "Please try again", preferredStyle: UIAlertControllerStyle.alert)
                       }
                 }
           } else {
            
        // Could not evaluate policy; look at authError and present an appropriate message to user
            exit(0)
               }
          } else {
         //Fallback on earlier versions
         }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    //sets up AVPlayerViewController and AVPlayer to play video
    func playVideo() {
        //sets the video path for the video we wnat to play. In this case water.mov in the Supporting files. can be mp4 as well
        let path = Bundle.main.path(forResource: "mastertwo", ofType:"mov")
        
        //convert pasth to NSURL
        let videoUrl = URL(fileURLWithPath: path!)
        
        //init AVPlayerViewController
        playerController = AVPlayerViewController()
        
        //init AVPlayer with video URL
        player = AVPlayer(url: videoUrl)
        
        //set the AVPlayerViewController's player to out player
        playerController.player = player
        
        //adds AVPlayerViewController to the view
        self.addChildViewController(playerController)
        
        //AVPlayerViewController's view to out video View
        videoView.addSubview(playerController.view)
        
        //sets the AVPlayerViewController's frame to the size out our video view frame
        playerController.view.frame = self.view.frame
        
        //disable/hide player control
        playerController.showsPlaybackControls = false
        
        //plays video
        player.play()
        
        //slows down the video playback rate
        player.rate = 0.9
        
        //mutes the audio
        player.isMuted = true
        
        //setion player's action upon video completion
        player.actionAtItemEnd = .none
        
        //set a listener for when the video ends
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(IntroViewController.restartVideoFromBeginning),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
    }
    
    
    
    
    //setup some UI stuff
    func setup(){
        
        //Rounds the buttons Button corners
        //signInButton.layer.cornerRadius = 2
        //registerButton.layer.cornerRadius = 2
        
        //Set up Blur View Controller for use
        blurView.frame = self.view.bounds
        blurView.bounds = self.view.bounds
        
        //Sets up the AVPlayerViewCOntoller frame and bounds to make it fullscreen
        videoView.bounds = self.view.bounds
        videoView.frame = self.view.bounds
        
        //Presents Blur and sets Blur Intensity
        if #available(iOS 10.0, *) {
            self.insertBlurView(blurView, style: UIBlurEffectStyle.regular)
        } else {
            self.insertBlurView(blurView, style: UIBlurEffectStyle.light)
        }
        blurView.alpha = 0.2
    }
    
    
    
    
    //function to restart the video
    func restartVideoFromBeginning()  {
        
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player!.seek(to: seekTime)
        
        player!.play()
        
    }
    
    
    
    
    
    //fnserts a blur on top of the video
    func insertBlurView (_ view: UIView, style: UIBlurEffectStyle) {
        view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        //comment line below to remove blue view
        view.insertSubview(blurEffectView, at: 0)
    }
    
    //hides the status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    

}

