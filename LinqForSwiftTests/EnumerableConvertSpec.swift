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
                    Enumerable<Int>.from(0..<count(bookArray)).each { (i: Int) -> Void in
                        let originalBook: Book = books[i]
                        expect(bookArray[i].title).to(equal(originalBook.title))
                        expect(bookArray[i].author).to(equal(originalBook.author))
                        expect(bookArray[i].publicationYear).to(equal(originalBook.publicationYear))
                    }
                }
            }
            
            describe("toDictionary") {
                it("is creates a Dictionary<TKey, T> from an Enumerable<T>") {
                    let bookDict: [String:Book] = enumerableBooks.toDictionary { $0.author }!
                    var keys: [String]? = bookDict.keys.array
                    for key in keys! {
                        expect(bookDict[key]!.author).to(equal(key))
                    }
                    let dupKey: [Character:Book]? = enumerableBooks.toDictionary { Enumerable.from($0.author).first()! }
                    expect(dupKey).to(beNil())
                }
                it("is creates a Dictionary<TKey, TValue> from an Enumerable<T>") {
                    let authorTitles: [String:String] = enumerableBooks.toDictionary({ $0.author }) { $0.title }!
                    expect(authorTitles["Fyodor Dostoyevsky"]).to(equal("Crime and Punishment"))
                    expect(authorTitles["Hermann Hesse"]).to(equal("Unterm Rad"))
                    expect(authorTitles["Jean Cocteau"]).to(equal("Les Enfants Terribles"))
                    expect(authorTitles["Durante Alighieri"]).to(equal("La Divina Commedia"))
                    expect(authorTitles["John Milton"]).to(equal("Paradise Lost"))
                    let dupKey: [Character:String]? = enumerableBooks.toDictionary({ Enumerable.from($0.author).first()! }) { $0.title }
                    expect(dupKey).to(beNil())
                }
            }
            
            describe("toLookup") {
                it("is creates a Lookup<TKey, T> from an Enumerable<T>") {
                    let even = Enumerable.from(1...10).toLookup { (x: Int) -> Bool in x % 2 == 0 }
                    expect(even[true].aggregate("") { $0 + String($1) }).to(equal("246810"))
                    expect(even[false].aggregate("") { $0 + String($1) }).to(equal("13579"))
                }
                it("is creates a Lookup<TKey, TElement> from an Enumerable<T>") {
                    let even = Enumerable.from(1...10).toLookup({ (x: Int) -> Bool in x % 2 == 0 }) {
                        (x: Int) -> String in String(x)
                    }
                    expect(even[true].aggregate("") { $0 + $1 }).to(equal("246810"))
                    expect(even[false].aggregate("") { $0 + $1 }).to(equal("13579"))
                }
            }
        }
    }
}
