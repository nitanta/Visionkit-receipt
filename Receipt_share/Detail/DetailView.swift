//
//  DetailView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI
import Combine

enum ColumnType {
    case title
    case address
    case vat
    case date
    case itemheader
    case itemcontent
    case grosstotal
    case discount
    case nettotal
    case footer
}

struct DetailView: View {
    let cacheManager: CacheManager
    @Binding var datasource: ReceiptItem?
    var docManager: DocumentManager = DocumentManager()
    
    var editedFields: [String: String] = [:]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            contructedView
            //overlayView
            
        }
        .navigationTitle(Constants.title)
    }
    
    var contructedView: some View {
        VStack(spacing: 16) {
            if let datasource = datasource {
                ForEach(datasource.items) { item in
                    ColumView(data: item)
                }
            }
            
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.white)
    }
    
    struct ColumView: View {
        let data: Column
        
        var body: some View {
            HStack(spacing: 16) {
                
                ForEach(data.items) { item in
                    Text(item.title)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        //.frame(width: item.displayRect!.width, height: item.displayRect!.height)
                        //.offset(x: item.displayRect!.xaxis, y: 0)
                        .onTapGesture {
                            alertTF(title: Constants.edit, message: Constants.message, hintText: "", value: item.title, primaryTitle: Constants.save, secondaryTitle: Constants.cancel) { newvalue in
                                
                                //self.editField(newValue: newvalue, item: item)
                                
                            } secondaryAction: {}
                        }
                }
                
                
            }
        }
    }
    
    var overlayView: some View {
        ZStack{
            if let datasource = datasource {
                if let image = docManager.loadImage(id: datasource.id) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    ForEach(datasource.items) { column in
                        ForEach(column.items) { item in
                            Rectangle()
                                .fill(.red.opacity(0.2))
                                .frame(width: item.displayRect!.width, height: item.displayRect!.height)
                                .offset(x: item.displayRect!.xaxis, y: item.displayRect!.yaxis)
                        }
                    }
                }
                
            }
        }
    }
    
    
//    func editField(newValue: String, item: Item) {
//        var newItem = item
//
//        newItem.title = newValue
//
//        if var newDatasource = datasource, let index = newDatasource.items.firstIndex(of: item) {
//            newDatasource.items[index] = newItem
//            cacheManager.replaceReceipt(newDatasource)
//        }
//    }
}

extension DetailView {
    struct Constants {
        static let title = "Receipt"
        static let edit = "Edit"
        static let message = "Edit values for the field"
        static let save = "Save"
        static let cancel = "Cancel"
    }
}

extension View {
    func alertTF(title: String, message: String, hintText: String, value: String, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping (String) -> (), secondaryAction: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = hintText
            field.text = value
        }
        
        alert.addAction(UIAlertAction(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
        }))
        
        alert.addAction(UIAlertAction(title: primaryTitle, style: .default, handler: { _ in
            if let text = alert.textFields?[0].text {
                primaryAction(text)
            }
        }))
        
        rootController().present(alert, animated: true)
    }
    
    func rootController() -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init() }
        guard let root = scene.windows.first?.rootViewController else { return .init() }
        return root
    }
}
