//
//  EnumerableGeneratorSpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/07.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//


import Nimble
import Quick

struct Book {
    let title: String
    let author: String
    let publicationYear: Int
}

// test data
let books: [Book] = [
    Book(title: "Crime and Punishment", author: "Fyodor Dostoyevsky", publicationYear: 1866),
    Book(title: "Unterm Rad", author: "Hermann Hesse", publicationYear: 1905),
    Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
    Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472),
    Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667)
]

let otherBooks: [Book] = [
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
var magnus: Person = Person(name: "Hedlund, Magnus")
var terry: Person = Person(name: "Adams, Terry")
var charlotte: Person = Person(name: "Weiss, Charlotte")
var barley: Pet = Pet(name: "Barley", owner: terry)
var boots: Pet = Pet(name: "Boots", owner: terry)
var whiskers: Pet = Pet(name: "Whiskers", owner: charlotte)
var daisy: Pet = Pet(name: "Daisy", owner: magnus)
var people: Enumerable<Person> = Enumerable.from([magnus, terry, charlotte])
var pets: Enumerable<Pet> = Enumerable.from([barley, boots, whiskers, daisy])

class EnumerableGeneratorSpec: QuickSpec {
    override func spec() {
        
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("choice") {
                it("is creates the infinite sequence from random elements of source sequence") {
                    let result = Enumerable.choice(books).take(10)
                    expect(result.count()).to(equal(10))
                    result.each { book -> Void in
                        expect(enumerableBooks.contains(book) { $0.title == $1.title }).to(beTrue())
                    }
                }
            }
            
            describe("cycle") {
                it("is creates the infinite cycle sequence from source sequence") {
                    let result = Enumerable.cycle(books).take(10).aggregate("") { "\($0),\($1.publicationYear)" }
                    expect(result).to(equal(",1866,1905,1929,1472,1667,1866,1905,1929,1472,1667"))
                }
            }
            
            describe("empty") {
                it(" is create empty Enumerable") {
                    let empty: Enumerable<Book> = Enumerable<Book>.empty()
                    var count: Int = 0
                    for e in empty {
                        count++
                    }
                    expect(count).to(equal(0))
                }
            }
            
            describe("from") {
                it("is create Enumerable instance from sequence") {
                    enumerableBooks.each { (book: Book, index: Int) -> Void in
                        let originalBook: Book = books[index]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
            
            describe("infinity") {
                it("is creates a infinite sequence from specified start number") {
                    let result = Enumerable<Int>.infinity(3).take(5)
                    let expects = [3,4,5,6,7]
                    expect(result.sequenceEqual(expects) { $0 == $1 }).to(beTrue())
                }
                it("is creates a infinite sequence from specified start number and step value") {
                    let result = Enumerable<Int64>.infinity(3, step: 2).take(5)
                    let expects = [3,5,7,9,11]
                    expect(result.sequenceEqual(expects) { $0 == $1 }).to(beTrue())
                }
            }

            describe("negativeInfinity") {
                it("is creates a infinite sequence from specified start number") {
                    let result = Enumerable<Int>.negativeInfinity(3).take(5)
                    let expects = [3,2,1,0,-1]
                    expect(result.sequenceEqual(expects) { $0 == $1 }).to(beTrue())
                }
                it("is creates a infinite sequence from specified start number and step value") {
                    let result = Enumerable<Int64>.negativeInfinity(3, step: 2).take(5)
                    let expects = [3,1,-1,-3,-5]
                    expect(result.sequenceEqual(expects) { $0 == $1 }).to(beTrue())
                }
            }
            
            let format = { (x: Double) -> NSString in NSString(format: "%.1f", x) }

            describe("range") {
                it("is generates a sequence of NumericType within a specified range") {
                    let result = Enumerable<Double>.range(1.2, count: 5)
                    let expects = [1.2,2.2,3.2,4.2,5.2]
                    expect(result.sequenceEqual(expects) { format($0) == format($1) }).to(beTrue())
                }
                it("is generates a sequence of NumericType within a specified range by step") {
                    let result = Enumerable<Double>.range(1.2, step: 1.2, count: 5)
                    let expects = [1.2,2.4,3.6,4.8,6]
                    expect(result.sequenceEqual(expects) { format($0) == format($1) }).to(beTrue())
                }
            }
            
            describe("rangeDown") {
                it("is generates a negative sequence of NumericType within a specified range") {
                    let result = Enumerable<Double>.rangeDown(1.2, count: 5)
                    let expects = [1.2,0.2,-0.8,-1.8,-2.8]
                    expect(result.sequenceEqual(expects) { format($0) == format($1) }).to(beTrue())
                }
                it("is generates a negative sequence of NumericType within a specified range by step") {
                    let result = Enumerable<Double>.rangeDown(1.2, step: 1.2, count: 5)
                    let expects = [1.2,0,-1.2,-2.4,-3.6]
                    let format = { (x: Double) -> NSString in NSString(format: "%.1f", x) }
                    expect(result.sequenceEqual(expects) { format($0) == format($1) }).to(beTrue())
                }
            }
            
            describe("repeat") {
                it("is generates an infinite sequence that contains one repeated value") {
                    let result = Enumerable.repeat(magnus).take(5)
                    let expects = [magnus, magnus, magnus, magnus, magnus]
                    expect(result.sequenceEqual(expects) { $0.name == $1.name }).to(beTrue())
                }
                it("is generates a sequence that contains one repeated value") {
                    let result = Enumerable.repeat(magnus, count: 5)
                    let expects = [magnus, magnus, magnus, magnus, magnus]
                    expect(result.sequenceEqual(expects) { $0.name == $1.name }).to(beTrue())
                }
            }
            
            describe("return$") {
                it("is generates a sequence that contains one value") {
                    let result = Enumerable.return$(magnus)
                    expect(result.count()).to(equal(1))
                    expect(result.first()!.name).to(equal(magnus.name))
                }
            }
        }
    }
}
