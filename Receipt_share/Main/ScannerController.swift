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
    let docManager: DocumentManager
    
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
        Coordinator(loading: $loading, cacheManager: cacheManager, documentManager: docManager, parser: getScanner())
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Binding var loading: Bool
        let cacheManager: CacheManager
        let docManager: DocumentManager
        let parser: ScannedDataParseable
        var textRecognitionRequest = VNRecognizeTextRequest()
        
        var referenceImageSize: CGSize = .zero
        var referenceImage: UIImage? = nil
        
        init(loading: Binding<Bool>, cacheManager: CacheManager, documentManager: DocumentManager, parser: ScannedDataParseable) {
            _loading = loading
            self.cacheManager = cacheManager
            self.docManager = documentManager
            self.parser = parser
            super.init()
            
            setupRecognition()
        }
        
        func setupRecognition() {
            textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
                if let results = request.results, !results.isEmpty {
                    if let requestResults = request.results as? [VNRecognizedTextObservation] {
                        DispatchQueue.main.async {
                            if let referenceImage = self.referenceImage {
                                let result = self.parser.generateDatasource(recognizedText: requestResults, image: referenceImage)
                                let receipt = ReceiptItem(id: UUID().uuidString, scannedDate: Date(), items: result)
                                self.docManager.saveImage(image: referenceImage, id: receipt.id)
                                self.cacheManager.addReceipt(receipt)
                            }
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
                referenceImage = image
                try handler.perform([textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }

}

protocol ScannedDataParseable {
    func generateDatasource(recognizedText: [VNRecognizedTextObservation], image: UIImage) -> [Column]
}

class OtherParser: ScannedDataParseable {
    
    var filterOutCharacterSets: [String]  = [":", "..", "#", "*", "-", "_"]

    func generateDatasource(recognizedText: [VNRecognizedTextObservation], image: UIImage) -> [Column] {
        let maximumCandidates = 1
  
        let items = recognizedText.compactMap { observation -> Item? in
            guard let candidate = observation.topCandidates(maximumCandidates).first else { return nil }
                        
            return Item(title: candidate.string, observation: candidate, image: image)
        }
        
        let grouped = Dictionary(grouping: items) { (device) -> Int in
            return Int((device.displayRect?.yaxis ?? 0) / 20)
        }
        
        let columns = grouped.map {
            Column(id: $0.key, items: $0.value.filter { !filterOutCharacterSets.contains($0.title) }.sorted { $0.displayRect?.xaxis ?? 0 < $1.displayRect?.xaxis ?? 0 })
        }.sorted { col1, col2 in
            return col1.id < col2.id
        }
        
        let amountColumsn = columns.filter { column in
            if let lastItem = column.items.last {
                let amount = Float(lastItem.title)
                return amount != nil
            }
            return false
        }
                
        debugPrint("***************************")
        debugPrint(columns)
        debugPrint("***************************")

        return amountColumsn
    }
}
