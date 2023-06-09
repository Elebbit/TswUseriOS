//
//  DefaultButton.swift
//  TswUseriOS
//
//  Created by 최연택 on 2023/05/09.
//

import Combine
import SwiftUI

#if DEBUG
typealias DefaultButtonType = DebugButtonStyle
#else
typealias DefaultButtonType = ExampleButtonStyle
#endif

struct DebugButtonStyle: PrimitiveButtonStyle {
    let location: String

    func makeBody(configuration: Configuration) -> some View {
        Button {
            print("Button was pressed on line \(location)")
            configuration.trigger()
        } label: {
            configuration.label
        }
        .buttonStyle(ExampleButtonStyle())
    }

    init(file: String = #file, line: Int = #line) {
        location = "\(line) in \(file)"
    }
}

struct ExampleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct CancellableButtonStyle: PrimitiveButtonStyle {
    private struct CancellableButton: View {
        @State private var timerSubscription: Cancellable?
        @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
        @State private var countDown = 0

        let configuration: Configuration
        let timeOut: Int

        var body: some View {
            Button {
                debugPrint("onClick cancellation Button")
                if timerSubscription == nil {
                    timer = Timer.publish(every: 1, on: .main, in: .common)
                    timerSubscription = timer.connect()
                    countDown = timeOut
                } else {
                    cancelTimer()
                }
            } label: {
                if timerSubscription == nil {
                    configuration.label
                } else {
                    Text("Cancel? \(countDown)")
                }
            }
            .onReceive(timer) { _ in
                if countDown > 1 {
                    countDown -= 1
                } else {
                    configuration.trigger()
                    cancelTimer()
                }
            }
        }

        func cancelTimer() {
            timerSubscription?.cancel()
            timerSubscription = nil
        }
    }

    var timeOut = 3

    func makeBody(configuration: Configuration) -> some View {
        CancellableButton(configuration: configuration, timeOut: timeOut)
    }
}

