//
//  ViewController.swift
//  ARKit-Transform-Recorder
//
//  Created by Illo Yoon on 2023/05/02.
//

import UIKit
import ARKit


enum Status{
    case READY
    case RECORD
}

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var controlButton: UIButton!
    
    var transforms: [matrix_float4x4] = []
    
    var status: Status = .READY{
        didSet{
            switch(status){
            case .READY:
                controlButton.setTitle("Record", for: .normal)
                break
            case .RECORD:
                controlButton.setTitle("Stop", for: .normal)
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.debugOptions = .showWorldOrigin
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    
    func saveToFile(){
        
//        guard let fileManager = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
//            // iCloud is not available
//            return
//        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            for index in 0...100{
                let filename = String(format: "transforms_%03d.txt", index)
//                let fileURL = fileManager.appendingPathComponent(filename)
                let fileURL = dir.appendingPathComponent(filename)
                if !FileManager.default.fileExists(atPath: fileURL.path){
                    var text = ""
                    for t in self.transforms{
                        let line = String(format: "%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f ", t.columns.0.x, t.columns.1.x, t.columns.2.x, t.columns.3.x,t.columns.0.y, t.columns.1.y, t.columns.2.y, t.columns.3.y,t.columns.0.z, t.columns.1.z, t.columns.2.z, t.columns.3.z,t.columns.0.w, t.columns.1.w, t.columns.2.w, t.columns.3.w)
                        text += line + "\n"
                    }
                    
                    
                    do {
                        try text.write(to: fileURL, atomically: false, encoding: .utf8)
                    }
                    catch {
                        print("Error writing to file: \(error)")
                    }
                    break
                }
            }
        }
    }
    
    @IBAction func tapControllButton(_ sender: Any) {
        switch(self.status){
        case .READY:
            self.status = .RECORD
            self.transforms = []
            self.transforms.reserveCapacity(60*60*5) // 5 Minutes
            
            self.sceneView.scene.rootNode.enumerateChildNodes{ (node, stop) in
                if node.name == "trace"{
                    node.removeFromParentNode()
                }
            }
            
            break
        case .RECORD:
            self.status = .READY
            self.saveToFile()
            break
        }
    }
}

extension ViewController: ARSessionDelegate{
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        DispatchQueue.main.async {
            if self.status == .RECORD{
                let t = frame.camera.transform
                self.transforms.append(t)
                
                let node = SCNNode()
                node.geometry = SCNSphere(radius: 0.01)
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                node.simdTransform = t
                node.name = "trace"
                self.sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }
    
}

