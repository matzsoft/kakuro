//
//  Document.swift
//  kakuro
//
//  Created by Mark Johnson on 4/4/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Cocoa

class Document: NSDocument, NSSpeechSynthesizerDelegate {
    var puzzle = Puzzle()
    var viewController: ViewController? = nil
    var isSpeaking = false
    var speechQueue: [ SpeechCommand ] = []
    var solver: PuzzleSolver?
    

    lazy var synthesizer: NSSpeechSynthesizer = {
        let synthesizer = NSSpeechSynthesizer()
        let voices = NSSpeechSynthesizer.availableVoices
        let desiredVoiceName = "com.apple.speech.synthesis.voice.Alex"
        let desiredVoice = NSSpeechSynthesizer.VoiceName(rawValue: desiredVoiceName)
        
        if let voice = voices.first(where: { $0 == desiredVoice } ) {
            synthesizer.setVoice(voice)
        }
        
        synthesizer.usesFeedbackWindow = true
        synthesizer.delegate = self
        return synthesizer
    }()
    
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
        switch item.action {
        case #selector(NSDocument.save(_:)), #selector(NSDocument.saveAs(_:)), #selector(Document.solvePuzzle(_:)):
            let validator = PuzzleValidator(with: puzzle)
            
            return validator.isValid
            
        case #selector(Document.audioVerify(_:)):
            return !isSpeaking

        default:
            return true
        }
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
    
    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        guard !speechQueue.isEmpty else {
            isSpeaking = false
            return
        }
        
        let command = speechQueue.removeFirst()
        
        if puzzle.moveTo(row: command.row, col: command.col) {
            viewController?.view.needsDisplay = true
        }
        
        sender.startSpeaking(command.string)
        isSpeaking = true
    }
    
    func stopSpeaking() -> Bool {
        speechQueue = []
        return isSpeaking
    }
    
    @IBAction func checkForErrors(_ sender: Any?) {
        let validator = PuzzleValidator(with: puzzle)
        
        if validator.isValid {
            viewController?.errorDialog(major: "Puzzle has no errors", minor: "")
        } else {
            let errors = validator.errors.joined(separator: "\n")
            
            viewController?.errorDialog(major: "Puzzle has errors", minor: errors)
        }
    }
    
    @IBAction func audioVerify(_ sender: Any?) {
        speechQueue = puzzle.audioVerify()
        speechSynthesizer(synthesizer, didFinishSpeaking: true)
    }
    
    @IBAction func solvePuzzle( _ sender: Any? ) {
        if solver == nil {
            solver = PuzzleSolver( with: puzzle )
        }
        
        DispatchQueue.global( qos: .userInitiated ).async {
            self.solverLoop( solver: self.solver! )
        }
    }
    
    func solverLoop( solver: PuzzleSolver ) -> Void {
        switch solver.step() {
        case .found:
            DispatchQueue.main.async {
                self.viewController?.view.needsDisplay = true
            }
            DispatchQueue.global( qos: .userInitiated ).async {
                self.solverLoop( solver: solver )
            }
        case .stuck:
            DispatchQueue.main.async {
                self.viewController?.errorDialog(major: "Solver is stuck", minor: "")
            }
        case .finished:
            DispatchQueue.main.async {
                self.viewController?.errorDialog(major: "Solver is finished", minor: "")
            }
        case .bogus:
            DispatchQueue.main.async {
                self.viewController?.errorDialog(major: "Solver says bogus", minor: "")
            }
        }
    }
}
