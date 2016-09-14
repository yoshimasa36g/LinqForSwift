//
//  EnumerableOSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/25.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import XCTest

class EnumerableOrderingTests: XCTestCase {
    
    let enumerableBooks = Enumerable.from(books)

    func testOrderBy() {
        let sortedBooks = enumerableBooks.orderBy { $0.publicationYear }
        sortedBooks.each { (book: Book, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("La Divina Commedia", book.title)
            case 1:
                XCTAssertEqual("Paradise Lost", book.title)
            case 2:
                XCTAssertEqual("Crime and Punishment", book.title)
            case 3:
                XCTAssertEqual("Unterm Rad", book.title)
            case 4:
                XCTAssertEqual("Les Enfants Terribles", book.title)
            default:
                assertionFailure("invalid index")
            }
        }
    }

    func testOrderByDescending() {
        let sortedBooks = enumerableBooks.orderByDescending { $0.publicationYear }
        sortedBooks.each { (book: Book, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("Les Enfants Terribles", book.title)
            case 1:
                XCTAssertEqual("Unterm Rad", book.title)
            case 2:
                XCTAssertEqual("Crime and Punishment", book.title)
            case 3:
                XCTAssertEqual("Paradise Lost", book.title)
            case 4:
                XCTAssertEqual("La Divina Commedia", book.title)
            default:
                assertionFailure("invalid index")
            }
        }
    }

    func testReverse() {
        let sortedBooks = enumerableBooks.orderBy { $0.publicationYear }.reverse()
        sortedBooks.each { (book: Book, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("Les Enfants Terribles", book.title)
            case 1:
                XCTAssertEqual("Unterm Rad", book.title)
            case 2:
                XCTAssertEqual("Crime and Punishment", book.title)
            case 3:
                XCTAssertEqual("Paradise Lost", book.title)
            case 4:
                XCTAssertEqual("La Divina Commedia", book.title)
            default:
                assertionFailure("invalid index")
            }
        }
    }

    func testThenBy() {
        let orderedPets = pets.orderBy { $0.owner.name }.thenBy { $0.name }
        let result = orderedPets.aggregate("") { "\($0),\($1.name)" }
        XCTAssertEqual(",Barley,Boots,Daisy,Whiskers", result)
    }

    func testThenByDescending() {
        let orderedPets = pets.orderBy { $0.owner.name }.thenByDescending { $0.name }
        let result = orderedPets.aggregate("") { "\($0),\($1.name)" }
        XCTAssertEqual(",Boots,Barley,Daisy,Whiskers", result)
    }
}
