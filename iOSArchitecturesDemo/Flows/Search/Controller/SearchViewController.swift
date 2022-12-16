//
//  ViewController.swift
//  iOSArchitecturesDemo
//
//  Created by ekireev on 14.02.2018.
//  Copyright © 2018 ekireev. All rights reserved.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Private Properties
    private var searchView: SearchView {
        return self.view as! SearchView
    }
    
    private struct Constants {
        static let reuseIdentifier = "reuseId"
    }
    
    private let searchService = ITunesSearchService()
    private var searchAppResults = [ITunesApp]()
    private var searchSongResults = [ITunesSong]()
    
    private var searchMode: SearchMode = .apps
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        self.view = SearchView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.searchView.searchBar.delegate = self
        self.searchView.delegate = self
        
        self.searchView.tableView.register(AppCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
        self.searchView.tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.reuseIdentifier)
        self.searchView.tableView.delegate = self
        self.searchView.tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.throbber(show: false)
    }
    
    // MARK: - Private
    private func throbber(show: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
    
    private func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNoResults() {
        self.searchView.emptyResultView.isHidden = false
    }
    
    private func hideNoResults() {
        self.searchView.emptyResultView.isHidden = true
    }
    
    private func requestApps(with query: String) {
        self.throbber(show: true)
        self.searchAppResults = []
        self.searchView.tableView.reloadData()
        
        self.searchService.getApps(forQuery: query) { [weak self] result in
            guard let self = self else { return }
            self.throbber(show: false)
            result
                .withValue { apps in
                    guard !apps.isEmpty else {
                        self.searchAppResults = []
                        self.showNoResults()
                        return
                    }
                    self.hideNoResults()
                    self.searchAppResults = apps
                    
                    self.searchView.tableView.isHidden = false
                    self.searchView.tableView.reloadData()
                    
                    self.searchView.searchBar.resignFirstResponder()
                }
                .withError {
                    self.showError(error: $0)
                }
        }
    }
    
    private func requestSongs(with query: String) {
        self.throbber(show: true)
        self.searchAppResults = []
        self.searchView.tableView.reloadData()
        
        self.searchService.getSongs(forQuery: query) { [weak self] result in
            guard let self = self else { return }
            self.throbber(show: false)
            result
                .withValue { songs in
                    guard !songs.isEmpty else {
                        self.searchSongResults = []
                        self.showNoResults()
                        return
                    }
                    self.hideNoResults()
                    self.searchSongResults = songs
                    
                    self.searchView.tableView.isHidden = false
                    self.searchView.tableView.reloadData()
                    
                    self.searchView.searchBar.resignFirstResponder()
                }
                .withError {
                    self.showError(error: $0)
                }
        }
    }
    
    private func updateTableView() {
        searchView.tableView.isHidden = false
        searchView.tableView.reloadData()
        searchView.searchBar.resignFirstResponder()
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchMode {
        case .apps:
            return searchAppResults.count
        case .songs:
            return searchSongResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchMode {
        case .apps:
            
            let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath)
            guard let cell = dequeuedCell as? AppCell else {
                return dequeuedCell
            }
            let app = self.searchAppResults[indexPath.row]
            let cellModel = AppCellModelFactory.cellModel(from: app)
            cell.configure(with: cellModel)
            return cell
            
        case .songs:
            
            let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: SongCell.reuseIdentifier, for: indexPath)
            guard let cell = dequeuedCell as? SongCell else {
                return dequeuedCell
            }
            let song = searchSongResults[indexPath.row]
            let cellModel = SongCellModelFactory.getCellModel(model: song)
            cell.configure(model: cellModel)
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch searchMode {
            
        case .apps:
            let app = searchAppResults[indexPath.row]
            let appDetaillViewController = AppDetailViewController(app: app)
            navigationController?.pushViewController(appDetaillViewController, animated: true)
            
        case .songs:
            let song = searchSongResults[indexPath.row]
            print(song)
        }
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else {
            searchBar.resignFirstResponder()
            return
        }
        if query.count == 0 {
            searchBar.resignFirstResponder()
            return
        }
        
        switch searchMode {
        case .apps:
            self.requestApps(with: query)
        case .songs:
            self.requestSongs(with: query)
        }
    }
}

extension SearchViewController: SearchModeControlDelegate {
    
    func didSelectSearchMode(with mode: SearchMode) {
        self.searchMode = mode
        self.updateTableView()
    }
}
