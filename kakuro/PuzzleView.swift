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
        if event.modifierFlags.contains(.command) {
            nextResponder?.keyDown(with: event)
        } else {
            interpretKeyEvents([event])
        }
    }
    
    override func insertText(_ insertString: Any) {
        Swift.print("Insert string = '\(insertString)'")
    }
    
    override func doCommand(by selector: Selector) {
        Swift.print("Do command = '\(selector)'")
    }
    
    override func moveRight(_ sender: Any?) {
        Swift.print("Got move right")
    }
}
