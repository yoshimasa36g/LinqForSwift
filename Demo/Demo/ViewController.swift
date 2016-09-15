//
//  ViewController.swift
//  Demo
//
//  Created by fssoftware on 2016/09/15.
//  Copyright © 2016年 yoshimasa36g. All rights reserved.
//

import UIKit
import LinqForSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        examples()
        generatingMethods()
        projectionAndFilteringMethods()
        joinMethods()
        setMethods()
        orderingMethods()
        groupingMethods()
        aggregateMethods()
        pagingMethods()
        convertMethods()
        actionMethods()
        debugMethods()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func examples() {
        struct Person {
            let name: String
            let age: Int
            let gender: Gender
        }

        enum Gender {
            case male, female, other
        }

        let people: [Person] = [
            Person(name: "A", age: 20, gender: .male),
            Person(name: "B", age: 25, gender: .male),
            Person(name: "C", age: 30, gender: .male),
            Person(name: "D", age: 35, gender: .male),
            Person(name: "E", age: 20, gender: .female),
            Person(name: "F", age: 25, gender: .female),
            Person(name: "G", age: 30, gender: .female),
            Person(name: "H", age: 35, gender: .female),
            Person(name: "I", age: 10, gender: .other),
            Person(name: "J", age: 20, gender: .other),
            Person(name: "K", age: 25, gender: .other),
            Person(name: "L", age: 30, gender: .other),
        ]

        print("========== examples ==========")
        print("--- get names of female of 20s ---")
        let result = people.toEnumerable()
            .where$ { 20 <= $0.age }
            .where$ { $0.age < 30 }
            .where$ { $0.gender == .female }
            .select { $0.name }
        for name in result {
            print(name)
        }

        print("--- get people of 20s by gender ---")
        let result2 = people.toEnumerable()
            .where$ { 20 <= $0.age }
            .where$ { $0.age < 30 }
            .toLookup { $0.gender }
        print("males:")
        for male in result2[.male] {
            print(male.name)
        }
        print("females:")
        for female in result2[.female] {
            print(female.name)
        }
        print("others:")
        for other in result2[.other] {
            print(other.name)
        }
    }

    func generatingMethods() {
        print("===== Generating methods =====")

        print("--- choice ---")
        Enumerable.choice(["a", "b", "c", "d", "e"])
            .take(10)
            .each { (x: String) -> Void in print(x) }

        print("--- cycle ---")
        Enumerable.cycle(["a", "b", "c", "d", "e"])
            .take(10)
            .each { (x: String) -> Void in print(x) }

        print("--- empty ---")
        let empty = Enumerable<Int>.empty()
        print("count:\(empty.count())")

        print("--- from ---")
        Enumerable.from(1...5)
            .each { (x: Int) -> Void in print(x) }

        print("--- infinity ---")
        Enumerable<Int>.infinity(0)
            .take(10)
            .each { (x: Int) -> Void in print(x) }

        print("--- negativeInfinity ---")
        Enumerable<Int>.negativeInfinity(0)
            .take(10)
            .each { (x: Int) -> Void in print(x) }

        print("--- range ---")
        Enumerable<Int>.range(0, count: 5)
            .each { (x: Int) -> Void in print(x) }

        print("--- range with step ---")
        Enumerable<Int>.range(0, step: 3, count: 5)
            .each { (x: Int) -> Void in print(x) }

        print("--- rangeDown ---")
        Enumerable<Int>.rangeDown(0, count: 5)
            .each { (x: Int) -> Void in print(x) }

        print("--- rangeDown with step ---")
        Enumerable<Int>.rangeDown(0, step: 3, count: 5)
            .each { (x: Int) -> Void in print(x) }

        print("--- repeat$ ---")
        Enumerable.repeat$("a").take(5)
            .each { (x: String) -> Void in print(x) }

        print("--- repeat$ with count ---")
        Enumerable.repeat$("a", count: 3)
            .each { (x: String) -> Void in print(x) }

        print("--- return$ ---")
        Enumerable.return$("hoge")
            .each { (x: String) -> Void in print(x) }
    }

    func projectionAndFilteringMethods() {
        print("========== Projection and Filtering methods ==========")

        print("--- ofType ---")
        Enumerable.from([1, "a", 2, "b", 3, "c"]).ofType(String.self)
            .each { (x: String) -> Void in print(x) }

        print("--- scan ---")
        Enumerable.from(1...10).scan { $0 + $1 }
            .each { (x: Int) -> Void in print(x) }

        print("--- scan with seed ---")
        Enumerable.from(1...10).scan(100) { $0 + $1 }
            .each { (x: Int) -> Void in print(x) }

        print("--- scan with result selector ---")
        Enumerable.from(1...10)
            .scan(100, accumulator: { $0 + $1 }) { $0 * 10 }
            .each { (x: Int) -> Void in print(x) }

        print("--- select ---")
        Enumerable.from(["oo", "ac", "lac", "ul"])
            .select { "B\($0)k" }
            .each { (x: String) -> Void in print(x) }

        print("--- select with index ---")
        Enumerable.from(["a", "b", "c", "d", "e"])
            .select { "\($1):\($0)" }
            .each { (x: String) -> Void in print(x) }

        print("--- selectMany ---")
        Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
            .selectMany { $0.1 }
            .each { (x: String) -> Void in print(x) }

        print("--- selectMany with index ---")
        Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
            .selectMany { (x, i) -> [String] in x.1.map { "\(i):\($0)" } }
            .each { (x: String) -> Void in print(x) }

        print("--- selectMany with result selector ---")
        Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
            .selectMany({ $0.1 }) { "\($0.0):\($1)" }
            .each { (x: String) -> Void in print(x) }

        print("--- selectMany with index and result selector ---")
        Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
            .selectMany({ (x, i) -> [(Int, String)] in x.1.map { (i, $0) } }) {
                "\($1.0):\($0.0):\($1.1)"
            }
            .each { (x: String) -> Void in print(x) }

        print("--- where$ ---")
        Enumerable.from(1...10).where$ { $0 % 2 == 0 }
            .each { (x: Int) -> Void in print(x) }

        print("--- where$ with index ---")
        Enumerable.from(1...10).where$ { (x: Int, i: Int) -> Bool in x % 2 == 0 || i < 5 }
            .each { (x: Int) -> Void in print(x) }

        print("--- zip ---")
        Enumerable.from(1...10).zip(1...5) { $0 * $1 }
            .each { (x: Int) -> Void in print(x) }
    }

    func joinMethods() {
        print("========== Join methods ==========")

        struct Data {
            let index: Int
            let text: String
        }

        let keySelector = { (x: Data) -> Int in x.index }

        print("--- groupJoin ---")
        let array1 = [Data(index: 1, text: "app"),
                      Data(index: 2, text: "ban")]
        let array2 = [Data(index: 1, text: "l"),
                      Data(index: 1, text: "e"),
                      Data(index: 2, text: "a"),
                      Data(index: 2, text: "n"),
                      Data(index: 2, text: "a")]
        Enumerable.from(array1)
            .groupJoin(array2,
                       outerKeySelector: keySelector,
                       innerKeySelector: keySelector) {
                           (a1: Data, a2: Enumerable<Data>) -> String in
                           a1.text + a2.aggregate("") { $0 + $1.text }
                       }
            .each { (x: String) -> Void in print(x) }

        print("--- join ---")
        let array3 = [Data(index: 1, text: "app"),
                      Data(index: 2, text: "ban"),
                      Data(index: 3, text: "ora")]
        let array4 = [Data(index: 1, text: "le"),
                      Data(index: 2, text: "ana"),
                      Data(index: 3, text: "nge")]
        Enumerable.from(array3)
            .join(array4,
                  outerKeySelector: keySelector,
                  innerKeySelector: keySelector) { $0.text + $1.text }
            .each { (x: String) -> Void in print(x) }
    }

    func setMethods() {
        print("========== Set methods ==========")

        print("--- all ---")
        let underThan5 = Enumerable.from(1...10).all { $0 < 5 }
        print(underThan5)
        let underThan15 = Enumerable.from(1...10).all { $0 < 15 }
        print(underThan15)

        print("--- any ---")
        let hasAny = Enumerable.from([Int]()).any()
        print(hasAny)
        let hasAny2 = Enumerable.from([1, 2, 3]).any()
        print(hasAny2)

        print("--- any with predicate ---")
        let hasAnyEqualTo5 = Enumerable.from(1...10).any { $0 == 5 }
        print(hasAnyEqualTo5)
        let hasAnyEqualTo15 = Enumerable.from(1...10).any { $0 == 15 }
        print(hasAnyEqualTo15)

        print("--- concat ---")
        Enumerable.from(1...3).concat(4...5)
            .each { (x: Int) -> Void in print(x) }

        print("--- contains ---")
        let contains2 = Enumerable.from(1...3).contains(2) { $0 == $1 }
        print(contains2)
        let contains4 = Enumerable.from(1...3).contains(4) { $0 == $1 }
        print(contains4)

        print("--- defaultIfEmpty ---")
        Enumerable.from([Int]()).defaultIfEmpty(5)
            .each { (x: Int) -> Void in print(x) }
        print("--")
        Enumerable.from(1...3).defaultIfEmpty(5)
            .each { (x: Int) -> Void in print(x) }

        print("--- distinct ---")
        Enumerable.from([1, 1, 3, 2, 2, 3]).distinct { $0 }
            .each { (x: Int) -> Void in print(x) }

        print("--- distinct with comparer ---")
        Enumerable.from([1, 1, 2, 3, 4, 4]).distinct { $0 == $1 }
            .each { (x: Int) -> Void in print(x) }

        print("--- except ---")
        let array1 = [57, 405, 730, 57, 82]
        let array2 = [33, 55, 730, 82, 58]
        Enumerable.from(array1).except(array2) { $0 }
            .each { (x: Int) -> Void in print(x) }

        print("--- except with comparer ---")
        let array3 = Enumerable.from(["a", "b", "c", "d", "e"])
        let array4 = Enumerable.from(["B", "C", "E"])
        Enumerable.from(array3).except(array4) { $0.uppercased() == $1}
            .each { (x: String) -> Void in print(x) }

        print("--- intersect ---")
        let array5 = [57, 405, 730, 57, 82]
        let array6 = [33, 55, 730, 82, 58]
        Enumerable.from(array5).intersect(array6) { $0 }
            .each { (x: Int) -> Void in print(x) }

        print("--- intersect with comparer ---")
        let array7 = Enumerable.from(["a", "b", "c", "d", "e"])
        let array8 = Enumerable.from(["B", "C", "E"])
        Enumerable.from(array7).intersect(array8) { $0.uppercased() == $1}
            .each { (x: String) -> Void in print(x) }

        print("--- sequenceEqual ---")
        let array9 = [1, 2, 3, 4, 5]
        let array10 = [1, 2, 3, 4, 5]
        let isEqual = Enumerable.from(array9).sequenceEqual(array10) { $0 == $1 }
        print(isEqual)
        let array11 = [1, 2, 3, 4, 5, 6]
        let isEqual2 = Enumerable.from(array9).sequenceEqual(array11) { $0 == $1 }
        print(isEqual2)

        print("--- union with comparer ---")
        Enumerable.from(1...8).union(3...10) { $0 == $1 }
            .each { (x: Int) -> Void in print(x) }

        print("--- union with key selector ---")
        Enumerable.from(1...8).union(3...10) { $0 }
            .each { (x: Int) -> Void in print(x) }
    }

    func orderingMethods() {
        print("========== Ordering methods ==========")

        print("--- orderBy ---")
        Enumerable.from([1, 71, 5, 3, 12]).orderBy { $0 }
            .each { (x: Int) -> Void in print(x) }

        print("--- orderByDescending ---")
        Enumerable.from([1, 71, 5, 3, 12]).orderByDescending { $0 }
            .each { (x: Int) -> Void in print(x) }

        print("--- reverse ---")
        Enumerable.from([1, 71, 5, 3, 12]).reverse()
            .each { (x: Int) -> Void in print(x) }

        print("--- thenBy ---")
        Enumerable.from([(3, 5), (1, 2), (2, 8), (3, 1)])
            .orderBy { $0.0 }.thenBy { $0.1 }
            .each { (x: (Int, Int)) -> Void in print(x) }

        print("--- thenByDescending ---")
        Enumerable.from([(3, 5), (1, 2), (2, 8), (3, 1)])
            .orderBy { $0.0 }.thenByDescending { $0.1 }
            .each { (x: (Int, Int)) -> Void in print(x) }

    }

    func groupingMethods() {
        print("========== Grouping methods ==========")

        let accumulator = { (x: String, y: Int) -> String in
            "\(x)/\(String(y))"
        }
        let selector = { (x: Grouping<Bool, Int>) -> String in
            "key:\(x.key)" + x.elements.aggregate("", accumulator: accumulator)
        }
        let resultSelector = { (key: Bool, elements: Enumerable<Int>) -> String in
            "key:\(key)" + elements.aggregate("", accumulator: accumulator)
        }

        print("--- groupBy ---")
        Enumerable.from(1...5).groupBy { $0 % 2 == 0 }.select(selector)
            .each { (x: String) -> Void in print(x) }

        print("--- groupBy with element selector ---")
        Enumerable.from(1...5).groupBy({ $0 % 2 == 0 }) { $0 * 10 }.select(selector)
            .each { (x: String) -> Void in print(x) }

        print("--- groupBy with result selector ---")
        Enumerable.from(1...5).groupBy({ $0 % 2 == 0 }, resultSelector: resultSelector)
            .each { (x: String) -> Void in print(x) }

        print("--- groupBy with element selector and result selector ---")
        Enumerable.from(1...5).groupBy({ $0 % 2 == 0 },
                                       elementSelector: { x -> Int in x * 10 },
                                       resultSelector: resultSelector)
            .each { (x: String) -> Void in print(x) }
    }

    func aggregateMethods() {
        print("========== Aggregate methods ==========")

        print("--- aggregate ---")
        print(Enumerable.from(1...10).aggregate { $0 + $1 })

        print("--- aggregate with seed ---")
        print(Enumerable.from(1...10).aggregate(100) { $0 + $1 })

        print("--- aggregate with result selector ---")
        let result = Enumerable.from(1...10)
            .aggregate(100, accumulator: { $0 + $1 }) { $0 * 10 }
        print(result)

        print("--- average ---")
        print(Enumerable.from(1...16).average { $0 })

        print("--- count ---")
        print(Enumerable.from(1...10).count())

        print("--- count with predicate ---")
        print(Enumerable.from(1...10).count { $0 % 2 == 0 })

        print("--- max ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).max { $0 })

        print("--- min ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).min { $0 })

        print("--- sum ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).sum { $0 })
    }

    func pagingMethods() {
        print("========== Paging methods ==========")

        print("--- elementAt ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).elementAt(2))

        print("--- elementAtOrDefault ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).elementAtOrDefault(1, defaultValue: 0))
        print(Enumerable.from([33, 22, 44, 11, 5]).elementAtOrDefault(10, defaultValue: 0))

        print("--- first ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).first())

        print("--- first with predicate ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).first { $0 < 20 })

        print("--- firstOrDefault ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).firstOrDefault(0))

        print("--- firstOrDefault with predicate ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).firstOrDefault(0) { $0 < 5 })

        print("--- last ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).last())

        print("--- last with predicate ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).last { $0 > 20 })

        print("--- lastOrDefault ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).lastOrDefault(0))

        print("--- lastOrDefault with predicate ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).lastOrDefault(0) { $0 > 50 })

        print("--- single ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).single())

        print("--- single with predicate ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).single { $0 % 3 == 0 })

        print("--- singleOrDefault ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).singleOrDefault(0))

        print("--- singleOrDefault with predicate ---")
        print(Enumerable.from([33, 22, 44, 11, 5]).singleOrDefault(0) { $0 % 6 == 0 })

        print("--- skip ---")
        Enumerable.from([33, 22, 44, 11, 5]).skip(3)
            .each { (x: Int) -> Void in print(x) }

        print("--- skipWhile ---")
        Enumerable.from([33, 22, 44, 11, 5]).skipWhile { $0 < 40 }
            .each { (x: Int) -> Void in print(x) }

        print("--- skipWhile with index ---")
        Enumerable.from([33, 22, 44, 11, 5]).skipWhile { $0 < 10 || $1 < 3 }
            .each { (x: Int) -> Void in print(x) }

        print("--- take ---")
        Enumerable.from([33, 22, 44, 11, 5]).take(3)
            .each { (x: Int) -> Void in print(x) }

        print("--- takeWhile ---")
        Enumerable.from([33, 22, 44, 11, 5]).takeWhile { $0 > 20 }
            .each { (x: Int) -> Void in print(x) }

        print("--- takeWhile with index ---")
        Enumerable.from([33, 22, 44, 11, 5]).takeWhile { $0 > 20 || $1 < 4 }
            .each { (x: Int) -> Void in print(x) }
    }

    func convertMethods() {
        print("========== Convert methods ==========")

        print("--- toArray ---")
        print(Enumerable.from([33, 22, 44, 11, 5])
            .where$ { $0 > 20 }
            .toArray())

        let array = [("apple", 3), ("banana", 2), ("cherry", 5)]

        print("--- toDictionary ---")
        print(Enumerable.from(array).toDictionary { $0.0 })

        print("--- toDictionary with element selector ---")
        print(Enumerable.from(array).toDictionary({ $0.0 }) { $0.1 })

        print("--- toLookup ---")
        let lookup = Enumerable.from(1...10).toLookup { $0 % 2 == 0 }
        print("ture:")
        lookup[true].each { (x: Int) -> Void in print(x) }
        print("false:")
        lookup[false].each { (x: Int) -> Void in print(x) }

        print("--- toLookup with element selector ---")
        let lookup2 = Enumerable.from(1...10).toLookup({ $0 % 2 == 0}) { $0 * 10 }
        lookup2[true].each { (x: Int) -> Void in print(x) }
        print("false:")
        lookup2[false].each { (x: Int) -> Void in print(x) }
    }

    func actionMethods() {
        print("========== Action methods ==========")

        print("--- each ---")
        Enumerable.from(["a", "b", "c", "d", "e"]).each { print($0) }

        print("--- each with index ---")
        Enumerable.from(["a", "b", "c", "d", "e"]).each { print("\($1):\($0)") }

        print("--- force ---")
        Enumerable.from(["a", "b", "c", "d", "e"]).print().force()
        print()
    }

    func debugMethods() {
        print("========== Debug methods ==========")

        print("--- dump ---")
        Enumerable.from(["a", "b", "c", "d", "e"]).dump().force()

        print("--- print ---")
        Enumerable.from(["a", "b", "c", "d", "e"]).print().force()
        print()

        print("--- print with formatter ---")
        Enumerable.from(["a", "b", "c", "d", "e"]).print { $0 + $0 }.force()
        print()

        print("--- println ---")
        Enumerable.from(1...5).println()
            .where$ { $0 % 2 == 0}.println()
            .select { $0 * 10 }.println()
            .force()

        print("--- println with formatter ---")
        Enumerable.from(1...5).println { "from:\($0)" }
            .where$ { x -> Bool in x % 2 == 0}.println { "where:\($0)" }
            .select { x -> Int in x * 10 }.println { "select:\($0)" }
            .force()
    }
}
