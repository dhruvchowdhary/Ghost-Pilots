//
//  EnemyType.swift
//  APBOv2
//
//  Created by 90306670 on 11/4/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

struct EnemyType: Codable {
    let name: String
    let shields: Int
    let speed: CGFloat
    let powerUpChance: Int
    let scoreinc: Int
}
