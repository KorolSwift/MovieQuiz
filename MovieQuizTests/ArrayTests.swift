//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Ди Di on 02/02/25.

import XCTest
@testable import MovieQuiz


final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() {
        // Given
        let array = [1, 1, 2, 3, 5]
        // When
        let value = array[safe: 1]
        // Then
        XCTAssertNotNil(value)
    }
}
