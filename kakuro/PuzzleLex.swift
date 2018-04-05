//
//  PuzzleLex.swift
//  puzzle
//
//  Created by Mark Johnson on 3/3/16.
//  Copyright © 2016 Mark Johnson. All rights reserved.
//

import Foundation
import Darwin



public enum PuzzleLexType {
    case dash
    case eol
    case backSlash
    case dot
    case space
    case number
    case eoi
    case error
}



enum PuzzleLexState {
    case initial
    case spaces
    case numbers
}



open class PuzzleLex {
    var line  = 0
    var col   = 0
    var state = PuzzleLexState.initial
    var value = 0
    var lines: [ String ]
    var savedLine = 0
    var savedCol = 0
    var savedChar: Character?
    
    public init( text: String ) {
        lines = text.split { $0 == "\n" }.map { "\($0)\n" }
    }
    
    
    
    open func getNext() -> PuzzleLexType {
        value = 0
        while true {
            switch state {
            case .initial:
                let char = currentCharacter()
                
                savePos()
                advance()
                switch char {
                case .none:                         return .eoi
                case .some( " " ):                  state = .spaces
                case .some( "-" ):                  return .dash
                case .some( "\n" ):                 return .eol
                case let c where "1"..."9" ~= c!:   state = .numbers; value = Int( String( char! ) )!
                case .some( "\\" ):                 return .backSlash
                case .some( "." ):                  return .dot
                default:                            return .error
                }
                
            case .spaces:
                let char = currentCharacter()
                
                switch char {
                case .some( " " ):  advance()
                default:            state = .initial; return .space
                }
                
            case .numbers:
                let char = currentCharacter()
                
                switch char {
                case let c where "0"..."9" ~= c!:
                    state = .initial
                    advance()
                    value = 10 * value + Int( String( char! ) )!
                    return .number
                    
                default:
                    state = .initial
                    return .number
                }
            }
        }
    }
    
    
    
    open func getValue() -> Int {
        return value
    }
    
    
    
    func savePos() {
        savedLine = line;
        savedCol  = col;
        savedChar = currentCharacter()
    }
    
    
    
    func advance() {
        if let _ = currentCharacter() {
            col += 1
            if col >= lines[line].count {
                line += 1
                col = 0
            }
        }
    }
    
    
    
    func currentCharacter() -> Character? {
        if line >= lines.count {
            return nil
        }
        
        let index = lines[line].index(lines[line].startIndex, offsetBy: col);
        
        return lines[line][index]
    }
    
    

    open func invalidSymbol() {
        var char = savedChar;
        let row  = savedLine + 1;
        let col  = savedCol + 1;
        
        if char == nil {
            char = "?"
        }
        
        fputs( "Ignoring invalid character '\(String(describing: char))' at row \(row), column \(col).\n", stderr )
    }
}
