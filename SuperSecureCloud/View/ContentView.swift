//
//  ContentView.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@FocusState private var focusedField: Focus?
	
    var body: some View {
		NavigationView {
			Form {
				Section {
					TextField("Username", text: $viewModel.username)
						.focused($focusedField, equals: .username)
					if let usernameError = viewModel.usernameValidationError {
						Text(usernameError.uiDescription)
							.foregroundColor(.red)
					}
					
					SecureField("Password", text: $viewModel.password)
						.focused($focusedField, equals: .password)
					if let passwordError = viewModel.passwordValidationError {
						Text(passwordError.uiDescription)
							.foregroundColor(.red)
					}
				}
				
				if let generalError = viewModel.generalError {
					Section {
						Text(generalError.localizedDescription)
					}
				}
				
				Section {
					Button("Sign Up") {
						focusedField = nil
					}
					.disabled(viewModel.passwordValidationError != nil || viewModel.usernameValidationError != nil)
				}
			}
			.navigationTitle("SuperSecureCloud")
			.onAppear {
				viewModel.start()
			}
		}
    }
}

extension ContentView {
	enum Focus: Hashable {
		case username
		case password
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
