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

import Nimble
import Quick

class EnumerablePagingSpec: QuickSpec {
    override func spec() {
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("elementAt") {
                it ("is returns the element at a specified index in a sequence") {
                    let result: Book? = enumerableBooks.elementAt(3)
                    expect(result!.title).to(equal(books[3].title))
                    expect(result!.author).to(equal(books[3].author))
                    expect(result!.publicationYear).to(equal(books[3].publicationYear))
                    let result2: Book? = enumerableBooks.elementAt(8)
                    expect(result2).to(beNil())
                }
            }
            
            describe("elementAtOrDefault") {
                it("is returns the element at a specified index in a sequence or a default value if the index is out of range") {
                    let defaultValue: Book = Book(title: "t", author: "a", publicationYear: 0)
                    let result: Book = enumerableBooks.elementAtOrDefault(2, defaultValue: defaultValue)
                    expect(result.title).to(equal(books[2].title))
                    expect(result.author).to(equal(books[2].author))
                    expect(result.publicationYear).to(equal(books[2].publicationYear))
                    let result2: Book = enumerableBooks.elementAtOrDefault(10, defaultValue: defaultValue)
                    expect(result2.title).to(equal(defaultValue.title))
                    expect(result2.author).to(equal(defaultValue.author))
                    expect(result2.publicationYear).to(equal(defaultValue.publicationYear))
                }
            }
            
            describe("first") {
                it("is returns the first element of a sequence") {
                    let result: Book? = enumerableBooks.first()
                    expect(result!.title).to(equal("Crime and Punishment"))
                    let result2: Book? = Enumerable<Book>.empty().first()
                    expect(result2).to(beNil())
                }
                it("is returns the first element in a sequence that satisfies a specified condition") {
                    let result: Book? = enumerableBooks.first { $0.publicationYear < 1500 }
                    expect(result!.title).to(equal("La Divina Commedia"))
                    let result2: Book? = enumerableBooks.first { $0.publicationYear > 2000 }
                    expect(result2).to(beNil())
                }
            }
            
            describe("firstOrDefault") {
                let defaultValue: Book = Book(title: "t", author: "a", publicationYear: 0)
                it("is returns the first element of a sequence, or a default value if the sequence contains no elements") {
                    let result: Book = enumerableBooks.firstOrDefault(defaultValue)
                    expect(result.title).to(equal("Crime and Punishment"))
                    let result2: Book = Enumerable<Book>.empty().firstOrDefault(defaultValue)
                    expect(result2.title).to(equal("t"))
                }
                it("is returns the first element in a sequence that satisfies a specified condition") {
                    let result: Book = enumerableBooks.firstOrDefault(defaultValue) { $0.publicationYear < 1500 }
                    expect(result.title).to(equal("La Divina Commedia"))
                    let result2: Book = enumerableBooks.firstOrDefault(defaultValue) { $0.publicationYear > 2000 }
                    expect(result2.title).to(equal("t"))
                }
            }
            
            describe("last") {
                it("is returns the last element of a sequence") {
                    let result = enumerableBooks.last()
                    expect(result!.title).to(equal("Paradise Lost"))
                    let result2 = Enumerable<Int>.empty().last()
                    expect(result2).to(beNil())
                }
                it("is returns the last element of a sequence that satisfies a specified condition") {
                    let result = enumerableBooks.last { $0.publicationYear > 1900 }
                    expect(result!.title).to(equal("Les Enfants Terribles"))
                    let result2 = enumerableBooks.last { $0.publicationYear > 2000 }
                    expect(result2).to(beNil())
                }
            }
            
            describe("lastOrDefault") {
                let defaultValue = Book(title: "def", author: "ault", publicationYear: 0)
                it("is returns the last element of a sequence or a default value") {
                    let result = enumerableBooks.lastOrDefault(defaultValue)
                    expect(result.title).to(equal("Paradise Lost"))
                    let result2 = Enumerable<Book>.empty().lastOrDefault(defaultValue)
                    expect(result2.title).to(equal("def"))
                }
                it("is returns the last element of a sequence that satisfies a condition or a default value") {
                    let result = enumerableBooks.lastOrDefault(defaultValue) { $0.publicationYear > 1900 }
                    expect(result.title).to(equal("Les Enfants Terribles"))
                    let result2 = enumerableBooks.lastOrDefault(defaultValue) { $0.publicationYear > 2000 }
                    expect(result2.title).to(equal("def"))
                }
            }
            
            describe("single") {
                it("is returns the only element of a sequence") {
                    let result: String? = Enumerable.from(["orange"]).single()
                    expect(result).to(equal("orange"))
                }
                it("is returns nil if there is not exactly one element in the sequence") {
                    let result: String? = Enumerable.from(["orange", "apple"]).single()
                    expect(result).to(beNil())
                }
                it("is returns the only element of a sequence that satisfies a specified condition") {
                    let result: Book? = enumerableBooks.single { $0.publicationYear > 1920 }
                    expect(result?.title).to(equal("Les Enfants Terribles"))
                }
                it("is returns nil if more than one such element exists") {
                    let result: Book? = enumerableBooks.single { $0.publicationYear > 1900 }
                    expect(result).to(beNil())
                }
            }
            
            describe("singleOrDefault") {
                it("is returns the only element of a sequence, or a default value if the sequence is empty") {
                    let result: String? = Enumerable.from(["orange"]).singleOrDefault("banana")
                    expect(result).to(equal("orange"))
                    let result2: String? = Enumerable<String>.empty().singleOrDefault("banana")
                    expect(result2).to(equal("banana"))
                }
                it("is returns nil if there is more than one element in the sequence") {
                    let result: String? = Enumerable.from(["orange", "apple"]).singleOrDefault("banana")
                    expect(result).to(beNil())
                }
                let defaultBook: Book = Book(title: "t", author: "a", publicationYear: 0)
                it("is returns the only element of a sequence that satisfies a specified condition or a default value if no such element exists") {
                    let result: Book? = enumerableBooks.singleOrDefault(defaultBook) { $0.publicationYear > 1920 }
                    expect(result?.title).to(equal("Les Enfants Terribles"))
                    let result2: Book? = enumerableBooks.singleOrDefault(defaultBook) { $0.publicationYear > 2000 }
                    expect(result2?.title).to(equal("t"))
                }
                it("is returns nil if more than one element satisfies the condition") {
                    let result: Book? = enumerableBooks.singleOrDefault(defaultBook) { $0.publicationYear > 1900 }
                    expect(result).to(beNil())
                }
            }
            
            describe("skip") {
                it("is bypasses a specified number of elements in a sequence and then returns the remaining elements") {
                    let result: Enumerable<Book> = enumerableBooks.skip(3)
                    result.eachWithIndex { (book: Book, index: Int) -> Void in
                        let originalBook: Book = books[index + 3]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
            
            describe("skipWhile") {
                it("is bypasses elements in a sequence as long as a specified condition is true") {
                    let result: Enumerable<Book> = enumerableBooks.skipWhile {
                        (book: Book) -> Bool in book.publicationYear < 1920
                    }
                    result.eachWithIndex { (book: Book, index: Int) -> Void in
                        let originalBook: Book = books[index + 2]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
                it("is the element's index is used in the logic of the predicate function") {
                    let result: Enumerable<Book> = enumerableBooks.skipWhile {
                        (book: Book, index: Int) -> Bool in
                        book.publicationYear * index < 4000
                    }
                    result.eachWithIndex { (book: Book, index: Int) -> Void in
                        let originalBook: Book = books[index + 3]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
            
            describe("take") {
                it("is returns a specified number of contiguous elements from the start of a sequence") {
                    let result: Enumerable<Book> = enumerableBooks.take(3)
                    expect(result.count()).to(equal(3))
                    result.eachWithIndex { (book: Book, index: Int) -> Void in
                        let originalBook: Book = books[index]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
            
            describe("takeWhile") {
                it("is returns elements from a sequence as long as a specified condition is true") {
                    let result: Enumerable<Book> = enumerableBooks.takeWhile {
                        (book: Book) -> Bool in book.publicationYear < 1920
                    }
                    expect(result.count()).to(equal(2))
                    result.eachWithIndex { (book: Book, index: Int) -> Void in
                        let originalBook: Book = books[index]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
                it("is the element's index is used in the logic of the predicate function") {
                    let result: Enumerable<Book> = enumerableBooks.takeWhile {
                        (book: Book, index: Int) -> Bool in book.publicationYear * index < 5000
                    }
                    expect(result.count()).to(equal(4))
                    result.eachWithIndex { (book: Book, index: Int) -> Void in
                        let originalBook: Book = books[index]
                        expect(book.title).to(equal(originalBook.title))
                        expect(book.author).to(equal(originalBook.author))
                        expect(book.publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
        }
    }
}