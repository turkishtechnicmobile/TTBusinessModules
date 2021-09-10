//
//  cellFSItemList.swift
//  TTAsistan
//
//  Created by MnzfM on 12.09.2019.
//  Copyright © 2019 Turkish Technic. All rights reserved.
//

import UIKit
import NMBaseView
import NMBaseApp
import NMBaseModel

class CellFSListItem: UITableViewCell, ThemeApplierListener {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var leftSideImage: UIImageView!
    @IBOutlet weak var leftSideTailImage: UIImageView!
    @IBOutlet weak var planeImageView: UIImageView!
    @IBOutlet weak var lblAc:UILabel!
    @IBOutlet weak var lblDepTitle: UILabel!
    @IBOutlet weak var lblDepTop: UILabel!
    @IBOutlet weak var lblDepBottom: UILabel!
    @IBOutlet weak var lblArrTitle: UILabel!
    @IBOutlet weak var lblArrTop: UILabel!
    @IBOutlet weak var lblArrBottom: UILabel!
    @IBOutlet weak var lblFlightTitle: UILabel!
    @IBOutlet weak var lblGateTitle: UILabel!
    @IBOutlet weak var lblParkTitle: UILabel!
    @IBOutlet weak var lblGate:UILabel!
    @IBOutlet weak var lblPositon:UILabel!
    @IBOutlet weak var lblFlight:UILabel!
    @IBOutlet weak var btnCountDown: UIButton!
    var itemOrigin = ""
    
    var themeApplier: ThemeApplier?
    var repairActionHadler: FS1_FirstStepSegmentItemVC.RepairCompletion?
    private var airCraft = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTheme()
    }
    
    func apply(theme: Theme) {
        dateLabel.textColor = theme.textColor
        lblAc.textColor = theme.textColor
        
        lblDepTitle.textColor = theme.textColor
        lblDepTop.textColor = theme.textColor
        lblDepBottom.textColor = theme.textColor
        lblArrTitle.textColor = theme.textColor
        lblArrTop.textColor = theme.textColor
        lblArrBottom.textColor = theme.textColor
        
        lblFlightTitle.textColor = theme.textColor
        lblGateTitle.textColor = theme.textColor
        lblParkTitle.textColor = theme.textColor
        lblGate.textColor = theme.textColor
        lblPositon.textColor = theme.textColor
        lblFlight.textColor = theme.textColor
    }

    func setCell(item: FlightArrivalOrDeparture, vcType:FSSegmentItemType, hour:Date){
        airCraft = item.ac ?? ""
        
        self.lblAc.text = item.ac!
        self.lblFlight.text = "TK" + item.flight!
        
        if item.gate != nil {
            self.lblGate?.text = item.gate!
        }
        self.lblPositon?.text = item.position
        
        itemOrigin = item.origin
        
        if vcType == FSSegmentItemType.departure {
            self.lblDepTop.text = item.origin!
            self.lblDepBottom.text = Date.time(item.scheduleDate)
            self.lblArrTop.text = item.destination
            self.lblArrBottom.text = Date.time(item.arrivalDate)
            planeImageView.image = UIImage(named: IconFS.planeTakeOffIcon.rawValue)
        }else {
            self.lblDepTop.text = item.origin
            self.lblDepBottom.text = Date.time(item.scheduleDate)
            self.lblArrTop.text = item.destination!
            self.lblArrBottom.text = Date.time(item.arrivalDate)
            planeImageView.image = UIImage(named: IconFS.planeLandIcon.rawValue)
        }
        
    
        self.leftSideTailImage.isHidden = true
        self.leftSideImage.isHidden = false
        
        self.dateLabel.text = String(Date.hour(hour))
        self.dateLabel.isHidden = false
        
        
        let txtCountdown = vcType == FSSegmentItemType.departure ? "DEPARTED" : "LANDED"
        
      //  let interval = hour.timeIntervalSince(Date.init())
        print("-*-*-*-*-*-*-*-*-*--*-*--")
       // print(interval)
        
        let aaa = Date().convert(from: DateFormatManager.shared.timeZone!, to: DateFormatManager.shared.timeZoneTR!)
        
        let interval = hour.timeIntervalSince(aaa)
        
        
       // print(interval2)

        if  interval <= 0 {
            self.btnCountDown.setTitle(txtCountdown, for: .normal)
            self.btnCountDown.isEnabled = false
        }
        else{
            let time = Date.timeFromTimeInterval(interval)
            
            var timeString = ""
            
            if time.hour > 0 {
                timeString = timeString + " \(time.hour)h"
            }
            if time.minute > 0 {
                timeString = timeString + " \(time.minute)m"
            }
            
            if timeString == "" {
                timeString = txtCountdown
            }
            
            self.btnCountDown.setTitle(timeString, for: .normal)
        }
    }
    
    @IBAction func goToDefect(){
        repairActionHadler?(airCraft)
    }
}
