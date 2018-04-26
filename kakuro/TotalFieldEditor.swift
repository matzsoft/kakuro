//
//  TotalFieldEditor.swift
//  kakuro
//
//  Created by Mark Johnson on 4/23/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Cocoa

class TotalFieldEditor: NSTextView {
    var viewController: ViewController? = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var acceptsFirstResponder: Bool { get { return true } }
    
    override func keyDown(with event: NSEvent) {
        Swift.print(event.keyCode, "=", event.characters as Any, " (TextField)")
        interpretKeyEvents([event])
    }
    
    override func insertText(_ insertString: Any) {
        Swift.print("Insert string = '\(insertString)'")
        
        let string = (insertString as! String).lowercased()
        
        switch string {
        case "0" ... "9":
            super.insertText(insertString)
        default:
            viewController?.insertText(insertString)
        }
    }
    
    override func doCommand(by selector: Selector) {
        Swift.print("Got command = '\(selector)' (TextField)")
        super.doCommand(by: selector)
    }
    
    override func insertTab(_ sender: Any?) {
        viewController?.insertTab(sender)
    }
    
    override func insertNewline(_ sender: Any?) {
        viewController?.insertNewline(sender)
    }
    
    override func cancelOperation(_ sender: Any?) {
        viewController?.cancelOperation(sender)
    }
}
