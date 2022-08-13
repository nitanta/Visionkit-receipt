//
//  DetailView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI

struct DetailView: View {
    @Binding var datasource: ReceiptItem?
    @State var scale: CGFloat = 1.0
    
    func getParentSize() -> CGSize {
        guard let ds = datasource else { return .zero }
        return ds.items.first!.parent
    }
    
    var body: some View {
        HStack {
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                
                if let datasource = datasource {
                    
                    ScannedReceipt(datasource: datasource.items)
                        .frame(width: getParentSize().width, height: getParentSize().height)
                        .scaleEffect(self.scale)
                        .frame(width: getParentSize().width * self.scale, height: getParentSize().height * self.scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged({ scale in
                                    self.scale = scale
                                })
                        )
                    
                }
                
            }
            .background(.white)
            .cornerRadius(4)
        }
        .navigationTitle(Constants.title)
    }
}

extension DetailView {
    struct Constants {
        static let title = "Receipt"
    }
}

struct ScannedReceipt: View {
    let datasource: [Item]
    var body: some View {
        ZStack {
            ForEach(datasource, id: \.id) { item in
                EditableField(title: item.title)
                    .frame(width: item.position.width, height: item.position.height)
                    .position(x: item.position.origin.x, y: item.position.origin.y)
                    .foregroundColor(.black)
            }
        }
    }
}

struct EditableField: View {
    var title: String
    @State var edit: Bool = false
    var body: some View {
        VStack {
            if edit {
                TextField("", text: .constant(title))
            } else {
                Text(title)
                    .onTapGesture {
                        edit.toggle()
                    }
            }
        }
        
    }
}
