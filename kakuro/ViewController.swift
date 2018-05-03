//
//  ViewController.swift
//  kakuro
//
//  Created by Mark Johnson on 4/4/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSWindowDelegate {
    @IBOutlet weak var imageView: NSImageView!
    
    var editingPuzzle = true
    var editingHorizontal = false
    var textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
    
    lazy var fieldEditor: TotalFieldEditor = {
        let editor = TotalFieldEditor(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
        
        editor.viewController = self
        return editor
    }()
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            view.needsDisplay = true
        }
    }
    
    
    // MARK: - Methods to handle user interface
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textField.isBordered = true
        
        if let puzzleView: PuzzleView = view as? PuzzleView {
            puzzleView.viewController = self
        }
    }

    func windowWillReturnFieldEditor(_ sender: NSWindow, to client: Any?) -> Any? {
        return editingPuzzle ? nil : fieldEditor
    }
    
    
    // MARK: - Methods for display
    
    func displayPuzzle() {
        if let puzzle = representedObject as! Puzzle? {
            if let image = puzzle.makeImage(editSelected: !editingPuzzle, editHorizontal: editingHorizontal) {
                let size = NSSize(width: image.width, height: image.height)
                
                view.window?.setContentSize(size)
                imageView.image = NSImage(cgImage: image, size: size)
            }
        }

    }
    
    func errorDialog(major: String, minor: String) {
        let alert = NSAlert()
        
        alert.messageText = major
        alert.informativeText = minor
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        
        alert.beginSheetModal(for: view.window!, completionHandler: nil)
    }
    

    // MARK: - Handle changing between Puzzle editing and Cell Editing
    
    func setupTotalEdit(horizontal: Bool) -> Bool {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.changeToHeader() {
                let header = puzzle.selectedCell as! HeaderCell
                let cellRect = puzzle.selectedRect()
                
                var editedValue = ""
                var textRect: CGRect
                
                view.needsDisplay = true
                editingPuzzle = false
                editingHorizontal = horizontal
                
                if horizontal {
                    textRect = puzzle.generator.getHorizontalRect()
                    
                    if let horz = header.horizontal {
                        editedValue = "\(horz)"
                    }
                } else {
                    textRect = puzzle.generator.getVerticalRect()
                    
                    if let vert = header.vertical {
                        editedValue = "\(vert)"
                    }
                }
                
                textRect = textRect.offsetBy(dx: cellRect.minX, dy: cellRect.minY)
                textField.frame = textRect
                textField.stringValue = editedValue
                textField.currentEditor()?.moveToEndOfLine(nil)
                view.addSubview(textField)
                textField.becomeFirstResponder()
                return true
            }
        }
        
        return false
    }
    
    func finishTotalEdit() {
        if let puzzle = representedObject as! Puzzle? {
            if let header = puzzle.selectedCell as? HeaderCell {
                let editedValue = textField.stringValue
                let value = editedValue == "" ? nil : Int(editedValue)
                
                if let numeric = value {
                    if numeric < 3 {
                        errorDialog(major: "Invalid total \(numeric)", minor: "Minimum total is 3")
                        return
                    } else if numeric > 45 {
                        errorDialog(major: "Invalid total \(numeric)", minor: "Maximum total is 45")
                        return
                    }
                }
                
                if editingHorizontal {
                    header.horizontal = value
                } else {
                    header.vertical = value
                }
                
                editingPuzzle = true
                textField.removeFromSuperview()
                view.becomeFirstResponder()
                view.window?.selectNextKeyView(view)
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }

    
    // MARK: - Methods to handle text input from the keyboard
    
    override func insertText(_ insertString: Any) {
        Swift.print("Insert string = '\(insertString)'")
        
        let string = (insertString as! String).lowercased()
        
        switch string {
        case "u":
            changeToUnused()
        case "e":
            changeToEmpty()
        case ".":
            changeToEmpty()
        case "h":
            changeToHeader(horizontal: true)
        case "v":
            changeToHeader(horizontal: false)
        case "0" ... "9":
            handleDigit(Int(string)!)
        default:
            NSSound.beep()
        }
    }
    
    func changeToUnused() {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.changeToUnused() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    func changeToEmpty() {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.changeToEmpty() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    func changeToHeader(horizontal: Bool) {
        if editingPuzzle {
            if setupTotalEdit(horizontal: horizontal) {
                return
            }
        } else {
            if editingHorizontal != horizontal {
                finishTotalEdit()
                if !editingPuzzle {
                    return
                }
                if setupTotalEdit(horizontal: horizontal) {
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    func handleDigit(_ digit: Int) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.appendCount( digit ) {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    
    // MARK: - Methods to handle keyboard commands
    
    override func doCommand(by selector: Selector) {
        Swift.print("Got command = '\(selector)'")
        super.doCommand(by: selector)
    }
    
    override func moveLeft(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveLeft() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func moveRight(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveRight() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func moveUp(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveUp() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func moveDown(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveDown() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToBeginningOfLine(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveToBeginningOfLine() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToEndOfLine(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveToEndOfLine() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToBeginningOfDocument(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveToBeginningOfDocument() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToEndOfDocument(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.moveToEndOfDocument() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func deleteBackward(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.deleteBackward() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func deleteForward(_ sender: Any?) {
        if editingPuzzle {
            if let puzzle = representedObject as! Puzzle? {
                if puzzle.deleteForward() {
                    view.needsDisplay = true
                    return
                }
            }
        }
        
        NSSound.beep()
    }
    
    override func insertBacktab(_ sender: Any?) {
        if !editingPuzzle {
            finishTotalEdit()
            if !editingPuzzle {
                return
            }
        }
        
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.insertBefore() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func insertTab(_ sender: Any?) {
        if !editingPuzzle {
            finishTotalEdit()
            if !editingPuzzle {
                return
            }
        }
        
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.advanceOrAppend() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func insertNewline(_ sender: Any?) {
        if !editingPuzzle {
            finishTotalEdit()
            if !editingPuzzle {
                return
            }
        }
        
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.newLine() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func insertLineBreak(_ sender: Any?) {
        if !editingPuzzle {
            finishTotalEdit()
            if !editingPuzzle {
                return
            }
        }
        
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.lineBreak() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()

    }
    
    override func cancelOperation(_ sender: Any?) {
        if !editingPuzzle {
            editingPuzzle = true
            view.needsDisplay = true
            textField.removeFromSuperview()
            view.becomeFirstResponder()
            view.window?.selectNextKeyView(view)
            return
        }
        
        NSSound.beep()
    }
}

