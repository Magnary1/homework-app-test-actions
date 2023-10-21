//
//  ContentView.swift
//  Exercise5_Hayes_Jonathan
//
//  Created by jonathan school on 10/1/23.
//

import SwiftUI
import Foundation
import Combine
import SDWebImageSwiftUI

// MARK: - Restaurant Struct
struct Restaurant: Identifiable, Decodable {
    let name: String
    let free: String
    let phone: String
    let logo: String
    let map: String
    let lots: String
    let about: String

    var id: String {
        name
    }
}

// MARK: - ImageView
struct ImageView: View {
    let url: URL?
    let isLogo: Bool
    
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else if phase.error != nil {
                Color.red
            }
        }
        .frame(width: isLogo ? 100 : nil, height: isLogo ? 100 : nil)
    }
}


// MARK: - RestaurantInfoView
struct RestaurantInfoView: View {
    let restaurant: Restaurant
    var body: some View {
        Text(restaurant.lots)
            .bold()
            .multilineTextAlignment(.center)
        Text(restaurant.about)
            .multilineTextAlignment(.center)
        Text(restaurant.phone)
            .multilineTextAlignment(.center)
    }
}



// MARK: - DetailsView
struct DetailsView: View {
    let restaurant: Restaurant
        
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Landscape view
                HStack(spacing: 10) {
                    ImageView(url: URL(string: restaurant.map), isLogo: false)
                    
                    VStack(alignment: .center, spacing: 10) {
                        ImageView(url: URL(string: restaurant.logo), isLogo: true)
                        
                        RestaurantInfoView(restaurant: restaurant)
                        Spacer()
                    }
                }
            } else {
                // Portrait view
                VStack(alignment: .center, spacing: 10) {
                    ImageView(url: URL(string: restaurant.map), isLogo: false)
                    
                    ImageView(url: URL(string: restaurant.logo), isLogo: true)
                    
                    RestaurantInfoView(restaurant: restaurant)

                    Spacer()
                }
            }
        }
        .padding()
    }
}

// MARK: - RestaurantRowView
struct RestaurantRowView: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ImageView(url: URL(string: restaurant.logo), isLogo: true)

                Spacer()
                
                Text(restaurant.free)
                    .font(.system(size: 20))
                    .bold()
            }
            
            Divider()
        }
        .background(Color.white)
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State private var restaurants = [Restaurant]()

    var body: some View {
        NavigationView {
            List(restaurants) { restaurant in
                NavigationLink(destination: DetailsView(restaurant: restaurant)) {
                    RestaurantRowView(restaurant: restaurant)
                }
                .listRowSeparator(.hidden)
            }
            .task {
                await fetch()
            }
            .listStyle(.plain)
        }
    }
    
    func fetch() async {
        do {
            let url = URL(string: "https://m.cpl.uh.edu/courses/ubicomp/fall2022/webservice/restaurant/restaurants.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            self.restaurants = try JSONDecoder().decode([Restaurant].self, from: data)
        } catch {
            print("Error: \(error)")
        }
    }
}
