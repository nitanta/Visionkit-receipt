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
}

extension MainView {
    struct Constants {
        static let title = "List"
        static let scan = "Scan"
        static let join = "Join"
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
