//
//  Receipt_shareApp.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI

@main
struct Receipt_shareApp: App {
    let persistenceController = PersistenceController.shared
    @ObservedObject private var chatConnectionManager = ChatConnectionManager()

    init() {
       debugPrint("DB path: \(Helpers.getFilePath)")
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
            }
            .environment(\.managedObjectContext, persistenceController.managedObjectContext)
            .environmentObject(chatConnectionManager)
        }
    }
}
