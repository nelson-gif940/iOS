//
//  ViewController.swift
//  TranslateWonder
//
//  Created by user192791 on 5/11/21.
//

// Import the different module necessary

import UIKit
import AVKit
import Vision
import CoreML

// Create the global variable of dictionnary

var dict_en = [String]()
var dict_it = [String]()
var dict_es = [String]()
var dict_jp = [String]()
var dict_fr = [String]()
var dict_array=[dict_it,dict_es,dict_fr,dict_jp]

// Create the global variable of language selection

var col=0

// Create the language array

let langArray = ["It : ","Es : ","Fr : ","Jp : "]

// Function to transform RGB Color to UIColor

class Helper{
    static func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0, blue: ((CGFloat)((rgbValue & 0x0000FF)))/255.0, alpha: 1.0)}
}
    
// Extension for gradient Button

extension UIButton {
        func applyGradient(colors: [CGColor]) {
            self.backgroundColor = nil
            self.layoutIfNeeded()
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.frame = self.bounds

            gradientLayer.shadowColor = UIColor.darkGray.cgColor
            gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
            gradientLayer.shadowRadius = 5.0
            gradientLayer.shadowOpacity = 0.3
            gradientLayer.masksToBounds = false

            self.layer.insertSublayer(gradientLayer, at: 0)
            self.contentVerticalAlignment = .center
            self.setTitleColor(UIColor.white, for: .normal)
            self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
            self.titleLabel?.textColor = UIColor.white
        }
        
        
    }
    

// Start View Controller

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override var prefersStatusBarHidden: Bool { return true }
    
    // UIButton : original english object name
    
    @IBOutlet weak var label: UIButton!
    
    // Translation
    
    @IBOutlet weak var label2: UIButton!
    
    // ViewDidLoad
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
      
        // Apply gradient to object description button
        
        self.label.applyGradient(colors: [Helper.UIColorFromRGB(0x242424).cgColor,Helper.UIColorFromRGB(0x787878).cgColor])
        
        // Apply gradient to translation button
        
        self.label2.applyGradient(colors: [Helper.UIColorFromRGB(0x787878).cgColor,Helper.UIColorFromRGB(0x242424).cgColor])
        
        // Take txt file and put in a string for each dictionnary
        
        do{
            guard let path = Bundle.main.path(forResource: "dict_en", ofType: "txt") else { return}
            var file = try String(contentsOfFile: path)
            dict_en = file.components(separatedBy: "\r\n")
        } catch { print("error")}
        
        do{
            guard let path = Bundle.main.path(forResource: "dict_fr", ofType: "txt") else { return}
            var file = try String(contentsOfFile: path)
            dict_fr = file.components(separatedBy: "\r\n")
        } catch { print("error")}
        
        do{
            guard let path = Bundle.main.path(forResource: "dict_jp", ofType: "txt") else { return}
            var file = try String(contentsOfFile: path)
            dict_jp = file.components(separatedBy: "\r\n")
        } catch { print("error")}
        
        do{
            guard let path = Bundle.main.path(forResource: "dict_es", ofType: "txt") else { return}
            var file = try String(contentsOfFile: path)
            dict_es = file.components(separatedBy: "\r\n")
        } catch { print("error")}
        
        do{
            guard let path = Bundle.main.path(forResource: "dict_it", ofType: "txt") else { return}
            var file = try String(contentsOfFile: path)
            dict_it = file.components(separatedBy: "\r\n")
        } catch { print("error")}
        
        // Background color set to black
        
        view.backgroundColor = .black
        
        // Capture session
        
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for:.video) else {return}
        
        guard let input = try? AVCaptureDeviceInput(device:captureDevice) else {return}
         
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
        
        view.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue"))
        captureSession.addOutput(dataOutput)
        
        // Addng buttons to view
        
        view.addSubview(label)
        
        label.setTitle("Started :)",for:.normal)
        
        view.addSubview(label2)
        
        label2.setTitle("Traduction",for:.normal)
        
    }
    
    // function to make the model work
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
            
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError()
            } //buffer of the video
    
        guard let model = try? VNCoreMLModel(for:Resnet50(configuration: MLModelConfiguration()).model) else {
            fatalError() }
        
        let request = VNCoreMLRequest(model:model){
            (finishedReq,err) in
            
            guard let results=finishedReq.results as? [VNClassificationObservation] else {
                return}
            
            guard let firstObservation = results.first else {return}
            
            var index_fin = dict_en.firstIndex(of: firstObservation.identifier)
            
            var dic = Array(dict_array[col])
            
            var index_fin_2 = String(dic[index_fin ?? 0])
            
            
            DispatchQueue.main.async{
                
                self.label.setTitle(firstObservation.identifier.uppercased(),for:.normal)
                
                self.label2.setTitle(langArray[col].uppercased()+index_fin_2.uppercased(),for:.normal)
                
            }
           
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer,options: [:]).perform( [request])
        
    }
    
    @IBAction func ChangeLang(_ sender: UIButton) {
    
            col=(col+1)%4
        
    }
    
}
    
    

