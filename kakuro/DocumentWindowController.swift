//
//  DocumentWindowController.swift
//  kakuro
//
//  Created by Mark Johnson on 4/4/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Cocoa

class DocumentWindowController: NSWindowController {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }

    // Implement this method to handle any initialization after your
    // window controller's window has been loaded from its nib file.
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let window = window, let screen = window.screen {
            let offsetFromLeftOfScreen: CGFloat = 20
            let offsetFromTopOfScreen: CGFloat = 20
            let screenRect = screen.visibleFrame
            let newOriginY = screenRect.maxY - window.frame.height - offsetFromTopOfScreen

            window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
        }
    }
}
