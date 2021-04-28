//
//  Bannerable.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/26.
//

import Foundation
import GoogleMobileAds

protocol Bannerable {
    var bannerView: GADBannerView! { get set }
    func initBanner(root: UIViewController)
}

extension Bannerable {
    func initBanner(root: UIViewController) {
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = root
        bannerView.load(GADRequest())
    }
}
