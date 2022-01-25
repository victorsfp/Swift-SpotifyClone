//
//  RecommendationsResponse.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 25/01/22.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
