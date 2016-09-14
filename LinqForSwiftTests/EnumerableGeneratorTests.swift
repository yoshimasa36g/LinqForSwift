//
//  EnumerableGeneratorSpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/07.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//


import XCTest

struct Book {
    let title: String
    let author: String
    let publicationYear: Int
}

// test data
let books = [
    Book(title: "Crime and Punishment", author: "Fyodor Dostoyevsky", publicationYear: 1866),
    Book(title: "Unterm Rad", author: "Hermann Hesse", publicationYear: 1905),
    Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
    Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472),
    Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667)
]

let otherBooks = [
    Book(title: "L'Étranger", author: "Albert Camus", publicationYear: 1942),
    Book(title: "L'Être et le néant", author: "Jean-Paul Charles Aymard Sartre", publicationYear: 1943),
    Book(title: "Vom Ursprung und Ziel der Geschichte", author: "Karl Theodor Jaspers", publicationYear: 1949)
]

struct Person {
    let name: String
}
struct Pet {
    let name: String
    let owner: Person
}
let magnus = Person(name: "Hedlund, Magnus")
let terry = Person(name: "Adams, Terry")
let charlotte = Person(name: "Weiss, Charlotte")
let barley = Pet(name: "Barley", owner: terry)
let boots = Pet(name: "Boots", owner: terry)
let whiskers = Pet(name: "Whiskers", owner: charlotte)
let daisy = Pet(name: "Daisy", owner: magnus)
let people = Enumerable.from([magnus, terry, charlotte])
let pets = Enumerable.from([barley, boots, whiskers, daisy])

class EnumerableGeneratorTests: XCTestCase {

    let enumerableBooks = books.toEnumerable()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testChoise() {
        let result = Enumerable.choice(books).take(10)
        XCTAssertEqual(10, result.count())
        result.each { book -> Void in
            XCTAssertTrue(enumerableBooks.contains(book) { $0.title == $1.title })
        }
    }

    func testCycle() {
        let result = Enumerable.cycle(books).take(10).aggregate("") { "\($0),\($1.publicationYear)" }
        XCTAssertEqual(",1866,1905,1929,1472,1667,1866,1905,1929,1472,1667", result)
    }

    func testEmpty() {
        let empty = Enumerable<Book>.empty()
        var count: Int = 0
        for _ in empty {
            count += 1
        }
        XCTAssertEqual(0, count)
    }

    func testFrom() {
        enumerableBooks.each { (book: Book, index: Int) -> Void in
            let originalBook: Book = books[index]
            XCTAssertEqual(originalBook.title, book.title)
            XCTAssertEqual(originalBook.author, book.author)
            XCTAssertEqual(originalBook.publicationYear, book.publicationYear)
        }
    }

    func testInfinity() {
        let parameters = [
            (result: Enumerable<Int>.infinity(3).take(5), expects: [3,4,5,6,7]),
            (result: Enumerable<Int64>.infinity(3, step: 2).take(5), expects: [3,5,7,9,11])
        ]

        for p in parameters {
            XCTAssertTrue(p.result.sequenceEqual(p.expects) { $0 == $1 })
        }
    }

    func testNegativeInfinity() {
        let parameters = [
            (result: Enumerable<Int>.negativeInfinity(3).take(5), expects: [3,2,1,0,-1]),
            (result: Enumerable<Int64>.negativeInfinity(3, step: 2).take(5), expects: [3,1,-1,-3,-5])
        ]

        for p in parameters {
            XCTAssertTrue(p.result.sequenceEqual(p.expects) { $0 == $1 })
        }
    }

    let format = { (x: Double) -> NSString in NSString(format: "%.1f", x) }

    func testRange() {
        let parameters = [
            (result: Enumerable<Double>.range(1.2, count: 5), expects: [1.2,2.2,3.2,4.2,5.2] as [Double]),
            (result: Enumerable<Double>.range(1.2, step: 1.2, count: 5), expects: [1.2,2.4,3.6,4.8,6] as [Double])
        ]

        for p in parameters {
            XCTAssertTrue(p.result.sequenceEqual(p.expects) { format($0) == format($1) })
        }
    }

    func testRangeDown() {
        let parameters = [
            (result: Enumerable<Double>.rangeDown(1.2, count: 5),
             expects: [1.2,0.2,-0.8,-1.8,-2.8] as [Double]),
            (result: Enumerable<Double>.rangeDown(1.2, step: 1.2, count: 5),
             expects: [1.2,0,-1.2,-2.4,-3.6] as [Double])
        ]

        for p in parameters {
            XCTAssertTrue(p.result.sequenceEqual(p.expects) { format($0) == format($1) })
        }
    }

    func testRepeat() {
        let parameters = [
            (result: Enumerable.repeat$(magnus).take(5),
             expects: [magnus, magnus, magnus, magnus, magnus]),
            (result: Enumerable.repeat$(magnus, count: 5),
             expects: [magnus, magnus, magnus, magnus, magnus])
        ]

        for p in parameters {
            XCTAssertTrue(p.result.sequenceEqual(p.expects) { $0.name == $1.name })
        }
    }

    func testReturn() {
        let result = Enumerable.return$(magnus)
        XCTAssertEqual(1, result.count())
        XCTAssertEqual(magnus.name, result.first()!.name)
    }
}
