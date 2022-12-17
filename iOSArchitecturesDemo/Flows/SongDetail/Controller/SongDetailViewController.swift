//
//  SongDetailViewController.swift
//  iOSArchitecturesDemo
//
//  Created by Артур Кондратьев on 16.12.2022.
//  Copyright © 2022 ekireev. All rights reserved.
//

import UIKit
import MediaPlayer

class SongDetailViewController: UIViewController, SongDetailViewDelegate {
    
    // MARK: - Properties
    let song: ITunesSong
    var player: AVPlayer!
    private var imageServise = ImageDownloader()
    
    // MARK: - Private Properties
    private var songDetailView: SongDetailView {
        return self.view as! SongDetailView
    }
    
    //MARK: - Init
    init(song: ITunesSong) {
        self.song = song
        super.init(nibName: nil, bundle: nil) }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func loadView() {
        self.view = SongDetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.navigationItem.largeTitleDisplayMode = .never
        songDetailView.delegate = self
        fillData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
    }
    
    // MARK: - Private
    func fillData() {
        songDetailView.artistNameLable.text = song.artistName
        songDetailView.trackNameLable.text = song.trackName
        imageServise.getImage(fromUrl: song.bigArtwork ?? "") { image, _ in
            self.songDetailView.albomImage.image = image
        }
    }
    
    func playActionButton() {
        
        guard let songUrl = song.previewUrl, let streamUrl = URL(string: songUrl) else { return }
        player = AVPlayer(url: streamUrl)
        
        guard let maxValue = player.currentItem?.asset.duration.seconds else { return }
        self.songDetailView.slider.maximumValue = Float(maxValue)
        
        if player.timeControlStatus == .playing {
            self.songDetailView.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
        } else {
            self.songDetailView.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
        }
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { time in
            self.songDetailView.leftTimeLable.text = String(format: "%.f", time.seconds)
            let rightTime = maxValue - time.seconds
            self.songDetailView.rightTimeLable.text = String(format: "%.f", -rightTime)
            self.songDetailView.slider.value = Float(time.seconds)
        }
    }
    
    func sliderDidChanged(value: Float) {
        player.seek(to: CMTime(seconds: Double(value), preferredTimescale: 1000))
        self.songDetailView.leftTimeLable.text = "\(value)"
    }
}
