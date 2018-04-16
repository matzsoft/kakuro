//
//  PuzzleParser.swift
//  puzzle
//
//  Created by Mark Johnson on 3/3/16.
//  Copyright © 2016 Mark Johnson. All rights reserved.
//

import Foundation


class PuzzleParser {
    static let stateTable = [
        [   // state 0 - start of 1st line
            PuzzleLexType.space:     ( nextState:  0, action: [] ),
            PuzzleLexType.dash:      ( nextState:  1, action: [ addDash ] ),
        ],
        [   // state 1 - in opening dashes
            PuzzleLexType.space:     ( nextState:  1, action: [] ),
            PuzzleLexType.dash:      ( nextState:  1, action: [ addDash ] ),
            PuzzleLexType.number:    ( nextState:  2, action: [ vertical ] ),
        ],
        [   // state 2 - got 1st number
            PuzzleLexType.backSlash: ( nextState:  3, action: [] ),
        ],
        [   // state 3 - backslash after number
            PuzzleLexType.space:     ( nextState:  4, action: [] ),
            PuzzleLexType.dash:      ( nextState:  5, action: [ addDash ] ),
            PuzzleLexType.eol:       ( nextState:  6, action: [ newLine ] ),
        ],
        [   // state 4 - space after backslash
            PuzzleLexType.space:     ( nextState:  4, action: [] ),
            PuzzleLexType.dash:      ( nextState:  5, action: [ addDash ] ),
            PuzzleLexType.number:    ( nextState:  2, action: [ vertical ] ),
            PuzzleLexType.eol:       ( nextState:  6, action: [ newLine ] ),
        ],
        [   // state 5 - dashes after 1st number
            PuzzleLexType.space:     ( nextState:  5, action: [] ),
            PuzzleLexType.dash:      ( nextState:  5, action: [ addDash ] ),
            PuzzleLexType.number:    ( nextState:  2, action: [ vertical ] ),
            PuzzleLexType.eol:       ( nextState:  6, action: [ newLine ] ),
        ],
        [   // state 6 - start of 2nd line
            PuzzleLexType.space:     ( nextState:  6, action: [] ),
            PuzzleLexType.dash:      ( nextState:  7, action: [ addDash ] ),
            PuzzleLexType.backSlash: ( nextState:  8, action: [ noVertical ] ),
        ],
        [   // state 7 - line starts with dash
            PuzzleLexType.space:     ( nextState:  7, action: [] ),
            PuzzleLexType.dash:      ( nextState:  7, action: [ addDash ] ),
            PuzzleLexType.number:    ( nextState:  9, action: [ vertical ] ),
            PuzzleLexType.backSlash: ( nextState:  8, action: [ noVertical ] ),
        ],
        [   // state 8 - backslash must be followed by number
            PuzzleLexType.number:    ( nextState: 10, action: [ horizontal ] ),
        ],
        [   // state 9 - number must be followed by backslash
            PuzzleLexType.backSlash: ( nextState: 11, action: [] ),
        ],
        [   // state 10 - number after backslash must be followed by 2 dots
            PuzzleLexType.space:     ( nextState: 10, action: [] ),
            PuzzleLexType.dot:       ( nextState: 12, action: [ addDot ] ),
        ],
        [   // state 11 - backslash after number may be followed by number
            PuzzleLexType.space:     ( nextState: 13, action: [] ),
            PuzzleLexType.dash:      ( nextState: 13, action: [ addDash ] ),
            PuzzleLexType.number:    ( nextState: 10, action: [ horizontal ] ),
            PuzzleLexType.backSlash: ( nextState:  8, action: [ noVertical ] ),
            PuzzleLexType.eol:       ( nextState: 14, action: [ newLine ] ),
        ],
        [   // state 12 - backslash, number, dot needs at least one more dot
            PuzzleLexType.space:     ( nextState: 12, action: [] ),
            PuzzleLexType.dot:       ( nextState: 15, action: [ addDot ] ),
        ],
        [   // state 13 - after vertical only, any thing goes except dot
            PuzzleLexType.space:     ( nextState: 13, action: [] ),
            PuzzleLexType.dash:      ( nextState: 13, action: [ addDash ] ),
            PuzzleLexType.number:    ( nextState:  9, action: [ vertical ] ),
            PuzzleLexType.backSlash: ( nextState:  8, action: [ noVertical ] ),
            PuzzleLexType.eol:       ( nextState: 14, action: [ newLine ] ),
        ],
        [   // state 14 - start of 3rd and subsequent lines
            PuzzleLexType.space:     ( nextState:  6, action: [] ),
            PuzzleLexType.dash:      ( nextState:  7, action: [ addDash ] ),
            PuzzleLexType.backSlash: ( nextState:  8, action: [ noVertical ] ),
            PuzzleLexType.eoi:       ( nextState: -1, action: [] ),
        ],
        [   // state 15 - sufficient dots may be followed by anything
            PuzzleLexType.space:     ( nextState: 15, action: [] ),
            PuzzleLexType.dash:      ( nextState: 13, action: [ addDash ] ),
            PuzzleLexType.number:    ( nextState:  9, action: [ vertical ] ),
            PuzzleLexType.backSlash: ( nextState:  8, action: [ noVertical ] ),
            PuzzleLexType.dot:       ( nextState: 15, action: [ addDot ] ),
            PuzzleLexType.eol:       ( nextState: 14, action: [ newLine ] ),
        ],
    ]
    
    var lex: PuzzleLex
    var state = 0
    
    init ( text: String ) {
        lex = PuzzleLex( text: text )
    }
    
    
    
    func parse( _ puzzle: Puzzle ) -> Bool {
        parseLoop: while true {
            let symbol = lex.getNext()
            
            switch symbol {
            case .error:
                lex.invalidSymbol()
                return false
                
            case .eoi:
                break parseLoop
                
            default:
                let state_entry = PuzzleParser.stateTable[state]
                
                if let transition = state_entry[symbol] {
                    state = transition.nextState
                    for method in transition.action {
                        method(self)( puzzle )
                    }
                    
                } else {
                    lex.invalidSymbol()
                    return false
                }
            }
        }
        
        if PuzzleParser.stateTable[state][.eoi] == nil {
            return false
        }
        
        return true
    }
    
    
    
    func addDash( _ puzzle: Puzzle ) {
        puzzle.append( UnusedCell() )
    }
    
    
    
    func addDot( _ puzzle: Puzzle ) {
        puzzle.append( EmptyCell() )
    }
    
    
    
    func horizontal( _ puzzle: Puzzle ) {
        puzzle.setHorizontal( lex.getValue() )
    }
    
    
    
    func newLine( _ puzzle: Puzzle ) {
        puzzle.endRow()
    }
    
    
    
    func noVertical( _ puzzle: Puzzle ) {
        puzzle.append( HeaderCell( vertical: nil, horizontal: nil ) )
    }
    
    
    
    func vertical( _ puzzle: Puzzle ) {
        puzzle.append( HeaderCell( vertical: lex.getValue(), horizontal: nil ) )
    }
}
