//
//  Ball.swift
//  Billiard_Blast
//
//  Created by Michael Hardin on 4/25/16.
//  Copyright © 2016 Michael Hardin. All rights reserved.
//

import SpriteKit

enum BallType: Int, CustomStringConvertible {
    case Unknown = 0, EightBall, NineBall, OneBall, TwoBall, ThreeBall, FourBall, FiveBall, SixBall, SevenBall
    
    var spriteName: String {
    
   let spriteNames = [
    "8ball",
    "9ball",
    "1ball",
    "2ball",
    "3ball",
    "4ball",
    "5ball",
    "6ball",
    "7ball"]
    
    return spriteNames[rawValue - 1]
    }
    var highlightedSpriteName: String {
        return spriteName + "-h"
    }
    
    static func random() -> BallType {
        if xlevel < 10 {
            return BallType(rawValue: Int(arc4random_uniform(5)) + 1)!
        }else if xlevel < 20 {
            return BallType(rawValue: Int(arc4random_uniform(6)) + 1)!
        }else if xlevel < 50 {
            return BallType(rawValue: Int(arc4random_uniform(7)) + 1)!
        }else if xlevel < 100 {
            return BallType(rawValue: Int(arc4random_uniform(8)) + 1)!
        }else if xlevel < 150 {
            return BallType(rawValue: Int(arc4random_uniform(9)) + 1)!
        }else {
            return BallType(rawValue: Int(arc4random_uniform(10)) + 1)!
        }
    }
    

    var description: String {
        return spriteName
    }
}

func ==(lhs: Ball, rhs: Ball) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

class Ball: CustomStringConvertible, Hashable {
    var column:Int
    var row:Int
    let ballType : BallType
    var sprite: SKSpriteNode?
    
    var description: String {
        return "type:\(ballType) square:(\(column),\(row))"
    }
    
    init(column: Int, row:Int, ballType: BallType) {
        self.column = column
        self.row = row
        self.ballType = ballType
    }
    var hashValue: Int {
        return row*10 + column
    }
}