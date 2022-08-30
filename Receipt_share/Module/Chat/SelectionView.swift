//
//  SelectionView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import SwiftUI

struct SelectionView: View {
    @EnvironmentObject var chatConnectionManager: ChatConnectionManager
    
    let cacheManager: PersistenceController
    @Binding var roomId: String?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "column.key", ascending: true)]
    ) var datasource: FetchedResults<Selection>
    
    var body: some View {
        VStack {
            chatInfoView
            
            splitDataView
            
            Spacer()
        }
        .navigationBarTitle(Constants.title, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(Constants.leave) {
                    chatConnectionManager.leaveChat()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            datasource.nsPredicate = Selection.roomPredicate(using: roomId.safeUnwrapped)
        }
    }
    
    private var chatInfoView: some View {
        VStack(alignment: .leading) {
            Divider()
            HStack {
                Text(Constants.members)
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.headline)
                if chatConnectionManager.peers.isEmpty {
                    Text(Constants.empty)
                        .font(Font.caption.italic())
                        .foregroundColor(.gray)
                } else {
                    chatParticipants
                }
            }
            .padding(.top, 8)
            .padding(.leading, 16)
            Divider()
        }
        .frame(height: 44)
    }
    
    private var chatParticipants: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(chatConnectionManager.peers, id: \.self) { peer in
                    Text(peer.displayName)
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 6)
                        .background(.green)
                        .foregroundColor(.gray)
                        .font(Font.body.bold())
                        .cornerRadius(9)
                }
            }
        }
    }
    
    
    var splitDataView: some View {
        VStack(spacing: 16) {
            
            List(datasource, id: \.id) { item in
                OverlayColumnCell(selection: item)
                    .onTapGesture {
                        
                    }
            }
            
            Spacer()
        }
    }
    
    struct OverlayColumnCell: View {
        let selection: Selection
        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                if let column = selection.column {
                    ColumView(column: column)
                }

                if let user = selection.user {
                    HStack {
                        Text("Selected by: \(user.nickName.safeUnwrapped)")
                            .italic()
                            .font(.caption2)
                            .foregroundColor(.black)
                    }
                    .background(.gray.opacity(0.15))
                }
            }
        }
    }
}

extension SelectionView {
    struct Constants {
        static let members = "Members:"
        static let title = "Split"
        static let empty = "Empty"
        static let leave = "Leave"
    }
}
