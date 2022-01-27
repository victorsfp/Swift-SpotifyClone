//
//  ViewController.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 21/01/22.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [NewReleasesCellViewModel]) // 1
    case featuredPalylists(viewModels: [FeaturedPlaylistCellViewModel]) // 2
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel]) //3
}

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return HomeViewController.createSectionLayout(section: sectionIndex)
    })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Home"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettings))
        
        

        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        
        collectionView.register(FeaturedPalylistsCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPalylistsCollectionViewCell.identifier)
        
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
    
    
    
    
    private func fetchData(){
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesResponse?
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        
        //New Releases
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
                case.success(let model):
                    newReleases = model
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
            }
        }
        
        
        //Featured Playlists
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            
            switch result {
                case.success(let model):
                    featuredPlaylist = model
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
            }
        }
        
        
        //Recommend Tracks
        APICaller.shared.getRecommendationsGenres { result in
            switch result {
                case .success(let model):
                    let genres = model.genres
                    var seeds = Set<String>()
                    while seeds.count < 5 {
                        if let random = genres.randomElement() {
                            seeds.insert(random)
                        }
                    }
                
                    APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
                        defer {
                            group.leave()
                        }
                        
                        switch recommendedResult {
                            case.success(let model):
                                recommendations = model
                                break
                            case .failure(let error):
                                print(error.localizedDescription)
                                break
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    break
            }
        }
        
        group.notify(queue: .main) {
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommendations?.tracks else {
                return
            }
            
            self.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
        
        
    }
    
    private func configureModels(newAlbums: [Album], playlists: [Playlist], tracks: [AudioTrack]){
        //Configure Models
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(
                name: $0.name,
                artworkURL: URL(string: $0.images.first?.url ?? ""),
                numberOfTracks: $0.total_tracks,
                artistName: $0.artists.first?.name ?? "-"
            )
        })))
        
        sections.append(.featuredPalylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(
                name: $0.name,
                artworkUrl: URL(string: $0.images.first?.url ?? ""),
                creatorName: $0.owner.display_name
            )
        })))
        
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTrackCellViewModel(
                name: $0.name,
                artistName: $0.artists.first?.name ?? "",
                artworkURL: URL(string: $0.album.images.first?.url ?? "")
            )
        })))
        collectionView.reloadData()
    }
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}



extension HomeViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
            case .newReleases(let viewModels):
                return viewModels.count
            case .featuredPalylists(let viewModels):
                return viewModels.count
            case .recommendedTracks(let viewModels):
                return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        
        switch type {
            case .newReleases(let viewModels):
            
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                    for: indexPath
                ) as? NewReleaseCollectionViewCell else { return UICollectionViewCell() }
                
                
                let viewModel = viewModels[indexPath.row]
                
                cell.configure(with: viewModel)
            
                return cell
            
            case .featuredPalylists(let viewModels):
            
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: FeaturedPalylistsCollectionViewCell.identifier,
                    for: indexPath
                ) as? FeaturedPalylistsCollectionViewCell else { return UICollectionViewCell() }
                
                let viewModel = viewModels[indexPath.row]
                cell.configure(with: viewModel)
            
                return cell
            
            case .recommendedTracks(let viewModels):
            
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                    for: indexPath
                ) as? RecommendedTrackCollectionViewCell else { return UICollectionViewCell() }
                
                let viewModel = viewModels[indexPath.row]
                cell.configure(with: viewModel)
            
                return cell
        }
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        if indexPath.section == 0 {
//            cell.backgroundColor = .systemGreen
//        } else if indexPath.section == 1 {
//            cell.backgroundColor = .systemPink
//        } else if indexPath.section == 2 {
//            cell.backgroundColor = .systemPink
//        }
//        return cell
    }
    
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        
        switch section {
            case 0:
                //ITEM
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                
                //GROUP
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)), subitem: item, count: 3)
                
                let horizontalGgroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)), subitem: verticalGroup, count: 1)
                
                //SECTION
                let section = NSCollectionLayoutSection(group: horizontalGgroup)
                section.orthogonalScrollingBehavior = .groupPaging
                return section
            case 1:
                //ITEM
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                
                //GROUP
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: item, count: 2)
                
                let horizontalGgroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: verticalGroup, count: 1)
                
                //SECTION
                let section = NSCollectionLayoutSection(group: horizontalGgroup)
                section.orthogonalScrollingBehavior = .continuous
                return section
            case 2:
                //ITEM
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                
                //GROUP
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)), subitem: item, count: 1)
                
                //SECTION
                let section = NSCollectionLayoutSection(group: group)
                return section
            
            default:
                //ITEM
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                
                //GROUP
                let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)), subitem: item, count: 1)
                
                
                //SECTION
                let section = NSCollectionLayoutSection(group: group)
                return section
        }
        
        
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
}
