//
//  ContentView.swift
//  Shared
//
//  Created by SUPRISUL on 15/07/22.
//

import SwiftUI

struct ContentView: View
{
    @StateObject private var viewModel = ContentViewPresenter()
    
    var body: some View {
        NavigationView {
            if (viewModel.visibleDevices.count == 0) {
                HStack(alignment: .center) {
                    Text("No itens to display").font(.system(size: 17)).bold()
                }
            } else {
                List(viewModel.visibleDevices) { device in
                    ReachableDeviceView(device: device,
                                        unlockAction: viewModel.unlockTapped(device:))
                }.overlay {
                    if viewModel.isUnlocking {
                      ProgressView("Trying to Unlock Device, please wait.")
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    }
                }.animation(.default)
                .navigationTitle("Visible Devices")
            }
        }.onAppear(perform: viewModel.onAppear)
            .onDisappear(perform: viewModel.onDisappear)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
