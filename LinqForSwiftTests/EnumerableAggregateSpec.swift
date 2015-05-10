//
//  EnumerableTSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/29.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Nimble
import Quick

class EnumerableAggregateSpec: QuickSpec {
    override func spec() {
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("aggregate") {
                it("is applies an accumulator function over a sequence") {
                    func accumulator(working: Book, next: Book) -> Book {
                        return working.publicationYear < next.publicationYear ? working : next
                    }
                    let result: Book? = enumerableBooks.aggregate(accumulator)
                    expect(result?.title).to(equal("La Divina Commedia"))
                }
                it("is the specified seed value is used as the initial accumulator value") {
                    func accumulator(working: Int, next: Book) -> Int {
                        return working + next.publicationYear
                    }
                    let result: Int? = enumerableBooks.aggregate(1, accumulator: accumulator)
                    expect(result).to(equal(8840))
                }
                it("is the specified function is used to select the result value") {
                    func accumulator(working: String, next: Book) -> String {
                        return count(working) < count(next.title) ?  next.title : working
                    }
                    func resultSelector(working: String) -> String {
                        return working.uppercaseString
                    }
                    let result: String = enumerableBooks.aggregate("", accumulator: accumulator, resultSelector: resultSelector)
                    expect(result).to(equal("LES ENFANTS TERRIBLES"))
                }
            }
            
            describe("average") {
                it("is computes the average") {
                    let result: Double = enumerableBooks.average { $0.publicationYear }
                    expect(result).to(equal(8839.0 / 5.0))
                }
            }
            
            describe("count") {
                it("is returns the number of elements in a sequence") {
                    let count: Int = enumerableBooks.count()
                    expect(count).to(equal(5))
                }
                it("is returns a number that represents how many elements in the specified sequence satisfy a condition") {
                    let count: Int = enumerableBooks.count { $0.publicationYear > 1900 }
                    expect(count).to(equal(2))
                }
            }

            describe("max") {
                it("is returns the maximum value in a sequence") {
                    let result = enumerableBooks.max { $0.publicationYear }
                    expect(result!).to(equal(1929))
                }
            }
            
            describe("min") {
                it("is returns the minimum value in a sequence") {
                    let result = enumerableBooks.min { $0.publicationYear }
                    expect(result!).to(equal(1472))
                }
            }

            describe("sum") {
                it("is computes the sum of the sequence of NumericType values") {
                    let result: Int = enumerableBooks.sum { (book: Book) -> Int in book.publicationYear }
                    expect(result).to(equal(8839))
                }
            }
        }
    }
}