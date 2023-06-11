//
//  ScanViewController.swift
//  ios-bangde
//
//  Created by jack on 2021/5/18.
//  Copyright © 2021 Barry. All rights reserved.
//

import Foundation


import UIKit

protocol ScanViewControllerDelegate{
    func setScanResult(message : String)
}

class ScanViewController: LBXScanViewController {
    
    var delegateCb : ScanViewControllerDelegate?

    /**
    @brief  扫码区域上方提示文字
    */
    var topTitle: UILabel?
    
    /**
     @brief  闪关灯开启状态
     */
    var isOpenedFlash: Bool = false
    
    // MARK: - 底部功能：开启闪光灯

    //底部显示的功能项
    var bottomItemsView: UIView?

    //闪光灯
    var btnFlash: UIButton = UIButton()

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "扫一扫"
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var style = LBXScanViewStyle()
        style.anmiationStyle = .NetGrid
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net")
        scanStyle = style
        //框向上移动10个像素
        scanStyle?.centerUpOffset += 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawBottomItems()
    }
    func drawBottomItems() {
        if (bottomItemsView != nil) {
            return
        }
        let yMax = self.view.frame.maxY - self.view.frame.minY
        bottomItemsView = UIView(
            frame: CGRect(x: 0.0, y: yMax-160, width: self.view.frame.size.width, height: 100 )
        )
        bottomItemsView!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        self.view .addSubview(bottomItemsView!)
        let size = CGSize(width: 65, height: 87)

        self.btnFlash = UIButton()
        btnFlash.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        btnFlash.center = CGPoint(
            x: bottomItemsView!.frame.width/2, y: bottomItemsView!.frame.height/2
        )
        btnFlash.setImage(
            UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"),
            for:UIControl.State.normal
        )
        btnFlash.addTarget(
            self, action: #selector(ScanViewController.openOrCloseFlash),
            for: UIControl.Event.touchUpInside
        )
        bottomItemsView?.addSubview(btnFlash)
        view.addSubview(bottomItemsView!)
    }
    
    //开关闪光灯
    @objc func openOrCloseFlash() {
        scanObj?.changeTorch()
        isOpenedFlash = !isOpenedFlash
        if isOpenedFlash
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_down"), for:UIControl.State.normal)
        }
        else
        {
            btnFlash.setImage(UIImage(named: "CodeScan.bundle/qrcode_scan_btn_flash_nor"), for:UIControl.State.normal)
        }
    }
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        if let result = arrayResult.first {
            let msg = result.strScanned
            print("扫描结果:\(msg ?? "")")
            self.delegateCb?.setScanResult(message:msg!)
        }
    }
//    @objc func pressBack() {
//        self.delegateCb?.setScanResult(message:"test")
//        navigationController?.popViewController(animated: true)
//    }
}
