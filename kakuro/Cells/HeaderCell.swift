//
//  HeaderCell.swift
//  kakuro
//
//  Created by Mark Johnson on 5/9/19.
//  Copyright © 2019 matzsoft. All rights reserved.
//

import Foundation


class HeaderCell: Cell {
    enum SelectType {
        case none
        case vertical
        case horizontal
        case both
    }
    
    var vertical: Int?
    var horizontal: Int?
    
    init( vertical: Int?, horizontal: Int? ) {
        self.vertical = vertical
        self.horizontal = horizontal
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
            image = generator.labelVertical( image: image, text: String( vert ) )
        }
        
        if let horz = horizontal {
            image = generator.labelHorizontal( image: image, text: String( horz ) )
        }
        
        return image
    }
    
    var string: String {
        var front = "  "
        var back  = "  "
        
        if let vert = vertical {
            front = String( format: "%2d", arguments: [vert] )
        }
        
        if let horz = horizontal {
            back = String( format: "%-2d", arguments: [horz] )
        }
        
        return "\(front)\\\(back)"
    }
    
    var speechString: String {
        var front = ""
        var back  = ""
        
        if let horz = horizontal {
            back = ", right \(horz)"
        }
        
        if let vert = vertical {
            front = ", down \(vert)"
        }
        
        return "Header\(front)\(back)"
    }
}
