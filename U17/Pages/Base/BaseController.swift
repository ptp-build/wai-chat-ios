//
//  BaseController.swift
//  U17
//
//  Created by jack on 2023/6/8.
//  Copyright © 2023 Barry. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Reusable
import Kingfisher
import MBProgressHUD



extension UIViewController {
    func showSpinner(onView : UIView) {
        MBProgressHUD.hide(for: onView, animated: false)
        MBProgressHUD.showAdded(to: onView, animated: true)
    }
    
    func removeSpinner(onView : UIView) {
        MBProgressHUD.hide(for: onView, animated: true)
    }
}

class BaseController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)

        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)
        
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setupLayout()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavigationBar()
    }
    
    func setupLayout() {}

    func configNavigationBar() {
        guard let navi = navigationController else { return }
        if navi.visibleViewController == self {
            navi.barStyle(.theme)
            navi.disablePopGesture = false
            navi.setNavigationBarHidden(false, animated: true)
            if navi.viewControllers.count > 1 {
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backGreen"),
                                                                   target: self,
                                                                   action: #selector(pressBack))
            }
        }
    }
    
    @objc func pressBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension BaseController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }

}
