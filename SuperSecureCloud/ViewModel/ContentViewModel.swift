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
	
	init(validator: SignUpValidatorProtocol = DependencyProvider.signUpValidator) {
		self.validator = validator
	}
	
	@Published var username: String = ""
	@Published var usernameValidationError: ValidationError.Username?

	@Published var password: String = ""
	@Published var passwordValidationError: ValidationError.Password?
	
	@Published var generalError: Error? = nil
	private var subscriptions = Set<AnyCancellable>()
	
	func start() {
		_ = _start
	}
	
	/// Start listening to `username` and `password` input changes and and validate them continuously.
	private lazy var _start: Void = {
		$username
			.dropFirst()
			.debounce(for: 0.8, scheduler: RunLoop.main)
			.sink { [weak self] username in
				do {
					_ = try self?.validator.validate(username: username)
					withAnimation { self?.usernameValidationError = nil }
				} catch {
					if let usernameError = error as? ValidationError.Username {
						withAnimation { self?.usernameValidationError = usernameError }
					}
				}
			}
			.store(in: &subscriptions)
		
		$password
			.dropFirst()
			.debounce(for: 0.8, scheduler: RunLoop.main)
			.sink { [weak self] password in
				do {
					_ = try self?.validator.validate(password: password)
					withAnimation { self?.passwordValidationError = nil }
				} catch {
					if let passwordError = error as? ValidationError.Password {
						withAnimation { self?.passwordValidationError = passwordError }
					}
				}
			}
			.store(in: &subscriptions)
	}()
	
}
