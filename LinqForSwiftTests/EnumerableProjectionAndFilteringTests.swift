//
//  EnumerableASpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/16.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import XCTest

class EnumerableProjectionAndFilteringTests: XCTestCase {

    let enumerableBooks = Enumerable.from(books)

    let petOwners = [
        (name: "Higa, Sidney", pets: ["Scruffy", "Sam"]),
        (name: "Ashkenazi, Ronen", pets: ["Walker", "Sugar"]),
        (name: "Price, Vernette", pets: ["Scratches", "Diesel"])
    ]

    func testWhere() {
        let result = enumerableBooks.where$ { $0.publicationYear > 1900 }
        XCTAssertEqual(2, result.count())
        let generator: AnyIterator<Book> = result.makeIterator()
        let first = generator.next()
        XCTAssertEqual(1905, first!.publicationYear)
        let second = generator.next()
        XCTAssertEqual(1929, second!.publicationYear)
    }

    func testWhereWithIndex() {
        let result = enumerableBooks.where$ { $1 % 2 == 1 }
        XCTAssertEqual(2, result.count())
        let generator:AnyIterator<Book> = result.makeIterator()
        let first = generator.next()
        XCTAssertEqual(1905, first!.publicationYear)
        let second = generator.next()
        XCTAssertEqual(1472, second!.publicationYear)
    }

    func testSelect() {
        let titles = enumerableBooks.select { $0.title }
        titles.each { (title: String, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("Crime and Punishment", title)
            case 1:
                XCTAssertEqual("Unterm Rad", title)
            case 2:
                XCTAssertEqual("Les Enfants Terribles", title)
            case 3:
                XCTAssertEqual("La Divina Commedia", title)
            case 4:
                XCTAssertEqual("Paradise Lost", title)
            default:
                assertionFailure("invalid index")
            }
        }
    }

    func testSelectWithIndex() {
        let titles = enumerableBooks.select { "\($1):\($0.title)" }
        titles.each { (title: String, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("0:Crime and Punishment", title)
            case 1:
                XCTAssertEqual("1:Unterm Rad", title)
            case 2:
                XCTAssertEqual("2:Les Enfants Terribles", title)
            case 3:
                XCTAssertEqual("3:La Divina Commedia", title)
            case 4:
                XCTAssertEqual("4:Paradise Lost", title)
            default:
                assertionFailure("invalid index")
            }
        }
    }

    func testSelectMany() {
        let result = Enumerable.from(petOwners).selectMany { $0.pets }
        result.each { (pet: String, index: Int) in
            switch index {
            case 0: XCTAssertEqual("Scruffy", pet)
            case 1: XCTAssertEqual("Sam", pet)
            case 2: XCTAssertEqual("Walker", pet)
            case 3: XCTAssertEqual("Sugar", pet)
            case 4: XCTAssertEqual("Scratches", pet)
            case 5: XCTAssertEqual("Diesel", pet)
            default: assertionFailure("invalid index")
            }
        }
    }

    func testSelectManyWithIndex() {
        let result = Enumerable.from(petOwners)
            .selectMany { (x, i) in x.pets.map { "\(i)\($0)" } }
        result.each { (pet: String, index: Int) in
            switch index {
            case 0: XCTAssertEqual("0Scruffy", pet)
            case 1: XCTAssertEqual("0Sam", pet)
            case 2: XCTAssertEqual("1Walker", pet)
            case 3: XCTAssertEqual("1Sugar", pet)
            case 4: XCTAssertEqual("2Scratches", pet)
            case 5: XCTAssertEqual("2Diesel", pet)
            default: assertionFailure("invalid index")
            }
        }
    }

    func testSelectManyWithResultSelector() {
        let result = Enumerable.from(petOwners)
            .selectMany({ $0.pets }) { (owner: $0.name, pet: $1) }
        result.each { (x, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("Higa, Sidney", x.owner)
                XCTAssertEqual("Scruffy", x.pet)
            case 1:
                XCTAssertEqual("Higa, Sidney", x.owner)
                XCTAssertEqual("Sam", x.pet)
            case 2:
                XCTAssertEqual("Ashkenazi, Ronen", x.owner)
                XCTAssertEqual("Walker", x.pet)
            case 3:
                XCTAssertEqual("Ashkenazi, Ronen", x.owner)
                XCTAssertEqual("Sugar", x.pet)
            case 4:
                XCTAssertEqual("Price, Vernette", x.owner)
                XCTAssertEqual("Scratches", x.pet)
            case 5:
                XCTAssertEqual("Price, Vernette", x.owner)
                XCTAssertEqual("Diesel", x.pet)
            default: assertionFailure("invalid index")
            }
        }
    }

    func testSelectManyWithIndexAndResultSelector() {
        let result = Enumerable.from(petOwners)
            .selectMany({ (x, i) in x.pets.map { "\(i)\($0)" } }) { (owner: $0.name, pet: $1) }
        result.each { (x, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("Higa, Sidney", x.owner)
                XCTAssertEqual("0Scruffy", x.pet)
            case 1:
                XCTAssertEqual("Higa, Sidney", x.owner)
                XCTAssertEqual("0Sam", x.pet)
            case 2:
                XCTAssertEqual("Ashkenazi, Ronen", x.owner)
                XCTAssertEqual("1Walker", x.pet)
            case 3:
                XCTAssertEqual("Ashkenazi, Ronen", x.owner)
                XCTAssertEqual("1Sugar", x.pet)
            case 4:
                XCTAssertEqual("Price, Vernette", x.owner)
                XCTAssertEqual("2Scratches", x.pet)
            case 5:
                XCTAssertEqual("Price, Vernette", x.owner)
                XCTAssertEqual("2Diesel", x.pet)
            default: assertionFailure("invalid index")
            }
        }
    }

    func testOfType() {
        let mixedTypeEnumerable = Enumerable<Any>.from([1, 2, "foo", 3, "bar"])
        let result = mixedTypeEnumerable.ofType(String.self)
        XCTAssertEqual(2, result.count())
        result.each { (element: String, index: Int) in
            switch index {
            case 0:
                XCTAssertEqual("foo", element)
            case 1:
                XCTAssertEqual("bar", element)
            default:
                break
            }
        }
    }

    func testZip() {
        let numbers = [1, 2, 3, 4, 5]
        let words = ["one", "two", "three"]
        let result = Enumerable.from(numbers).zip(words) { "\($0) \($1)" }
        let expects = ["1 one", "2 two", "3 three"]
        XCTAssertTrue(result.sequenceEqual(expects) { $0 == $1 })
    }
}
