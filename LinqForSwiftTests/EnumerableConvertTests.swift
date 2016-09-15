//
//  EnumerableConvertSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/05/03.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import XCTest

class EnumerableConvertTests: XCTestCase {
    let enumerableBooks = Enumerable.from(books)

    func testToArray() {
        let books = enumerableBooks.toArray()
        Enumerable<Int>.from(0..<books.count).each {
            (i: Int) -> Void in
            let originalBook: Book = books[i]
            XCTAssertEqual(originalBook.title, books[i].title)
            XCTAssertEqual(originalBook.author, books[i].author)
            XCTAssertEqual(originalBook.publicationYear, books[i].publicationYear)
        }
    }

    func testToDictionary() {
        let books = enumerableBooks.toDictionary { $0.author }!
        let keys = books.keys.map { $0 }
        for key in keys {
            XCTAssertEqual(key, books[key]!.author)
        }
        let dupKey = enumerableBooks.toDictionary { $0.author.characters.first! }
        XCTAssertNil(dupKey)
    }

    func testToDictionaryWithValueSelector() {
        let authorTitles = enumerableBooks.toDictionary({ $0.author }) { $0.title }!
        XCTAssertEqual("Crime and Punishment", authorTitles["Fyodor Dostoyevsky"])
        XCTAssertEqual("Unterm Rad", authorTitles["Hermann Hesse"])
        XCTAssertEqual("Les Enfants Terribles", authorTitles["Jean Cocteau"])
        XCTAssertEqual("La Divina Commedia", authorTitles["Durante Alighieri"])
        XCTAssertEqual("Paradise Lost", authorTitles["John Milton"])
        let dupKey = enumerableBooks.toDictionary({ $0.author.characters.first! }) { $0.title }
        XCTAssertNil(dupKey)
    }

    func testToLookup() {
        let even = Enumerable.from(1...10).toLookup { (x: Int) -> Bool in x % 2 == 0 }
        let evenTrues = even[true].aggregate("") { $0 + String($1) }
        XCTAssertEqual("246810", evenTrues)
        let evenFalses = even[false].aggregate("") { $0 + String($1) }
        XCTAssertEqual("13579", evenFalses)
    }

    func testToLookupWithValueSelector() {
        let even = Enumerable.from(1...10).toLookup({ $0 % 2 == 0 }) { String($0) }
        let evenTrues = even[true].aggregate("") { $0 + $1 }
        XCTAssertEqual("246810", evenTrues)
        let evenFalses = even[false].aggregate("") { $0 + $1 }
        XCTAssertEqual("13579", evenFalses)
    }
}
