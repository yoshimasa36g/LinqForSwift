//
//  EnumerableSSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/26.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import XCTest

class EnumerableGroupingTests: XCTestCase {

    let enumerableBooks = Enumerable.from(books)

    func testGroupBy() {
        let result = enumerableBooks.groupBy { $0.publicationYear > 1900 }
        XCTAssertEqual(2, result.count())
        for r in result {
            let elements = r.elements.toArray()
            if r.key {
                XCTAssertEqual(1905, elements[0].publicationYear)
                XCTAssertEqual(1929, elements[1].publicationYear)
            } else {
                XCTAssertEqual(1866, elements[0].publicationYear)
                XCTAssertEqual(1472, elements[1].publicationYear)
                XCTAssertEqual(1667, elements[2].publicationYear)
            }
        }
    }

    func testGroupByWithElementSelector() {
        let result = enumerableBooks.groupBy({ $0.publicationYear > 1900 }) { $0.publicationYear }
        XCTAssertEqual(2, result.count())
        for r in result {
            let elements = r.elements.toArray()
            if r.key {
                XCTAssertEqual(1905, elements[0])
                XCTAssertEqual(1929, elements[1])
            } else {
                XCTAssertEqual(1866, elements[0])
                XCTAssertEqual(1472, elements[1])
                XCTAssertEqual(1667, elements[2])
            }
        }
    }

    func testGroupByWithKey() {
        let result = enumerableBooks.groupBy({ $0.publicationYear > 1900 }) {
            (key: Bool, books: Enumerable<Book>) -> (key: Bool, count: Int) in
            return (key, books.count())
        }
        XCTAssertEqual(2, result.count())
        result.each { (group: (key: Bool, count: Int)) in
            if group.key {
                XCTAssertEqual(2, group.count)
            } else {
                XCTAssertEqual(3, group.count)
            }
        }
    }

    func testGroupByWithResultSelector() {
        let result = enumerableBooks
            .groupBy({ $0.publicationYear > 1900 },
                     elementSelector: { $0.publicationYear },
                     resultSelector: {
                        (key: Bool, books: Enumerable<Int>) -> (key: Bool, average: Double) in
                        return (key, books.average { $0 })
                     })
        XCTAssertEqual(2, result.count())
        result.each { (group: (key: Bool, average: Double)) in
            if group.key {
                XCTAssertEqual(1917, group.average)
            } else {
                XCTAssertEqual("1668.3", NSString(format: "%.1f", group.average))
            }
        }
    }
}
