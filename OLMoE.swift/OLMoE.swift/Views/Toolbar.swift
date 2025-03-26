//
//  ToolBar.swift
//  OLMoE.swift
//
//  Created by Thomas Jones on 11/18/24.
//


import SwiftUI

<<<<<<< HEAD
struct AppToolbar<Leading: View, Trailing: View>: ToolbarContent {
    let leadingContent: Leading
    let trailingContent: Trailing

    init(
        @ViewBuilder leadingContent: () -> Leading = { EmptyView() },
        @ViewBuilder trailingContent: () -> Trailing = { EmptyView() }
    ) {
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
=======
struct AppToolbar<Content: View>: ToolbarContent {

    let leadingContent: Content

    init(
        @ViewBuilder leadingContent: () -> Leading = { EmptyView() },
        @ViewBuilder trailingContent: () -> Trailing = { EmptyView() }
    ) {
        self.leadingContent = leadingContent()
>>>>>>> 800cefc0 (Initial commit- Research was already conducted for more info refer to the research structure file)
    }

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            self.leadingContent
        }

        ToolbarItem(placement: .principal) {
            Image("Splash")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)  // Adjust size as needed
        }
<<<<<<< HEAD
        
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            self.trailingContent
        }
=======
>>>>>>> 800cefc0 (Initial commit- Research was already conducted for more info refer to the research structure file)
    }
}

