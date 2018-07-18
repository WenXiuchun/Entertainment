//
//  ViewController.swift
//  SlotMachineiPad
//
//  Created by Gabriel, Jan on 20.07.16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var WebContainer: UIWebView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    
    var session:            AVCaptureSession?
    var stillImageOutput:   AVCaptureStillImageOutput?
    var videoPreviewLayer:  AVCaptureVideoPreviewLayer?
    var username: String = ""
    var appleID: String = ""
    
    // Added to support different barcodes
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    
    
    var backgroundMusicPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Listener -> Start Gambling !
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startGamblingNotification:", name: startGameKey, object: nil)
        
        // Show default slot machine
        self.gamblingDefault()
        
        playBackgroundMusic("sound.mp3")
        
    }
    
    // Handels the video preview and starts a session for image capturing
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        session                 = AVCaptureSession()
        session!.sessionPreset  = AVCaptureSessionPresetPhoto
        
        var captureDevice:AVCaptureDevice! = nil
        
        let backCamera = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in backCamera {
            
            let device = device as! AVCaptureDevice
            
            if device.position == AVCaptureDevicePosition.Front {
                
                captureDevice = device
                break
            }
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        
        do {
            
            input = try AVCaptureDeviceInput(device: captureDevice)
            
        } catch let error1 as NSError {
            
            error = error1
            input = nil
            print(error!.localizedDescription)
            
        }
        
        if error == nil && session!.canAddInput(input) {
            
            session!.addInput(input)
            stillImageOutput                    = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings    = [AVVideoCodecKey: AVVideoCodecJPEG]
            
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        if session!.canAddOutput(captureMetadataOutput) {
            session!.addOutput(captureMetadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        }
        
        
        if session!.canAddOutput(stillImageOutput) {
            
            session!.addOutput(stillImageOutput)
            
            videoPreviewLayer                               = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer!.videoGravity                 = AVLayerVideoGravityResizeAspect
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
            previewView.layer.addSublayer(videoPreviewLayer!)
            session!.startRunning()
            
        }
        
    }
    
    // Handles the video preview animation
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = previewView.bounds
        
    }
    
    func startGamblingNotification(notification: NSNotification) {
        
        let dict            = notification.object as! NSDictionary
        var gameResultWin   = dict["gameResultWin"] as! Bool
        var appleId         = dict["appleId"] as! String
        
        var urlParameter = ""
        
        if (gameResultWin == true){
            
            urlParameter = "?game=win&user=\(username)"
            
        } else {
            
            urlParameter = "?game=lose&user=\(username)"
            
        }
        
        var urlIndex    = NSBundle.mainBundle().pathForResource("web/index_win", ofType:"html")
        let requestURL  = NSURL(string: urlIndex!+urlParameter)
        let request     = NSURLRequest(URL: requestURL!)
        
        WebContainer.loadRequest(request)
        
        // To get instance of FaceEmotionRest and PubSubRest
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // wift completion handler, take picture of the player
        self.takePicture() {
            
            imageReturn in
            
            // swift completion handler, wait for emotion result
            appDelegate.faceEmotionRest.getFaceEmotion(imageReturn) {
                
                emotionReturn in
                
                // Send event with emotion to user
                appDelegate.pubSubRest.sendGameEndEvent(self.appleID, username: self.username, emotion: emotionReturn)
                
            }
            
        }
        
        // Reset - Show default slot machine
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                NSTimer.scheduledTimerWithTimeInterval(7, target: self, selector: "gamblingDefault", userInfo: nil, repeats: false)
                
            }
            
        }
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            print("No barcode/QR code is detected")
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedBarCodes.contains(metadataObj.type) {
            if metadataObj.stringValue != nil {
                
                // QR Code holds three information: AppleID;PlayerName;BeaconID
                let valueQR = metadataObj.stringValue.characters.split{$0 == ";"}.map(String.init)
                registerMachine(valueQR)
                
            }
        }
    }
    
    // Take a picture of the player
    func takePicture(imageReturn: (UIImage) -> ()) {
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                
                if sampleBuffer != nil {
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    // Preview picture on UI
                    self.captureImageView.image = image
                    
                    imageReturn(image)
                    
                }
                
            })
            
        }
        
    }
    
    
    
    // called, once QR Code is scanned
    // sets username on frontend and appleID as global variable
    // global variables appleID & username will be cleared, after every game played
    func registerMachine(credentials: [String]) {
        
        if(self.username != ""){
            // register the machine only once
            return
        }
        
        
        self.username = credentials[1]
        self.appleID = credentials[0]
        
        print("New user registered \(self.username) with ID \(self.appleID)")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.pubSubRest.sendGameRegisterEvent(self.appleID, username: self.username)
        appDelegate.pubSubRest.getEvents()
        
        var urlIndex    = NSBundle.mainBundle().pathForResource("web/index_win", ofType:"html")
        let requestURL  = NSURL(string: urlIndex!+"?game=shuffle&user="+self.username)
        let request     = NSURLRequest(URL: requestURL!)
        WebContainer.loadRequest(request)
        
    }
    
    // called, after view load
    // called, after every game has finished
    func gamblingDefault() {
        
        // reset global variables.
        self.username = ""
        self.appleID = ""
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.pubSubRest.stopEvents()
        
        var urlIndex    = NSBundle.mainBundle().pathForResource("web/index_win", ofType:"html")
        let requestURL  = NSURL(string: urlIndex!+"?game=shuffle&user=Welcome")
        let request     = NSURLRequest(URL: requestURL!)
        
        WebContainer.loadRequest(request)
        
    }
    
    // Lock oriontation - only allow portrait
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // Lock oriontation - only allow portrait
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func testrollDice(sender: AnyObject) {
        var myDict: [String:AnyObject] = [ "gameResultWin" : true, "appleId" : "Guest", "deviceId" : "local"]
        NSNotificationCenter.defaultCenter().postNotificationName(startGameKey, object: myDict)
    }
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
}
