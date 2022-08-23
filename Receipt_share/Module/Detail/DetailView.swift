//
//  DetailView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI
import Combine

struct DetailView: View {
    @ObservedObject private var chatConnectionManager = ChatConnectionManager()

    let cacheManager: CacheManager
    @Binding var datasource: ReceiptItem?
    var docManager: DocumentManager = DocumentManager()
    
    var editedFields: [String: String] = [:]
    
    var body: some View {
        ZStack {
            
            NavigationLink(destination: ChatView().environmentObject(chatConnectionManager), isActive: $chatConnectionManager.connectedToChat) {
                EmptyView()
            }
            
            ScrollView(showsIndicators: false) {
                
                contructedView
                //overlayView
                    .toolbar {
                        Button(Constants.start) {
                            chatConnectionManager.host()
                        }
                    }
                
            }
            .navigationTitle(Constants.title)
            
        }
    }
    
    var contructedView: some View {
        VStack(spacing: 16) {
            if let datasource = datasource {
                ForEach(datasource.items) { item in
                    ColumView(data: item)
                        .onTapGesture {
                            editValueAlertTF(title: Constants.edit, message: Constants.message, colums: item, primaryTitle: Constants.save, secondaryTitle: Constants.cancel) { new in
                                editColumn(newValue: new, oldValue: item)
                            } secondaryAction: {}
                        }
                }
            }
            
            Spacer()
        }
    }
    
    struct ColumView: View {
        let data: Column
        
        var body: some View {
            HStack(spacing: 16) {
                
                ForEach(data.items) { item in
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary)
                        .font(.system(size: 14))
                        //.frame(width: item.displayRect!.width, height: item.displayRect!.height)
                        //.offset(x: item.displayRect!.xaxis, y: 0)
                }
                
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
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
    
    
    func editColumn(newValue: Column, oldValue: Column) {
        if var newDatasource = datasource, let index = newDatasource.items.firstIndex(of: oldValue) {
            newDatasource.items[index] = newValue
            cacheManager.replaceReceipt(newDatasource)
            
            self.datasource = newDatasource
        }
    }
}

extension DetailView {
    struct Constants {
        static let title = "Receipt"
        static let edit = "Edit"
        static let message = "Edit values for the field"
        static let save = "Save"
        static let cancel = "Cancel"
        static let start = "Start"
    }
}

extension View {
    func editValueAlertTF(title: String, message: String, colums: Column, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping (Column) -> (), secondaryAction: @escaping () -> ()) {
        var editableColumn = colums
        let editableItems = colums.items
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        editableItems.enumerated().forEach { item in
            alert.addTextField { field in
                field.placeholder = item.element.title
                field.tag = item.offset
                field.text = item.element.title
            }
        }
        
        alert.addAction(UIAlertAction(title: secondaryTitle, style: .cancel, handler: { _ in
            secondaryAction()
        }))
        
        alert.addAction(UIAlertAction(title: primaryTitle, style: .default, handler: { _ in
            if let fields = alert.textFields {
                let editedItems = fields.compactMap { field -> Item? in
                    guard var editItems = editableItems[safe: field.tag] else { return nil }
                    editItems.title = field.text ?? field.placeholder ?? ""
                    return editItems
                }
                editableColumn.items = editedItems
                primaryAction(editableColumn)
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

extension Array {
    subscript (safe index: Index) -> Element? {
        0 <= index && index < count ? self[index] : nil
    }
}
