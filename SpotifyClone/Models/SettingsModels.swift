//
//  SettingsModels.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 25/01/22.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
