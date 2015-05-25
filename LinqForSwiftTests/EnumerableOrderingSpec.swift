//
//  EnumerableOSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/25.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Nimble
import Quick

class EnumerableOrderingSpec: QuickSpec {
    override func spec() {
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("orderBy") {
                it("is sorts the elements of a sequence in ascending order according to a key") {
                    let sortedBooks: OrderedEnumerable<Book> = enumerableBooks.orderBy { $0.publicationYear }
                    sortedBooks.each { (book: Book, index: Int) in
                        switch index {
                        case 0:
                            expect(book.title).to(equal("La Divina Commedia"))
                        case 1:
                            expect(book.title).to(equal("Paradise Lost"))
                        case 2:
                            expect(book.title).to(equal("Crime and Punishment"))
                        case 3:
                            expect(book.title).to(equal("Unterm Rad"))
                        case 4:
                            expect(book.title).to(equal("Les Enfants Terribles"))
                        default:
                            assertionFailure("invalid index")
                        }
                    }
                }
            }
            
            describe("orderByDescending") {
                it("is sorts the elements of a sequence in descending order according to a key") {
                    let sortedBooks: OrderedEnumerable<Book> = enumerableBooks.orderByDescending { $0.publicationYear }
                    sortedBooks.each { (book: Book, index: Int) in
                        switch index {
                        case 0:
                            expect(book.title).to(equal("Les Enfants Terribles"))
                        case 1:
                            expect(book.title).to(equal("Unterm Rad"))
                        case 2:
                            expect(book.title).to(equal("Crime and Punishment"))
                        case 3:
                            expect(book.title).to(equal("Paradise Lost"))
                        case 4:
                            expect(book.title).to(equal("La Divina Commedia"))
                        default:
                            assertionFailure("invalid index")
                        }
                    }
                }
            }
            
            describe("reverse") {
                it("is inverts the order of the elements in a sequence") {
                    let sortedBooks: Enumerable<Book> = enumerableBooks.orderBy { $0.publicationYear }.reverse()
                    sortedBooks.each { (book: Book, index: Int) in
                        switch index {
                        case 0:
                            expect(book.title).to(equal("Les Enfants Terribles"))
                        case 1:
                            expect(book.title).to(equal("Unterm Rad"))
                        case 2:
                            expect(book.title).to(equal("Crime and Punishment"))
                        case 3:
                            expect(book.title).to(equal("Paradise Lost"))
                        case 4:
                            expect(book.title).to(equal("La Divina Commedia"))
                        default:
                            assertionFailure("invalid index")
                        }
                    }
                }
            }
            
            describe("thenBy") {
                it("is performs a subsequent ordering of the elements in a sequence in ascending order according to a key") {
                    let orderedPets: OrderedEnumerable<Pet> = pets.orderBy { $0.owner.name }.thenBy { $0.name }
                    let result: String = orderedPets.aggregate("") { "\($0),\($1.name)" }
                    expect(result).to(equal(",Barley,Boots,Daisy,Whiskers"))
                }
            }
            
            describe("thenByDescending") {
                it("is performs a subsequent ordering of the elements in a sequence in descending order, according to a key") {
                    let orderedPets: OrderedEnumerable<Pet> = pets.orderBy { $0.owner.name }.thenByDescending { $0.name }
                    let result: String = orderedPets.aggregate("") { "\($0),\($1.name)" }
                    expect(result).to(equal(",Boots,Barley,Daisy,Whiskers"))
                }
            }
            
        }
    }
}
