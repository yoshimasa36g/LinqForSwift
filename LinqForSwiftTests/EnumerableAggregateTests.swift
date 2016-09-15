//
//  EnumerableTSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/29.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import XCTest

class EnumerableAggregateTests: XCTestCase {
    let enumerableBooks = Enumerable.from(books)

    func testAggregate() {
        let accumulator = { (_ working: Book, next: Book) -> Book in
            return working.publicationYear < next.publicationYear ? working : next
        }
        let result = enumerableBooks.aggregate(accumulator)
        XCTAssertEqual("La Divina Commedia", result?.title)
    }

    func testAggregateWithSeed() {
        let accumulator = { (_ working: Int, next: Book) -> Int in
            return working + next.publicationYear
        }
        let result = enumerableBooks.aggregate(1, accumulator: accumulator)
        XCTAssertEqual(8840, result)
    }

    func testAggregateWithResultSelector() {
        let accumulator = { (_ working: String, next: Book) -> String in
            return working.characters.count < next.title.characters.count ?  next.title : working
        }
        let resultSelector = { (_ working: String) -> String in
            return working.uppercased()
        }
        let result = enumerableBooks.aggregate("", accumulator: accumulator, resultSelector: resultSelector)
        XCTAssertEqual("LES ENFANTS TERRIBLES", result)
    }

    func testAverage() {
        let result = enumerableBooks.average { $0.publicationYear }
        XCTAssertEqual(8839.0 / 5.0, result)
    }

    func testCount() {
        let count = enumerableBooks.count()
        XCTAssertEqual(5, count)
    }

    func testCountWithPredicate() {
        let count = enumerableBooks.count { $0.publicationYear > 1900 }
        XCTAssertEqual(2, count)
    }

    func testMax() {
        let result = enumerableBooks.max { $0.publicationYear }
        XCTAssertEqual(1929, result!)
    }

    func testMin() {
        let result = enumerableBooks.min { $0.publicationYear }
        XCTAssertEqual(1472, result!)
    }

    func testSum() {
        let result = enumerableBooks.sum { (book: Book) -> Int in book.publicationYear }
        XCTAssertEqual(8839, result)
    }
}
