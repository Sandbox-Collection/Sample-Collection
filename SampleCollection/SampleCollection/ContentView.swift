//
//  ContentView.swift
//  SampleCollection
//
//  Created by 이재훈 on 7/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("LocalAuthentication") {
                    LocalAuthenticationView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
