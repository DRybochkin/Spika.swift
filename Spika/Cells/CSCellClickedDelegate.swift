//
//  CellClickedDelegate.h
//  Prototype
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright (c) 2015 Clover Studio. All rights reserved.
//

import Foundation
import UIKit

protocol CSCellClickedDelegate: NSObjectProtocol {
    func onInfoClicked(_ message: CSMessageModel)
    func onDeleteClicked(_ message: CSMessageModel)
    func onCopyClicked(_ message: CSMessageModel)
}
