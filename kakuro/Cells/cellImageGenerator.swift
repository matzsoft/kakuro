//
//  cellImageGenerator.swift
//  greekKey
//
//  Created by Mark Johnson on 3/20/16.
//  Copyright © 2016 Mark Johnson. All rights reserved.
//

//
//   +---------+          This crude ASCII art shows the geometry of the cells
//   |\       /|          created by this class.  The 8 obvious points are at
//   | \     / |          the corners of the inner and outer squares.  They
//   |  +---+  |          are marked here by the + character.  Their coordinate
//   |  |   |  |          values are given in the "c" array.  The "p" array
//   |  |   |  |          expands this to 16 points by extending the edges of
//   |  |   |  |          the inner square to meet the edges of the outer
//   |  +---+  |          one.  The outer square is filled with the desired
//   | /     \ |          color and then the 4 outer regions are overlayed with
//   |/       \|          a gradient to give the appearance of an indented or
//   +---------+          outdented button.
//

import Foundation

class cellImageGenerator {
    fileprivate static let userWidth    = CGFloat( 930 )
    fileprivate static let diagWidth    = CGFloat( 30 )
    fileprivate static let headerMargin = CGFloat( 30 )
    fileprivate static let emptyMargin  = CGFloat( 60 )
    fileprivate static let c: [CGFloat] = [ 0, 150, 790, 929 ]
    fileprivate static let x: [CGFloat] = [ 51, 119, 176, 247, 312, 369, 448, 499, 561, 618, 686, 754, 811, 879 ]
    fileprivate static let y: [CGFloat] = [ 51, 119, 176, 252, 306, 380, 425, 505, 561, 629, 686, 754, 822, 879 ]
    fileprivate static let p            = [
        [ CGPoint(x: c[0],y: c[0]), CGPoint(x: c[0],y: c[1]), CGPoint(x: c[0],y: c[2]), CGPoint(x: c[0],y: c[3]) ],
        [ CGPoint(x: c[1],y: c[0]), CGPoint(x: c[1],y: c[1]), CGPoint(x: c[1],y: c[2]), CGPoint(x: c[1],y: c[3]) ],
        [ CGPoint(x: c[2],y: c[0]), CGPoint(x: c[2],y: c[1]), CGPoint(x: c[2],y: c[2]), CGPoint(x: c[2],y: c[3]) ],
        [ CGPoint(x: c[3],y: c[0]), CGPoint(x: c[3],y: c[1]), CGPoint(x: c[3],y: c[2]), CGPoint(x: c[3],y: c[3]) ]
    ]

    fileprivate let context:            CGContext
    fileprivate let lightGradient:      CGGradient
    fileprivate let darkGradient:       CGGradient
    fileprivate let headerRange:        CGRect
    fileprivate let headerAttributes:   [String:AnyObject]
    fileprivate let emptyRange:         CGRect
    fileprivate let emptyAttributes:    [String:AnyObject]
    fileprivate let eligibleRange:      CGRect
    fileprivate let eligibleAttributes: [String:AnyObject]
    
    var imageWidth: Int
    var colorSpace: CGColorSpace

    var unusedNrmDark:  CGColor
    var unusedNrmLight: CGColor
    var emptyNrmDark:   CGColor
    var emptyNrmLight:  CGColor
    var emptySelDark:   CGColor
    var emptySelLight:  CGColor
    var unusedSelDark:  CGColor
    var unusedSelLight: CGColor
    var borderSolid:    CGColor
    var borderBG:       CGColor
    var borderFG:       CGColor
    
    init( imageWidth: Int, colorSpace: CGColorSpace ) {
        self.imageWidth  = imageWidth
        self.colorSpace  = colorSpace
        
        unusedNrmDark  = CGColor(red: 147.0/255.0, green: 120.0/255.0, blue:  86.0/255.0, alpha: 1 )
        unusedNrmLight = CGColor(red: 155.0/255.0, green: 129.0/255.0, blue:  99.0/255.0, alpha: 1 )
        emptyNrmDark   = CGColor(red: 185.0/255.0, green: 147.0/255.0, blue: 104.0/255.0, alpha: 1 )
        emptyNrmLight  = CGColor(red: 187.0/255.0, green: 152.0/255.0, blue: 111.0/255.0, alpha: 1 )
        emptySelDark   = CGColor(red: 188.0/255.0, green: 119.0/255.0, blue:  84.0/255.0, alpha: 1 )
        emptySelLight  = CGColor(red: 190.0/255.0, green: 123.0/255.0, blue:  89.0/255.0, alpha: 1 )
        unusedSelDark  = CGColor(red: 160.0/255.0, green:  94.0/255.0, blue:  67.0/255.0, alpha: 1 )
        unusedSelLight = CGColor(red: 166.0/255.0, green: 102.0/255.0, blue:  78.0/255.0, alpha: 1 )
        borderSolid    = CGColor(red:  72.0/255.0, green:  39.0/255.0, blue:  32.0/255.0, alpha: 1 )
        borderBG       = CGColor(red: 176.0/255.0, green: 156.0/255.0, blue: 132.0/255.0, alpha: 1 )
        borderFG       = CGColor(red:  91.0/255.0, green:  66.0/255.0, blue:  55.0/255.0, alpha: 1 )
        
        let lessWhite = CGColor(red: 1, green: 1, blue: 1, alpha: 0.05 )
        let moreWhite = CGColor(red: 1, green: 1, blue: 1, alpha: 0.30 )
        let lessBlack = CGColor(red: 0, green: 0, blue: 0, alpha: 0.05 )
        let moreBlack = CGColor(red: 0, green: 0, blue: 0, alpha: 0.30 )
        
        let lightColors   = [ lessWhite, moreWhite ]
        let darkColors    = [ lessBlack, moreBlack ]
        
        lightGradient = CGGradient( colorsSpace: colorSpace, colors: lightColors as CFArray, locations: nil )!
        darkGradient  = CGGradient( colorsSpace: colorSpace, colors: darkColors as CFArray, locations: nil )!
        
        context = cellImageGenerator.setupContext( imageWidth, colorSpace: colorSpace, lineColor: borderSolid )
        
        let attributes = cellImageGenerator.setupFontAttributes(context, borderColor: borderSolid, scaleFactor: 1)
        let textRange = cellImageGenerator.setupTextRange(context: context, attributes: attributes)
        let vertRect = cellImageGenerator.getVerticalRect( textRange: textRange )
        let vertScale = vertRect.height / textRange.height
        let emptyRect = cellImageGenerator.getEmptyRect()
        let emptyScale = emptyRect.height / textRange.height
        let eligibleRect = cellImageGenerator.getEligibleRect()
        let eligibleScale = eligibleRect.height / textRange.height
        
        headerAttributes = cellImageGenerator.setupFontAttributes( context, borderColor: borderSolid, scaleFactor: vertScale )
        headerRange = cellImageGenerator.setupTextRange( context: context, attributes: headerAttributes )
        emptyAttributes = cellImageGenerator.setupFontAttributes( context, borderColor: borderSolid, scaleFactor: emptyScale )
        emptyRange = cellImageGenerator.setupTextRange( context: context, attributes: emptyAttributes )
        eligibleAttributes = cellImageGenerator.setupFontAttributes( context, borderColor: borderSolid, scaleFactor: eligibleScale )
        eligibleRange = cellImageGenerator.setupTextRange( context: context, attributes: eligibleAttributes )
    }
    
    
    fileprivate static func setupContext( _ imageWidth: Int, colorSpace: CGColorSpace, lineColor: CGColor ) -> CGContext {
        let context = CGContext(data: nil, width: imageWidth, height: imageWidth, bitsPerComponent: 8, bytesPerRow: imageWidth*4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.interpolationQuality = .high
        context.setAllowsAntialiasing(true )
        context.scaleBy(x: CGFloat(imageWidth)/userWidth, y: CGFloat(imageWidth)/userWidth )

        context.setStrokeColor(lineColor )
        context.setLineWidth(diagWidth )

        return context
    }
    
    
    fileprivate static func setupFontAttributes( _ context: CGContext, borderColor: CGColor, scaleFactor: CGFloat ) -> [ String: AnyObject ] {
        let fontAttributes = [
            String( kCTFontFamilyNameAttribute ): "Arial",
            String( kCTFontStyleNameAttribute ):  "Regular",
            String( kCTFontSizeAttribute ):       20.0 * scaleFactor
            ] as [String : Any]
        let fontDescriptor = CTFontDescriptorCreateWithAttributes( fontAttributes as CFDictionary )
        let font           = CTFontCreateWithFontDescriptor( fontDescriptor, 0.0, nil )
        
        let attributes: [ String: AnyObject ] = [
            String( kCTFontAttributeName ):            font,
            String( kCTForegroundColorAttributeName ): borderColor
        ]
        
        return attributes
    }
    
    
    fileprivate static func setupTextRange( context: CGContext, attributes: [String: AnyObject]) ->  CGRect {
        var textRange = CGRect( x: 0, y: 0, width: 0, height: 0 )
        
        context.textPosition = CGPoint( x: 0, y: 0)
        for label in 3 ... 45 {
            let text     = CFAttributedStringCreate( kCFAllocatorDefault, String( label ) as CFString, attributes as CFDictionary )
            let line     = CTLineCreateWithAttributedString( text! )
            let textRect = CTLineGetImageBounds( line, context )
            
            textRange = textRange.union(textRect )
        }
        
        return textRange
    }
    
    
//   +---------+          This crude ASCII art is a closeup of the inner square
//   |\        |          in the diagram at the top of this file.  The following
//   | \       |          function computes the VerticalRect, where the text of
//   |  \      |          the vertical total of a header cell is drawn.  The
//   |   \     |          lower left corner of that Rect is known at (x1,y1).
//   |    \    |          We must compute the upper corner at (x2,y2).  We do
//   | +-+ \   |          that by intersecting the diagonal of the VerticalRect
//   | | |  \  |          with the diagonal of the full cell (offset by half of
//   | +-+   \ |          the TextMargin plus the width of the drawn diagonal).
//   |        \|          The slope of the VerticalRect is m1 and the slope of
//   +---------+          the cell diagonal is m2.

    fileprivate func convertToPuzzleSpace( rect: CGRect ) -> CGRect {
        let flip = CGAffineTransform( a: 1, b: 0, c: 0, d: -1, tx: 0, ty: cellImageGenerator.userWidth )
        
        context.saveGState()
        context.concatenate(flip )
        
        let newRect = context.convertToDeviceSpace(rect)
        context.restoreGState()
        
        return newRect
    }
    
    
    fileprivate static func getVerticalRect( textRange: CGRect ) -> CGRect {
        let m1 = textRange.height / textRange.width
        let m2 = CGFloat( -1 )
        let x1 = c[1] + headerMargin
        let y1 = c[1] + headerMargin
        let x2 = ( c[3] - ( headerMargin + diagWidth ) / 2 - y1 + m1 * x1 ) / ( m1 - m2 )
        let y2 = m1 * x2 + y1 - m1 * x1
        
        return CGRect(x: x1, y: y1, width: x2 - x1 + 1, height: y2 - y1 + 1 )
    }
    
    
    func getVerticalRect() -> CGRect {
        let userRect = cellImageGenerator.getVerticalRect(textRange: headerRange)
        
        return convertToPuzzleSpace(rect: userRect)
    }
    
    
    fileprivate static func getHorizontalRect( textRange: CGRect ) -> CGRect {
        let rect = getVerticalRect( textRange: textRange )
        let xoffset = c[2] - headerMargin - rect.width - rect.minX
        let yoffset = c[2] - headerMargin - rect.height - rect.minY
        
        return rect.offsetBy(dx: xoffset, dy: yoffset )
    }
    
    
    func getHorizontalRect() -> CGRect {
        let userRect = cellImageGenerator.getHorizontalRect(textRange: headerRange)
        
        return convertToPuzzleSpace(rect: userRect)
    }
    
    
    fileprivate static func getEmptyRect() -> CGRect {
        let x1 = c[1] + emptyMargin
        let y1 = c[1] + emptyMargin
        let x2 = c[2] - emptyMargin
        let y2 = c[2] - emptyMargin
        
        return CGRect(x: x1, y: y1, width: x2 - x1 + 1, height: y2 - y1 + 1 )
    }
    
    
    fileprivate static func getEligibleRect() -> CGRect {
        let emptyRect = getEmptyRect()
        let width = emptyRect.width / 3
        let height = ( emptyRect.height - 2 * emptyMargin ) / 3
        let x = emptyRect.minX
        let y = emptyRect.maxY - height
        
        return CGRect(x: x, y: y, width: width, height: height )
    }
    
    
    func makeImage() -> CGImage {
        guard let image = context.makeImage() else {
            fatalError("Unable to create image")
        }
        
        return image
    }
    
    
    lazy var NormalUnused: CGImage = {
        fullFill( unusedNrmLight )
        makeOutdent()
        
        return makeImage()
    }()
    

    lazy var SelectUnused: CGImage = {
        fullFill( unusedSelDark )
        makeOutdent()
        
        return makeImage()
    }()
    
    
    lazy var NormalEmpty: CGImage = {
        fullFill( emptyNrmLight )
        makeIndent()
        
        return makeImage()
    }()
    
    
    lazy var SelectEmpty: CGImage = {
        fullFill( emptySelDark )
        makeIndent()
        
        return makeImage()
    }()
    
    
    lazy var NormalHeader: CGImage = {
        fullFill( unusedNrmLight )
        makeOutdent()
        context.strokeLineSegments(between: [ cellImageGenerator.p[0][3], cellImageGenerator.p[3][0] ])
        
        return makeImage()
    }()
    
    
    lazy var SelectVertical: CGImage = {
        fullFill( unusedNrmLight )
        halfFill( unusedSelDark, midPoint: cellImageGenerator.p[0][0] )
        makeOutdent()
        context.strokeLineSegments(between: [ cellImageGenerator.p[0][3], cellImageGenerator.p[3][0] ])
        
        return makeImage()
    }()
    
    
    lazy var SelectHorizontal: CGImage = {
        fullFill( unusedNrmLight )
        halfFill( unusedSelDark, midPoint: cellImageGenerator.p[3][3] )
        makeOutdent()
        context.strokeLineSegments(between: [ cellImageGenerator.p[0][3], cellImageGenerator.p[3][0] ])
        
        return makeImage()
    }()
    
    
    lazy var SelectBoth: CGImage = {
        fullFill(unusedSelDark)
        makeOutdent()
        context.strokeLineSegments(between: [ cellImageGenerator.p[0][3], cellImageGenerator.p[3][0] ])
        
        return makeImage()
    }()
    
    
    lazy var BorderCell: CGImage = {
        context.setFillColor(borderBG )
        context.fill(CGRect( x: 0, y: 0, width: cellImageGenerator.userWidth, height: cellImageGenerator.userWidth ) )
        
        context.beginPath()
        
        context.move(to: CGPoint(x: cellImageGenerator.x[0], y: cellImageGenerator.y[0]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[13], y: cellImageGenerator.y[0]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[13], y: cellImageGenerator.y[13]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[0], y: cellImageGenerator.y[13]));
        context.closePath();
        //
        context.move(to: CGPoint(x: cellImageGenerator.x[1], y: cellImageGenerator.y[1]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[1], y: cellImageGenerator.y[6]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[5], y: cellImageGenerator.y[6]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[5], y: cellImageGenerator.y[3]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[3], y: cellImageGenerator.y[3]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[3], y: cellImageGenerator.y[4]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[4], y: cellImageGenerator.y[4]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[4], y: cellImageGenerator.y[5]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[2], y: cellImageGenerator.y[5]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[2], y: cellImageGenerator.y[2]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[6], y: cellImageGenerator.y[2]));
        //
        context.addLine(to: CGPoint(x: cellImageGenerator.x[6], y: cellImageGenerator.y[11]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[2], y: cellImageGenerator.y[11]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[2], y: cellImageGenerator.y[8]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[4], y: cellImageGenerator.y[8]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[4], y: cellImageGenerator.y[9]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[3], y: cellImageGenerator.y[9]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[3], y: cellImageGenerator.y[10]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[5], y: cellImageGenerator.y[10]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[5], y: cellImageGenerator.y[7]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[1], y: cellImageGenerator.y[7]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[1], y: cellImageGenerator.y[12]));
        //
        context.addLine(to: CGPoint(x: cellImageGenerator.x[12], y: cellImageGenerator.y[12]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[12], y: cellImageGenerator.y[7]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[8], y: cellImageGenerator.y[7]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[8], y: cellImageGenerator.y[10]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[10], y: cellImageGenerator.y[10]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[10], y: cellImageGenerator.y[9]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[9], y: cellImageGenerator.y[9]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[9], y: cellImageGenerator.y[8]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[11], y: cellImageGenerator.y[8]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[11], y: cellImageGenerator.y[11]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[7], y: cellImageGenerator.y[11]));
        //
        context.addLine(to: CGPoint(x: cellImageGenerator.x[7], y: cellImageGenerator.y[2]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[11], y: cellImageGenerator.y[2]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[11], y: cellImageGenerator.y[5]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[9], y: cellImageGenerator.y[5]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[9], y: cellImageGenerator.y[4]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[10], y: cellImageGenerator.y[4]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[10], y: cellImageGenerator.y[3]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[8], y: cellImageGenerator.y[3]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[8], y: cellImageGenerator.y[6]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[12], y: cellImageGenerator.y[6]));
        context.addLine(to: CGPoint(x: cellImageGenerator.x[12], y: cellImageGenerator.y[1]));
        //
        context.closePath();
        
        context.setFillColor(borderFG )
        context.fillPath()
        
        return makeImage()
    }()
    
    
    fileprivate func fullFill( _ bgColor: CGColor ) {
        context.setFillColor(bgColor )
        context.fill(CGRect( x: 0, y: 0, width: cellImageGenerator.userWidth, height: cellImageGenerator.userWidth ) )
    }
    
    
    fileprivate func halfFill( _ bgColor: CGColor, midPoint: CGPoint ) {
        context.beginPath()
        context.move(to: cellImageGenerator.p[0][3])
        context.addLine(to: midPoint);
        context.addLine(to: cellImageGenerator.p[3][0]);
        context.closePath();
        
        context.setFillColor(bgColor)
        context.fillPath()
    }
    
    
    fileprivate func makeIndent() {
        drawShades( darkGradient, lrGradient: lightGradient )
    }
    
    
    fileprivate func makeOutdent() {
        drawShades( lightGradient, lrGradient: darkGradient )
    }
    
    
    fileprivate func drawShades( _ ulGradient: CGGradient, lrGradient: CGGradient ) {
        // Top Shade
        drawShade( ulGradient,
                   cellImageGenerator.p[0][3],
                   cellImageGenerator.p[3][3],
                   cellImageGenerator.p[2][2],
                   cellImageGenerator.p[1][2],
                   cellImageGenerator.p[0][2]
        )
        
        // Left Shade
        drawShade( ulGradient,
                   cellImageGenerator.p[0][3],
                   cellImageGenerator.p[1][2],
                   cellImageGenerator.p[1][1],
                   cellImageGenerator.p[0][0],
                   cellImageGenerator.p[1][3]
        )

        // Right Shade
        drawShade( lrGradient,
                   cellImageGenerator.p[3][3],
                   cellImageGenerator.p[3][0],
                   cellImageGenerator.p[2][1],
                   cellImageGenerator.p[2][2],
                   cellImageGenerator.p[2][3]
        )

        // Bottom Shade
        drawShade( lrGradient,
                   cellImageGenerator.p[0][0],
                   cellImageGenerator.p[1][1],
                   cellImageGenerator.p[2][1],
                   cellImageGenerator.p[3][0],
                   cellImageGenerator.p[0][1]
        )
    }

    
    fileprivate func drawShade( _ gradient: CGGradient, _ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ p4: CGPoint ) {
        context.beginPath()
        context.move(to: p0);
        context.addLine(to: p1);
        context.addLine(to: p2);
        context.addLine(to: p3);
        context.closePath();
        
        context.saveGState()
        context.clip()
        context.drawLinearGradient(gradient, start: p0, end: p4, options: .drawsBeforeStartLocation )
        context.restoreGState()
    }
    
    
    func getAvailableRect() -> CGRect {
        let rect = CGRect(
            x: cellImageGenerator.c[1] + cellImageGenerator.headerMargin,
            y: cellImageGenerator.c[1] + cellImageGenerator.headerMargin,
            width: cellImageGenerator.c[2] - cellImageGenerator.c[1] + 1 - 2 * cellImageGenerator.headerMargin,
            height: cellImageGenerator.c[2] - cellImageGenerator.c[1] + 1 - 2 * cellImageGenerator.headerMargin
        )
        
        return context.convertToDeviceSpace(rect )
    }
    
    
    func wallpaperImage(_ image: CGImage) {
        let imageRect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        let wallRect = context.convertToUserSpace(imageRect)
        
        context.draw(image, in: wallRect)
    }
    
    
    fileprivate func drawLabel( text: String, rect: CGRect ) -> CGImage {
        let attrString = CFAttributedStringCreate( kCFAllocatorDefault, text as CFString, headerAttributes as CFDictionary )
        let line       = CTLineCreateWithAttributedString( attrString! )
        let textSize   = CTLineGetImageBounds( line, context )
        let x          = rect.minX - headerRange.minX + ( rect.width - textSize.width ) / 2
        let y          = rect.minY - headerRange.minY + ( rect.height - textSize.height ) / 2
        
        context.textPosition = CGPoint( x: x, y: y)
        context.saveGState()
        CTLineDraw( line, context )
        context.restoreGState()
        
        return makeImage()
    }
    
    
    func labelVertical(image: CGImage, text: String) -> CGImage {
        let baseRect = cellImageGenerator.getVerticalRect( textRange: headerRange )

        wallpaperImage(image)
        return drawLabel( text: String( text ), rect: baseRect )
    }
    
    
    func labelHorizontal(image: CGImage, text: String) -> CGImage {
        let baseRect = cellImageGenerator.getHorizontalRect( textRange: headerRange )
        
        wallpaperImage(image)
        return drawLabel( text: String( text ), rect: baseRect )
    }
    
    
    func labelSolved( image: CGImage, text: String ) -> CGImage {
        let rect = cellImageGenerator.getEmptyRect()
        let attrString = CFAttributedStringCreate( kCFAllocatorDefault, text as CFString, emptyAttributes as CFDictionary )
        let line       = CTLineCreateWithAttributedString( attrString! )
        let textSize   = CTLineGetImageBounds( line, context )
        let x          = rect.minX - emptyRange.minX + ( rect.width - textSize.width ) / 2
        let y          = rect.minY - emptyRange.minY + ( rect.height - textSize.height ) / 2

        wallpaperImage(image)

        context.textPosition = CGPoint( x: x, y: y)
        context.saveGState()
        CTLineDraw( line, context )
        context.restoreGState()
        
        return makeImage()
    }
    
    
    func labelEligible( image: CGImage, eligible: Set<Int> ) -> CGImage {
        let rect = cellImageGenerator.getEligibleRect()
        let yGap = rect.height + cellImageGenerator.emptyMargin
        
        wallpaperImage(image)
        
        for ( index, number ) in eligible.sorted().enumerated() {
            let text = String( number )
            let attrString = CFAttributedStringCreate( kCFAllocatorDefault, text as CFString, eligibleAttributes as CFDictionary )
            let line       = CTLineCreateWithAttributedString( attrString! )
            let textSize   = CTLineGetImageBounds( line, context )
            let minX       = rect.minX + rect.width * CGFloat( index % 3 )
            let minY       = rect.minY - yGap * CGFloat( index / 3 )
            let x          = minX - eligibleRange.minX + ( rect.width - textSize.width ) / 2
            let y          = minY - eligibleRange.minY + ( rect.height - textSize.height ) / 2
            
            context.textPosition = CGPoint( x: x, y: y)
            context.saveGState()
            CTLineDraw( line, context )
            context.restoreGState()
        }
        
        return makeImage()
    }
}
