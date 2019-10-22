//
//  ContentView.swift
//  IntervalTimer WatchKit Extension
//
//  Created by Evan Deaubl on 10/21/19.
//  Copyright © 2019 Tic Tac Code, LLC. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var timer = MyTimer()
    
    var body: some View {
        VStack {
            Spacer()
            Text(String(timer.state))
            Spacer()
            HStack {
                if (timer.running) {
                    Button(action: {self.timer.stop()}) {
                        Text("Stop")
                    }.foregroundColor(.red)
                }
                else {
                    Button(action: {self.timer.start()}) {
                        Text("Start")
                    }.foregroundColor(.green)
                }
            }.padding(.horizontal, 10)
        }.edgesIgnoringSafeArea(.bottom)
    }
}

class MyTimer: ObservableObject {
    @Published var state = "Off"
    @Published var running = false
    
    var extendedRuntimeSession: WKExtendedRuntimeSession?
    
    // TODO not quite right
    var workTimerChain = Timer.publish(every: 37.5, tolerance: 0.05, on: .main, in: .common).autoconnect()
    var restTimerChain = Timer.publish(every: 37.5, tolerance: 0.05, on: .main, in: .common).autoconnect().delay(for: 7.5, scheduler: RunLoop.main).makeConnectable().autoconnect()

    var cancellable: Cancellable?
    var cancellable2: Cancellable?

    func start() {
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.start()
        state = "Work"
        running = true
        WKInterfaceDevice.current().play(.start)
        cancellable = workTimerChain.sink(receiveCompletion: {_ in}, receiveValue: {_ in self.state = "Rest" ; WKInterfaceDevice.current().play(.stop)})
        cancellable2 = restTimerChain.sink(receiveCompletion: {_ in}, receiveValue: {_ in self.state = "Work" ; WKInterfaceDevice.current().play(.start)})
    }
    
    func stop() {
        extendedRuntimeSession?.invalidate()
        extendedRuntimeSession = nil
        WKInterfaceDevice.current().play(.stop)
        running = false
        cancellable?.cancel()
        cancellable2?.cancel()
        state = "Off"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
