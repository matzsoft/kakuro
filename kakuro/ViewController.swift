//
//  ViewController.swift
//  kakuro
//
//  Created by Mark Johnson on 4/4/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let puzzleView: PuzzleView = view as? PuzzleView {            
            puzzleView.viewController = self
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            view.needsDisplay = true
        }
    }
    
    func displayPuzzle() {
        if let puzzle = representedObject as! Puzzle? {
            let image = puzzle.makeImage()
            let size = NSSize(width: (image?.width)!, height: (image?.height)!)
            
            view.window?.setContentSize(size)
            imageView.image = NSImage(cgImage: image!, size: size)
        }

    }
    
    override func insertText(_ insertString: Any) {
        Swift.print("Insert string = '\(insertString)'")
    }
    
    override func doCommand(by selector: Selector) {
        Swift.print("Got command = '\(selector)'")
        super.doCommand(by: selector)
    }
    
    override func moveLeft(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveLeft() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func moveRight(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveRight() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func moveUp(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveUp() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func moveDown(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveDown() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToBeginningOfLine(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveToBeginningOfLine() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToEndOfLine(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveToEndOfLine() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToBeginningOfDocument(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveToBeginningOfDocument() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func moveToEndOfDocument(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveToEndOfDocument() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func insertTab(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.newCells(1) {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
    
    override func insertNewline(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.newLine() {
                view.needsDisplay = true
                return
            }
        }
        
        NSSound.beep()
    }
}

