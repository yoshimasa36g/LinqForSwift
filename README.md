Linq for Swift
========================================

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift>=3.0](https://img.shields.io/badge/Swift-%3E%3D3.0-brightgreen.svg)

Linq for Swift is implemented some .NET Framework methods and some extra methods that is inspired by [linq.js](https://linqjs.codeplex.com/).

## Supported types

* All types that implemented SequneceType protocol
    * Array, Dictionary, and more...

## Examples

```swift
struct Person {
    let name: String
    let age: Int
    let gender: Gender
}

enum Gender {
    case male, female, other
}

let people: [Person] = [/* a lot of people */]

// get names of female of 20s
let result = people.toEnumerable()
                       .where$ { 20 <= $0.age }
                       .where$ { $0.age < 30 }
                       .where$ { $0.gender == .female }
                       .select { $0.name }

// get people of 20s by gender
let result2 = people.toEnumerable()
                        .where$ { 20 <= $0.age }
                        .where$ { $0.age < 30 }
                        .toLookup { $0.gender }
// males
for male in result2[.male] {
    print(male.name)
}
// females
for female in result2[.female] {
    print(female.name)
}
// others
for other in result2[.other] {
    print(other.name)
}
```

## Installation and Setup

To use Linq for Swift, simply copy `Enumerable.swift` into your project folder.

It also can be use by installing with Carthage.  
Add to your Cartfile:

```
github "yoshimasa36g/LinqForSwift"
```

## Enumerable <a name="enumerable" />

* [generationg methods](#generators)
* [projection and filtering methods](#projectors-and-filters)
* [join methods](#join)
* [set methods](#set)
* [ordering methods](#order)
* [grouping methods](#group)
* [aggregate methods](#aggregate)
* [paging methods](#page)
* [convert methods](#convert)
* [action methods](#action)
* [for debug methods](#debug)

---

### generationg methods <a name="generators" />

#### choice

Generates an infinite sequence from random elements of source sequence.

##### declaration

```swift
final class func choice
    <TSequence: SequenceType where TSequence.Generator.Element == T>
    (source: TSequence) -> Enumerable
```

##### example

```swift
let result = Enumerable.choice(["a", "b", "c", "d", "e"]).take(10)
> e, d, e, c, a, d, a, e, d, c
```

#### cycle

Generates an infinite cycle sequence from source sequence

##### declaration

```swift
final class func cycle
    <TSequence: SequenceType where TSequence.Generator.Element == T>
    (source: TSequence) -> Enumerable
```

##### example

```swift
let result = Enumerable.cycle(["a", "b", "c", "d", "e"]).take(10)
> a, b, c, d, e, a, b, c, d, e
```

#### empty

Generates an empty Enumerable.

##### declaration

```swift
final class func empty() -> Enumerable
```

##### example

```swift
let emptyNumbers = Enumerable<Int>.empty() // Type name is required
```

#### from

Generates an Enumerable from sequence.

##### declaration

```swift
final class func from
    <TSequence: SequenceType where TSequence.Generator.Element == T>
    (source: TSequence) -> Enumerable
```

##### example

```swift
let result = Enumerable.from(1...5)
> 1, 2, 3, 4, 5
```

#### infinity

Generates an infinite sequence from specified start number and step value.

##### declaration

```swift
final class func infinity<N: NumericType>
    (start: N, step: N = 1) -> Enumerable<N>
```
##### example

```swift
let result = Enumerable<Int>.infinity(0).take(10) // Type name is required
> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
```

#### negativeInfinity

Generates a negative infinite sequence from specified start number and step value.

##### declaration

```swift
final class func negativeInfinity<N: NumericType>
    (start: N, step: N = 1) -> Enumerable<N>
```

##### example

```swift
let result = Enumerable<Int>.negativeInfinity(0).take(10) // Type name is required
> 0, -1, -2, -3, -4, -5, -6, -7, -8, -9
```

#### range

Generates a sequence of NumericType within a specified range.

##### declaration

```swift
final class func range<N: NumericType>
    (start: N, count: Int) -> Enumerable<N>

final class func range<N: NumericType>
    (start: N, step: N, count: Int) -> Enumerable<N>
```

##### example

```swift
let result = Enumerable<Int>.range(0, count: 5) // Type name is required
> 0, 1, 2, 3, 4

let result = Enumerable<Int>.range(0, step: 3, count: 5)
> 0, 3, 6, 9, 12
```

#### rangeDown

Generates a negative sequence of NumericType within a specified range.

##### declaration

```swift
final class func rangeDown<N: NumericType>
    (start: N, count: Int) -> Enumerable<N>

final class func rangeDown<N: NumericType>
    (start: N, step: N, count: Int) -> Enumerable<N>
```

##### example

```swift
let result = Enumerable<Int>.rangeDown(0, count: 5) // Type name is required
> 0, -1, -2, -3, -4

let result = Enumerable<Int>.rangeDown(0, step: 3, count: 5)
> 0, -3, -6, -9, -12
```

#### repeat$

Generates a sequence that contains one repeated value

##### declaration

```swift
final class func repeat$(value: T) -> Enumerable

final class func repeat$(value: T, count: Int) -> Enumerable
```

##### example

```swift
let result = Enumerable.repeat$("a").take(5)
> a, a, a, a, a

let result = Enumerable.repeat$("a", count: 3)
> a, a, a
```

#### return$

Generates a sequence that contains one value

##### declaration

```swift
final class func return$(value: T) -> Enumerable
```

##### example

```swift
let result = Enumerable.return$("hoge")
> hoge
```

---

### projection and filtering methods <a name="projectors-and-filters" />

#### ofType

Filters the elements of an Enumerable based on a specified type.

##### declaration

```swift
final func ofType<TResult>(resultType: TResult.Type) -> Enumerable<TResult>
```

##### example

```swift
let result = Enumerable.from([1, "a", 2, "b", 3, "c"]).ofType(String.self)
> a, b, c
```

#### scan

Applies an accumulator function over a sequence.

##### declaration

```swift
final func scan(accumulator: (T, T) -> T) -> Enumerable

final func scan<TAccumulate>(
    seed: TAccumulate,
    accumulator: (TAccumulate, T) -> TAccumulate
    ) -> Enumerable<TAccumulate>

final func scan<TAccumulate, TResult>(
    seed: TAccumulate,
    accumulator: (TAccumulate, T) -> TAccumulate,
    resultSelector: TAccumulate -> TResult
    ) -> Enumerable<TResult>
```

##### example

```swift
let result = Enumerable.from(1...10).scan { $0 + $1 }
> 1, 3, 6, 10, 15, 21, 28, 36, 45, 55

let result = Enumerable.from(1...10).scan(100) { $0 + $1 }
> 100, 101, 103, 106, 110, 115, 121, 128, 136, 145, 155

let result = Enumerable.from(1...10)
    .scan(100, accumulator: { $0 + $1 }) { $0 * 10 }
> 1000, 1010, 1030, 1060, 1100, 1150, 1210, 1280, 1360, 1450, 1550
```

#### select

Projects each element of a sequence into a new form.

##### declaration

```swift
final func select<TResult>
    (selector: T -> TResult) -> Enumerable<TResult>

final func select<TResult>
    (selector: (T, Int) -> TResult) -> Enumerable<TResult>
```

##### example

```swift
let result = Enumerable.from(["oo", "ac", "lac", "ul"])
    .select { "B\($0)k" }
> Book, Back, Black, Bulk

let result = Enumerable.from(["a", "b", "c", "d", "e"])
    .select { "\($1):\($0)" }
> 0:a, 1:b, 2:c, 3:d, 4:e
```

#### selectMany

Projects each element of a sequence to an Enumerable<T>,
and flattens the resulting sequences into one sequence.

##### declaration

```swift
final func selectMany<TCollection: SequenceType>
    (collectionSelector: T -> TCollection)
    -> Enumerable<TCollection.Generator.Element>

final func selectMany<TCollection: SequenceType>
    (collectionSelector: (T, Int) -> TCollection)
    -> Enumerable<TCollection.Generator.Element>

final func selectMany<TCollection: SequenceType, TResult>(
    collectionSelector: T -> TCollection,
    resultSelector: (T, TCollection.Generator.Element) -> TResult
    ) -> Enumerable<TResult>

final func selectMany<TCollection: SequenceType, TResult>(
    collectionSelector: (T, Int) -> TCollection,
    resultSelector: (T, TCollection.Generator.Element) -> TResult
    ) -> Enumerable<TResult>
```

##### example

```swift
let result = Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
    .selectMany { $0.1 }
> a, b, c, d, e

let result = Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
    .selectMany { (x, i) -> [String] in x.1.map { "\(i):\($0)" } }
> 0:a, 0:b, 1:c, 1:d, 1:e

let result = Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
    .selectMany({ $0.1 }) { "\($0.0):\($1)" }
> 10:a, 10:b, 20:c, 20:d, 20:e

let result = Enumerable.from([(10, ["a", "b"]),(20, ["c", "d", "e"])])
    .selectMany({ (x, i) -> [(Int, String)] in x.1.map { (i, $0) } }) {
        "\($1.0):\($0.0):\($1.1)"
    }
> 0:10:a, 0:10:b, 1:20:c, 1:20:d, 1:20:e
```

#### where$

Filters a sequence of values based on a predicate

##### declaration

```swift
func where$(predicate: T -> Bool) -> Enumerable

func where$(predicate: (T, Int) -> Bool) -> Enumerable
```

##### example

```swift
let result = Enumerable.from(1...10).where$ { $0 % 2 == 0 }
> 2, 4, 6, 8, 10

let result = Enumerable.from(1...10).where$ { $0 % 2 == 0 || $1 < 5 }
> 1, 2, 3, 4, 5, 6, 8, 10
```

#### zip

Applies a specified function to the corresponding elements of two sequences, producing a sequence of the results.

##### declaration

```swift
final func zip<TSequence: SequenceType, TResult>(
    second: TSequence,
    resultSelector: (T, TSequence.Generator.Element) -> TResult
    ) -> Enumerable<TResult>
```

##### example

```swift
let result = Enumerable.from(1...10).zip(1...5) { $0 * $1 }
> 1, 4, 9, 16, 25
```

---

### join methods <a name="join" />

#### groupJoin

Correlates the elements of two sequences based on equality of keys and groups the results.

##### declaration

```swift
final func groupJoin<TInner: SequenceType, TKey: Hashable, TResult>(
    inner: TInner,
    outerKeySelector: T -> TKey,
    innerKeySelector: TInner.Generator.Element -> TKey,
    resultSelector: (T, Enumerable<TInner.Generator.Element>) -> TResult
    ) -> Enumerable<TResult>
```

##### example

```swift
let array1 = [(1, "app"),(2, "ban")]
let array2 = [(1, "l"),(1, "e"),(2, "a"),(2, "n"),(2, "a")]
let result = Enumerable.from(array1)
    .groupJoin(array2, outerKeySelector: { $0.0 }, innerKeySelector: { $0.0 }) {
        $0.1 + $1.aggregate("") { (x, y) -> String in x + y.1 }
    }
> apple, banana
```

#### join

Correlates the elements of two sequences based on matching keys.

##### declaration

```swift
final func join<TInner: SequenceType, TKey: Hashable, TResult>(
    inner: TInner,
    outerKeySelector: T -> TKey,
    innerKeySelector: TInner.Generator.Element -> TKey,
    resultSelector: (T, TInner.Generator.Element) -> TResult
    ) -> Enumerable<TResult>
```

##### example
```swift
let array1 = [(1, "app"),(2, "ban"),(3, "ora")]
let array2 = [(1, "le"),(2, "ana"),(3, "nge")]
let result = Enumerable.from(array1)
    .join(array2, outerKeySelector: { $0.0 }, innerKeySelector: { $0.0 }) {
        $0.1 + $1.1
    }
> apple, banana, orange
```

---

### set methods <a name="set" />

#### all

Determines whether all elements of a sequence satisfy a condition.

##### declaration

```swift
final func all(predicate: T -> Bool) -> Bool
```

##### example

```swift
let result = Enumerable.from(1...10).all { $0 < 5 }
> false
let result = Enumerable.from(1...10).all { $0 < 15 }
> true
```

#### any

Determines whether a sequence contains any elements.

##### declaration

```swift
final func any() -> Bool

final func any(predicate: T -> Bool) -> Bool
```

##### example

```swift
let result = Enumerable.from([Int]()).any()
> false
let result = Enumerable.from([1, 2, 3]).any()
> true

let result = Enumerable.from(1...10).any { $0 == 5 }
> true
let result = Enumerable.from(1...10).any { $0 == 15 }
> false
```

#### concat

Concatenates two sequences.

##### declaration

```swift
final func concat
    <TSequence: SequenceType where TSequence.Generator.Element == T>
    (second: TSequence) -> Enumerable
```

##### example

```swift
let result = Enumerable.from(1...3).concat(4...5)
> 1, 2, 3, 4, 5
```

#### contains

Determines whether a sequence contains a specified element by using a specified comparer.

##### declaration

```swift
final func contains(value: T, comparer: (T, T) -> Bool) -> Bool
```

##### example

```swift
let result = Enumerable.from(1...3).contains(2) { $0 == $1 }
> true
let result = Enumerable.from(1...3).contains(4) { $0 == $1 }
> false
```

#### defaultIfEmpty

Returns the elements of the specified sequence or the specified value in a singleton collection if the sequence is empty.

##### declaration

```swift
final func defaultIfEmpty(defaultValue: T) -> Enumerable
```

##### example

```swift
let result = Enumerable.from([Int]()).defaultIfEmpty(5)
> 5
let result = Enumerable.from(1...3).defaultIfEmpty(5)
> 1, 2, 3
```

#### distinct

Returns distinct elements from a sequence.

##### declaration

```swift
final func distinct<TKey: Hashable>(keySelector: T -> TKey) -> Enumerable

final func distinct(comparer: (T, T) -> Bool) -> Enumerable
```

##### example

```swift
let result = Enumerable.from([1, 1, 3, 2, 2, 3]).distinct { $0 }
> 1, 3, 2

let result = Enumerable.from([1, 1, 2, 3, 4, 4]).distinct { $0 == $1 }
> 1, 2, 3, 4
```

#### except

Produces the set difference of two sequences

##### declaration

```swift
final func except
    <TKey: Hashable, TSequence: SequenceType where TSequence.Generator.Element == T>
    (second: TSequence, keySelector: T -> TKey) -> Enumerable

final func except
    <TSequence: SequenceType where TSequence.Generator.Element == T>
    (second: TSequence, comparer: (T, T) -> Bool) -> Enumerable
```

##### example

```swift
let array1 = [57, 405, 730, 57, 82]
let array2 = [33, 55, 730, 82, 58]
let result = Enumerable.from(array1).except(array2) { $0 }
> 57, 405

let array1 = Enumerable.from(["a", "b", "c", "d", "e"])
let array2 = Enumerable.from(["B", "C", "E"])
let result = Enumerable.from(array1).except(array2) { $0.uppercased() == $1 }
> a, d
```

#### intersect

Produces the set intersection of two sequences.

##### declaration

```swift
final func intersect
    <TKey: Hashable, TSecond: SequenceType where TSecond.Generator.Element == T>
    (second: TSecond, keySelector: T -> TKey) -> Enumerable<T>

final func intersect
    <TSecond: SequenceType where TSecond.Generator.Element == T>
    (second: TSecond, comparer: (T, T) -> Bool) -> Enumerable<T>
```

##### example

```swift
let array1 = [57, 405, 730, 57, 82]
let array2 = [33, 55, 730, 82, 58]
let result = Enumerable.from(array1).intersect(array2) { $0 }
> 730, 82

let array1 = Enumerable.from(["a", "b", "c", "d", "e"])
let array2 = Enumerable.from(["B", "C", "E"])
let result = Enumerable.from(array1).intersect(array2) { $0.uppercased() == $1 }
> b, c, e
```

#### sequenceEqual

Determines whether two sequences are equal by comparing their elements by using a specified comparer.

##### declaration

```swift
final func sequenceEqual
    <TSequence: SequenceType where TSequence.Generator.Element == T>
    (second: TSequence, comparer: (T, T) -> Bool) -> Bool
```

##### example

```swift
let array1 = [1, 2, 3, 4, 5]
let array2 = [1, 2, 3, 4, 5]
let result = Enumerable.from(array1).sequenceEqual(array2) { $0 == $1 }
> true

let array1 = [1, 2, 3, 4, 5]
let array2 = [1, 2, 3, 4, 5, 6]
let result = Enumerable.from(array1).sequenceEqual(array2) { $0 == $1 }
> false
```

#### union

Produces the set union of two sequences by using the comparer.

##### declaration

```swift
final func union
    <TSequence: SequenceType where TSequence.Generator.Element == T>
    (second: TSequence, comparer: (T, T) -> Bool) -> Enumerable<T>

final func union
    <TKey: Hashable, TSequence: SequenceType where TSequence.Generator.Element == T>
    (second: TSequence, keySelector: T -> TKey) -> Enumerable<T>
```

##### example

```swift
let result = Enumerable.from(1...8).union(3...10) { $0 == $1 }
> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

let result = Enumerable.from(1...8).union(3...10) { $0 }
> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
```

---

### ordering methods <a name="order" />

#### orderBy

Sorts the elements of a sequence in ascending order according to a key.

##### declaration

```swift
final func orderBy<TKey: Comparable>
    (keySelector: T -> TKey) -> OrderedEnumerable<T>
```

##### example

```swift
let result = Enumerable.from([1, 71, 5, 3, 12]).orderBy { $0 }
> 1, 3, 5, 12, 71
```

#### orderByDescending

Sorts the elements of a sequence in descending order according to a key.

##### declaration

```swift
final func orderByDescending<TKey: Comparable>
    (keySelector: T -> TKey) -> OrderedEnumerable<T>
```

##### example

```swift
let result = Enumerable.from([1, 71, 5, 3, 12]).orderByDescending { $0 }
> 71, 12, 5, 3, 1
```

#### reverse

Inverts the order of the elements in a sequence.

##### declaration

```swift
final func reverse() -> Enumerable<T>
```

##### example

```swift
let result = Enumerable.from([1, 71, 5, 3, 12]).reverse()
> 12, 3, 5, 71, 1
```

#### thenBy

Performs a subsequent ordering of the elements in a sequence in ascending order according to a key.

##### declaration

```swift
public final func thenBy<TKey: Comparable>
    (keySelector: T -> TKey) -> OrderedEnumerable<T>
```

##### example

```swift
let result = Enumerable.from([(3, 5), (1, 2), (2, 8), (3, 1)])
                       .orderBy { $0.0 }.thenBy { $0.1 }
> (1, 2), (2, 8), (3, 1), (3, 5)
```

#### thenByDescending

Performs a subsequent ordering of the elements in a sequence in descending order, according to a key.

##### declaration

```swift
public final func thenByDescending<TKey: Comparable>
    (keySelector: T -> TKey) -> OrderedEnumerable<T>
```

##### example

```swift
let result = Enumerable.from([(3, 5), (1, 2), (2, 8), (3, 1)])
                       .orderBy { $0.0 }.thenByDescending { $0.1 }
> (1, 2), (2, 8), (3, 5), (3, 1)
```

---

### grouping methods <a name="group" />

#### groupBy

Groups the elements of a sequence according to a specified key selector function

##### declaration

```swift
final func groupBy<TKey: Hashable>
    (keySelector: T -> TKey) -> Enumerable<Grouping<TKey, T>>

final func groupBy<TKey: Hashable, TElement>(
    keySelector: T -> TKey,
    elementSelector: T -> TElement
    ) -> Enumerable<Grouping<TKey, TElement>>

final func groupBy<TKey: Hashable, TResult>(
    keySelector: T -> TKey,
    resultSelector: (TKey, Enumerable<T>) -> TResult
    ) -> Enumerable<TResult>

final func groupBy<TKey: Hashable, TElement, TResult>(
    keySelector: T -> TKey,
    elementSelector: T -> TElement,
    resultSelector: (TKey, Enumerable<TElement>) -> TResult
    ) -> Enumerable<TResult>
```

##### example

```swift
let accumulator = { (x: String, y: Int) -> String in
    "\(x)/\(String(y))"
}
let selector = { (x: Grouping<Bool, Int>) -> String in
    "key:\(x.key)" + x.elements.aggregate("", accumulator: accumulator)
}

let result = Enumerable.from(1...5).groupBy { $0 % 2 == 0 }.select(selector)
> key:false/1/3/5, key:true/2/4

let result = Enumerable.from(1...5).groupBy({ $0 % 2 == 0 }) { $0 * 10 }.select(selector)
> key:false/10/30/50, key:true/20/40

let resultSelector = { (key: Bool, elements: Enumerable<Int>) -> String in
    "key:\(key)" + elements.aggregate("", accumulator: accumulator)
}

let result = Enumerable.from(1...5).groupBy({ $0 % 2 == 0 },
    resultSelector: resultSelector)
> key:false/1/3/5, key:true/2/4

let result = Enumerable.from(1...5).groupBy({ $0 % 2 == 0 },
    elementSelector: { x -> Int in x * 10 },
    resultSelector: resultSelector)
> key:false/10/30/50, key:true/20/40
```

---

### aggregate methods <a name="aggregate" />

#### aggregate

Applies an accumulator function over a sequence.

##### declaration

```swift
final func aggregate(accumulator:  (T, T) -> T) -> T?

final func aggregate<TAccumulate>(
    seed: TAccumulate,
    accumulator: (TAccumulate, T) -> TAccumulate
    ) -> TAccumulate

final func aggregate<TAccumulate, TResult>(
    seed: TAccumulate,
    accumulator: (TAccumulate, T) -> TAccumulate,
    resultSelector: (TAccumulate) -> TResult
    ) -> TResult
```

##### example

```swift
let result = Enumerable.from(1...10).aggregate { $0 + $1 }
> 55

let result = Enumerable.from(1...10).aggregate(100) { $0 + $1 }
> 155

let result = Enumerable.from(1...10)
    .aggregate(100, accumulator: { $0 + $1 }) { $0 * 10 }
> 1550
```

#### average

Computes the average of a sequence of NumericType values that are obtained by invoking a transform function on each element of the input sequence.

##### declaration

```swift
final func average<N: NumericType>(selector: T -> N) -> Double
```

##### example

```swift
let result = Enumerable.from(1...16).average { $0 }
> 8.5
```

#### count

Returns the number of elements in a sequence.

##### declaration

```swift
final func count() -> Int

final func count(predicate: T -> Bool) -> Int
```

##### example

```swift
let result = Enumerable.from(1...10).count()
> 10

let result = Enumerable.from(1...10).count { $0 % 2 == 0 }
> 5
```

#### max

Returns the maximum value in a sequence.

##### declaration

```swift
final func max<TValue: Comparable>(selector: T -> TValue) -> TValue?
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).max { $0 }
> Optional(44)
```

#### min

Returns the minimum value in a sequence

##### declaration

```swift
final func min<TValue: Comparable>(selector: T -> TValue) -> TValue?
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).min { $0 }
> Optional(5)
```

#### sum

Computes the sum of the sequence of NumericType values
that are obtained by invoking a transform function on each element of the input sequence

##### declaration

```swift
final func sum<N: NumericType>(selector: T -> N) -> N
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).sum { $0 }
> 115
```

---

### paging methods <a name="page" />

#### elementAt

Returns the element at a specified index in a sequence.

##### declaration

```swift
final func elementAt(index: Int) -> T?
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).elementAt(2)
> Optional(44)
```

#### elementAtOrDefault

Returns the element at a specified index in a sequence or a default value if the index is out of range.

##### declaration

```swift
final func elementAtOrDefault(index: Int, defaultValue: T) -> T
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5])
    .elementAtOrDefault(1, defaultValue: 0)
> 22

let result = Enumerable.from([33, 22, 44, 11, 5])
    .elementAtOrDefault(10, defaultValue: 0)
> 0
```

#### first

Returns the first element of a sequence

##### declaration

```swift
final func first() -> T?

final func first(predicate: T -> Bool) -> T?
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).first()
> Optional(33)

let result = Enumerable.from([33, 22, 44, 11, 5]).first { $0 < 20 }
> Optional(11)
```

#### firstOrDefault

Returns the first element of a sequence, or a default value if the sequence contains no elements

##### declaration

```swift
final func firstOrDefault(defaultValue: T) -> T

final func firstOrDefault(defaultValue: T, predicate: T -> Bool) -> T
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).firstOrDefault(0)
> 33

let result = Enumerable.from([33, 22, 44, 11, 5])
    .firstOrDefault(0) { $0 < 5 }
> 0
```

#### last

Returns the last element of a sequence

##### declaration

```swift
final func last() -> T?

final func last(predicate: T -> Bool) -> T?
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).last()
> Optional(5)

let result = Enumerable.from([33, 22, 44, 11, 5]).last { $0 > 20 }
> Optional(44)
```

#### lastOrDefault

Returns the last element of a sequence, or a default value if the sequence contains no elements

##### declaration

```swift
final func lastOrDefault(defaultValue: T) -> T

final func lastOrDefault(defaultValue: T, predicate: T -> Bool) -> T
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).lastOrDefault(0)
> 5

let result = Enumerable.from([33, 22, 44, 11, 5])
    .lastOrDefault(0) { $0 > 50 }
> 0
```

#### single

Returns the only element of a sequence, or returns nil if there is not exactly one element in the sequence

##### declaration

```swift
final func single() -> T?

final func single(predicate: T -> Bool) -> T?
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).single()
> nil

let result = Enumerable.from([33, 22, 44, 11, 5]).single { $0 % 3 == 0 }
> Optional(33)
```

#### singleOrDefault

Returns the only element of a sequence, or a default value if the sequence is empty. This method returns nil if there is more than one element in the sequence.

##### declaration

``` swift
final func singleOrDefault(defaultValue: T) -> T?

final func singleOrDefault(defaultValue: T, predicate: T -> Bool) -> T?
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).singleOrDefault(0)
> nil

let result = Enumerable.from([33, 22, 44, 11, 5])
    .singleOrDefault(0) { $0 % 6 == 0 }
> Optional(0)
```

#### skip

Bypasses a specified number of elements in a sequence and then returns the remaining elements

##### declaration

```swift
final func skip(count: Int) -> Enumerable
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).skip(3)
> 11, 5
```

#### skipWhile

Bypasses elements in a sequence as long as a specified condition is true and then returns the remaining elements.

##### declaration

```swift
final func skipWhile(predicate: T -> Bool) -> Enumerable

final func skipWhile(predicate: (T, Int) -> Bool) -> Enumerable
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).skipWhile { $0 < 40 }
> 44, 11, 5

let result = Enumerable.from([33, 22, 44, 11, 5]).skipWhile { $0 < 10 || $1 < 3 }
> 11, 5
```

#### take

Returns a specified number of contiguous elements from the start of a sequence.

##### declaration

```swift
final func take(count: Int) -> Enumerable
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).take(3)
> 33, 22, 44
```

#### takeWhile

Returns elements from a sequence as long as a specified condition is true.

##### declaration

```swift
final func takeWhile(predicate: T -> Bool) -> Enumerable

final func takeWhile(predicate: (T, Int) -> Bool) -> Enumerable
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5]).takeWhile { $0 > 20 }
> 33, 22, 44

let result = Enumerable.from([33, 22, 44, 11, 5]).takeWhile { $0 > 20 || $1 < 4 }
> 33, 22, 44, 11
```

---

### convert methods <a name="convert" />

#### toArray

Creates an array from a Enumerable<T>.

##### declaration

```swift
final func toArray() -> Array<T>
```

##### example

```swift
let result = Enumerable.from([33, 22, 44, 11, 5])
    .where$ { $0 > 20 }
    .toArray()
> [33, 22, 44]
```

#### toDictionary

Creates a Dictionary<TKey, T> from an Enumerable<T>. This method returns nil if duplicate key exists.

##### declaration

```swift
final func toDictionary<TKey: Hashable>(
    keySelector: T -> TKey
    ) -> Dictionary<TKey, T>?

final func toDictionary<TKey: Hashable, TValue>(
    keySelector: T ->
    TKey, elementSelector: T -> TValue
    ) -> Dictionary<TKey, TValue>?
```

##### example

```swift
let array = [("apple", 3), ("banana", 2), ("cherry", 5)]

let result = Enumerable.from(array).toDictionary { $0.0 }
> Optional(["banana": (banana, 2), "apple": (apple, 3), "cherry": (cherry, 5)])

let result = Enumerable.from(array).toDictionary({ $0.0 }) { $0.1 }
> Optional(["banana": 2, "apple": 3, "cherry": 5])
```

#### toLookup

Creates a Lookup<TKey, T> from an Enumerable<T>.

##### declaration

```swift
final func toLookup<TKey: Hashable>(
    keySelector: T -> TKey
    ) -> Lookup<TKey, T>

final func toLookup<TKey: Hashable, TElement>(
    keySelector: T -> TKey,
    elementSelector: T -> TElement
    ) -> Lookup<TKey, TElement>
```

##### example

```swift
let result = Enumerable.from(1...10).toLookup { $0 % 2 == 0}
result[true]> 2, 4, 6, 8, 10
result[false]> 1, 3, 5, 7, 9

let result = Enumerable.from(1...10).toLookup({ $0 % 2 == 0}) { $0 * 10 }
result[true]> 20, 40, 60, 80, 100
result[false]> 10, 30, 50, 70, 90
```

---

### action methods <a name="action" />

#### each

Performs the specified action on each element of the sequence.

##### declaration

```swift
final func each(action: T -> Void)

final func each(action: (T, Int) -> Void)
```

##### example

```swift
Enumerable.from(["a", "b", "c", "d", "e"]).each { Swift.print($0) }
> a, b, c, d, e

Enumerable.from(["a", "b", "c", "d", "e"])
    .each { Swift.print("\($1):\($0)") }
> 0:a, 1:b, 2:c, 3:d, 4:e
```

#### force

Executes the query that has been delayed

##### declaration

```swift
final func force() -> Void
```

##### example

```swift
Enumerable.from(["a", "b", "c", "d", "e"]).print().force()
> abcde
```

---

### for debug methods <a name="debug" />

#### dump

Dump each element of the sequence.

##### declaration

```swift
final func dump() -> Enumerable
```

##### example

```swift
Enumerable.from(["a", "b", "c", "d", "e"]).dump().force()
> - a
  - b
  - c
  - d
  - e
```

#### print

Prints each element of a sequence.

##### declaration

```swift
final func print() -> Enumerable

final func print(formatter: T -> String) -> Enumerable
```

##### example

```swift
Enumerable.from(["a", "b", "c", "d", "e"]).print().force()
> abcde

Enumerable.from(["a", "b", "c", "d", "e"]).print { $0 + $0 }.force()
> aabbccddee
```

#### println

Prints each element of a sequence and a newline character.

##### declaration

```swift
final func println() -> Enumerable

final func println(formatter: T -> String) -> Enumerable
```

##### example

```swift
Enumerable.from(1...5).println()
    .where$ { $0 % 2 == 0}.println()
    .select { $0 * 10 }.println()
    .force()
> 1
  2
  2
  20
  3
  4
  4
  40
  5

Enumerable.from(1...5).println { "from:\($0)" }
    .where$ { x -> Bool in x % 2 == 0}.println { "where:\($0)" }
    .select { x -> Int in x * 10 }.println { "select:\($0)" }
    .force()
> from:1
  from:2
  where:2
  select:20
  from:3
  from:4
  where:4
  select:40
  from:5
```

