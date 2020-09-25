//
//  KeyboardResponder.swift
//  SimpleQrCode
//
//  Created by Martin Albrecht on 01.08.20.
//  Copyright © 2020 Martin Albrecht. All rights reserved.
//

import SwiftUI

final class KeyboardResponder: ObservableObject {
    @Published private(set) var currentHeight: CGFloat = 0
    
    private var notificationCenter: NotificationCenter

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self,
                                       selector: #selector(keyBoardWillShow(notification:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyBoardWillHide(notification:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = size.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

extension View {
    func keyboardResponsive(keyboard: KeyboardResponder) -> some View {
        self
            .padding(.bottom, keyboard.currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .animation(.easeOut(duration: 0.16))
    }
}
