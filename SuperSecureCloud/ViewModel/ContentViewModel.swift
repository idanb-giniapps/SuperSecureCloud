//
//  ContentViewModel.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
	private let validator: SignUpValidatorProtocol
	private var usernameValidationTask: Task<Void, Never>?
	private var passwordValidationTask: Task<Void, Never>?
	
	@Published var username: String = ""
	@Published var usernameValidationError: ValidationError.Username?
	
	@Published var password: String = ""
	@Published var passwordValidationError: ValidationError.Password?
	
	@Published var generalError: Error?
	
	
	init(validator: SignUpValidatorProtocol = DependencyProvider.signUpValidator) {
		self.validator = validator
	}
	
	/// Start listening to `username` and `password` input changes and and validate them continuously.
	func start() {
		startValidatingUsername()
		startValidatingPassword()
	}
	
	private func startValidatingUsername() {
		usernameValidationTask = Task {
			let usernameValues = $username
				.debounce(for: 0.5, scheduler: RunLoop.main)
				.values
			
			for await usernameValue in usernameValues {
				do {
					try await validator.validate(username: usernameValue)
					await MainActor.run {
						withAnimation { usernameValidationError = nil }
					}
				} catch {
					if let usernameError = error as? ValidationError.Username {
						await MainActor.run {
							withAnimation { usernameValidationError = usernameError }
						}
					}
				}
			}
		}
	}
	
	private func startValidatingPassword() {
		passwordValidationTask = Task {
			let passwordValues = $password
				.debounce(for: 0.5, scheduler: RunLoop.main)
				.values
			
			for await passwordValue in passwordValues {
				do {
					try await validator.validate(password: passwordValue)
					await MainActor.run {
						withAnimation { passwordValidationError = nil }
					}
				} catch {
					if let passwordError = error as? ValidationError.Password {
						await MainActor.run {
							withAnimation { passwordValidationError = passwordError }
						}
					}
				}
			}
		}
	}
}
