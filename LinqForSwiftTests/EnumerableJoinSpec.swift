//
//  EnumerableESpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/16.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Nimble
import Quick

class EnumerableJoinSpec: QuickSpec {
    override func spec() {
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("groupJoin") {
                it("is correlates the elements of two sequences based on equality of keys and groups the results") {
                    let result: Enumerable<(owner: String, pets: Enumerable<String>)> = people.groupJoin(pets,
                        outerKeySelector: { $0.name },
                        innerKeySelector: { $0.owner.name },
                        resultSelector: { (owner: Person, pet: Enumerable<Pet>) -> (owner: String, pets: Enumerable<String>) in
                            return (owner: owner.name, pets: pet.select { $0.name })
                    })
                    expect(result.count()).to(equal(3))
                    result.each { (owner: String, pets: Enumerable<String>) in
                        var g: GeneratorOf<String> = pets.generate()
                        switch owner {
                        case "Hedlund, Magnus":
                            expect(pets.count()).to(equal(1))
                            var first: String? = g.next()
                            expect(first!).to(equal("Daisy"))
                        case "Adams, Terry":
                            expect(pets.count()).to(equal(2))
                            var first: String? = g.next()
                            expect(first!).to(equal("Barley"))
                            var second: String? = g.next()
                            expect(second!).to(equal("Boots"))
                        case "Weiss, Charlotte":
                            expect(pets.count()).to(equal(1))
                            var first: String? = g.next()
                            expect(first!).to(equal("Whiskers"))
                        default:
                            break
                        }
                    }
                }
            }

            describe("join") {
                it("is correlates the elements of two sequences based on matching keys") {
                    let result: Enumerable<(owner: String, pet: String)> = people.join(pets,
                        outerKeySelector: { $0.name },
                        innerKeySelector: { $0.owner.name },
                        resultSelector: { (owner: Person, pet: Pet) -> (owner: String, pet: String) in
                            return (owner: owner.name, pet: pet.name)
                    })
                    expect(result.count()).to(equal(4))
                    result.eachWithIndex { (r: (owner: String, pet: String), i: Int) in
                        switch r.owner {
                        case "Hedlund, Magnus":
                            expect(r.pet).to(equal("Daisy"))
                        case "Adams, Terry":
                            switch (i) {
                            case 1:
                                expect(r.pet).to(equal("Barley"))
                            case 2:
                                expect(r.pet).to(equal("Boots"))
                            default:
                                break
                            }
                        case "Weiss, Charlotte":
                            expect(r.pet).to(equal("Whiskers"))
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
}
