//
//  Artist.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 21/01/22.
//

import Foundation

struct Artists: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
