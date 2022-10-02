//
//  RepositoryModel.swift
//  Widget Demo App
//
//  Created by Abdullah Kardas on 18.09.2022.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct RepositoryModel: Decodable {
    let name:String
    let owner: Owner
    let hasIssues:Bool
    let forks, openIssues, watchers: Int
    let pushedAt: String
    let description:String

    static let testRepo = RepositoryModel(name: "SideMenu", owner: Owner(avatarUrl: "https://avatars.githubusercontent.com/u/28716129?v=4"), hasIssues: true, forks: 1, openIssues: 0, watchers: 13, pushedAt: "2022-08-21T08:16:02Z", description: "This is describtion")
    
//    enum CodingKeys: String, CodingKey {
//        case name
//        case owner
//        case hasIssues = "has_issues"
//        case forks
//        case openIssues = "open_issues"
//        case watchers
//        case pushedAt = "pushed_at"
//    }
}

// MARK: - Owner
struct Owner: Decodable {
    let avatarUrl: String
   
    
//    enum CodingKeys: String, CodingKey {
//        case avatarURL = "avatar_url"
//    }
}

