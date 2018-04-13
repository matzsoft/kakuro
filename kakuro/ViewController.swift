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
            
            imageView.image = NSImage(cgImage: image!, size: size)
        }

    }
    override func insertText(_ insertString: Any) {
        Swift.print("Insert string = '\(insertString)'")
    }
    
    override func moveLeft(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveLeft() {
                view.needsDisplay = true
            }
        }
    }
    
    override func moveRight(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveRight() {
                view.needsDisplay = true
            }
        }
    }
    
    override func moveUp(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveUp() {
                view.needsDisplay = true
            }
        }
    }
    
    override func moveDown(_ sender: Any?) {
        if let puzzle = representedObject as! Puzzle? {
            if puzzle.moveDown() {
                view.needsDisplay = true
            }
        }
    }
}

