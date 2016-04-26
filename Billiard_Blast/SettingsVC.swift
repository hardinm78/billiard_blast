//
//  SettingsVC.swift
//  Billiard_Blast
//
//  Created by Michael Hardin on 4/25/16.
//  Copyright © 2016 Michael Hardin. All rights reserved.
//

import Foundation
import UIKit


class SettingsVC : UIViewController {
     var startLvlVal: Int = 1
    
    
    @IBOutlet weak var hmLvlSliderOutlet: UISlider!
     @IBOutlet weak var hmLvlLabel: UILabel!
    override func viewDidLoad() {
        startLvlVal = xlevel + 1
        hmLvlSliderOutlet.value = Float(startLvlVal)
        
        hmLvlLabel.text = "\(startLvlVal)"
        hmLvlSliderOutlet.minimumValue = 1
        hmLvlSliderOutlet.maximumValue = Float(highestLevelCompleted + 1)
            }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func backPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func hmSliderAction(sender: AnyObject) {
        
        startLvlVal = Int(hmLvlSliderOutlet.value)
        
        hmLvlLabel.text = "\(startLvlVal)"
        
        xlevel = startLvlVal - 1
        
        if xlevel < 100 {
            level = Level(filename: "Level_\(xlevel)")
        }else if xlevel >= 100 {
            level = Level(filename: "Level_\(xlevel-100)")
        }
    }
    
    @IBAction func lvUP(sender: AnyObject) {
        
        hmLvlSliderOutlet.value += 1
        startLvlVal = Int(hmLvlSliderOutlet.value)
        
        hmLvlLabel.text = "\(startLvlVal)"
        
        xlevel = startLvlVal - 1
        
        if xlevel < 100 {
            level = Level(filename: "Level_\(xlevel)")
        }else if xlevel >= 100 {
            level = Level(filename: "Level_\(xlevel-100)")
        }
    }
    
    
    
    @IBAction func lvDWN(sender: AnyObject) {
        hmLvlSliderOutlet.value -= 1
        startLvlVal = Int(hmLvlSliderOutlet.value)
        
        hmLvlLabel.text = "\(startLvlVal)"
        
        xlevel = startLvlVal - 1
        
        if xlevel < 100 {
            level = Level(filename: "Level_\(xlevel)")
        }else if xlevel >= 100 {
            level = Level(filename: "Level_\(xlevel-100)")
        }
        
        
    }
    

}