//
//  EnumerableSSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/26.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Nimble
import Quick

class EnumerableGroupingSpec: QuickSpec {
    override func spec() {
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("groupBy") {
                it("is groups the elements of a sequence according to a specified key selector function") {
                    let result: Enumerable<Grouping<Bool, Book>> = enumerableBooks.groupBy { $0.publicationYear > 1900 }
                    expect(result.count()).to(equal(2))
                    result.each { (group: Grouping<Bool, Book>) in
                        var generator: GeneratorOf<Book> = group.elements.generate()
                        if group.key {
                            let first: Book? = generator.next()
                            expect(first!.publicationYear).to(equal(1905))
                            let second: Book? = generator.next()
                            expect(second!.publicationYear).to(equal(1929))
                        } else {
                            let first: Book? = generator.next()
                            expect(first!.publicationYear).to(equal(1866))
                            let second: Book? = generator.next()
                            expect(second!.publicationYear).to(equal(1472))
                            let third: Book? = generator.next()
                            expect(third!.publicationYear).to(equal(1667))
                        }
                    }
                }
                it("is projects the elements for each group by using a specified function") {
                    let result: Enumerable<Grouping<Bool, Int>> = enumerableBooks.groupBy({ $0.publicationYear > 1900 }) { $0.publicationYear }
                    expect(result.count()).to(equal(2))
                    result.each { (group: Grouping<Bool, Int>) in
                        var generator: GeneratorOf<Int> = group.elements.generate()
                        if group.key {
                            let first: Int? = generator.next()
                            expect(first!).to(equal(1905))
                            let second: Int? = generator.next()
                            expect(second!).to(equal(1929))
                        } else {
                            let first: Int? = generator.next()
                            expect(first!).to(equal(1866))
                            let second: Int? = generator.next()
                            expect(second!).to(equal(1472))
                            let third: Int? = generator.next()
                            expect(third!).to(equal(1667))
                        }
                    }
                }
                it("is creates a result value from each group and its key") {
                    let result: Enumerable<(key: Bool, count: Int)> = enumerableBooks.groupBy({ $0.publicationYear > 1900 }) {
                        (key: Bool, books: Enumerable<Book>) -> (key: Bool, count: Int) in
                        return (key, books.count())
                    }
                    expect(result.count()).to(equal(2))
                    result.each { (group: (key: Bool, count: Int)) in
                        if group.key {
                            expect(group.count).to(equal(2))
                        } else {
                            expect(group.count).to(equal(3))
                        }
                    }
                }
                it("is the elements of each group are projected by using a specified function") {
                    let result: Enumerable<(key: Bool, average: Double)> = enumerableBooks.groupBy({ $0.publicationYear > 1900 },
                        elementSelector: { $0.publicationYear },
                        resultSelector: { (key: Bool, books: Enumerable<Int>) -> (key: Bool, average: Double) in
                            return (key, books.average { $0 })
                    })
                    expect(result.count()).to(equal(2))
                    result.each { (group: (key: Bool, average: Double)) in
                        if group.key {
                            expect(group.average).to(equal(1917))
                        } else {
                            expect(NSString(format: "%.1f", group.average)).to(equal("1668.3"))
                        }
                    }
                }
            }
        }
    }
}
