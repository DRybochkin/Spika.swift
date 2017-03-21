//
//  CustomView.h
//  chaplideviap
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import UIKit

class CSCustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFromNib()
    }

    func initFromNib()  {
        let newView: UIView! = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)![0] as! UIView
        newView?.frame = bounds
        addSubview(newView)
        customInit()
    }
    
    func customInit() {
    }
}
