//
//  Enumerable.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/07.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//
import Foundation

/**
Provides a set of methods for querying objects
*/
open class Enumerable<T>: Sequence {

    // sequence source
    fileprivate let source : AnySequence<T>

    // generator
    open func makeIterator() -> AnyIterator<T> { return source.makeIterator() }

    /**
    Initialize from generator.

    - parameter generator: - A generator of source sequence
    */
    fileprivate init<TGenerator: IteratorProtocol>(_ generator: @escaping () -> TGenerator) where TGenerator.Element == T {
        source = AnySequence(generator)
    }

    /**
    Initialize from sequence.

    - parameter source: - A source sequence
    */
    fileprivate init<TSequence: Sequence>(_ source: TSequence)
        where TSequence.Iterator.Element == T,
            TSequence.SubSequence : Sequence,
            TSequence.SubSequence.Iterator.Element == T,
            TSequence.SubSequence.SubSequence == TSequence.SubSequence {
        self.source = AnySequence(source)
    }

    /*---------------------*/
    /* generationg methods */
    /*---------------------*/

    /**
    Generates an infinite sequence from random elements of source sequence

    - parameter source: - A source sequence
    :return: An infinite sequence from random elements of source sequence
    */
    final class func choice<TSequence: Sequence>
        (_ source: TSequence) -> Enumerable where TSequence.Iterator.Element == T
    {
        return Enumerable { () -> AnyIterator<T> in
            var sourceArray = [T](source)
            return AnyIterator { () -> T? in
                return sourceArray[Int(arc4random_uniform(UInt32(sourceArray.count)))]
            }
        }
    }

    /**
    Generates an infinite cycle sequence from source sequence

    - parameter source: - A source sequence
    :return: An infinite cycle sequence from source sequence
    */
    final class func cycle<TSequence: Sequence>
        (_ source: TSequence) -> Enumerable where TSequence.Iterator.Element == T
    {
        return Enumerable { () -> AnyIterator<T> in
            var sourceArray = [T](source)
            var index = -1
            return AnyIterator { () -> T? in
                index += 1
                if sourceArray.count <= index {
                    index = 0
                }
                return sourceArray[index]
            }
        }
    }

    /**
    Generates an empty Enumerable.
    Type name is required

    - returns: An empty Enumerable<T>
    */
    final class func empty() -> Enumerable {
        return Enumerable { () -> AnyIterator<T> in
            return AnyIterator { () -> T? in
                return nil
            }
        }
    }

    /**
    Generates an Enumerable from sequence.

    - parameter source: - A source sequence
    - returns: An enumerable sequence
    */
    final class func from<TSequence: Sequence>
        (_ source: TSequence) -> Enumerable
        where TSequence.Iterator.Element == T,
            TSequence.SubSequence : Sequence,
            TSequence.SubSequence.Iterator.Element == T,
            TSequence.SubSequence.SubSequence == TSequence.SubSequence
    {
        return Enumerable(source)
    }

    /**
    Generates an infinite sequence from specified start number and step value.
    Type name is required

    - parameter start: - The number of start
    - parameter step: - The step value to increase
    - returns: A infinite sequence from specified start number and step value
    */
    final class func infinity<N: NumericType>(_ start: N, step: N = 1) -> Enumerable<N> {
        return Enumerable<N> { () -> AnyIterator<N> in
            var value = start - step
            return AnyIterator { () -> N? in
                value += step
                return value
            }
        }
    }

    /**
    Generates a negative infinite sequence from specified start number and step value.
    Type name is required

    - parameter start: - The number of start
    - parameter step: - The step value to decrease
    - returns: A infinite sequence from specified start number and step value
    */
    final class func negativeInfinity<N: NumericType>(_ start: N, step: N = 1) -> Enumerable<N> {
        return Enumerable<N> { () -> AnyIterator<N> in
            var value = start + step
            return AnyIterator { () -> N? in
                value -= step
                return value
            }
        }
    }

    /**
    Generates a sequence of NumericType within a specified range.
    Type name is required

    - parameter start: - The value of the first NumericType in the sequence
    - parameter count: - The number of sequential NumericType to generate
    - returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func range<N: NumericType>(_ start: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.infinity(start, step: 1).take(count)
    }

    /**
    Generates a sequence of NumericType within a specified range by step.
    Type name is required

    - parameter start: - The value of the first NumericType in the sequence
    - parameter step: - The step value to increase
    - parameter count: - The number of sequential NumericType to generate
    - returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func range<N: NumericType>(_ start: N, step: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.infinity(start, step: step).take(count)
    }

    /**
    Generates a negative sequence of NumericType within a specified range.
    Type name is required

    - parameter start: - The value of the first NumericType in the sequence
    - parameter count: - The number of sequential NumericType to generate
    - returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func rangeDown<N: NumericType>(_ start: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.negativeInfinity(start, step: 1).take(count)
    }

    /**
    Generates a negative sequence of NumericType within a specified range by step.
    Type name is required

    - parameter start: - The value of the first NumericType in the sequence
    - parameter step: - The step value to increase
    - parameter count: - The number of sequential NumericType to generate
    - returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func rangeDown<N: NumericType>(_ start: N, step: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.negativeInfinity(start, step: step).take(count)
    }

    /**
    Generates an infinite sequence that contains one repeated value

    - parameter value: - The value to be repeated
    - returns: An infinite sequence that contains one repeated value
    */
    final class func repeat$(_ value: T) -> Enumerable {
        return Enumerable { () -> AnyIterator<T> in
            return AnyIterator { () -> T? in
                return value
            }
        }
    }

    /**
    Generates a sequence that contains one repeated value

    - parameter value: - The value to be repeated
    - parameter count: - The number of times to repeat the value in the generated sequence
    - returns: A sequence that contains one repeated value
    */
    final class func repeat$(_ value: T, count: Int) -> Enumerable {
        return Enumerable.repeat$(value).take(count)
    }

    /**
    Generates a sequence that contains one value

    - parameter value: - The value of sequence
    */
    final class func return$(_ value: T) -> Enumerable {
        return Enumerable.repeat$(value).take(1)
    }

    /*----------------------------------*/
    /* projection and filtering methods */
    /*----------------------------------*/

    /**
    Filters the elements of an Enumerable based on a specified type

    - parameter resultType: - The type to filter the elements of the sequence on
    - returns: An Enumerable that contains elements from the input sequence of type TResult
    */
    final func ofType<TResult>(_ resultType: TResult.Type) -> Enumerable<TResult> {
        return Enumerable<TResult> { () -> AnyIterator<TResult> in
            let generator = self.makeIterator()
            return AnyIterator {
                while let element = generator.next() {
                    if let resultTypeValue = element as? TResult {
                        return resultTypeValue
                    }
                }
                return nil
            }
        }
    }

    /**
    Applies an accumulator function over a sequence.

    - parameter accumulator: - An accumulator function to be invoked on each element
    - returns: An Enumerable<T> that contains results of accumulator function
    */
    final func scan(_ accumulator: @escaping (T, T) -> T) -> Enumerable {
        return self.scan(seed: nil, accumulator: accumulator) { $0 }
    }

    /**
    Applies an accumulator function over a sequence.
    The specified seed value is used as the initial accumulator value.

    - parameter seed: - The initial accumulator value
    - parameter accumulator: - An accumulator function to be invoked on each element
    - returns: An Enumerable<TAccumulate> that contains results of accumulator function
    */
    final func scan<TAccumulate>(
        _ seed: TAccumulate,
        accumulator: @escaping (TAccumulate, T) -> TAccumulate
        ) -> Enumerable<TAccumulate>
    {
        return self.scan(seed: seed, accumulator: accumulator) { $0 }
    }

    /**
    Applies an accumulator function over a sequence.
    The specified seed value is used as the initial accumulator value,
    and the specified function is used to select the result value.

    - parameter seed: - The initial accumulator value
    - parameter accumulator: - An accumulator function to be invoked on each element
    - parameter resultSelector: - A function to transform the final accumulator value into the result value
    - returns: An Enumerable<T> that contains results of accumulator function
    */
    final func scan<TAccumulate, TResult>(
        _ seed: TAccumulate,
        accumulator: @escaping (TAccumulate, T) -> TAccumulate,
        resultSelector: @escaping (TAccumulate) -> TResult
        ) -> Enumerable<TResult>
    {
        return self.scan(seed: seed, accumulator: accumulator, resultSelector: resultSelector)
    }

    /**
    Projects each element of a sequence into a new form

    - parameter selector: - A transform function to apply to each element
    - returns: An Enumerable<T> whose elements are the result of invoking the transform function on each element of source
    */
    final func select<TResult>(_ selector: @escaping (T) -> TResult) -> Enumerable<TResult> {
        return self.select { (x, _) -> TResult in selector(x) }
    }

    /**
    Projects each element of a sequence into a new form by incorporating the element's index

    - parameter selector: - A transform function to apply to each source element; the second parameter of the function represents the index of the source element
    - returns: An Enumerable<T> whose elements are the result of invoking the transform function on each element of source
    */
    final func select<TResult>(_ selector: @escaping (T, Int) -> TResult) -> Enumerable<TResult> {
        return Enumerable<TResult> { () -> AnyIterator<TResult> in
            let generator = self.makeIterator()
            var index = -1
            return AnyIterator {
                while let element = generator.next() {
                    index += 1
                    return selector(element, index)
                }
                return nil
            }
        }
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    and flattens the resulting sequences into one sequence.

    - parameter collectionSelector: - A transform function to apply to each element
    - returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function on each element of the input sequence
    */
    final func selectMany<TCollection: Sequence, Element>
        (_ collectionSelector: @escaping (T) -> TCollection) -> Enumerable<TCollection.Iterator.Element>
        where TCollection.Iterator.Element == Element,
            TCollection.SubSequence : Sequence,
            TCollection.SubSequence.Iterator.Element == Element,
            TCollection.SubSequence.SubSequence == TCollection.SubSequence
    {
        return self.selectMany({ (x, _) -> TCollection in collectionSelector(x) }, resultSelector: { (_, x) in x } )
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    and flattens the resulting sequences into one sequence.
    The index of each source element is used in the projected form of that element.

    - parameter collectionSelector: - A transform function to apply to each source element; the second parameter of the function represents the index of the source element
    - returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function on each element of the input sequence
    */
    final func selectMany<TCollection: Sequence, Element>
        (_ collectionSelector: @escaping (T, Int) -> TCollection) -> Enumerable<TCollection.Iterator.Element>
        where TCollection.Iterator.Element == Element,
            TCollection.SubSequence : Sequence,
            TCollection.SubSequence.Iterator.Element == Element,
            TCollection.SubSequence.SubSequence == TCollection.SubSequence
    {
        return self.selectMany(collectionSelector, resultSelector: { (_, x) in x } )
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    flattens the resulting sequences into one sequence,
    and invokes a result selector function on each element therein

    - parameter collectionSelector: - A transform function to apply to each element
    - parameter resultSelector: - A transform function to apply to each element of the intermediate sequence
    - returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function collectionSelector on each element of source and then mapping each of those sequence elements and their corresponding source element to a result element
    */
    final func selectMany<TCollection: Sequence, Element, TResult>(
        _ collectionSelector: @escaping (T) -> TCollection,
        resultSelector: @escaping (T, TCollection.Iterator.Element) -> TResult
        ) -> Enumerable<TResult>
        where TCollection.Iterator.Element == Element,
            TCollection.SubSequence : Sequence,
            TCollection.SubSequence.Iterator.Element == Element,
            TCollection.SubSequence.SubSequence == TCollection.SubSequence
    {
        return self.selectMany({ (x, _) -> TCollection in collectionSelector(x) }, resultSelector: resultSelector)
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    flattens the resulting sequences into one sequence,
    and invokes a result selector function on each element therein.
    The index of each source element is used in the intermediate projected form of that element

    - parameter collectionSelector: - A transform function to apply to each source element; the second parameter of the function represents the index of the source element
    - parameter resultSelector: - A transform function to apply to each element of the intermediate sequence
    - returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function collectionSelector on each element of source and then mapping each of those sequence elements and their corresponding source element to a result element
    */
    final func selectMany<TCollection: Sequence, Element, TResult>(
        _ collectionSelector: @escaping (T, Int) -> TCollection,
        resultSelector: @escaping (T, TCollection.Iterator.Element) -> TResult
        ) -> Enumerable<TResult>
        where TCollection.Iterator.Element == Element,
            TCollection.SubSequence : Sequence,
            TCollection.SubSequence.Iterator.Element == Element,
            TCollection.SubSequence.SubSequence == TCollection.SubSequence
    {
        return Enumerable<TResult> { () -> AnyIterator<TResult> in
            typealias TElement = TCollection.Iterator.Element
            var index = -1
            let generator = self.makeIterator()
            var middleGenerator: AnySequence<TElement>.Iterator? = nil
            var element: T? = nil

            return AnyIterator {
                if middleGenerator == nil {
                    if let first = generator.next() {
                        element = first
                    } else {
                        return nil
                    }
                }
                repeat {
                    if (middleGenerator == nil)
                    {
                        index += 1
                        let middleSequence = collectionSelector(element!, index);
                        middleGenerator = Enumerable<TElement>.from(middleSequence).makeIterator();
                    }
                    if let middleElement = middleGenerator?.next()
                    {
                        return resultSelector(element!, middleElement);
                    }
                    middleGenerator = nil;
                    element = generator.next()
                } while element != nil
                return nil
            }
        }
    }

    /**
    Filters a sequence of values based on a predicate

    - parameter predicate: - A function to test each element for a condition
    - returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    func where$(_ predicate: @escaping (T) -> Bool) -> Enumerable {
        return self.where$ { (x, _) -> Bool in predicate(x) }
    }

    /**
    Filters a sequence of values based on a predicate
    Each element's index is used in the logic of the predicate function

    - parameter predicate: - A function to test each element for a condition; the second parameter of the function represents the index of the source element
    - returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    func where$(_ predicate: @escaping (T, Int) -> Bool) -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            var index = -1
            return AnyIterator {
                while let element = generator.next() {
                    index += 1
                    if predicate(element, index) {
                        return element
                    }
                }
                return nil
            }
        }
    }

    /**
    Applies a specified function to the corresponding elements of two sequences,
    producing a sequence of the results

    - parameter second: - The second sequence to merge
    - parameter resultSelector: - A function that specifies how to merge the elements from the two sequences
    - returns: An IEnumerable<TResult> that contains merged elements of two input sequences
    */
    final func zip<TSequence: Sequence, TResult>(
        _ second: TSequence,
        resultSelector: @escaping (T, TSequence.Iterator.Element) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> AnyIterator<TResult> in
            let firstGenerator = self.makeIterator()
            var secondGenerator = second.makeIterator()
            return AnyIterator {
                switch (firstGenerator.next(), secondGenerator.next()) {
                case (.some(let first), .some(let second)):
                    return resultSelector(first, second)
                default:
                    return nil
                }
            }
        }
    }

    /*--------------*/
    /* join methods */
    /*--------------*/

    /**
    Correlates the elements of two sequences based on equality of keys and groups the results

    - parameter inner: - The sequence to join to the first sequence
    - parameter outerKeySelector: - A function to extract the join key from each element of the first sequence
    - parameter innerKeySelector: - A function to extract the join key from each element of the second sequence
    - parameter resultSelector: - A function to create a result element from an element from the first sequence and a collection of matching elements from the second sequence
    - returns: An Enumerable<TResult> that are obtained by performing a grouped join on two sequences
    */
    final func groupJoin<TInner: Sequence, TKey: Hashable, TResult>(
        _ inner: TInner,
        outerKeySelector: @escaping (T) -> TKey,
        innerKeySelector: @escaping (TInner.Iterator.Element) -> TKey,
        resultSelector: @escaping (T, Enumerable<TInner.Iterator.Element>) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> AnyIterator<TResult> in
            let innerGroups = self.sequenceToGroupDictionary(inner, keySelector: innerKeySelector)
            let outerGenerator = self.makeIterator()

            return AnyIterator {
                if let element = outerGenerator.next() {
                    let key = outerKeySelector(element)
                    if let group = innerGroups[key] {
                        return resultSelector(element, Enumerable<TInner.Iterator.Element>.from(group))
                    } else {
                        return resultSelector(element, Enumerable<TInner.Iterator.Element>.empty())
                    }
                } else {
                    return nil
                }
            }

        }
    }

    /**
    Correlates the elements of two sequences based on matching keys

    - parameter inner: - The sequence to join to the first sequence
    - parameter outerKeySelector: - A function to extract the join key from each element of the first sequence
    - parameter innerKeySelector: - A function to extract the join key from each element of the second sequence
    - parameter resultSelector: - A function to create a result element from two matching elements
    - returns: An Enumerable<T> that are obtained by performing an inner join on two sequences
    */
    final func join<TInner: Sequence, TKey: Hashable, TResult>(
        _ inner: TInner,
        outerKeySelector: @escaping (T) -> TKey,
        innerKeySelector: @escaping (TInner.Iterator.Element) -> TKey,
        resultSelector: @escaping (T, TInner.Iterator.Element) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { [unowned self] () -> AnyIterator<TResult> in
            let innerGroups = self.sequenceToGroupDictionary(inner, keySelector: innerKeySelector)
            let outerGenerator = self.makeIterator()
            var outerElement: T? = nil
            var innerGenerator = Array<TInner.Iterator.Element>().makeIterator()

            return AnyIterator {
                while let element = innerGenerator.next() {
                    return resultSelector(outerElement!, element)
                }
                while let element = outerGenerator.next() {
                    let key = outerKeySelector(element)
                    if let group = innerGroups[key] {
                        innerGenerator = group.makeIterator()
                        outerElement = element
                        return resultSelector(element, innerGenerator.next()!)
                    }
                }
                return nil
            }
        }
    }

    /*-------------*/
    /* set methods */
    /*-------------*/

    /**
    Determines whether all elements of a sequence satisfy a condition.

    - parameter predicate: - A function to test each element for a condition
    - returns: true if every element of the source sequence passes the test in the specified predicate, or if the sequence is empty; otherwise, false
    */
    final func all(_ predicate: (T) -> Bool) -> Bool {
        for element in self {
            if !predicate(element) {
                return false
            }
        }
        return true
    }

    /**
    Determines whether a sequence contains any elements.

    - returns: true if the source sequence contains any elements; otherwise, false
    */
    final func any() -> Bool {
        for _ in self {
            return true
        }
        return false
    }

    /**
    Determines whether any element of a sequence satisfies a condition.

    - parameter predicate: - A function to test each element for a condition
    - returns: true if any elements in the source sequence pass the test in the specified predicate; otherwise, false
    */
    final func any(_ predicate: (T) -> Bool) -> Bool {
        for element in self {
            if predicate(element) {
                return true
            }
        }
        return false
    }

    /**
    Concatenates two sequences.

    - parameter second: - The sequence to concatenate to the first sequence
    - returns: An Enumerable<T> that contains the concatenated elements of the two input sequences
    */
    final func concat<TSequence: Sequence>
        (_ second: TSequence) -> Enumerable where TSequence.Iterator.Element == T
    {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let firstGenerator = self.makeIterator()
            var secondGenerator = second.makeIterator()
            return AnyIterator {
                if let f = firstGenerator.next() {
                    return f
                }
                return secondGenerator.next()
            }
        }
    }

    /**
    Determines whether a sequence contains a specified element by using a specified comparer.

    - parameter value: - The value to locate in the sequence
    - parameter comparer: - An equality comparer to compare values
    - returns: true if the source sequence contains an element that has the specified value; otherwise, false
    */
    final func contains(_ value: T, comparer: (T, T) -> Bool) -> Bool {
        let generator = self.makeIterator()
        while let element = generator.next() {
            if comparer(value, element) {
                return true
            }
        }
        return false
    }


    /**
    Returns the elements of the specified sequence
    or the specified value in a singleton collection if the sequence is empty.

    - parameter defaultValue: - The value to return if the sequence is empty
    - returns: An Enumerable<T> that contains defaultValue if source is empty; otherwise, source
    */
    final func defaultIfEmpty(_ defaultValue: T) -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            var isFirst = true
            return AnyIterator {
                while let element = generator.next() {
                    isFirst = false
                    return element
                }
                if isFirst {
                    isFirst = false
                    return defaultValue
                }
                return nil
            }
        }
    }

    /**
    Returns distinct elements from a sequence by using a specified key selector

    - parameter keySelector: - A function to generate the keys to compare
    - returns: An Enumerable<T> that contains distinct elements from the source sequence
    */
    final func distinct<TKey: Hashable>(_ keySelector: @escaping (T) -> TKey) -> Enumerable
    {
        return self.except(Enumerable<T>.empty(), keySelector: keySelector)
    }

    /**
    Returns distinct elements from a sequence by using a specified comparer

    - parameter comparer: - An equality comparer to compare values
    - returns: An Enumerable<T> that contains distinct elements from the source sequence
    */
    final func distinct(_ comparer: @escaping (T, T) -> Bool) -> Enumerable
    {
        return self.except(Enumerable<T>.empty(), comparer: comparer)
    }

    /**
    Produces the set difference of two sequences by using the key selector

    - parameter second: - A sequence whose elements that also occur in the first sequence will cause those elements to be removed from the returned sequence
    - parameter keySelector: - A function to generate the keys to compare
    - returns: A sequence that contains the set difference of the elements of two sequences
    */
    final func except<TKey: Hashable, TSequence: Sequence>
        (_ second: TSequence, keySelector: @escaping (T) -> TKey) -> Enumerable
        where TSequence.Iterator.Element == T,
            TSequence.SubSequence : Sequence,
            TSequence.SubSequence.Iterator.Element == T,
            TSequence.SubSequence.SubSequence == TSequence.SubSequence
    {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let firstGenerator = self.makeIterator()
            var returnedElements = [TKey:Bool]()
            Enumerable.from(second).each { returnedElements[keySelector($0)] = true }
            return AnyIterator {
                while let element = firstGenerator.next() {
                    let key = keySelector(element)
                    if let _ = returnedElements[key] {
                        continue
                    }
                    returnedElements[key] = true
                    return element
                }
                return nil
            }
        }
    }

    /**
    Produces the set difference of two sequences by using the specified comparer

    - parameter second: - A sequence whose elements that also occur in the first sequence will cause those elements to be removed from the returned sequence
    - parameter comparer: - An equality comparer to compare values
    - returns: A sequence that contains the set difference of the elements of two sequences
    */
    final func except<TSequence: Sequence>
        (_ second: TSequence, comparer: @escaping (T, T) -> Bool) -> Enumerable where TSequence.Iterator.Element == T
    {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let firstGenerator = self.makeIterator()
            var returnedElements = [T](second)
            return AnyIterator {
                let returned = Enumerable.from(returnedElements)
                while let element = firstGenerator.next() {
                    if !returned.contains(element, comparer: comparer) {
                        returnedElements.append(element)
                        return element
                    }
                }
                return nil
            }
        }
    }

    /**
    Produces the set intersection of two sequences by using the key selector

    - parameter second: - An sequence whose distinct elements that also appear in the first sequence will be returned
    - parameter keySelector: - A function to generate the keys to compare
    - returns: A sequence that contains the elements that form the set intersection of two sequences
    */
    final func intersect<TKey: Hashable, TSecond: Sequence>
        (_ second: TSecond, keySelector: @escaping (T) -> TKey) -> Enumerable<T>
        where TSecond.Iterator.Element == T,
            TSecond.SubSequence : Sequence,
            TSecond.SubSequence.Iterator.Element == T,
            TSecond.SubSequence.SubSequence == TSecond.SubSequence
    {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let first = self.makeIterator()
            var returnedElements = [TKey:Bool]()
            let secondDictionary = Enumerable.from(second).toDictionary(keySelector)
            return AnyIterator {
                while let element = first.next() {
                    let key = keySelector(element)
                    if let _ = returnedElements[key] {
                        continue
                    }
                    if let _ = secondDictionary![key] {
                        returnedElements[key] = true
                        return element
                    }
                }
                return nil
            }
        }
    }

    /**
    Produces the set intersection of two sequences by using the comparer to compare values

    - parameter second: - An sequence whose distinct elements that also appear in the first sequence will be returned
    - parameter comparer: - An equality comparer to compare values
    - returns: A sequence that contains the elements that form the set intersection of two sequences
    */
    final func intersect<TSecond: Sequence>
        (_ second: TSecond, comparer: @escaping (T, T) -> Bool) -> Enumerable<T>
        where TSecond.Iterator.Element == T,
            TSecond.SubSequence : Sequence,
            TSecond.SubSequence.Iterator.Element == T,
            TSecond.SubSequence.SubSequence == TSecond.SubSequence
    {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let firstGenerator = self.distinct(comparer).makeIterator()
            let secondEnumerable = Enumerable.from(second)
            var returnedElements = [T]()
            return AnyIterator {
                let returned = Enumerable.from(returnedElements)
                while let element = firstGenerator.next() {
                    if !returned.contains(element, comparer: comparer)
                        && secondEnumerable.contains(element, comparer: comparer) {
                            returnedElements.append(element)
                            return element
                    }
                }
                return nil
            }
        }
    }

    /**
    Determines whether two sequences are equal by comparing their elements
    by using a specified comparer

    - parameter second: - A sequence to compare to the first sequence
    - returns: true if the two source sequences are of equal length and their corresponding elements compare equal according to comparer; otherwise, false
    */
    final func sequenceEqual<TSequence: Sequence>
        (_ second: TSequence, comparer: (T, T) -> Bool) -> Bool where TSequence.Iterator.Element == T
    {
        let firstGenerator = self.makeIterator()
        var secondGenerator = second.makeIterator()
        while let first = firstGenerator.next() {
            if let second: T = secondGenerator.next() {
                if !comparer(first, second) {
                    return false
                }
            } else {
                return false
            }
        }
        if let _ = secondGenerator.next() {
            return false
        }
        return true
    }

    /**
    Produces the set union of two sequences by using the comparer

    - parameter second: - A sequence whose distinct elements form the second set for the union
    - parameter comparer: - The equality comparer to compare values
    - returns: An Enumerable<T> that contains the elements from both input sequences, excluding duplicates
    */
    final func union<TSequence: Sequence>
        (_ second: TSequence, comparer: @escaping (T, T) -> Bool) -> Enumerable<T> where TSequence.Iterator.Element == T
    {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let firstGenerator = self.makeIterator()
            var secondGenerator: TSequence.Iterator? = nil
            var returnedElements = [T]()

            return AnyIterator {
                let returned = Enumerable.from(returnedElements)
                if secondGenerator == nil {
                    while let firstElement = firstGenerator.next() {
                        if !returned.contains(firstElement, comparer: comparer) {
                            returnedElements.append(firstElement)
                            return firstElement
                        }
                    }
                    secondGenerator = second.makeIterator()
                }
                while let secondElement: T = secondGenerator?.next() {
                    if !returned.contains(secondElement, comparer: comparer) {
                        returnedElements.append(secondElement)
                        return secondElement
                    }
                }
                return nil
            }
        }
    }

    /**
    Produces the set union of two sequences by using the key selector

    - parameter second: - A sequence whose distinct elements form the second set for the union
    - parameter keySelector: - A function to generate the keys to compare
    - returns: An Enumerable<T> that contains the elements from both input sequences, excluding duplicates
    */
    final func union<TKey: Hashable, TSequence: Sequence>
        (_ second: TSequence, keySelector: @escaping (T) -> TKey) -> Enumerable<T> where TSequence.Iterator.Element == T
    {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let firstGenerator = self.makeIterator()
            var secondGenerator: TSequence.Iterator? = nil
            var returnedElements = [TKey:Bool]()

            return AnyIterator {
                if secondGenerator == nil {
                    while let firstElement = firstGenerator.next() {
                        let key = keySelector(firstElement)
                        if let _ = returnedElements[key] {
                            continue
                        }
                        returnedElements[key] = true
                        return firstElement
                    }
                    secondGenerator = second.makeIterator()
                }
                while let secondElement: T = secondGenerator?.next() {
                    let key = keySelector(secondElement)
                    if let _ = returnedElements[key] {
                        continue
                    }
                    returnedElements[key] = true
                    return secondElement
                }
                return nil
            }
        }
    }

    /*------------------*/
    /* ordering methods */
    /*------------------*/

    /**
    Sorts the elements of a sequence in ascending order according to a key

    - parameter keySelector: - A function to extract a key from an element
    - returns: An OrderedEnumerable<T> whose elements are sorted according to a key
    */
    final func orderBy<TKey: Comparable>(_ keySelector: @escaping (T) -> TKey) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: source, comparer: { keySelector($0) < keySelector($1) })
    }

    /**
    Sorts the elements of a sequence in descending order according to a key

    - parameter keySelector: - A function to extract a key from an element
    - returns: An OrderedEnumerable<T> whose elements are sorted in descending order according to a key
    */
    final func orderByDescending<TKey: Comparable>(_ keySelector: @escaping (T) -> TKey) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: source, comparer: { keySelector($0) > keySelector($1) })
    }

    /**
    Inverts the order of the elements in a sequence

    - returns: A sequence whose elements correspond to those of the input sequence in reverse order
    */
    final func reverse() -> Enumerable<T> {
        return Enumerable { () -> IndexingIterator<[T]> in
            Array(self.toArray().reversed()).makeIterator()
        }
    }

    /*------------------*/
    /* grouping methods */
    /*------------------*/

    /**
    Groups the elements of a sequence according to a specified key selector function

    - parameter keySelector: - A function to extract the key for each element
    - returns: A collection of Grouping<TKey, T> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable>(_ keySelector: @escaping (T) -> TKey) -> Enumerable<Grouping<TKey, T>> {
        return self.groupBy(keySelector) { $0 }
    }

    /**
    Groups the elements of a sequence according to a specified key selector function
    and projects the elements for each group by using a specified function

    - parameter keySelector: - A function to extract the key for each element
    - parameter elementSelector: - A function to map each source element to an element in the Grouping<TKey, TElement>
    - returns: A collection of Grouping<TKey, TElement> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable, TElement>
        (_ keySelector: @escaping (T) -> TKey, elementSelector: @escaping (T) -> TElement) -> Enumerable<Grouping<TKey, TElement>>
    {
        return Enumerable<Grouping<TKey, TElement>> { () -> AnyIterator<Grouping<TKey, TElement>> in
            let groups = self.sequenceToGroupDictionary(self, keySelector: keySelector)
            var keysGenerator = groups.keys.makeIterator()

            return AnyIterator {
                if let key = keysGenerator.next() {
                    let elements = Enumerable.from(groups[key]!).select(elementSelector)
                    return Grouping(key: key, elements: elements)
                } else {
                    return nil
                }
            }
        }
    }

    /**
    Groups the elements of a sequence according to a specified key selector function
    and creates a result value from each group and its key

    - parameter keySelector: - A function to extract the key for each element
    - parameter resultSelector: - A function to create a result value from each group
    - returns: A collection of Grouping<TKey, TResult> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable, TResult>
        (_ keySelector: @escaping (T) -> TKey, resultSelector: @escaping (TKey, Enumerable<T>) -> TResult) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { [unowned self] () -> AnyIterator<TResult> in
            let groups = self.sequenceToGroupDictionary(self, keySelector: keySelector)
            var keysGenerator = groups.keys.makeIterator()

            return AnyIterator {
                if let key = keysGenerator.next() {
                    return resultSelector(key, Enumerable.from(groups[key]!))
                } else {
                    return nil
                }
            }
        }
    }

    /**
    Groups the elements of a sequence according to a specified key selector function
    and creates a result value from each group and its key.
    The elements of each group are projected by using a specified function.

    - parameter keySelector: - A function to extract the key for each element
    - parameter elementSelector: - A function to map each source element to an element in the Grouping<TKey, TElement>
    - parameter resultSelector: - A function to create a result value from each group
    - returns: A collection of Grouping<TKey, TResult> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable, TElement, TResult>(
        _ keySelector: @escaping (T) -> TKey,
        elementSelector: @escaping (T) -> TElement,
        resultSelector: @escaping (TKey, Enumerable<TElement>) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { [unowned self] () -> AnyIterator<TResult> in
            let groups = self.sequenceToGroupDictionary(self, keySelector: keySelector)
            var keysGenerator = groups.keys.makeIterator()

            return AnyIterator {
                if let key = keysGenerator.next() {
                    return resultSelector(key, Enumerable.from(groups[key]!).select(elementSelector))
                } else {
                    return nil
                }
            }
        }
    }

    /*-------------------*/
    /* aggregate methods */
    /*-------------------*/

    /**
    Applies an accumulator function over a sequence.

    - parameter accumulator: - An accumulator function to be invoked on each element
    - returns: The final accumulator value or nil
    */
    final func aggregate(_ accumulator:  (T, T) -> T) -> T? {
        let generator = self.makeIterator()
        if var result = generator.next() {
            while let element = generator.next() {
                result = accumulator(result, element)
            }
            return result
        }
        return nil
    }

    /**
    Applies an accumulator function over a sequence.
    The specified seed value is used as the initial accumulator value.

    - parameter seed: - The initial accumulator value
    - parameter accumulator: - An accumulator function to be invoked on each element
    - returns: The final accumulator value
    */
    final func aggregate<TAccumulate>(
        _ seed: TAccumulate,
        accumulator: (TAccumulate, T) -> TAccumulate
        ) -> TAccumulate
    {
        var result = seed
        self.each { result = accumulator(result, $0) }
        return result
    }

    /**
    Applies an accumulator function over a sequence.
    The specified seed value is used as the initial accumulator value,
    and the specified function is used to select the result value.

    - parameter seed: - The initial accumulator value
    - parameter accumulator: - An accumulator function to be invoked on each element
    - parameter resultSelector: - A function to transform the final accumulator value into the result value
    - returns: The transformed final accumulator value
    */
    final func aggregate<TAccumulate, TResult>(
        _ seed: TAccumulate,
        accumulator: (TAccumulate, T) -> TAccumulate,
        resultSelector: (TAccumulate) -> TResult
        ) -> TResult
    {
        return resultSelector(aggregate(seed, accumulator: accumulator))
    }

    /**
    Computes the average of a sequence of NumericType values
    that are obtained by invoking a transform function
    on each element of the input sequence.

    - parameter selector: - A transform function to apply to each element
    - returns: The average of the sequence of values
    */
    final func average<N: NumericType>(_ selector: (T) -> N) -> Double {
        var count = 0
        let total = self.aggregate(0) { (x: N, y: T) -> N in
            count += 1
            return x + selector(y)
        }

        return total.toDouble() / Double(count)
    }

    /**
    Returns the number of elements in a sequence.

    - returns: The number of elements in the input sequence
    */
    final func count() -> Int {
        var count = 0
        self.each { (_: T) -> Void in count += 1 }
        return count
    }

    /**
    Returns a number that represents how many elements in the specified sequence satisfy a condition.

    - parameter predicate: - A function to test each element for a condition
    - returns: A number that represents how many elements in the sequence satisfy the condition in the predicate function
    */
    final func count(_ predicate: @escaping (T) -> Bool) -> Int {
        return self.where$(predicate).aggregate(0) { (x, _) -> Int in x + 1 }
    }

    /**
    Returns the maximum value in a sequence

    - parameter selector: - A transform function to apply to each element
    - returns: The maximum value in the sequence or nil if the sequence is empty
    */
    final func max<TValue: Comparable>(_ selector: (T) -> TValue) -> TValue? {
        let generator = self.makeIterator()
        var max: TValue? = nil
        if let first = generator.next() {
            max = selector(first)
        } else {
            return max
        }
        while let element = generator.next() {
            let value = selector(element)
            if max! < value {
                max = value
            }
        }
        return max
    }

    /**
    Returns the minimum value in a sequence

    - parameter selector: - A transform function to apply to each element
    - returns: The minimum value in the sequence or nil if the sequence is empty
    */
    final func min<TValue: Comparable>(_ selector: (T) -> TValue) -> TValue? {
        let generator = self.makeIterator()
        var min: TValue? = nil
        if let first = generator.next() {
            min = selector(first)
        } else {
            return min
        }
        while let element = generator.next() {
            let value = selector(element)
            if value < min! {
                min = value
            }
        }
        return min
    }

    /**
    Computes the sum of the sequence of NumericType values
    that are obtained by invoking a transform function on each element of the input sequence

    - parameter selector: - A transform function to apply to each element
    - returns: The sum of the projected values
    */
    final func sum<N: NumericType>(_ selector: @escaping (T) -> N) -> N {
        return self.select(selector).aggregate(0) { $0 + $1 }
    }

    /*----------------*/
    /* paging methods */
    /*----------------*/

    /**
    Returns the element at a specified index in a sequence.

    - parameter index: - The zero-based index of the element to retrieve
    - returns: The element at the specified position in the source sequence or nil if the index is out of range
    */
    final func elementAt(_ index: Int) -> T? {
        return self.elementAt(index, defaultValue: nil)
    }

    /**
    Returns the element at a specified index in a sequence or a default value if the index is out of range

    - parameter index: - The zero-based index of the element to retrieve
    - parameter defaultValue: - The value to return if the index is out of range
    - returns: defaultValue if the index is outside the bounds of the source sequence; otherwise, the element at the specified position in the source sequence
    */
    final func elementAtOrDefault(_ index: Int, defaultValue: T) -> T {
        return self.elementAt(index, defaultValue: defaultValue)!
    }

    /**
    Returns the first element of a sequence

    - returns: The first element in the specified sequence, or nil if sequence is empty
    */
    final func first() -> T? {
        let generator = self.makeIterator()
        return generator.next()
    }

    /**
    Returns the first element in a sequence that satisfies a specified condition

    - parameter predicate: - A function to test each element for a condition
    - returns: The first element in the sequence that passes the test in the specified predicate function, or nil If no elements pass the test in the predicate function
    */
    final func first(_ predicate: @escaping (T) -> Bool) -> T? {
        let generator = self.where$(predicate).makeIterator()
        return generator.next()
    }

    /**
    Returns the first element of a sequence, or a default value if the sequence contains no elements

    - parameter defaultValue: - The value to return if the source sequence is empty
    - returns: defaultValue if source is empty; otherwise, the first element in source
    */
    final func firstOrDefault(_ defaultValue: T) -> T {
        let generator = self.makeIterator()
        return self.firstOrDefault(generator, defaultValue: defaultValue)
    }

    /**
    Returns the first element of the sequence that satisfies a condition or a default value
    if no such element is found.

    - parameter defaultValue: - The value to return if source is empty or if no element passes the test specified by predicate
    - parameter predicate: - A function to test each element for a condition
    - returns: defaultValue if source is empty or if no element passes the test specified by predicate; otherwise, the first element in source that passes the test specified by predicate
    */
    final func firstOrDefault(_ defaultValue: T, predicate: @escaping (T) -> Bool) -> T {
        let generator = self.where$(predicate).makeIterator()
        return self.firstOrDefault(generator, defaultValue: defaultValue)
    }

    /**
    Returns the last element of a sequence

    - returns: The value at the last position in the source sequence or nil if sequence is empty
    */
    final func last() -> T? {
        let generator = self.makeIterator()
        var lastElement: T? = nil
        while let element = generator.next() {
            lastElement = element
        }
        return lastElement
    }

    /**
    Returns the last element of a sequence that satisfies a specified condition

    - parameter predicate: - A function to test each element for a condition
    - returns: The last element in the sequence that passes the test in the specified predicate function, or nil If no elements pass the test in the predicate function
    */
    final func last(_ predicate: (T) -> Bool) -> T? {
        let generator = self.makeIterator()
        var lastElement: T? = nil
        while let element = generator.next() {
            if predicate(element) {
                lastElement = element
            }
        }
        return lastElement
    }

    /**
    Returns the last element of a sequence, or a default value if the sequence contains no elements

    - parameter defaultValue: - The value to return if the source sequence is empty
    - returns: defaultValue if the source sequence is empty; otherwise, the last element in the sequence
    */
    final func lastOrDefault(_ defaultValue: T) -> T {
        if let lastElement = last() {
            return lastElement
        }
        return defaultValue
    }

    /**
    Returns the last element of a sequence that satisfies a condition
    or a default value if no such element is found

    - parameter defaultValue: - The value to return if the sequence is empty or if no elements pass the test in the predicate function
    - parameter predicate: - A function to test each element for a condition
    - returns: defaultValue if the sequence is empty or if no elements pass the test in the predicate function; otherwise, the last element that passes the test in the predicate function
    */
    final func lastOrDefault(_ defaultValue: T, predicate: (T) -> Bool) -> T {
        if let lastElement = last(predicate) {
            return lastElement
        }
        return defaultValue
    }

    /**
    Returns the only element of a sequence,
    or returns nil if there is not exactly one element in the sequence

    - returns: nil if the sequence is empty or not single element; otherwise, The single element of the input sequence
    */
    final func single() -> T? {
        let generator = self.makeIterator()
        return self.single(generator, defaultValue: nil)
    }

    /**
    Returns the only element of a sequence that satisfies a specified condition,
    or returns nil if more than one such element exists

    - parameter predicate: - A function to test an element for a condition
    - returns: The single element of the input sequence that satisfies a condition, or nil if more than one such element exists
    */
    final func single(_ predicate: @escaping (T) -> Bool) -> T? {
        let generator = self.where$(predicate).makeIterator()
        return self.single(generator, defaultValue: nil)
    }

    /**
    Returns the only element of a sequence, or a default value if the sequence is empty.
    This method returns nil if there is more than one element in the sequence

    - parameter defaultValue: - The value to return if the sequence is empty
    - returns: The single element of the input sequence, or defaultValue if the sequence contains no elements, or nil if there is more than one element in the sequence
    */
    final func singleOrDefault(_ defaultValue: T) -> T? {
        let generator = self.makeIterator()
        return self.single(generator, defaultValue: defaultValue)
    }

    /**
    Returns the only element of a sequence that satisfies a specified condition
    or a default value if no such element exists.
    This method returns nil if more than one element satisfies the condition

    - parameter defaultValue: - The value to return if the sequence is empty
    - parameter predicate: - A function to test an element for a condition
    - returns: The single element of the input sequence that satisfies the condition, or defaultValue if no such element is found, or nil if more than one element satisfies the condition
    */
    final func singleOrDefault(_ defaultValue: T, predicate: @escaping (T) -> Bool) -> T? {
        let generator = self.where$(predicate).makeIterator()
        return self.single(generator, defaultValue: defaultValue)
    }

    /**
    Bypasses a specified number of elements in a sequence and then returns the remaining elements

    - parameter count: - The number of elements to skip before returning the remaining elements
    - returns: An Enumerable<T> that contains the elements that occur after the specified index in the input sequence
    */
    final func skip(_ count: Int) -> Enumerable {
        return Enumerable { () -> AnyIterator<T> in
            let generator = self.makeIterator()
            for _ in 0..<count { let _ = generator.next() }
            return generator
        }
    }

    /**
    Bypasses elements in a sequence as long as a specified condition is true
    and then returns the remaining elements

    - parameter predicate: - A function to test each element for a condition
    - returns: An Enumerable<T> that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate
    */
    final func skipWhile(_ predicate: @escaping (T) -> Bool) -> Enumerable {
        return self.skipWhile { (x, _) -> Bool in predicate(x) }
    }

    /**
    Bypasses elements in a sequence as long as a specified condition is true
    and then returns the remaining elements.
    The element's index is used in the logic of the predicate function

    - parameter predicate: - A function to test each source element for a condition; the second parameter of the function represents the index of the source element
    - returns: An IEnumerable<T> that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate
    */
    final func skipWhile(_ predicate: @escaping (T, Int) -> Bool) -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            var index = -1
            var isSkipEnd = false
            return AnyIterator {
                while !isSkipEnd {
                    if let element = generator.next() {
                        index += 1
                        if !predicate(element, index) {
                            isSkipEnd = true
                            return element
                        }
                        continue
                    }
                    return nil
                }
                return generator.next()
            }
        }
    }

    /**
    Returns a specified number of contiguous elements from the start of a sequence

    - parameter count: - The number of elements to return
    - returns: An Enumerable<T> that contains the specified number of elements from the start of the input sequence
    */
    final func take(_ count: Int) -> Enumerable {
        return Enumerable { () -> AnyIterator<T> in
            let generator = self.makeIterator()
            var index = 0
            return AnyIterator {
                if count <= index {
                    return nil
                }
                index += 1
                return generator.next()
            }
        }
    }

    /**
    Returns elements from a sequence as long as a specified condition is true

    - parameter predicate: - A function to test each element for a condition
    - returns: An Enumerable<T> that contains the elements from the input sequence that occur before the element at which the test no longer passes
    */
    final func takeWhile(_ predicate: @escaping (T) -> Bool) -> Enumerable {
        return self.takeWhile { (x, _) -> Bool in predicate(x) }
    }

    /**
    Returns elements from a sequence as long as a specified condition is true.
    The element's index is used in the logic of the predicate function

    - parameter predicate: - A function to test each source element for a condition; the second parameter of the function represents the index of the source element
    - returns: An Enumerable<T> that contains elements from the input sequence that occur before the element at which the test no longer passes
    */
    final func takeWhile(_ predicate: @escaping (T, Int) -> Bool) -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            var index = -1
            return AnyIterator {
                while let element = generator.next() {
                    index += 1
                    if !predicate(element, index) {
                        return nil
                    }
                    return element
                }
                return nil
            }
        }
    }

    /*-----------------*/
    /* convert methods */
    /*-----------------*/

    /**
    Creates an array from a Enumerable<T>

    - returns: An array that contains the elements from the input sequence
    */
    final func toArray() -> Array<T> {
        return [T](self)
    }

    /**
    Creates a Dictionary<TKey, T> from an Enumerable<T> according to a specified key selector function.
    This method returns nil if duplicate key exists

    - parameter keySelector: - A function to extract a key from each element
    - returns: A Dictionary<TKey, T> that contains keys and values, or nil if duplicate key exists
    */
    final func toDictionary<TKey: Hashable>(_ keySelector: (T) -> TKey) -> Dictionary<TKey, T>? {
        return self.toDictionary(keySelector) { $0 }
    }

    /**
    Creates a Dictionary<TKey, TValue> from an Enumerable<T> according to specified key selector
    and element selector functions.
    This method returns nil if duplicate key exists

    - parameter keySelector: - A function to extract a key from each element
    - parameter elementSelector: - A transform function to produce a result element value from each element
    - returns: A Dictionary<TKey, TValue> that contains values of type TValue selected from the input sequence, or nil if duplicate key exists
    */
    final func toDictionary<TKey: Hashable, TValue>
        (_ keySelector: (T) -> TKey, elementSelector: (T) -> TValue) -> Dictionary<TKey, TValue>?
    {
        var dict = [TKey: TValue]()
        for element in self {
            let key = keySelector(element)
            if dict[key] == nil {
                dict[key] = elementSelector(element)
                continue
            }
            return nil
        }
        return dict
    }

    /**
    Creates a Lookup<TKey, T> from an Enumerable<T> according to a specified key selector function

    - parameter keySelector: - A function to extract a key from each element
    - returns: A Lookup<TKey, T> that contains keys and values
    */
    final func toLookup<TKey: Hashable>(_ keySelector: (T) -> TKey) -> Lookup<TKey, T> {
        return Lookup(source: sequenceToGroupDictionary(self, keySelector: keySelector))
    }

    /**
    Creates a Lookup<TKey, TElement> from an Enumerable<T> according to specified key selector
    and element selector functions

    - parameter keySelector: - A function to extract a key from each element
    - parameter elementSelector: - A transform function to produce a result element value from each element
    - returns: A Lookup<TKey, TElement> that contains values of type TElement selected from the input sequence
    */
    final func toLookup<TKey: Hashable, TElement>
        (_ keySelector: (T) -> TKey, elementSelector: (T) -> TElement) -> Lookup<TKey, TElement>
    {
        return Lookup(source: sequenceToGroupDictionary(self, keySelector: keySelector, valueSelector: elementSelector))
    }

    /*----------------*/
    /* action methods */
    /*----------------*/

    /**
    Performs the specified action on each element of the sequence

    - parameter action: - A function to perform on each element of the source sequence
    */
    final func each(_ action: (T) -> Void) {
        self.each { (x, _) in action(x) }
    }

    /**
    Performs the specified action on each element of the sequence
    Each element's index is used in the logic of the action

    - parameter action: - A function to perform on each element of the source sequence; the second parameter of the function represents the index of the source element
    */
    final func each(_ action: (T, Int) -> Void) {
        var index = -1
        for element in self {
            index += 1
            action(element, index)
        }
    }

    /**
    Executes the query that has been delayed
    */
    final func force() -> Void {
        let generator = self.makeIterator()
        while let _ = generator.next() {
            // nothing
        }
    }

    /*-------------------*/
    /* for debug methods */
    /*-------------------*/

    /**
    Dump each element of the sequence

    - returns: The sequence
    */
    final func dump() -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            return AnyIterator {
                if let element = generator.next() {
                    let _ = Swift.dump(element)
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence

    - returns: The sequence
    */
    final func print() -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            return AnyIterator {
                if let element = generator.next() {
                    Swift.print(element, terminator: "")
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence with separator

    - parameter formatter: - A function to format to string
    - returns: The sequence
    */
    final func print(_ formatter: @escaping (T) -> String) -> Enumerable {
        return Enumerable { () -> AnyIterator<T> in
            let generator = self.makeIterator()
            return AnyIterator {
                if let element = generator.next() {
                    Swift.print(formatter(element), terminator: "")
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence and a newline character

    - returns: The sequence
    */
    final func println() -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            return AnyIterator {
                if let element = generator.next() {
                    Swift.print(element)
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence and a newline character

    - parameter formatter: - A function to format to string
    - returns: The sequence
    */
    final func println(_ formatter: @escaping (T) -> String) -> Enumerable {
        return Enumerable { [unowned self] () -> AnyIterator<T> in
            let generator = self.makeIterator()
            return AnyIterator {
                if let element = generator.next() {
                    Swift.print(formatter(element))
                    return element
                }
                return nil
            }
        }
    }

    /*-----------------*/
    /* private methods */
    /*-----------------*/

    /**
    Common component for elementAt and elementAdOrDefault

    - parameter index: - The zero-based index of the element to retrieve
    - parameter defaultValue: - The value to return if the index is out of range
    - returns: defaultValue if the index is outside the bounds of the source sequence; otherwise, the element at the specified position in the source sequence
    */
    fileprivate final func elementAt(_ index: Int, defaultValue: T?) -> T? {
        var i = 0
        var value = defaultValue
        for x in self {
            if (i == index) {
                value = x
                break
            }
            i += 1
        }
        return value
    }

    /**
    Common component for firstOrDefault

    - parameter generator: - The generator of target sequence
    - parameter defaultValue: - The value to return if source is empty
    - returns: defaultValue if source is empty; otherwise, the first element in source sequence
    */
    fileprivate final func firstOrDefault(_ generator: AnyIterator<T>, defaultValue: T) -> T {
        while let element = generator.next() {
            return element
        }
        return defaultValue
    }

    /**
    Common component for scan

    - parameter seed: - The initial accumulator value
    - parameter accumulator: - An accumulator function to be invoked on each element
    - parameter resultSelector: - A function to transform the final accumulator value into the result value
    - returns: An Enumerable<T> that contains results of accumulator function
    */
    fileprivate final func scan<TAccumulate, TResult>(
        seed: TAccumulate?,
        accumulator: @escaping (TAccumulate, T) -> TAccumulate,
        resultSelector: @escaping (TAccumulate) -> TResult
        ) -> Enumerable<TResult> {
            return Enumerable<TResult> { [unowned self] () -> AnyIterator<TResult> in
                let generator = self.makeIterator()
                var working: TAccumulate? = nil
                return AnyIterator {
                    if working == nil {
                        if seed == nil {
                            working = generator.next() as? TAccumulate
                        } else {
                            working = seed
                        }
                        return resultSelector(working!)
                    }
                    while let element = generator.next() {
                        working = accumulator(working!, element)
                        return resultSelector(working!)
                    }
                    return nil
                }
            }
    }

    /**
    Common component for single and singleOrDefault

    - parameter defaultValue: - The value to return if the sequence is empty
    - returns: The single element of the input sequence, or defaultValue if the sequence contains no elements, or nil if there is more than one element in the sequence
    */
    fileprivate final func single(_ generator: AnyIterator<T>, defaultValue: T?) -> T? {
        var found = false
        var value = defaultValue
        while let element = generator.next() {
            if !found {
                found = true
                value = element
            } else {
                return nil
            }
        }
        return value
    }

    /**
    convert source to group dictionary

    - parameter sequence: - The target sequence
    - parameter keySelector: - A function to extract a key from each element
    - returns: A Dictionary that contains values of Array<TSequence.Generator.Element>
    */
    fileprivate final func sequenceToGroupDictionary<TSequence: Sequence, TKey: Hashable>(
        _ sequence: TSequence,
        keySelector: (TSequence.Iterator.Element) -> TKey
        ) -> Dictionary<TKey, Array<TSequence.Iterator.Element>>
    {
        return sequenceToGroupDictionary(sequence, keySelector: keySelector) { $0 }
    }

    /**
    convert source to group dictionary

    - parameter sequence: - The target sequence
    - parameter keySelector: - A function to extract a key from each element
    - parameter valueSelector: - A transform function to produce a result element value from each element
    - returns: A Dictionary that contains values of Array<TValue>
    */
    fileprivate final func sequenceToGroupDictionary<TSequence: Sequence, TKey: Hashable, TValue>(
        _ sequence: TSequence,
        keySelector: (TSequence.Iterator.Element) -> TKey,
        valueSelector: (TSequence.Iterator.Element) -> TValue
        ) -> Dictionary<TKey, Array<TValue>>
    {
        var dict = [TKey: [TValue]]()
        for element in sequence {
            let key = keySelector(element)
            if dict[key] == nil {
                dict[key] = [TValue]()
            }
            dict[key]!.append(valueSelector(element))
        }
        return dict
    }
}

/**
Numeric type interface for aggregate methods of Enumerable
*/
public protocol NumericType: Equatable, ExpressibleByIntegerLiteral {
    static func +(lhs: Self, rhs: Self) -> Self
    static func +=(lhs: inout Self, rhs: Self)
    static func -(lhs: Self, rhs: Self) -> Self
    static func -=(lhs: inout Self, rhs: Self)
    func toDouble() -> Double
}

extension Int: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension Int8: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension Int16: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension Int32: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension Int64: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension UInt8: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension UInt16: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension UInt32: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension UInt64: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension Float: NumericType {
    public func toDouble() -> Double { return Double(self) }
}

extension Double: NumericType {
    public func toDouble() -> Double { return self }
}

/**
Represents a collection of objects that have a common key
*/
public struct Grouping<TKey, TElement> {
    public let key: TKey
    public let elements: Enumerable<TElement>
}

extension Grouping: Sequence {
    typealias GeneratorType = Enumerable<TElement>.Iterator
    public func makeIterator() -> Enumerable<TElement>.Iterator { return elements.makeIterator() }
}

/**
Represents a collection of keys each mapped to one or more values
*/
open class Lookup<TKey: Hashable, TElement> {
    let data: Dictionary<TKey, Array<TElement>>

    init(source: Dictionary<TKey, Array<TElement>>) {
        data = source
    }

    subscript(key: TKey) -> Enumerable<TElement> {
        if let elements = data[key] {
            return Enumerable.from(elements)
        }
        return Enumerable<TElement>.empty()
    }

    func count() -> Int {
        return data.count
    }

    func contains(_ key: TKey) -> Bool {
        return data[key] != nil
    }
}

/**
Represents a sorted sequence
*/
open class OrderedEnumerable<T> : Enumerable<T> {
    open override func makeIterator() -> AnyIterator<T> {
        var array = Enumerable.from(source).toArray()
        array.sort {
            [unowned self] (a: T, b: T) in
            for comparer in self.comparers {
                if comparer(a, b) {
                    return true
                }
                if comparer(b, a) {
                    return false
                }
            }
            return false
        }
        return AnyIterator(array.makeIterator())
    }

    public init<S: Sequence>(source: S, comparer: @escaping (T, T) -> Bool)
        where S.Iterator.Element == T,
            S.SubSequence : Sequence,
            S.SubSequence.Iterator.Element == T,
            S.SubSequence.SubSequence == S.SubSequence {
        self.comparers = [comparer]
        super.init(source)
    }

    public init<S: Sequence>(source: S, comparers: Array<(T, T) -> Bool>)
        where S.Iterator.Element == T,
            S.SubSequence : Sequence,
            S.SubSequence.Iterator.Element == T,
            S.SubSequence.SubSequence == S.SubSequence {
        self.comparers = comparers
        super.init(source)
    }

    fileprivate let comparers : Array<(T, T) -> Bool>

    /**
    Performs a subsequent ordering of the elements in a sequence in ascending order according to a key

    - parameter keySelector: - A function to extract a key from each element
    - returns: An OrderedEnumerable<T> whose elements are sorted according to a key
    */
    public final func thenBy<TKey: Comparable>(_ keySelector: @escaping (T) -> TKey) -> OrderedEnumerable<T> {
        var newComparers = comparers
        newComparers.append { keySelector($0) < keySelector($1) }
        return OrderedEnumerable(source: source, comparers: newComparers)
    }

    /**
    Performs a subsequent ordering of the elements in a sequence in descending order, according to a key

    - parameter keySelector: - A function to extract a key from each element
    - returns: An OrderedEnumerable<T> whose elements are sorted in descending order according to a key
    */
    public final func thenByDescending<TKey: Comparable>(_ keySelector: @escaping (T) -> TKey) -> OrderedEnumerable<T> {
        var newComparers = comparers
        newComparers.append { keySelector($0) > keySelector($1) }
        return OrderedEnumerable(source: source, comparers: newComparers)
    }

    /**
    Filters a sequence of values based on a predicate

    - parameter predicate: - A function to test each element for a condition
    - returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    public final override func where$(_ predicate: @escaping (T) -> Bool) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: Enumerable.from(source).where$(predicate), comparers: comparers)
    }

    /**
    Filters a sequence of values based on a predicate
    Each element's index is used in the logic of the predicate function

    - parameter predicate: - A function to test each element for a condition; the second parameter of the function represents the index of the source element
    - returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    public final override func where$(_ predicate: @escaping (T, Int) -> Bool) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: Enumerable.from(source).where$(predicate), comparers: comparers)
    }
}

public extension Sequence
    where Self.SubSequence: Sequence,
        Self.SubSequence.Iterator.Element == Self.Iterator.Element,
        Self.SubSequence.SubSequence == Self.SubSequence {
    public func toEnumerable() -> Enumerable<Self.Iterator.Element> {
        return Enumerable.from(self)
    }
}
