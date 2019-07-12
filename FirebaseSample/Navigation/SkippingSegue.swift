//
//  SkippingSegue.swift
//  FirebaseSample
//
//  Created by Pavel H on 7/10/19.
//  Copyright © 2019 smartum.pro. All rights reserved.
//

import UIKit

class SkippingSegue: UIStoryboardSegue {
    override func perform() {
//        source.title = ""
        super.perform()
        guard var viewControllers = source.navigationController?.viewControllers else { return }
        guard let index = viewControllers.firstIndex(of: source) else { return }
        viewControllers.remove(at: index)
        source.navigationController?.setViewControllers(viewControllers, animated: true)
        
    }
}
