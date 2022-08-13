//
//  ScannerController.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import UIKit
import VisionKit
import Vision
import SwiftUI
import Combine

struct ScannerController: UIViewControllerRepresentable {
    static let textHeightThreshold: CGFloat = 0.025

    enum ScanMode {
        case receipt
        case businesscard
        case other
    }
    
    @Binding var loading: Bool
    var mode: ScanMode
    let cacheManager: CacheManager
    
    func getScanner() -> ScannedDataParseable {
        return OtherParser()
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        uiViewController.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(loading: $loading, cacheManager: cacheManager, parser: getScanner())
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var loading: Bool
        let cacheManager: CacheManager
        let parser: ScannedDataParseable
        var textRecognitionRequest = VNRecognizeTextRequest()
        
        var referenceImageSize: CGSize = .zero
        
        init(loading: Binding<Bool>, cacheManager: CacheManager, parser: ScannedDataParseable) {
            _loading = loading
            self.cacheManager = cacheManager
            self.parser = parser
            super.init()
            
            setupRecognition()
        }
        
        func setupRecognition() {
            textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
                if let results = request.results, !results.isEmpty {
                    if let requestResults = request.results as? [VNRecognizedTextObservation] {
                        DispatchQueue.main.async {
                            let result = self.parser.generateDatasource(recognizedText: requestResults, referenceSize: self.referenceImageSize)
                            self.cacheManager.addReceipt(ReceiptItem(scannedDate: Date(), items: result))
                        }
                    }
                }
            })
            // This doesn't require OCR on a live camera feed, select accurate for more accurate results.
            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.usesLanguageCorrection = true
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            self.loading = true
            controller.dismiss(animated: true) {
                DispatchQueue.global(qos: .userInitiated).async {
                    for pageNumber in 0 ..< scan.pageCount {
                        let image = scan.imageOfPage(at: pageNumber)
                        self.processImage(image: image)
                    }
                    DispatchQueue.main.async {
                        self.loading = false
                    }
                }
            }
        }
        
        func processImage(image: UIImage) {
            guard let cgImage = image.cgImage else {
                print("Failed to get cgimage from input image")
                return
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                referenceImageSize = image.size
                try handler.perform([textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }

}

protocol ScannedDataParseable {
    func generateDatasource(recognizedText: [VNRecognizedTextObservation], referenceSize: CGSize) -> [Item]
}

class OtherParser: ScannedDataParseable {

    func generateDatasource(recognizedText: [VNRecognizedTextObservation], referenceSize: CGSize) -> [Item] {
        let maximumCandidates = 1
  
        let items = recognizedText.compactMap { observation -> Item? in
            guard let candidate = observation.topCandidates(maximumCandidates).first else { return nil }
            return Item(title: candidate.string, boundingBox: observation.boundingBox, parentSize: referenceSize)
        }
        debugPrint("***************************")
        items.forEach { item in
            debugPrint(item.description)
        }
        debugPrint("***************************")
        return items
    }
}
