//
//  ContentView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var chatConnectionManager = ChatConnectionManager()
    
    @State var showLoader: Bool = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "scannedDate", ascending: true)]
    ) var datasource: FetchedResults<ReceiptItem>
    
    var cacheManager: PersistenceController = .shared
    var docManager: DocumentManager = DocumentManager()
    
    @State var showScanner: Bool = false
    
    @State var detailItem: String? = nil
    @State var showDetail: Bool = false
    
    @AppStorage("user_init") var userInit: Bool = false
    
    var user: User!
    
    init() {
        if !userInit {
            user = User.save(User.getDeviceId, deviceName: User.deviceName, nickName: "")
            cacheManager.saveContext()
            userInit.toggle()
        } else {
            user = User.findFirst(predicate: NSPredicate(format: "id == %@", User.getDeviceId), type: User.self)
        }
    }
    
    var body: some View {
        ZStack {
            
            Group {
                NavigationLink("", isActive: $showDetail) {
                    LazyView(DetailView(cacheManager: cacheManager, receiptId: $detailItem))
                }
                
                NavigationLink(destination: ChatView().environmentObject(chatConnectionManager), isActive: $chatConnectionManager.connectedToChat) {
                    EmptyView()
                }
            }
            
            VStack {
                
                ScrollView {
                    ForEach(datasource, id: \.id) { item in
                        ListCell(item: item)
                            .onTapGesture {
                                detailItem = item.id.safeUnwrapped
                                showDetail = true
                            }
                    }
                }
                
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
            field.text = user.nickName.safeUnwrapped
        }
        
        alert.addAction(UIAlertAction(title: Constants.cancel, style: .cancel, handler: { _ in
            
        }))
        
        alert.addAction(UIAlertAction(title: Constants.save, style: .default, handler: { _ in
            if let field = alert.textFields?.first {
                user?.nickName = field.text.safeUnwrapped
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
