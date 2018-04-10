//
//  PuzzleView.swift
//  kakuro
//
//  Created by Mark Johnson on 4/9/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Cocoa

class PuzzleView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var acceptsFirstResponder: Bool { get { return true } }
    
    override func keyDown(with event: NSEvent) {
        Swift.print(event.keyCode, "=", event.characters as Any)
        interpretKeyEvents([event])
    }
}
