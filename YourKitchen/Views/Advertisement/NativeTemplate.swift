//
//  NativeTemplate.swift
//  YourKitchen
//
//  Created by Markus Moltke on 27/11/2020.
//  Copyright © 2020 Markus Moltke. All rights reserved.
//

import Foundation

public class NativeTemplate : UIView {
    
    public var callToAction : () -> Void
    @IBOutlet weak var actionButton: UIButton!
    
    required init(frame: CGRect = CGRect(x: 0, y: 0, width: 325, height: 325), action: @escaping () -> Void) {
        self.callToAction = action
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func callToAction(_ sender: Any) {
        self.callToAction()
    }
}
