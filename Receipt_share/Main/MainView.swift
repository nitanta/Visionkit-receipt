//
//  ContentView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI

struct MainView: View {
    @State var showLoader: Bool = false
    @State var datasource: [ReceiptItem] = []
    
    var cacheManager: CacheManager = CacheManager()
    var docManager: DocumentManager = DocumentManager()

    @State var showScanner: Bool = false
    
    @State var detailItem: ReceiptItem? = nil
    @State var showDetail: Bool = false
        
    var body: some View {
        ZStack {
            
            Text("")
                .onAppear {
                    cacheManager.reload = {
                        self.datasource = cacheManager.loadRecceiptList()
                    }
                }
            
            Group {
                NavigationLink("", isActive: $showDetail) {
                    LazyView(DetailView(cacheManager: cacheManager, datasource: $detailItem))
                }
                
            }
            
            VStack {
                
                ScrollView {
                    ForEach(datasource, id: \.id) { item in
                        ListCell(item: item)
                            .onTapGesture {
                                detailItem = item
                                showDetail = true
                            }
                    }
                }
                
            }
            .toolbar {
                Button(Constants.scan) {
                    showScanner.toggle()
                }
            }
            
            if showLoader {
                ProgressView()
            }
        }
        .onAppear {
            self.datasource = cacheManager.loadRecceiptList()
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
                Text(item.scannedDate.formatted(.dateTime))
                    .foregroundColor(.primary)
                
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
