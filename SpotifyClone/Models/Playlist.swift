//
//  Playlist.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 21/01/22.
//

import Foundation

struct Playlist: Codable {
    let description: String?
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
    let type: String
    let uri: String
}
