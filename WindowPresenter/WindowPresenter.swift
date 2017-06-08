//
//  WindowPresenter.swift
//  FMU
//
//  Created by Jens Reynders on 06/01/2017.
//  Copyright © 2017 November Five. All rights reserved.
//

import Foundation

protocol WindowPresenter {
    func showOnKeyedWindow()
    func hide()
    
    func show(on viewController: UIViewController?)
}

extension WindowPresenter where Self:UIView {
    
    // MARK: On Keyed window
    func showOnKeyedWindow() {
        DispatchQueue.main.async {
            self.showInMain()
        }
    }
    
    func showInMain() {
        
        if let mainWindow = UIApplication.shared.keyWindow {
            mainWindow.addSubview(self)
            mainWindow.bringSubview(toFront: self)
            self.frame = CGRect(x: 0, y: 0, width: mainWindow.size.width, height: mainWindow.size.height)
        }
        
        show(true, animated: true)
    }
    
    func hide(_ animated:NSNumber) {
        DispatchQueue.main.async {
            self.hideInMain(animated)
        }
    }
    
    func hideInMain(_ animated:NSNumber) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.0
        }) { (finished) in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    func hide() {
        hide(NSNumber(value: true as Bool))
    }
    
    // MARK: On ViewController
    func show(on viewController: UIViewController?) {
        guard let vc = viewController else { return }
        
        isHidden = true
        alpha = 0.0
                
        vc.view.addSubviewWithConstraints(self)
        
        show(true, animated: true)
    }
}
