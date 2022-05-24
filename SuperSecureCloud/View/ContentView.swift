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
				usernameTextFieldSection
				passwordTextFieldSection
				maybeGeneralErrorIndicatorSection
				signUpButtonSection
			}
			.navigationTitle("Choose Credentials")
			.onAppear {
				viewModel.start()
			}
		}
    }
}

// MARK: - Subviews
extension ContentView {
	private var usernameTextFieldSection: some View {
		Section("must be 4-16 characters long and unique") {
			TextField("Username", text: $viewModel.username)
				.focused($focusedField, equals: .username)
			if let usernameError = viewModel.usernameValidationError {
				Text(usernameError.uiDescription)
					.foregroundColor(.red)
			}
		}
	}
	
	private var passwordTextFieldSection: some View {
		Section("must be 8-16 characters long, unique and secure") {
			SecureField("Password", text: $viewModel.password)
				.focused($focusedField, equals: .password)
			if let passwordError = viewModel.passwordValidationError {
				Text(passwordError.uiDescription)
					.foregroundColor(.red)
			}
		}
	}
	
	private var signUpButtonSection: some View {
		Section("By signing up you agree to our terms and conditions") {
			Button("Sign Up") {
				focusedField = nil
			}
			.disabled(viewModel.passwordValidationError != nil ||
					  viewModel.usernameValidationError != nil ||
					  viewModel.generalError != nil ||
					  viewModel.username.isEmpty ||
					  viewModel.password.isEmpty)
		}
	}
	
	private var maybeGeneralErrorIndicatorSection: some View {
		Group {
			if let generalError = viewModel.generalError {
				Section {
					Text(generalError.localizedDescription)
						.foregroundColor(.red)
				}
			}
		}
	}

}

// MARK: - ContentView.Focus
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
