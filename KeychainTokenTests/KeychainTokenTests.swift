//
//  KeychainTokenTests.swift
//  KeychainTokenTests
//
//  Created by Dmytro Mazalov on 21.09.2025.
//

import XCTest
@testable import KeychainToken

final class KeychainTokenTests: XCTestCase {
    private var tm: TokenManager!
    
    override func setUp() {
        super.setUp()
        tm = TokenManager(store: MockStore())
    }
    
    func testAccessToken_SetGetDelete() throws {
        XCTAssertNil(tm.getAccessToken())
        try tm.setAccessToken("abc")
        XCTAssertEqual(tm.getAccessToken(), "abc")
        try tm.clearAccessToken()
        XCTAssertNil(tm.getAccessToken())
        XCTAssertEqual(tm.getLastAccessToken(), "abc")
    }

    func testBotToken_IndependentFromAccess() throws {
        try tm.setAccessToken("access")
        try tm.setAnyOtherValue("value")
        XCTAssertEqual(tm.getAccessToken(), "access")
        XCTAssertEqual(tm.getAnyOtherValue(), "value")

        try tm.clearAnyOtherValue()
        XCTAssertEqual(tm.getAccessToken(), "access")
        XCTAssertNil(tm.getAnyOtherValue())
    }

    func testIdempotency() throws {
        try tm.clearAnyOtherValue()
        try tm.clearAnyOtherValue()
        XCTAssertNil(tm.getAccessToken())

        try tm.setAccessToken("x")
        try tm.setAccessToken("x")
        XCTAssertEqual(tm.getAccessToken(), "x")
    }
}
