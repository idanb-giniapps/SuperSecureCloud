//
//  SignUpValidatorTests.swift
//  SignUpValidatorTests
//
//  Created by Idan Birman on 22/05/2022.
//

import XCTest
@testable import SuperSecureCloud

class SignUpValidatorTests: XCTestCase {
	var sut: SignUpValidator! // system under test
	
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		sut = SignUpValidator(networkingService: MockNetworkingService())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
		sut = nil
    }
		
	func test_username_too_short() async {
		// Arrange
		let shortUsernames = ["A", "Ab", "Abc"]
		
		for username in shortUsernames {
			// Act
			do {
				try await sut.validate(username: username)
				
				// Assert
				XCTFail("All usernames are expected to fail.")
			}
			catch {
				assertThrownError(error, is: ValidationError.Username.tooShort)
			}
		}
	}
	
	func test_password_too_short() async {
		// Arrange
		let shortPasswords = ["1", "12", "abc", "girl", "rufus", "banana", "banana1"]
		
		for password in shortPasswords {
			// Act
			do {
				try await sut.validate(password: password)
				XCTFail("All passwords are expected to be invalid.")
			}
			// Assert
			catch {
				assertThrownError(error, is: ValidationError.Password.tooShort)
			}
		}
	}
	
	func test_username_already_exists_case_sensitive() async {
		
		// Arrange
		let existingUsernameVariations = ["dude7", "Dude7", "dUdE7", "DUDE7"]
		
		for username in existingUsernameVariations {
			// Act
			do {
				try await sut.validate(username: username)
				XCTFail("All variations are expected to be invalid.")
			}
			
			// Assert
			catch {
				assertThrownError(error, is: ValidationError.Username.alreadyExists)
			}
		}
	}
	
	func test_username_too_long() async {
		// Arrange
		let longUsername = "therealslimshady1"
		
		// Act
		do {
			try await sut.validate(username: longUsername)
			XCTFail("Username is expected to be invalid.")
		}
		
		// Assert
		catch {
			assertThrownError(error, is: ValidationError.Username.tooLong)
		}
	}
	
	func test_password_is_insecure() async {
		// Arrange
		let insecurePasswords = ["12345678", "password"]
		
		for password in insecurePasswords {
			
			// Act
			do {
				try await sut.validate(password: password)
				
				// Assert
				XCTFail("All passwords are insecure.")
			}
			
			catch {
				assertThrownError(error, is: ValidationError.Password.insecure)
			}
		}
		
	}
	
	func test_acceptable_usernames_are_validated() async {
		// Arrange
		let okUsernames = ["danny5", "mr_man", "lilmama"]
		for username in okUsernames {
			
			// Act
			do {
				let validatedUsername = try await sut.validate(username: username)
				
				// Assert
				XCTAssertEqual(validatedUsername, username)
			}
			catch {
				XCTFail("All usernames are expected to be validated.")
			}
		}
	}
	
	func test_password_already_exists() async {
		// Arrange
		let existingPasswords = ["appetizer-broadside-unsure",
								 "edge-cardinal-overstate",
								 "tinker-partridge-scalded"]
		
		for password in existingPasswords {
			// Act
			do {
				try await sut.validate(password: password)
				XCTFail("All passwords are expected to be invalid.")
			}
			
			// Assert
			catch {
				assertThrownError(error, is: ValidationError.Password.alreadyExists)
			}
		}
	}
	
	func test_password_too_long() async {
		// Arrange
		let longPassword = "bfu24bhfu942bf9u2u4fb3924bfu92bf9u2b9ubf92u39bf9u3b"
		
		// Act
		do {
			try await sut.validate(password: longPassword)
			XCTFail("Password is expected to be invalid.")
		}
		
		// Assert
		catch {
			assertThrownError(error, is: ValidationError.Password.tooLong)
		}
	}
	
	func test_acceptable_passwords_are_validated() async {
		// Arrange
		let okPasswords = ["g3927gf92g", "fhudgf92ueg", "j803rh8gh3"]
		
		for password in okPasswords {
			// Act
			do {
				let validatedPassword = try await sut.validate(password: password)
				
				// Assert
				XCTAssertEqual(validatedPassword, password)
			} catch {
				XCTFail("All passwords are expected to be validated.")
			}
		}
	}
	
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
}

extension SignUpValidatorTests {
	
	private func assertThrownError<T: Equatable & Error>(_ error: Error, is specificError: T) {
		guard let e = error as? T else { return XCTFail("Error is of the wrong type") }
		XCTAssertEqual(e, specificError)
	}
}
