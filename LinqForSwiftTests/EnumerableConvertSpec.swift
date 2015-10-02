//
//  EnumerableConvertSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/05/03.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

//
//  EnumerableSSpec.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/26.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Nimble
import Quick

class EnumerableConvertSpec: QuickSpec {
    override func spec() {
        describe("Enumerable") {
            let enumerableBooks: Enumerable<Book> = Enumerable.from(books)
            
            describe("toArray") {
                it("is creates an array from a Enumerable<T>") {
                    let bookArray: [Book] = enumerableBooks.toArray()
                    Enumerable<Int>.from(0..<bookArray.count).each { (i: Int) -> Void in
                        let originalBook: Book = books[i]
                        let title = bookArray[i].title
                        expect(title).to(equal(originalBook.title))
                        let author = bookArray[i].author
                        expect(author).to(equal(originalBook.author))
                        expect(bookArray[i].publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
            
            describe("toDictionary") {
                it("is creates a Dictionary<TKey, T> from an Enumerable<T>") {
                    let bookDict: [String:Book] = enumerableBooks.toDictionary { $0.author }!
                    let keys: [String]? = bookDict.keys.map { $0 }
                    for key in keys! {
                        expect(bookDict[key]!.author).to(equal(key))
                    }
                    let dupKey: [Character:Book]? = enumerableBooks.toDictionary { $0.author.characters.first! }
                    expect(dupKey).to(beNil())
                }
                it("is creates a Dictionary<TKey, TValue> from an Enumerable<T>") {
                    let authorTitles: [String:String] = enumerableBooks.toDictionary({ $0.author }) { $0.title }!
                    expect(authorTitles["Fyodor Dostoyevsky"]).to(equal("Crime and Punishment"))
                    expect(authorTitles["Hermann Hesse"]).to(equal("Unterm Rad"))
                    expect(authorTitles["Jean Cocteau"]).to(equal("Les Enfants Terribles"))
                    expect(authorTitles["Durante Alighieri"]).to(equal("La Divina Commedia"))
                    expect(authorTitles["John Milton"]).to(equal("Paradise Lost"))
                    let dupKey: [Character:String]? = enumerableBooks.toDictionary({ $0.author.characters.first! }) { $0.title }
                    expect(dupKey).to(beNil())
                }
            }
            
            describe("toLookup") {
                it("is creates a Lookup<TKey, T> from an Enumerable<T>") {
                    let even = Enumerable.from(1...10).toLookup { (x: Int) -> Bool in x % 2 == 0 }
                    let evenTrues = even[true].aggregate("") { $0 + String($1) }
                    expect(evenTrues).to(equal("246810"))
                    let evenFalses = even[false].aggregate("") { $0 + String($1) }
                    expect(evenFalses).to(equal("13579"))
                }
                it("is creates a Lookup<TKey, TElement> from an Enumerable<T>") {
                    let even = Enumerable.from(1...10).toLookup({ (x: Int) -> Bool in x % 2 == 0 }) {
                        (x: Int) -> String in String(x)
                    }
                    let evenTrues = even[true].aggregate("") { $0 + $1 }
                    expect(evenTrues).to(equal("246810"))
                    let evenFalses = even[false].aggregate("") { $0 + $1 }
                    expect(evenFalses).to(equal("13579"))
                }
            }
        }
    }
}
