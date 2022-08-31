//
//  ContentView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var chatConnectionManager: ChatConnectionManager
    
    @State var showLoader: Bool = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "scannedDate", ascending: true)]
    ) var datasource: FetchedResults<ReceiptItem>
    
    @State private var refreshID = UUID()
    
    var cacheManager: PersistenceController = .shared
    var docManager: DocumentManager = DocumentManager()
    
    @State var showScanner: Bool = false
    
    @State var detailItem: String? = nil
    @State var showDetail: Bool = false
            
    init() {}
    
    func createMyUser() {
        _ = User.save(User.getDeviceId, deviceName: User.phoneName, nickName: "")
        cacheManager.saveContext()
    }
    
    private func makeDetailViewFetchRequest(receiptId: String) -> FetchRequest<Column> {
        let predicate: NSPredicate? = Column.columnPredicate(using: receiptId)
        return FetchRequest<Column>(
            entity: Column.entity(),
            sortDescriptors: [
                NSSortDescriptor(key: "key", ascending: true)
            ],
            predicate: predicate
        )
    }
    
    private func makeSelectionViewFetchRequest(roomId: String) -> FetchRequest<Selection> {
        let predicate: NSPredicate? = Selection.roomPredicate(using: roomId)
        return FetchRequest<Selection>(
            entity: Selection.entity(),
            sortDescriptors: [
                NSSortDescriptor(key: "column.key", ascending: true)
            ],
            predicate: predicate
        )
    }
    
    var body: some View {
        ZStack {
            
            Group {
                NavigationLink("", isActive: $showDetail) {
                    LazyView(DetailView(cacheManager: cacheManager, receiptId: $detailItem, fetchRequest: makeDetailViewFetchRequest(receiptId: detailItem.safeUnwrapped)))
                }
                
                NavigationLink("", isActive: $chatConnectionManager.connectedToChat) {
                    LazyView(SelectionView(cacheManager: cacheManager, roomId: $chatConnectionManager.roomId, fetchRequest: makeSelectionViewFetchRequest(roomId: chatConnectionManager.roomId.safeUnwrapped)))
                }
            }
            
            VStack {
                
                List(datasource, id: \.id) { item in
                    ListCell(item: item)
                        .onTapGesture {
                            detailItem = item.id.safeUnwrapped
                            showDetail = true
                        }
                }
                .id(refreshID)
                
                
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(Constants.scan) {
#if targetEnvironment(simulator)
                        let coordinator = ScannerController.Coordinator(loading: .constant(false), cacheManager: PersistenceController.shared, documentManager: DocumentManager(), parser: OtherParser())
                        coordinator.processImage(image: UIImage(named: "test_receipt")!)
#else
                        showScanner.toggle()
#endif
                    }
                    
                    Button(Constants.join) {
                        chatConnectionManager.join()
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        editNicknameAlertTF()
                    } label: {
                        Label(Constants.nickName, systemImage: "person.circle")
                    }
                    
                    Button(Constants.clear) {
                        clearData()
                    }
                }
            }
            
            if showLoader {
                ProgressView()
            }
        }
        .navigationTitle(Constants.title)
        .fullScreenCover(isPresented: $showScanner, content: {
            ScannerController(loading: $showScanner, mode: .other, cacheManager: cacheManager, docManager: docManager)
        })
    }
    
    struct ListCell: View {
        var item: ReceiptItem
        
        var body: some View {
            HStack {
                Text(item.scannedDate?.formatted(.dateTime) ?? String())
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding()
        }
    }
    
    func editNicknameAlertTF() {
        
        let alert = UIAlertController(title: Constants.change, message: "", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = Constants.nickName
            if let user = User.getMyUser() {
                field.text = user.nickName.safeUnwrapped
            }
        }
        
        alert.addAction(UIAlertAction(title: Constants.cancel, style: .cancel, handler: { _ in
            
        }))
        
        alert.addAction(UIAlertAction(title: Constants.save, style: .default, handler: { _ in
            if let field = alert.textFields?.first {
                guard let user = User.getMyUser() else { return }
                user.nickName = field.text.safeUnwrapped
                cacheManager.saveContext()
            }
        }))
        
        rootController().present(alert, animated: true)
    }
    
    func rootController() -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init() }
        guard let root = scene.windows.first?.rootViewController else { return .init() }
        return root
    }
    
    func clearData() {
        cacheManager.deleteData()
        cacheManager.saveContext()
                
        createMyUser()
        refreshID = UUID()
    }
}

extension MainView {
    struct Constants {
        static let title = "List"
        static let scan = "Scan"
        static let join = "Join"
        static let change = "Change nickname"
        static let save = "Save"
        static let cancel = "Cancel"
        static let nickName = "Nick name"
        static let clear = "Clear"
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
