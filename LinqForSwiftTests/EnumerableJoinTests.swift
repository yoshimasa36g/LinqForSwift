//
//  EnumerableESpec.swift
//  Enumerable
//
//  Created by Yoshimasa Aoki on 2015/04/16.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import XCTest

class EnumerableJoinTests: XCTestCase {

    func testGroupJoin() {

        struct Result {
            let owner: String
            let pets: [String]
        }

        let outerKeySelector = { (owner: Person) -> String in owner.name }
        let innerKeySelector = { (pet: Pet) -> String in pet.owner.name }
        let resultSelector = {
            (owner: Person, pet: Enumerable<Pet>) -> Result in
            return Result(owner: owner.name,
                          pets: pet.select({ (p: Pet) -> String in p.name }).toArray())
        }

        let result = people.groupJoin(pets,
                                      outerKeySelector: outerKeySelector,
                                      innerKeySelector: innerKeySelector,
                                      resultSelector: resultSelector)

        XCTAssertEqual(3, result.count())

        for r in result {
            switch r.owner {
            case "Hedlund, Magnus":
                XCTAssertEqual(1, r.pets.count)
                XCTAssertEqual("Daisy", r.pets[0])
            case "Adams, Terry":
                XCTAssertEqual(2, r.pets.count)
                XCTAssertEqual("Barley", r.pets[0])
                XCTAssertEqual("Boots", r.pets[1])
            case "Weiss, Charlotte":
                XCTAssertEqual(1, r.pets.count)
                XCTAssertEqual("Whiskers", r.pets[0])
            default:
                break
            }
        }
    }

    func testJoin() {
        struct Result {
            let owner: String
            let pet: String
        }

        let outerKeySelector = { (owner: Person) -> String in owner.name }
        let innerKeySelector = { (pet: Pet) -> String in pet.owner.name }
        let resultSelector = {
            (owner: Person, pet: Pet) -> Result in
            return Result(owner: owner.name, pet: pet.name)
        }

        let result = people.join(pets,
                                 outerKeySelector: outerKeySelector,
                                 innerKeySelector: innerKeySelector,
                                 resultSelector: resultSelector)

        XCTAssertEqual(4, result.count())
        result.each { (r: Result, i: Int) in
            switch r.owner {
            case "Hedlund, Magnus":
                XCTAssertEqual("Daisy", r.pet)
            case "Adams, Terry":
                switch (i) {
                case 1:
                    XCTAssertEqual("Barley", r.pet)
                case 2:
                    XCTAssertEqual("Boots", r.pet)
                default:
                    break
                }
            case "Weiss, Charlotte":
                XCTAssertEqual("Whiskers", r.pet)
            default:
                break
            }
        }
    }
}
