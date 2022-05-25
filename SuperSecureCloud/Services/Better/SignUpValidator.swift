//
//  SignUpValidationService.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import Foundation
import Combine

protocol SignUpValidatorProtocol {
	@discardableResult func validate(username: String) async throws -> String
	@discardableResult func validate(password: String) async throws -> String
}

class SignUpValidator: SignUpValidatorProtocol {
	// MARK: - Properties
	private let networkingService: NetworkingServiceProtocol
	
	private var validationInfo: SignUpValidationInfo {
		get async {
			let remoteValidationInfo = try? await networkingService.bringSignUpValidationInfo()
			return remoteValidationInfo ?? .default
		}
	}
	
	// MARK: - Object Lifecycle
	init(networkingService: NetworkingServiceProtocol = DependencyProvider.networkingService) {
		self.networkingService = networkingService
	}
	
	// MARK: - Methods (Internal)
	@discardableResult
	func validate(username: String) async throws -> String {
		
		if username.count < 4 {
			throw ValidationError.Username.tooShort
		}
		else if username.count > 16 {
			throw ValidationError.Username.tooLong
		}
		else if await validationInfo
			.existingUsernames
			.map(\.localizedLowercase)
			.contains(username.localizedLowercase) { throw ValidationError.Username.alreadyExists }
		
		return username
	}
	
	@discardableResult
	func validate(password: String) async throws -> String {
		
		if password.count < 8 {
			throw ValidationError.Password.tooShort
		}
		
		else if password.count > 32 {
			throw ValidationError.Password.tooLong
		}
		
		else if await validationInfo
			.existingPasswords
			.map(\.localizedLowercase)
			.contains(password.localizedLowercase) { throw ValidationError.Password.alreadyExists }
		
		else if await validationInfo
			.insecurePasswords
			.map({ $0.lowercased() })
			.contains(password.localizedLowercase) { throw ValidationError.Password.insecure }
		
		return password
	}

}
