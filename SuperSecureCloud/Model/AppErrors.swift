//
//  AppErrors.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 25/05/2022.
//

import Foundation

// MARK: - Networking
enum NetworkingError: Error {
	case requestFailed
	case parsingFailed
}

// MARK: - Validation
enum ValidationError {
	
	// MARK: Username
	enum Username: Error {
		case tooLong
		case tooShort
		case alreadyExists
		
		var uiDescription: String {
			switch self {
				case .tooLong		: return "Username too long"
				case .tooShort		: return "Username too short"
				case .alreadyExists	: return "This username already exists"
			}
		}
	}
	
	// MARK: Password
	enum Password: Error {
		case tooLong
		case tooShort
		case alreadyExists
		case insecure
		
		var uiDescription: String {
			switch self {
				case .tooLong		: return "Password is too long"
				case .tooShort		: return "Password is too short"
				case .alreadyExists	: return "Password already exists"
				case .insecure		: return "Password is insecure"
			}
		}
	}
}
