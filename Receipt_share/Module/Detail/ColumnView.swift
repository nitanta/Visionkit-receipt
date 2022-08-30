//
//  ColumnView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import SwiftUI

struct ColumView: View {
    let column: Column

    var body: some View {
        HStack(spacing: 16) {

            ForEach(column.itemList, id: \.id) { item in
                Text(item.title.safeUnwrapped)
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
