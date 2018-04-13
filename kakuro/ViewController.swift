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
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            if let puzzle = representedObject as! Puzzle? {
                let image = puzzle.makeImage()
                let size = NSSize(width: (image?.width)!, height: (image?.height)!)
                
                imageView.image = NSImage(cgImage: image!, size: size)
            }
        }
    }
    
    override func insertText(_ insertString: Any) {
        Swift.print("Insert string = '\(insertString)'")
    }
    
    override func moveLeft(_ sender: Any?) {
        Swift.print("Got move left")
    }
    
    override func moveRight(_ sender: Any?) {
        Swift.print("Got move right")
    }
    
    override func moveUp(_ sender: Any?) {
        Swift.print("Got move up")
    }
    
    override func moveDown(_ sender: Any?) {
        Swift.print("Got move down")
    }
}

