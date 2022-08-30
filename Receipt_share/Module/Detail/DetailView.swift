//
//  DetailView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI
import Combine


struct DetailView: View {
    @EnvironmentObject var chatConnectionManager: ChatConnectionManager

    let cacheManager: PersistenceController
    @Binding var receiptId: String?
    var docManager: DocumentManager = DocumentManager()
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "key", ascending: true)]
    ) var datasource: FetchedResults<Column>
            
    var body: some View {
        ZStack {
            
            Group {
                NavigationLink("", isActive: $chatConnectionManager.connectedToChat) {
                    LazyView(SelectionView(cacheManager: cacheManager, roomId: $chatConnectionManager.roomId))
                }
            }
            
            HStack {
                
                contructedView
                //overlayView
                    .toolbar {
                        Button(Constants.start) {
                            setupRoomData()
                        }
                    }
                
            }
            .navigationTitle(Constants.title)
            .onAppear {
                datasource.nsPredicate = Column.columnPredicate(using: receiptId.safeUnwrapped)
            }
            
        }
    }
    
    var contructedView: some View {
        VStack(spacing: 16) {
            
            List(datasource, id: \.id) { item in
                ColumView(column: item)
                    .onTapGesture {
                        editValueAlertTF(title: Constants.edit, message: Constants.message, colums: item, primaryTitle: Constants.save, secondaryTitle: Constants.cancel) {
                            self.cacheManager.saveContext()
                        } secondaryAction: { }
                    }
                    .swipeActions {
                        Button {
                            self.delete(item)
                        } label: {
                            Label(Constants.delete, systemImage: "trash.slash")
                        }
                        .tint(.red)
                        
                        Button {
                            split(title: Constants.split, message: Constants.splitMessage, colums: item, primaryTitle: Constants.split, secondaryTitle: Constants.cancel) {
                                self.cacheManager.saveContext()
                            } secondaryAction: {}
                        } label: {
                            Label(Constants.split, systemImage: "rectangle.split.3x1")
                        }
                        .tint(.blue)

                    }
            }
            
            Spacer()
        }
    }
    
    var overlayView: some View {
        ZStack{
            if let image = docManager.loadImage(id: receiptId.safeUnwrapped) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                ForEach(datasource, id: \.id) { column in
                    ForEach(column.itemList as [Item], id: \.id) { value in
                        Rectangle()
                            .fill(.red.opacity(0.2))
                            .frame(width: CGFloat(value.displayRect!.width), height: CGFloat(value.displayRect!.height))
                            .offset(x: CGFloat(value.displayRect!.xaxis), y: CGFloat(value.displayRect!.yaxis))
                    }
                }
            }
        }
    }
    
    func delete(_ column: Column) {
        cacheManager.managedObjectContext.delete(column)
        cacheManager.saveContext()
    }
    
    func setupRoomData() {
        let room = Room.save(receiptId.safeUnwrapped)
        room.addSelections(datasource.map { $0 }, room: room)
        chatConnectionManager.host(receiptId.safeUnwrapped)
        if /*let receipt = ReceiptItem.getRecepeit(using: receiptId.safeUnwrapped),*/ let user = User.getMyUser() {
            //chatConnectionManager.sendReceiptInfo(receipt, user: user)
            chatConnectionManager.sendRoomInfo(room)
            chatConnectionManager.sendUserInfo(user)
        }
        cacheManager.saveContext()
    }
}

extension DetailView {
    struct Constants {
        static let title = "Receipt"
        static let edit = "Edit"
        static let message = "Edit values for the field"
        static let splitMessage = "Split columns"
        static let save = "Save"
        static let cancel = "Cancel"
        static let start = "Start"
        static let split = "Split"
        static let delete = "Delete"
    }
}

extension DetailView {
    func editValueAlertTF(title: String, message: String, colums: Column, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping () -> (), secondaryAction: @escaping () -> ()) {
        let editableItems = colums.itemList
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
                fields.forEach { field in
                    guard let editItems = editableItems[safe: field.tag] else { return }
                    editItems.title = field.text ?? field.placeholder ?? ""
                }
                primaryAction()
            }
        }))
        
        rootController().present(alert, animated: true)
    }
    
    func split(title: String, message: String, colums: Column, primaryTitle: String, secondaryTitle: String, primaryAction: @escaping () -> (), secondaryAction: @escaping () -> ()) {
        let editableItems = colums.itemList
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
                let newItems = fields.compactMap { field -> Item? in
                    guard let editedItem = editableItems[safe: field.tag] else { return nil }
                    return Item.copy(UUID().uuidString, title: field.text ?? field.placeholder ?? "", rect: editedItem.displayRect)
                }
                let column = Column.save(UUID().uuidString, key: Int(colums.key), items: newItems)
                column.receiptItem = colums.receiptItem
                primaryAction()
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
