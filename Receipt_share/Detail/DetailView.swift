//
//  DetailView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI

struct DetailView: View {
    @Binding var datasource: ReceiptItem?
    var docManager: DocumentManager = DocumentManager()
    
    var body: some View {
        ScrollView {
            
            ZStack{
                if let datasource = datasource {
                    if let image = docManager.loadImage(id: datasource.id) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        
                        ForEach(datasource.items) { item in
                            Rectangle()
                                .fill(.red.opacity(0.2))
                                .frame(width: item.displayRect!.width, height: item.displayRect!.height)
                                .offset(x: item.displayRect!.xaxis, y: item.displayRect!.yaxis)
                        }
                    }
                    
                }
            }
            
        }
        .navigationTitle(Constants.title)
    }
}

extension DetailView {
    struct Constants {
        static let title = "Receipt"
    }
}
