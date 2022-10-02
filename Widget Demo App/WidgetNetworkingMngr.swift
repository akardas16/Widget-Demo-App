//
//  WidgetNetworkingMngr.swift
//  Widget Demo App
//
//  Created by Abdullah Kardas on 18.09.2022.
//

import Foundation
import SwiftUI
import Combine

class WidgetNetworkingMngr{
    
    static let instance = WidgetNetworkingMngr()
    private let baseUrl = "https://api.github.com"
    
    let decoder = JSONDecoder()
    
    private init(){
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func getRepo(from url:RepoURLs) async throws -> RepositoryModel {
        guard let url = URL(string: url.name) else {throw URLError(.badURL)}
        
        do {
            let (data,_) = try await URLSession.shared.data(from: url)
            do {
                return try decoder.decode(RepositoryModel.self, from: data)
            } catch let error {
                print(error)
                throw URLError(.badURL)
            }
            
        
        } catch  {
            print("32352352dfgdfgd")
            throw URLError(.badURL)
        }
       
        
    }
    
    func downloadImage(url:String) async throws -> UIImage{
        do {
            guard let url = URL(string: url) else {
                print("url is not correct")
                throw URLError(.badURL)}
            let (data,response) = try await URLSession.shared.data(from: url)
            guard let image = handleResponse(data: data, response: response) else {
                throw URLError(.badServerResponse)
            }
            return image
        } catch let error {
            print(error.localizedDescription)
            throw error
        }
       
    }
    
    func handleResponse(data:Data?, response:URLResponse?) -> UIImage?{
        guard let data = data, let image = UIImage(data: data), let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil}
         return image
    }

}

enum RepoURLs{
    case videoPlayer
    case sideMenu
    case tabBars
    
    var name:String{
        
        switch self {
        case .videoPlayer:
            return "https://api.github.com/repos/akardas16/VideoPlayer"
        case .sideMenu:
            return "https://api.github.com/repos/akardas16/SideMenu"
        case .tabBars:
            return "https://api.github.com/repos/akardas16/SwiftUI-Custom-Tab-Bars"
        }
    }
}

