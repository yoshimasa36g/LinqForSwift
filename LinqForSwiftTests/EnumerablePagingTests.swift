//
//  EnumerableUSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/05/02.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

//
//  EnumerableTSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/29.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import XCTest

class EnumerablePagingTests: XCTestCase {
    let enumerableBooks = Enumerable.from(books)

    func testElementAt() {
        let result = enumerableBooks.elementAt(3)
        XCTAssertEqual(books[3].title, result!.title)
        XCTAssertEqual(books[3].author, result!.author)
        XCTAssertEqual(books[3].publicationYear, result!.publicationYear)
        let result2 = enumerableBooks.elementAt(8)
        XCTAssertNil(result2)
    }

    func testElementAtOrDefault() {
        let defaultValue = Book(title: "t", author: "a", publicationYear: 0)
        let result = enumerableBooks.elementAtOrDefault(2, defaultValue: defaultValue)
        XCTAssertEqual(books[2].title, result.title)
        XCTAssertEqual(books[2].author, result.author)
        XCTAssertEqual(books[2].publicationYear, result.publicationYear)
        let result2: Book = enumerableBooks.elementAtOrDefault(10, defaultValue: defaultValue)
        XCTAssertEqual(defaultValue.title, result2.title)
        XCTAssertEqual(defaultValue.author, result2.author)
        XCTAssertEqual(defaultValue.publicationYear, result2.publicationYear)
    }

    func testFirst() {
        let result = enumerableBooks.first()
        XCTAssertEqual("Crime and Punishment", result!.title)
        let result2 = Enumerable<Book>.empty().first()
        XCTAssertNil(result2)
    }

    func testFirstWithPredicate() {
        let result = enumerableBooks.first { $0.publicationYear < 1500 }
        XCTAssertEqual("La Divina Commedia", result!.title)
        let result2 = enumerableBooks.first { $0.publicationYear > 2000 }
        XCTAssertNil(result2)
    }

    func testFirstOrDefault() {
        let defaultValue = Book(title: "t", author: "a", publicationYear: 0)
        let result = enumerableBooks.firstOrDefault(defaultValue)
        XCTAssertEqual("Crime and Punishment", result.title)
        let result2 = Enumerable<Book>.empty().firstOrDefault(defaultValue)
        XCTAssertEqual("t", result2.title)
    }

    func testFirstOrDefaultWithPredicate() {
        let defaultValue = Book(title: "t", author: "a", publicationYear: 0)
        let result = enumerableBooks.firstOrDefault(defaultValue) { $0.publicationYear < 1500 }
        XCTAssertEqual("La Divina Commedia", result.title)
        let result2 = enumerableBooks.firstOrDefault(defaultValue) { $0.publicationYear > 2000 }
        XCTAssertEqual("t", result2.title)
    }

    func testLast() {
        let result = enumerableBooks.last()
        XCTAssertEqual("Paradise Lost", result!.title)
        let result2 = Enumerable<Int>.empty().last()
        XCTAssertNil(result2)
    }

    func testLastWithPredicate() {
        let result = enumerableBooks.last { $0.publicationYear > 1900 }
        XCTAssertEqual("Les Enfants Terribles", result!.title)
        let result2 = enumerableBooks.last { $0.publicationYear > 2000 }
        XCTAssertNil(result2)
    }

    func testLastOrDefault() {
        let defaultValue = Book(title: "def", author: "ault", publicationYear: 0)
        let result = enumerableBooks.lastOrDefault(defaultValue)
        XCTAssertEqual("Paradise Lost", result.title)
        let result2 = Enumerable<Book>.empty().lastOrDefault(defaultValue)
        XCTAssertEqual("def", result2.title)
    }

    func testLastOrDefaultWithPredicate() {
        let defaultValue = Book(title: "def", author: "ault", publicationYear: 0)
        let result = enumerableBooks.lastOrDefault(defaultValue) { $0.publicationYear > 1900 }
        XCTAssertEqual("Les Enfants Terribles", result.title)
        let result2 = enumerableBooks.lastOrDefault(defaultValue) { $0.publicationYear > 2000 }
        XCTAssertEqual("def", result2.title)
    }

    func testSingle() {
        let result = Enumerable.from(["orange"]).single()
        XCTAssertEqual("orange", result)
        let result2 = Enumerable.from(["orange", "apple"]).single()
        XCTAssertNil(result2)
    }

    func testSingleWithPredicate() {
        let result = enumerableBooks.single { $0.publicationYear > 1920 }
        XCTAssertEqual("Les Enfants Terribles", result!.title)
        let result2 = enumerableBooks.single { $0.publicationYear > 1900 }
        XCTAssertNil(result2)
    }

    func testSingleOrDefault() {
        let result = Enumerable.from(["orange"]).singleOrDefault("banana")
        XCTAssertEqual("orange", result)
        let result2 = Enumerable<String>.empty().singleOrDefault("banana")
        XCTAssertEqual("banana", result2)
        let result3 = Enumerable.from(["orange", "apple"]).singleOrDefault("banana")
        XCTAssertNil(result3)
    }

    func testSingleOrDefaultWithPredicate() {
        let defaultBook = Book(title: "t", author: "a", publicationYear: 0)
        let result = enumerableBooks.singleOrDefault(defaultBook) { $0.publicationYear > 1920 }
        XCTAssertEqual("Les Enfants Terribles", result?.title)
        let result2 = enumerableBooks.singleOrDefault(defaultBook) { $0.publicationYear > 2000 }
        XCTAssertEqual("t", result2?.title)
        let result3 = enumerableBooks.singleOrDefault(defaultBook) { $0.publicationYear > 1900 }
        XCTAssertNil(result3)
    }

    func testSkip() {
        let result = enumerableBooks.skip(3)
        result.each { (book: Book, index: Int) -> Void in
            let originalBook: Book = books[index + 3]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testSkipWhile() {
        let result = enumerableBooks.skipWhile { $0.publicationYear < 1920 }
        result.each { (book: Book, index: Int) -> Void in
            let originalBook: Book = books[index + 2]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testSkipWhileWithIndex() {
        let result = enumerableBooks.skipWhile { $0.publicationYear * $1 < 4000 }
        result.each { (book: Book, index: Int) -> Void in
            let originalBook: Book = books[index + 3]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testTake() {
        let result = enumerableBooks.take(3)
        XCTAssertEqual(3, result.count())
        result.each { (book: Book, index: Int) -> Void in
            let originalBook: Book = books[index]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testTakeWhile() {
        let result = enumerableBooks.takeWhile { $0.publicationYear < 1920 }
        XCTAssertEqual(2, result.count())
        result.each { (book: Book, index: Int) -> Void in
            let originalBook: Book = books[index]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testTakeWhileWithIndex() {
        let result = enumerableBooks.takeWhile { $0.publicationYear * $1 < 5000 }
        XCTAssertEqual(4, result.count())
        result.each { (book: Book, index: Int) -> Void in
            let originalBook: Book = books[index]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }
}
