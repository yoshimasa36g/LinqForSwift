//
//  EnumerableISpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/21.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Nimble
import Quick

class EnumerableSetSpec: QuickSpec {
    override func spec() {
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)

            describe("all") {
                it("is determines whether all elements of a sequence satisfy a condition") {
                    func predicateGenerator(year: Int) -> Book -> Bool {
                        return { (book: Book) -> Bool in book.publicationYear > year }
                    }
                    let result: Bool = enumerableBooks.all(predicateGenerator(1000))
                    expect(result).to(beTrue())
                    let result2: Bool = enumerableBooks.all(predicateGenerator(1500))
                    expect(result2).to(beFalse())
                }
            }
            
            describe("any") {
                it("is determines whether a sequence contains any elements") {
                    let result: Bool = enumerableBooks.any()
                    expect(result).to(beTrue())
                    let empty: Enumerable<Book> = Enumerable.from([Book]())
                    expect(empty.any()).to(beFalse())
                }
                it("is determines whether any element of a sequence satisfies a condition") {
                    func predicateGenerator(author: String) -> Book -> Bool {
                        return { (book: Book) -> Bool in book.author == author }
                    }
                    let result: Bool = enumerableBooks.any(predicateGenerator("Hermann Hesse"))
                    expect(result).to(beTrue())
                    let result2: Bool = enumerableBooks.any(predicateGenerator("Franz Kafka"))
                    expect(result2).to(beFalse())
                }
            }
            
            describe("concat") {
                it("is concatenates two sequences") {
                    let allBooks: Enumerable<Book> = enumerableBooks.concat(otherBooks)
                    allBooks.eachWithIndex { (book: Book, index: Int) in
                        let originalBook: Book
                        if (index < books.count) {
                            originalBook = books[index]
                        } else {
                            originalBook = otherBooks[index - books.count]
                        }
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
            
            describe("contains") {
                it("is determines whether a sequence contains a specified element by using a specified comparer") {
                    let targetBook: Book = Book(title: "?", author: "?", publicationYear: 1929)
                    let result: Bool = enumerableBooks.contains(targetBook) { $0.publicationYear == $1.publicationYear }
                    expect(result).to(beTrue())
                    let result2: Bool = enumerableBooks.contains(targetBook) { $0.author == $1.author }
                    expect(result2).to(beFalse())
                }
            }
            
            describe("defaultIfEmpty") {
                var defaultBook: Book = Book(title: "title", author: "author", publicationYear: 2015)
                it("is returns the elements of the specified sequence") {
                    let result: Enumerable<Book> = enumerableBooks.defaultIfEmpty(defaultBook)
                    result.eachWithIndex { (book: Book, index: Int) in
                        let originalBook: Book = books[index]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
                it("is returns the specified value in a singleton collection if the sequence is empty") {
                    let emptyBooks: Enumerable<Book> = Enumerable<Book>.empty()
                    let result: Enumerable<Book> = emptyBooks.defaultIfEmpty(defaultBook)
                    result.each {
                        expect($0.title).to(equal(defaultBook.title))
                        expect($0.author).to(equal(defaultBook.author))
                        expect($0.publicationYear).to(equal(defaultBook.publicationYear))
                    }
                    expect(result.count()).to(equal(1))
                }
            }
            
            describe("distinct") {
                var testData: [Book] = []
                testData.append(Book(title: "Crime and Punishment", author: "Fyodor Dostoyevsky", publicationYear: 1866))
                testData.append(Book(title: "Unterm Rad", author: "Hermann Hesse", publicationYear: 1905))
                testData.append(Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929))
                testData.append(Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929))
                testData.append(Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472))
                testData.append(Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472))
                testData.append(Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472))
                testData.append(Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667))
                
                let dupBooks: Enumerable<Book> = Enumerable.from(testData)
                
                it("is returns distinct elements from a sequence by using a specified key generator") {
                    let result: Enumerable<Book> = dupBooks.distinct { $0.publicationYear }
                    result.eachWithIndex { (book: Book, index: Int) in
                        expect(book.title).to(equal(books[index].title))
                        expect(book.author).to(equal(books[index].author))
                        expect(book.publicationYear).to(equal(books[index].publicationYear))
                    }
                }
                
                it("is produces the set difference of two sequences by using the specified comparer") {
                    func comparer(first: Book, second: Book) -> Bool {
                        return first.title == second.title
                            && first.author == second.author
                            && first.publicationYear == second.publicationYear
                    }
                    let result: Enumerable<Book> = dupBooks.distinct(comparer)
                    result.eachWithIndex { (book: Book, index: Int) in
                        expect(book.title).to(equal(books[index].title))
                        expect(book.author).to(equal(books[index].author))
                        expect(book.publicationYear).to(equal(books[index].publicationYear))
                    }
                }
            }

            describe("except") {
                let includeBooks: [Book] = [
                    Book(title: "Unterm Rad", author: "Hermann Hesse", publicationYear: 1905),
                    Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
                    Book(title: "La Divina Commedia", author: "Durante Alighieri", publicationYear: 1472)
                ]
                
                let excludeBooks: [Book] = [
                    Book(title: "Crime and Punishment", author: "Fyodor Dostoyevsky", publicationYear: 1866),
                    Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667)
                ]
                
                it("is produces the set difference of two sequences by using the key generator") {
                    let result: Enumerable<Book> = enumerableBooks.except(excludeBooks) { $0.publicationYear }
                    result.eachWithIndex { (book: Book, index: Int) in
                        expect(book.title).to(equal(includeBooks[index].title))
                        expect(book.author).to(equal(includeBooks[index].author))
                        expect(book.publicationYear).to(equal(includeBooks[index].publicationYear))
                    }
                }
                
                it("is produces the set difference of two sequences by using the specified comparer") {
                    let result: Enumerable<Book> = enumerableBooks.except(excludeBooks) { $0.title == $1.title }
                    result.eachWithIndex { (book: Book, index: Int) in
                        expect(book.title).to(equal(includeBooks[index].title))
                        expect(book.author).to(equal(includeBooks[index].author))
                        expect(book.publicationYear).to(equal(includeBooks[index].publicationYear))
                    }
                }
            }
            
            describe("intersect") {
                it("is produces the set intersection of two sequences by using the comparer to compare values") {
                    let testBooks: [Book] = [
                        Book(title: "L'Étranger", author: "Albert Camus", publicationYear: 1942),
                        Book(title: "L'Être et le néant", author: "Jean-Paul Charles Aymard Sartre", publicationYear: 1943),
                        Book(title: "Les Enfants Terribles", author: "Jean Cocteau", publicationYear: 1929),
                        Book(title: "Vom Ursprung und Ziel der Geschichte", author: "Karl Theodor Jaspers", publicationYear: 1949),
                        Book(title: "Paradise Lost", author: "John Milton", publicationYear: 1667)
                    ]
                    let result: Enumerable<Book> = enumerableBooks.intersect(testBooks) { $0.title == $1.title && $0.author == $1.author }
                    expect(result.count()).to(equal(2))
                    var g: GeneratorOf<Book> = result.generate()
                    let first: Book? = g.next()
                    expect(first!.title).to(equal("Les Enfants Terribles"))
                    let second: Book? = g.next()
                    expect(second?.author).to(equal("John Milton"))
                }
            }
            
            describe("sequenceEqual") {
                it("is determines whether two sequences are equal by comparing their elements") {
                    let comparer: (first: Book, second: Book) -> Bool = { (first: Book, second: Book) -> Bool in
                        return first.title == second.title
                            && first.author == second.author
                            && first.publicationYear == second.publicationYear
                    }
                    let result: Bool = enumerableBooks.sequenceEqual(books, comparer: comparer)
                    expect(result).to(beTrue())
                    let result2: Bool = enumerableBooks.sequenceEqual(otherBooks, comparer: comparer)
                    expect(result2).to(beFalse())
                }
            }
            
            // test data
            let unionBooks: [Book] = books + otherBooks
            
            describe("union") {
                it("is produces the set union of two sequences by using the key selector") {
                    let result: Enumerable<Book> = enumerableBooks.union(unionBooks) { $0.title }
                    expect(result.count()).to(equal(8))
                    for book in books {
                        expect(result.contains(book) { $0.title == $1.title }).to(beTrue())
                    }
                    for book in otherBooks {
                        expect(result.contains(book) { $0.title == $1.title }).to(beTrue())
                    }
                }
                it("is produces the set union of two sequences by using the comparer") {
                    let result: Enumerable<Book> = enumerableBooks.union(unionBooks) { $0.publicationYear == $1.publicationYear }
                    expect(result.count()).to(equal(8))
                    for book in books {
                        expect(result.contains(book) { $0.title == $1.title }).to(beTrue())
                    }
                    for book in otherBooks {
                        expect(result.contains(book) { $0.title == $1.title }).to(beTrue())
                    }
                }
            }
        }
    }
}
