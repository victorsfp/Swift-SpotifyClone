//
//  PlaylistDetailsResponse.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 28/01/22.
//

import Foundation


struct PlaylistDetailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    //let `public`: Bool
    let tracks: PlaylistTracksResponse
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
}


struct PlaylistItem: Codable {
    let track: AudioTrack
}
