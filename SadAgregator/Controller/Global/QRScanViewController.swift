//
//  QRScanViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 25.11.2021.
//

import UIKit
import AVFoundation

class QRScanViewController: UIViewController {
    
    var qrConnected : ((String) -> Void)?
    var willDis : (() -> Void)?
    var didDis : (() -> Void)?
    
    private var key = ""
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    
    private var closeButton : UIButton!
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton = UIButton()
        closeButton.setTitle("Закрыть", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeBarButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession.startRunning()
            
            view.bringSubviewToFront(closeButton)
            
            // Initialize QR Code Frame to highlight the QR Code
            qrCodeFrameView = UIView()
            
            if let qrcodeFrameView = qrCodeFrameView {
                qrcodeFrameView.layer.borderColor = UIColor.systemBlue.cgColor
                qrcodeFrameView.layer.borderWidth = 2
                
                qrCodeFrameView?.layer.cornerRadius = 8
                
                view.addSubview(qrcodeFrameView)
                view.bringSubviewToFront(qrcodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue anymore
            print(error)
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDis?()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDis?()
    }
    
    //MARK: - Actions
    
    @IBAction func closeBarButtonTapped(_ sender : Any){
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            print("No QR code is detected")
            return
        }
        
        // Get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let qrValue = metadataObj.stringValue {
                
                //Here we get the value that was in the scanned qr codr
                
                qrConnected?(qrValue)
                
                print(qrValue)
                
                captureSession.stopRunning()
                
            }
            
        }
        
    }
    
}
