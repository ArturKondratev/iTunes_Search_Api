//
//  AppDetailWhatsNewViewController.swift
//  iOSArchitecturesDemo
//
//  Created by Артур Кондратьев on 11.12.2022.
//  Copyright © 2022 ekireev. All rights reserved.
//

import UIKit

class AppDetailWhatsNewViewController: UIViewController {
    
    private let app: ITunesApp
    
    private var appDetailWhatsNewView: AppDetailWhatsNewView {
        return self.view as! AppDetailWhatsNewView
    }
    
    init(app: ITunesApp) {
        self.app = app
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = AppDetailWhatsNewView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fillData()
    }
    
    private func fillData() {
        appDetailWhatsNewView.versionLabel.text = "Версия \(app.version)"
        appDetailWhatsNewView.descriptionLabel.text = app.releaseNotes
        appDetailWhatsNewView.dateLabel.text = app.currentVersionReleaseDate
    }
}
