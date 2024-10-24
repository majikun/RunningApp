//
//  AboutView.swift
//  RunningApp
//
//  Created by Jake Ma on 10/24/24.
//
import SwiftUI

struct AboutView: View { // New AboutView struct
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("about_this_app", comment: ""))
                .font(.largeTitle)
                .padding()
            
            Text(NSLocalizedString("about_description", comment: ""))
                .font(.body)
                .padding()
                .multilineTextAlignment(.center)
            
            Link(NSLocalizedString("github_repository", comment: ""), destination: URL(string: "https://github.com/majikun/RunningApp")!)
                .font(.headline)
                .padding()
                .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
    }
}
