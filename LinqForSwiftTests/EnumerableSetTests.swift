//
//  EnumerableISpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/21.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.

import XCTest

class EnumerableSetTests: XCTestCase {

    let enumerableBooks = books.toEnumerable()
    let defaultBook = Book(title: "title", author: "author", publicationYear: 2015)
    let unionBooks = books + otherBooks

    let testData = [
        Book(title: "Crime and Punishment", author: "Fyodor Dostoyevsky", publicationYear: 1866),
        Book(title: "Unterm Rad", author: "Hermann Hesse", publicationYear: 1905),
        Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
        Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
        Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472),
        Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472),
        Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472),
        Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667)
    ]
    
    let includeBooks: [Book] = [
        Book(title: "Unterm Rad", author: "Hermann Hesse", publicationYear: 1905),
        Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
        Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472)
    ]
    
    let excludeBooks: [Book] = [
        Book(title: "Crime and Punishment", author: "Fyodor Dostoyevsky", publicationYear: 1866),
        Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667)
    ]
    
    func testAll() {
        let predicateGenerator = { (_ year: Int) -> (Book) -> Bool in
            return { (book: Book) -> Bool in book.publicationYear > year }
        }
        let result = enumerableBooks.all(predicateGenerator(1000))
        XCTAssertTrue(result)
        let result2 = enumerableBooks.all(predicateGenerator(1500))
        XCTAssertFalse(result2)
    }

    func testAny() {
        let result = enumerableBooks.any()
        XCTAssertTrue(result)
        let empty = Enumerable.from([Book]())
        XCTAssertFalse(empty.any())
    }
    
    func testAnyWithPredicate() {
        let predicateGenerator = { (_ author: String) -> (Book) -> Bool in
            return { (book: Book) -> Bool in book.author == author }
        }
        let result = enumerableBooks.any(predicateGenerator("Hermann Hesse"))
        XCTAssertTrue(result)
        let result2 = enumerableBooks.any(predicateGenerator("Franz Kafka"))
        XCTAssertFalse(result2)
    }
    
    func testConcat() {
        let allBooks = enumerableBooks.concat(otherBooks)
        allBooks.each { (book: Book, index: Int) in
            let originalBook: Book
            if (index < books.count) {
                originalBook = books[index]
            } else {
                originalBook = otherBooks[index - books.count]
            }
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testContains() {
        let targetBook = Book(title: "?", author: "?", publicationYear: 1929)
        let result = enumerableBooks.contains(targetBook) { $0.publicationYear == $1.publicationYear }
        XCTAssertTrue(result)
        let result2 = enumerableBooks.contains(targetBook) { $0.author == $1.author }
        XCTAssertFalse(result2)
    }

    func testDefaultIfEmptyWhenNotEmpty() {
        let result = enumerableBooks.defaultIfEmpty(defaultBook)
        result.each { (book: Book, index: Int) in
            let originalBook = books[index]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testDefaultIfEmpty() {
        let emptyBooks = Enumerable<Book>.empty()
        let result = emptyBooks.defaultIfEmpty(defaultBook)
        result.each { (x: Book) -> Void in
            XCTAssertEqual(defaultBook.title, x.title)
            XCTAssertEqual(defaultBook.author, x.author)
            XCTAssertEqual(defaultBook.publicationYear, x.publicationYear)
        }
        XCTAssertEqual(1, result.count())
    }

    func testDistinct() {
        let dupBooks = Enumerable.from(testData)
        
        let result = dupBooks.distinct { $0.publicationYear }
        result.each { (book: Book, index: Int) in
            XCTAssertEqual(books[index].title, book.title)
            XCTAssertEqual(books[index].author, book.author)
            XCTAssertEqual(books[index].publicationYear, book.publicationYear)
        }
    }

    func testDistinctWithComparer() {
        let dupBooks = Enumerable.from(testData)
        
        let comparer = { (_ first: Book, second: Book) -> Bool in
            return first.title == second.title
                && first.author == second.author
                && first.publicationYear == second.publicationYear
        }
        let result = dupBooks.distinct(comparer)
        result.each { (book: Book, index: Int) in
            XCTAssertEqual(books[index].title, book.title)
            XCTAssertEqual(books[index].author, book.author)
            XCTAssertEqual(books[index].publicationYear, book.publicationYear)
        }
    }

    func testExcept() {
        let result = enumerableBooks.except(excludeBooks) { $0.publicationYear }
        result.each { (book: Book, index: Int) in
            XCTAssertEqual(includeBooks[index].title, book.title)
            XCTAssertEqual(includeBooks[index].author, book.author)
            XCTAssertEqual(includeBooks[index].publicationYear, book.publicationYear)
        }
    }

    func testExceptWithComparer() {
        let result = enumerableBooks.except(excludeBooks) { $0.title == $1.title }
        result.each { (book: Book, index: Int) in
            XCTAssertEqual(includeBooks[index].title, book.title)
            XCTAssertEqual(includeBooks[index].author, book.author)
            XCTAssertEqual(includeBooks[index].publicationYear, book.publicationYear)
        }
    }

    func testIntersect() {
        let testBooks = [
            Book(title: "L'Étranger", author: "Albert Camus", publicationYear: 1942),
            Book(title: "L'Être et le néant", author: "Jean-Paul Charles Aymard Sartre", publicationYear: 1943),
            Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
            Book(title: "Vom Ursprung und Ziel der Geschichte", author: "Karl Theodor Jaspers", publicationYear: 1949),
            Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667)
        ]
        let result = enumerableBooks.intersect(testBooks) { $0.title == $1.title && $0.author == $1.author }
        XCTAssertEqual(2, result.count())
        let g = result.makeIterator()
        let first = g.next()
        XCTAssertEqual("Les Enfants Terribles", first!.title)
        let second = g.next()
        XCTAssertEqual("John Milton", second!.author)
    }

    func testSequenceEqual() {
        let comparer: (_ first: Book, _ second: Book) -> Bool = { (first: Book, second: Book) -> Bool in
            return first.title == second.title
                && first.author == second.author
                && first.publicationYear == second.publicationYear
        }
        let result = enumerableBooks.sequenceEqual(books, comparer: comparer)
        XCTAssertTrue(result)
        let result2 = enumerableBooks.sequenceEqual(otherBooks, comparer: comparer)
        XCTAssertFalse(result2)
    }

    func testUnion() {
        let result = enumerableBooks.union(unionBooks) { $0.title }
        XCTAssertEqual(8, result.count())
        for book in books {
            XCTAssertTrue(result.contains(book) { $0.title == $1.title })
        }
        for book in otherBooks {
            XCTAssertTrue(result.contains(book) { $0.title == $1.title })
        }
    }

    func testUnionWithComparer() {
        let result = enumerableBooks.union(unionBooks) { $0.publicationYear == $1.publicationYear }
        XCTAssertEqual(8, result.count())
        for book in books {
            XCTAssertTrue(result.contains(book) { $0.title == $1.title })
        }
        for book in otherBooks {
            XCTAssertTrue(result.contains(book) { $0.title == $1.title })
        }
    }
}
