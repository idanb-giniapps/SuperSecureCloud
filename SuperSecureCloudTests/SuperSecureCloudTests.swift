//
//  SuperSecureCloudTests.swift
//  SuperSecureCloudTests
//
//  Created by Idan Birman on 22/05/2022.
//

import XCTest
@testable import SuperSecureCloud

class SuperSecureCloudTests: XCTestCase {
	var sut: SignUpValidator!
	
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		sut = SignUpValidator(networkingService: MockNetworkingService())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
		sut = nil
    }
	
	func test_password_too_short() async {
		// Arrange
		let password = "123"
		
		var thrownError: Error?
		// Act
		do {
			_ = try await sut.validate(password: password)
		} catch {
			thrownError = error
		}
		
		// Assert
		XCTAssertEqual(thrownError as! ValidationError.Password, ValidationError.Password.tooShort)
	}
	
	func test_username_too_short() async {
		// Arrange
		let shortUsernames = ["A", "Ab", "Abc"]
		
		// Act
		for username in shortUsernames {
			do {
				try await sut.validate(username: username)
			} catch {
				guard let usernameError = error as? ValidationError.Username,
					  usernameError == .tooShort
				else {
					// Assert
					XCTFail()
					return
				}
			}
		}
	}
	
	func test_username_already_exists_case_sensitive() async {
		
		// Arrange
		let usernameAttempts = ["dude7", "Dude7", "dUdE7", "DUDE7"]
		
		// Act
		for username in usernameAttempts {
			do {
				try await sut.validate(username: username)
			} catch {
				guard let usernameError = error as? ValidationError.Username,
					  usernameError == .alreadyExists
				else {
					// Assert
					XCTFail(username)
					return
				}
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
