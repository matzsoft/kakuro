//
//  Document.swift
//  kakuro
//
//  Created by Mark Johnson on 4/4/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    var puzzle = Puzzle()
    var viewController: ViewController? = nil

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
        puzzle.append( UnusedCell() )
        puzzle.append( HeaderCell(vertical: nil, horizontal: nil) )
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        
        let controller = windowController.contentViewController as! ViewController

        controller.representedObject = puzzle
        viewController = controller
    }
    
    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if ( item.action == #selector(NSDocument.save(_:)) ) {
            let validator = PuzzleValidator(with: puzzle)
            
            if !validator.isValid {
                let errors = validator.errors.joined(separator: "\n")
                
                viewController?.errorDialog(major: "Puzzle has errors", minor: errors)
                return false
            }
        }

        return true
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//        if let vc = self.windowControllers[0].contentViewController as? ViewController {
//            return vc.textView.string.data(using: String.Encoding.utf8) ?? Data()
//        }
//        else {
//            return Data()
//        }

        if let theData = puzzle.string.data(using: .utf8) {
            return theData
        }
        
        throw NSError(domain: NSCocoaErrorDomain, code: NSFormattingError, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        if let text = String(data: data, encoding: String.Encoding.utf8) {
            puzzle = Puzzle(text: text)!
        }
    }
}

