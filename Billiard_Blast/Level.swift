//
//  Level.swift
//  Billiard_Blast
//
//  Created by Michael Hardin on 4/25/16.
//  Copyright © 2016 Michael Hardin. All rights reserved.
//

import Foundation


import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    private var balls = Array2D<Ball>(columns: NumColumns, rows: NumRows)
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var possibleSwaps = Set<Swap>()
    
    private var comboMultiplier = 0

    var targetScore = 0
    var maximumMoves = 0
    
    private func calculateScores(chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
    
    func ballAtColumn(column: Int, row: Int) -> Ball? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return balls[column, row]
    }
    func shuffle() -> Set<Ball> {
        var set: Set<Ball>
        repeat {
            set = createInitialBalls()
            detectPossibleSwaps()
            print("possible swaps: \(possibleSwaps)")
        }
            while possibleSwaps.count == 0
        
        return set
    }
    
    private func createInitialBalls() -> Set<Ball> {
        var set = Set<Ball>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil {
                // 2
                    var ballType: BallType
                    repeat {
                        ballType = BallType.random()
                    }
                        while (column >= 2 &&
                            balls[column - 1, row]?.ballType == ballType &&
                            balls[column - 2, row]?.ballType == ballType)
                            || (row >= 2 &&
                                balls[column, row - 1]?.ballType == ballType &&
                                balls[column, row - 2]?.ballType == ballType)
                
                // 3
                let ball = Ball(column: column, row: row, ballType: ballType)
                balls[column, row] = ball
                
                // 4
                set.insert(ball)
                }
            }
        }
        return set
    }
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    init(filename: String) {
        // 1
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            // 2
            if let tilesArray: AnyObject = dictionary["tiles"] {
                // 3
                for (row, rowArray) in (tilesArray as! [[Int]]).enumerate() {
                    // 4
                    let tileRow = NumRows - row - 1
                    // 5
                    for (column, value) in rowArray.enumerate() {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                  }
                    }
                }
                
                targetScore = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int

            }
        }
    }
    func performSwap(swap: Swap) {
        let columnA = swap.ballA.column
        let rowA = swap.ballA.row
        let columnB = swap.ballB.column
        let rowB = swap.ballB.row
        
        balls[columnA, rowA] = swap.ballB
        swap.ballB.column = columnA
        swap.ballB.row = rowA
        
        balls[columnB, rowB] = swap.ballA
        swap.ballA.column = columnB
        swap.ballA.row = rowB
    }
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let ballType = balls[column, row]!.ballType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && balls[i, row]?.ballType == ballType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && balls[i, row]?.ballType == ballType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && balls[column, i]?.ballType == ballType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && balls[column, i]?.ballType == ballType;
            ++i, ++vertLength { }
        return vertLength >= 3
    }
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let ball = balls[column, row] {
                    
                    // Is it possible to swap this ball with the one on the right?
                    if column < NumColumns - 1 {
                        // Have a ball in this spot? If there is no tile, there is no ball.
                        if let other = balls[column + 1, row] {
                            // Swap them
                            balls[column, row] = other
                            balls[column + 1, row] = ball
                            
                            // Is either ball now part of a chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                set.insert(Swap(ballA: ball, ballB: other))
                            }
                            
                            // Swap them back
                            balls[column, row] = ball
                           balls[column + 1, row] = other
                        }
                    }
                    if row < NumRows - 1 {
                        if let other = balls[column, row + 1] {
                            balls[column, row] = other
                            balls[column, row + 1] = ball
                            
                            // Is either ball now part of a chain?
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                set.insert(Swap(ballA: ball, ballB: other))
                            }
                            
                            // Swap them back
                            balls[column, row] = ball
                            balls[column, row + 1] = other
                        }
                    }

                }
            }
        }
        
        possibleSwaps = set
    }
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    private func detectHorizontalMatches() -> Set<Chain> {
        // 1
        var set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            for var column = 0; column < NumColumns - 2 ; {
                // 3
                if let ball = balls[column, row] {
                    let matchType = ball.ballType
                    // 4
                    if balls[column + 1, row]?.ballType == matchType &&
                        balls[column + 2, row]?.ballType == matchType {
                        // 5
                        let chain = Chain(chainType: .Horizontal)
                        repeat {
                            chain.addBall(balls[column, row]!)
                            ++column
                        }
                            while column < NumColumns && balls[column, row]?.ballType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                // 6
                ++column
            }
        }
        return set
    }
    private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                if let ball = balls[column, row] {
                    let matchType = ball.ballType
                    
                    if balls[column, row + 1]?.ballType == matchType &&
                        balls[column, row + 2]?.ballType == matchType {
                        
                        let chain = Chain(chainType: .Vertical)
                        repeat {
                            chain.addBall(balls[column, row]!)
                            ++row
                        }
                            while row < NumRows && balls[column, row]?.ballType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                }
                ++row
            }
        }
        return set
    }
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeBalls(horizontalChains)
        removeBalls(verticalChains)
        calculateScores(horizontalChains)
        calculateScores(verticalChains)
        return horizontalChains.union(verticalChains)
    }
    private func removeBalls(chains: Set<Chain>) {
        for chain in chains {
            for ball in chain.balls {
                balls[ball.column, ball.row] = nil
            }
        }
    }
    func fillHoles() -> [[Ball]] {
        var columns = [[Ball]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Ball]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && balls[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let ball = balls[column, lookup] {
                            // 4
                            balls[column, lookup] = nil
                            balls[column, row] = ball
                            ball.row = row
                            // 5
                            array.append(ball)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    func topUpBalls() -> [[Ball]] {
        var columns = [[Ball]]()
        var ballType: BallType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Ball]()
            // 1
            for var row = NumRows - 1; row >= 0 && balls[column, row] == nil; --row {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newBallType: BallType
                    repeat {
                        newBallType = BallType.random()
                    } while newBallType == ballType
                    ballType = newBallType
                    // 4
                    let ball = Ball(column: column, row: row, ballType: ballType)
                    balls[column, row] = ball
                    array.append(ball)
                }
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
}