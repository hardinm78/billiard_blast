//
//  Chain.swift
//  Billiard_Blast
//
//  Created by Michael Hardin on 4/25/16.
//  Copyright © 2016 Michael Hardin. All rights reserved.
//

import Foundation

class Chain: Hashable, CustomStringConvertible {
    var balls = [Ball]()
    var score = 0
    
    
    enum ChainType: CustomStringConvertible {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addBall(ball: Ball) {
        balls.append(ball)
    }
    
    func firstBall() -> Ball {
        return balls[0]
    }
    
    func lastBall() -> Ball {
        return balls[balls.count - 1]
    }
    
    var length: Int {
        return balls.count
    }
    
    var description: String {
        return "type:\(chainType) balls:\(balls)"
    }
    
    var hashValue: Int {
        return balls.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.balls == rhs.balls
}
