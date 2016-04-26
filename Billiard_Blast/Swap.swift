//
//  Swap.swift
//  Billiard_Blast
//
//  Created by Michael Hardin on 4/25/16.
//  Copyright © 2016 Michael Hardin. All rights reserved.
//

import Foundation
func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.ballA == rhs.ballA && lhs.ballB == rhs.ballB) ||
        (lhs.ballB == rhs.ballA && lhs.ballA == rhs.ballB)
}
struct Swap: CustomStringConvertible, Hashable {
    let ballA: Ball
    let ballB: Ball
    
    init(ballA: Ball, ballB: Ball) {
        self.ballA = ballA
        self.ballB = ballB
    }
    
    var description: String {
        return "swap \(ballA) with \(ballB)"
    }
    var hashValue: Int {
        return ballA.hashValue ^ ballB.hashValue
    }
}
