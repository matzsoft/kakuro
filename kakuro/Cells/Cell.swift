//
//  Cell.swift
//  kakuro
//
//  Created by Mark Johnson on 4/15/18.
//  Copyright © 2018 matzsoft. All rights reserved.
//

import Foundation

protocol Cell {
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage
    var string: String { get }
    var speechString: String { get }
}


class UnusedCell: Cell {
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage {
        return selected ? generator.SelectUnused : generator.NormalUnused
    }
    
    var string: String {
        return "  -  "
    }
    
    var speechString: String {
        return "Unused"
    }
}


class EmptyCell: Cell {
    var eligible = Set<Int>( 1 ... 9 )
    weak var vertical: HeaderCell? = nil
    weak var horizontal: HeaderCell? = nil
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage {
        return selected ? generator.SelectEmpty : generator.NormalEmpty
    }
    
    var string: String {
        return "  .  "
    }
    
    var speechString: String {
        return "Empty"
    }
}


struct HeaderSum {
    var total: Int
    var cells: [ EmptyCell ]
    var eligible: Set<Int>
    var possibles: [ Set<Int> ]
    
    init(total: Int) {
        self.total = total
        cells = []
        eligible = Set<Int>( 1 ... 9 )
        possibles = []
    }
    
    mutating func setCells(cells: [EmptyCell]) {
        self.cells = cells
        eligible = Set<Int>( 1 ... 9 )
        possibles = possibilities(total: total, number: cells.count, available: eligible)
        eligible = possibles.reduce(eligible, { ( s1: Set<Int>, s2: Set<Int> ) -> Set<Int> in
            s1.intersection(s2)
        } )
    }
}


class HeaderCell: Cell {
    enum SelectType {
        case none
        case vertical
        case horizontal
        case both
    }
    
    var vertical: HeaderSum?
    var horizontal: HeaderSum?
    
    init( vertical: Int?, horizontal: Int? ) {
        if let total = vertical {
            self.vertical = HeaderSum(total: total)
        } else {
            self.vertical = nil
        }
        
        if let total = horizontal {
            self.horizontal = HeaderSum(total: total)
        } else {
            self.horizontal = nil
        }
    }
    
    func setVertical( _ vertical: Int? ) {
        if let total = vertical {
            self.vertical = HeaderSum(total: total)
        } else {
            self.vertical = nil
        }
    }
    
    func setHorizontal( _ horizontal: Int? ) {
        if let total = horizontal {
            self.horizontal = HeaderSum(total: total)
        } else {
            self.horizontal = nil
        }
    }
    
    func hasNoTotal() -> Bool {
        return vertical == nil && horizontal == nil
    }
    
    func draw( generator: cellImageGenerator, selected: Bool ) -> CGImage {
        if selected {
            return draw( generator: generator, selectType: .both )
        } else {
            return draw( generator: generator, selectType: .none )
        }
    }
    
    func draw( generator: cellImageGenerator, selectType type: SelectType ) -> CGImage {
        var image: CGImage
        
        switch type {
        case .none:
            image = generator.NormalHeader
        case .vertical:
            image = generator.SelectVertical
        case .horizontal:
            image = generator.SelectHorizontal
        case .both:
            image = generator.SelectBoth
        }
        
        if let vert = vertical {
            image = generator.labelVertical(image: image, text: String(vert.total))
        }
        
        if let horz = horizontal {
            image = generator.labelHorizontal(image: image, text: String(horz.total))
        }
        
        return image
    }
    
    var string: String {
        var front = "  "
        var back  = "  "
        
        if let vert = vertical {
            front = String(format: "%2d", arguments: [vert.total])
        }
        
        if let horz = horizontal {
            back = String(format: "%-2d", arguments: [horz.total])
        }

        return "\(front)\\\(back)"
    }
    
    var speechString: String {
        var front = ""
        var back  = ""
        
        if let vert = vertical {
            front = ", down \(vert.total)"
        }
        
        if let horz = horizontal {
            back = ", right \(horz.total)"
        }
        
        return "Header\(front)\(back)"
    }
}


func possibilities(total: Int, number: Int, available: Set<Int>) -> Array<Set<Int>> {
    var results = Array<Set<Int>>()
    
    if number == 1 {
        if available.contains(total) {
            results.append([total])
        }
        
    } else {
        let limit = total / ( number - 1 )
        var eligible = available
        
        while !eligible.isEmpty {
            let trial = eligible.min()!
            
            if trial >= limit { break }
            
            eligible.remove(trial)
            
            let possibles = possibilities(total: total - trial, number: number - 1, available: eligible)
            
            results.append( contentsOf: possibles.map { $0.union( [trial] ) } )
        }
    }
    
    return results
}
