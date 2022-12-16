//
//  SongCell.swift
//  iOSArchitecturesDemo
//
//  Created by Артур Кондратьев on 16.12.2022.
//  Copyright © 2022 ekireev. All rights reserved.
//

import UIKit

final class SongCell: UITableViewCell {
    
    static let reuseIdentifier = "songCellReuseId"
    private var imageServise = ImageDownloader()
    
    // MARK: - Subviews
    private(set) lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        return image
    }()
    
    private(set) lazy var artistNameLable: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = UIFont.boldSystemFont(ofSize: 18)
        lable.textColor = .black
        return lable
    }()
    
    private(set) lazy var trackNameLable: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = UIFont.boldSystemFont(ofSize: 18)
        lable.textColor = .black
        return lable
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    // MARK: - Methods
    func configure(model: SongCellModel) {
        self.artistNameLable.text = model.artistName
        self.trackNameLable.text = model.trackname
        
        imageServise.getImage(fromUrl: model.icon) { image, _ in
            DispatchQueue.main.async {
                self.image.image = image
            }
        }
    }
    
    // MARK: - UI
    override func prepareForReuse() {
        artistNameLable.text = nil
        trackNameLable.text = nil
        image.image = nil
    }
    
    private func configureUI() {
        addTitleLabel()
        addArtistLable()
        addTrackLable()
    }
    
    private func addTitleLabel() {
        self.contentView.addSubview(self.image)
        
        NSLayoutConstraint.activate([
            self.image.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8.0),
            self.image.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20.0),
            self.image.widthAnchor.constraint(equalToConstant: 60),
            self.image.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func addArtistLable() {
        self.contentView.addSubview(self.artistNameLable)
        
        NSLayoutConstraint.activate([
            self.artistNameLable.topAnchor.constraint(equalTo: self.image.topAnchor),
            self.artistNameLable.leftAnchor.constraint(equalTo: self.image.rightAnchor, constant: 10),
            self.artistNameLable.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0)
        ])
    }
    
    private func addTrackLable() {
        self.contentView.addSubview(self.trackNameLable)
        
        NSLayoutConstraint.activate([
            self.trackNameLable.topAnchor.constraint(equalTo: self.artistNameLable.bottomAnchor, constant: 10),
            self.trackNameLable.leftAnchor.constraint(equalTo: self.artistNameLable.leftAnchor),
            self.trackNameLable.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8.0)
        ])
    }
}
