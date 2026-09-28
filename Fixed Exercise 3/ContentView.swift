//
//  ContentView.swift
//  Fixed Exercise 4
//
//  Created by Armin Assadzadeh on 28.09.26.
//

import SwiftUI

struct ContentView: View {
    @State private var networking = Networking()

    var body: some View {
        NavigationStack {
            LoginView(networking: networking)
        }
    }
}

#Preview {
    ContentView()
}
