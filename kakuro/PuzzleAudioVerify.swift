//
//  PuzzleAudioVerify.swift
//  kakuro
//
//  Created by Mark Johnson on 5/2/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

struct SpeechCommand {
    let row: Int
    let col: Int
    let string: String
}

extension Puzzle {
    func audioVerify() -> [ SpeechCommand ] {
        var commands: [ SpeechCommand ] = []
        
        if nrows == 0 {
            commands.append( SpeechCommand( row: 0, col: 0, string: "Puzzle is empty." ) )
        } else {
            for col in 0 ..< ncols {
                commands.append( SpeechCommand( row: 0, col: col, string: "Column \(col+1)." ) )
                for row in 0 ..< nrows {
                    if col >= cells[row].count {
                        commands.append( SpeechCommand( row: row, col: col, string: "Missing." ) )
                    } else {
                        let cell = cells[row][col]
                        let string = cell.speechString
                        
                        commands.append( SpeechCommand( row: row, col: col, string: "\(string)." ) )
                    }
                }
            }
        }
        
        return commands
    }
}
