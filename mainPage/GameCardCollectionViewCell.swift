//
//  GameCardCell.swift
//  betlead
//
//  Created by vanness wu on 2019/6/12.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit

class GameCardCollectionViewCell:UICollectionViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var teamAIcon:UIImageView!
    @IBOutlet weak var teamANameLabel:UILabel!
    @IBOutlet weak var teamBIcon:UIImageView!
    @IBOutlet weak var teamBNameLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var leagueNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.applyCornerRadius(radius: 4)
        shadowView.applyShadow(color: .black, radius: 4, alpha: 0.12)
        
    }
    
    func configureCell(gameCardDto:GameCardDto){
        teamAIcon.image = UIImage(named: gameCardDto.firstIcon)
        teamBIcon.image = UIImage(named: gameCardDto.secondIcon)
        teamANameLabel.text = gameCardDto.teamAName
        teamBNameLabel.text = gameCardDto.teamBName
        dateLabel.text = gameCardDto.date
        leagueNameLabel.text = gameCardDto.leagueName
    }
    
    
}
