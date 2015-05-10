//
//  EnumerableASpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/16.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Nimble
import Quick

class EnumerableProjectionAndFilteringSpec: QuickSpec {
    override func spec() {
        
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("where$") {
                it("is filters a sequence of values based on a predicate") {
                    let result: Enumerable<Book> = enumerableBooks.where$ { $0.publicationYear > 1900 }
                    expect(result.count()).to(equal(2))
                    var generator: GeneratorOf<Book> = result.generate()
                    let first: Book? = generator.next()
                    expect(first!.publicationYear).to(equal(1905))
                    let second: Book? = generator.next()
                    expect(second!.publicationYear).to(equal(1929))
                }
                it("is each element's index is used in the logic of the predicate function") {
                    let result: Enumerable<Book> = enumerableBooks.where$ { $1 % 2 == 1 }
                    expect(result.count()).to(equal(2))
                    var generator: GeneratorOf<Book> = result.generate()
                    let first: Book? = generator.next()
                    expect(first!.publicationYear).to(equal(1905))
                    let second: Book? = generator.next()
                    expect(second!.publicationYear).to(equal(1472))
                }
            }
            
            describe("select") {
                it("is projects each element of a sequence into a new form") {
                    let titles: Enumerable<String> = enumerableBooks.select { $0.title }
                    titles.eachWithIndex { (title: String, index: Int) in
                        switch index {
                        case 0:
                            expect(title).to(equal("Crime and Punishment"))
                        case 1:
                            expect(title).to(equal("Unterm Rad"))
                        case 2:
                            expect(title).to(equal("Les Enfants Terribles"))
                        case 3:
                            expect(title).to(equal("La Divina Commedia"))
                        case 4:
                            expect(title).to(equal("Paradise Lost"))
                        default:
                            assertionFailure("invalid index")
                        }
                    }
                }
                it("is projects each element of a sequence into a new form by incorporating the element's index") {
                    let titles: Enumerable<String> = enumerableBooks.select { "\($1):\($0.title)" }
                    titles.eachWithIndex { (title: String, index: Int) in
                        switch index {
                        case 0:
                            expect(title).to(equal("0:Crime and Punishment"))
                        case 1:
                            expect(title).to(equal("1:Unterm Rad"))
                        case 2:
                            expect(title).to(equal("2:Les Enfants Terribles"))
                        case 3:
                            expect(title).to(equal("3:La Divina Commedia"))
                        case 4:
                            expect(title).to(equal("4:Paradise Lost"))
                        default:
                            assertionFailure("invalid index")
                        }
                    }
                }
            }
            
            describe("selectMany") {
                let petOwners: [(name: String, pets: [String])] = [
                    (name: "Higa, Sidney", pets: ["Scruffy", "Sam"]),
                    (name: "Ashkenazi, Ronen", pets: ["Walker", "Sugar"]),
                    (name: "Price, Vernette", pets: ["Scratches", "Diesel"])
                ]
                it("is Projects each element of a sequence to an Enumerable<T>, and flattens the resulting sequences into one sequence") {
                    let result: Enumerable<String> = Enumerable.from(petOwners).selectMany { $0.pets }
                    result.eachWithIndex { (pet: String, index: Int) in
                        switch index {
                        case 0: expect(pet).to(equal("Scruffy"))
                        case 1: expect(pet).to(equal("Sam"))
                        case 2: expect(pet).to(equal("Walker"))
                        case 3: expect(pet).to(equal("Sugar"))
                        case 4: expect(pet).to(equal("Scratches"))
                        case 5: expect(pet).to(equal("Diesel"))
                        default: assertionFailure("invalid index")
                        }
                    }
                }
                it("is the index of each source element is used in the projected form of that element") {
                    let result: Enumerable<String> = Enumerable.from(petOwners)
                        .selectMany { (x, i) in x.pets.map { "\(i)\($0)" } }
                    result.eachWithIndex { (pet: String, index: Int) in
                        switch index {
                        case 0: expect(pet).to(equal("0Scruffy"))
                        case 1: expect(pet).to(equal("0Sam"))
                        case 2: expect(pet).to(equal("1Walker"))
                        case 3: expect(pet).to(equal("1Sugar"))
                        case 4: expect(pet).to(equal("2Scratches"))
                        case 5: expect(pet).to(equal("2Diesel"))
                        default: assertionFailure("invalid index")
                        }
                    }
                }
                it("is invokes a result selector function on each element therein") {
                    let result: Enumerable<(owner: String, pet: String)> = Enumerable.from(petOwners)
                        .selectMany({ $0.pets }) { (owner: $0.name, pet: $1) }
                    result.eachWithIndex { (x, index: Int) in
                        switch index {
                        case 0: expect(x.owner).to(equal("Higa, Sidney")); expect(x.pet).to(equal("Scruffy"))
                        case 1: expect(x.owner).to(equal("Higa, Sidney")); expect(x.pet).to(equal("Sam"))
                        case 2: expect(x.owner).to(equal("Ashkenazi, Ronen")); expect(x.pet).to(equal("Walker"))
                        case 3: expect(x.owner).to(equal("Ashkenazi, Ronen")); expect(x.pet).to(equal("Sugar"))
                        case 4: expect(x.owner).to(equal("Price, Vernette")); expect(x.pet).to(equal("Scratches"))
                        case 5: expect(x.owner).to(equal("Price, Vernette")); expect(x.pet).to(equal("Diesel"))
                        default: assertionFailure("invalid index")
                        }
                    }
                }
                it("is the index of each source element is used in the intermediate projected form of that element") {
                    let result: Enumerable<(owner: String, pet: String)> = Enumerable.from(petOwners)
                        .selectMany({ (x, i) in x.pets.map { "\(i)\($0)" } }) { (owner: $0.name, pet: $1) }
                    result.eachWithIndex { (x, index: Int) in
                        switch index {
                        case 0: expect(x.owner).to(equal("Higa, Sidney")); expect(x.pet).to(equal("0Scruffy"))
                        case 1: expect(x.owner).to(equal("Higa, Sidney")); expect(x.pet).to(equal("0Sam"))
                        case 2: expect(x.owner).to(equal("Ashkenazi, Ronen")); expect(x.pet).to(equal("1Walker"))
                        case 3: expect(x.owner).to(equal("Ashkenazi, Ronen")); expect(x.pet).to(equal("1Sugar"))
                        case 4: expect(x.owner).to(equal("Price, Vernette")); expect(x.pet).to(equal("2Scratches"))
                        case 5: expect(x.owner).to(equal("Price, Vernette")); expect(x.pet).to(equal("2Diesel"))
                        default: assertionFailure("invalid index")
                        }
                    }
                }
            }
            
            describe("ofType") {
                it("is filters the elements of an Enumerable based on a specified type") {
                    let mixedTypeEnumerable: Enumerable<AnyObject> = Enumerable<AnyObject>.from([1, 2, "foo", 3, "bar"])
                    let result: Enumerable<String> = mixedTypeEnumerable.ofType(String)
                    expect(result.count()).to(equal(2))
                    result.eachWithIndex { (element: String, index: Int) in
                        switch index {
                        case 0:
                            expect(element).to(equal("foo"))
                        case 1:
                            expect(element).to(equal("bar"))
                        default:
                            break
                        }
                    }
                }
            }
            
            describe("zip") {
                it("is applies a specified function to the corresponding elements of two sequences, producing a sequence of the results") {
                    let numbers = [1, 2, 3, 4, 5]
                    let words = ["one", "two", "three"]
                    let result = Enumerable.from(numbers).zip(words) { "\($0) \($1)" }
                    let expects = ["1 one", "2 two", "3 three"]
                    expect(result.sequenceEqual(expects) { $0 == $1 }).to(beTrue())
                }
            }
        }
    }
}
