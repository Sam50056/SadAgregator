//
//  SortirovkaViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 24.08.2021.
//

import UIKit
import AVFoundation
import RealmSwift
import FloatingPanel

class SortirovkaViewController: UIViewController {

    //    @IBOutlet weak var corneredView : OnlyCorneredView!
    
    private let realm = try! Realm()
    
    private var key : String = ""
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var qrCodeFrameView: UIView?
    
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
    
    var fpc: FloatingPanelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        
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
            
            //            view.bringSubviewToFront(closeButton)
            
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
}


//MARK: - AVCaptureMetadataOutputObjectsDelegate

extension SortirovkaViewController: AVCaptureMetadataOutputObjectsDelegate {
    
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
                
                QRScanQRDataManager().getQRScanQRData(key: "part_2_test", qr: "бМ") { [weak self] data, error in
                    
                    if let error = error , data == nil{
                        print("Error with QRScanQRDataManager : \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        guard data!["result"].intValue == 1 else {return}
                        
                        self?.captureSession.stopRunning()
                        
                        self?.fpc = FloatingPanelController()
                        
                        self?.fpc.delegate = self
                        
                        let contentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SortContentViewVC") as! SortirovkaContentViewController
                        
                        contentVC.data = data
                        
                        contentVC.view.backgroundColor = UIColor(named: "whiteblack")
                        
                        contentVC.closeButtonPressed = { [weak self] in
                            
                            self?.fpc.willMove(toParent: nil)
                            
                            self?.dismiss(animated: true){ [weak self] in
                                self?.qrCodeFrameView?.frame = .zero
                                self?.captureSession.startRunning()
                            }
                            
                        }
                        
                        self?.fpc.layout = MyFloatingPanelLayout()
                        
                        self?.fpc.set(contentViewController: contentVC)
                        
                        self?.fpc.isRemovalInteractionEnabled = false // Optional: Let it removable by a swipe-down
                        
                        // Create a new appearance.
                        let appearance = SurfaceAppearance()
                        
                        // Define shadows
                        let shadow = SurfaceAppearance.Shadow()
                        shadow.color = UIColor.black
                        shadow.offset = CGSize(width: 0, height: 16)
                        shadow.radius = 16
                        shadow.spread = 8
                        appearance.shadows = [shadow]
                        
                        // Define corner radius and background color
                        appearance.cornerRadius = 16
                        appearance.backgroundColor = .clear
                        
                        // Set the new appearance
                        self?.fpc.surfaceView.appearance = appearance
                        
                        self?.present(self!.fpc, animated: true, completion: nil)
                        
                        // Track a scroll view(or the siblings) in the content view controller.
                        self?.fpc.track(scrollView: contentVC.tableView)
                        
                    }
                    
                }
                
                print(qrValue)
                
            }
            
        }
        
    }
    
}

//MARK: - Data Manipulation Methods

extension SortirovkaViewController {
    
    func loadUserData (){
        
        let userDataObject = realm.objects(UserData.self)
        
        key = userDataObject.first!.key
        
    }
    
}

//MARK: - Floating Panel

class MyFloatingPanelLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    
    let initialState: FloatingPanelState = .tip
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 490, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 316, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
    
}

extension SortirovkaViewController : FloatingPanelControllerDelegate{
    
    func floatingPanelWillEndDragging(_ fpc: FloatingPanelController, withVelocity velocity: CGPoint, targetState: UnsafeMutablePointer<FloatingPanelState>) {
        
        if targetState.pointee == .tip {
            
            (fpc.children.first! as! SortirovkaContentViewController).state = 1
            
        }else if targetState.pointee == .half{
            
            (fpc.children.first! as! SortirovkaContentViewController).state = 2
            
            //            print("\((UIScreen.main.bounds.height - 64) * 0.65)")
            
        }else if targetState.pointee == .full{
            
            (fpc.children.first! as! SortirovkaContentViewController).state = 3
            
        }
        
    }
    
    
}
