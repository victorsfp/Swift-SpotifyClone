//
//  NewReleaseCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 25/01/22.
//

import UIKit
import SDWebImage

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"
    
    private let albumcoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumcoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        contentView.clipsToBounds = true
        contentView.addSubview(artistNameLabel)
        
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 10
        let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 10, height: contentView.height - 10))
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        
        //IMAGE
        albumcoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        //ALBUM NAME LABEL
        let albumLabelHeight = min(60, albumLabelSize.height)
        albumNameLabel.frame = CGRect(
            x: albumcoverImageView.right + 10,
            y: 5,
            width: albumLabelSize.width,
            height: albumLabelHeight
        )
        
        artistNameLabel.frame = CGRect(
            x: albumcoverImageView.right + 10,
            y: albumNameLabel.bottom,
            width: contentView.width - albumcoverImageView.right - 5,
            height: 30
        )
        
        numberOfTracksLabel.frame = CGRect(
            x: albumcoverImageView.right + 10,
            y: contentView.bottom - 44,
            width: numberOfTracksLabel.width,
            height: 44
        )
        
        
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumcoverImageView.image = nil
    }
    
    func configure(with viewModel: NewReleasesCellViewModel){
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumcoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
