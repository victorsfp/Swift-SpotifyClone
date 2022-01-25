//
//  NewReleasesResponse.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 25/01/22.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let href: String
    let items: [Album]
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int
}

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let href: String
    let id: String
    let artists: [Artists]
    let images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int

}
