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
public class Enumerable<T>: SequenceType {

    // sequence source
    private let source : SequenceOf<T>

    // generator
    public func generate() -> GeneratorOf<T> { return source.generate() }

    /**
    Initialize from generator.

    :param: generator - A generator of source sequence
    */
    private init<TGenerator: GeneratorType where TGenerator.Element == T>(_ generator: () -> TGenerator) {
        source = SequenceOf(generator)
    }

    /**
    Initialize from sequence.

    :param: source - A source sequence
    */
    private init<TSequence: SequenceType where TSequence.Generator.Element == T>(_ source: TSequence) {
        self.source = SequenceOf(source)
    }

    /*---------------------*/
    /* generationg methods */
    /*---------------------*/

    /**
    Generates an infinite sequence from random elements of source sequence

    :param: source - A source sequence
    :return: An infinite sequence from random elements of source sequence
    */
    final class func choice<TSequence: SequenceType where TSequence.Generator.Element == T>
        (source: TSequence) -> Enumerable
    {
        return Enumerable { () -> GeneratorOf<T> in
            var sourceArray = [T](source)
            return GeneratorOf<T> { () -> T? in
                return sourceArray[Int(arc4random_uniform(UInt32(sourceArray.count)))]
            }
        }
    }

    /**
    Generates an infinite cycle sequence from source sequence

    :param: source - A source sequence
    :return: An infinite cycle sequence from source sequence
    */
    final class func cycle<TSequence: SequenceType where TSequence.Generator.Element == T>
        (source: TSequence) -> Enumerable
    {
        return Enumerable { () -> GeneratorOf<T> in
            var sourceArray = [T](source)
            var index = 0
            return GeneratorOf<T> { () -> T? in
                if sourceArray.count <= index {
                    index = 0
                }
                return sourceArray[index++]
            }
        }
    }

    /**
    Generates an empty Enumerable.
    Type name is required

    :returns: An empty Enumerable<T>
    */
    final class func empty() -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            return GeneratorOf<T> { () -> T? in
                return nil
            }
        }
    }

    /**
    Generates an Enumerable from sequence.

    :param: source - A source sequence
    :returns: An enumerable sequence
    */
    final class func from<TSequence: SequenceType where TSequence.Generator.Element == T>
        (source: TSequence) -> Enumerable
    {
        return Enumerable(source)
    }

    /**
    Generates an infinite sequence from specified start number and step value.
    Type name is required

    :param: start - The number of start
    :param: step - The step value to increase
    :returns: A infinite sequence from specified start number and step value
    */
    final class func infinity<N: NumericType>(start: N, step: N = 1) -> Enumerable<N> {
        return Enumerable<N> { () -> GeneratorOf<N> in
            var value = start - step
            return GeneratorOf<N> { () -> N? in
                value += step
                return value
            }
        }
    }

    /**
    Generates a negative infinite sequence from specified start number and step value.
    Type name is required

    :param: start - The number of start
    :param: step - The step value to decrease
    :returns: A infinite sequence from specified start number and step value
    */
    final class func negativeInfinity<N: NumericType>(start: N, step: N = 1) -> Enumerable<N> {
        return Enumerable<N> { () -> GeneratorOf<N> in
            var value = start + step
            return GeneratorOf<N> { () -> N? in
                value -= step
                return value
            }
        }
    }

    /**
    Generates a sequence of NumericType within a specified range.
    Type name is required

    :param: start - The value of the first NumericType in the sequence
    :param: count - The number of sequential NumericType to generate
    :returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func range<N: NumericType>(start: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.infinity(start, step: 1).take(count)
    }

    /**
    Generates a sequence of NumericType within a specified range by step.
    Type name is required

    :param: start - The value of the first NumericType in the sequence
    :param: step - The step value to increase
    :param: count - The number of sequential NumericType to generate
    :returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func range<N: NumericType>(start: N, step: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.infinity(start, step: step).take(count)
    }

    /**
    Generates a negative sequence of NumericType within a specified range.
    Type name is required

    :param: start - The value of the first NumericType in the sequence
    :param: count - The number of sequential NumericType to generate
    :returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func rangeDown<N: NumericType>(start: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.negativeInfinity(start, step: 1).take(count)
    }

    /**
    Generates a negative sequence of NumericType within a specified range by step.
    Type name is required

    :param: start - The value of the first NumericType in the sequence
    :param: step - The step value to increase
    :param: count - The number of sequential NumericType to generate
    :returns: An Enumerable<N> that contains a range of sequential integral numbers
    */
    final class func rangeDown<N: NumericType>(start: N, step: N, count: Int) -> Enumerable<N> {
        return Enumerable<N>.negativeInfinity(start, step: step).take(count)
    }

    /**
    Generates an infinite sequence that contains one repeated value

    :param: value - The value to be repeated
    :returns: An infinite sequence that contains one repeated value
    */
    final class func repeat(value: T) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            return GeneratorOf<T> { () -> T? in
                return value
            }
        }
    }

    /**
    Generates a sequence that contains one repeated value

    :param: value - The value to be repeated
    :param: count - The number of times to repeat the value in the generated sequence
    :returns: A sequence that contains one repeated value
    */
    final class func repeat(value: T, count: Int) -> Enumerable {
        return Enumerable.repeat(value).take(count)
    }

    /**
    Generates a sequence that contains one value

    :param: value - The value of sequence
    */
    final class func return$(value: T) -> Enumerable {
        return Enumerable.repeat(value).take(1)
    }

    /*----------------------------------*/
    /* projection and filtering methods */
    /*----------------------------------*/

    /**
    Filters the elements of an Enumerable based on a specified type

    :param: resultType - The type to filter the elements of the sequence on
    :returns: An Enumerable that contains elements from the input sequence of type TResult
    */
    final func ofType<TResult>(resultType: TResult.Type) -> Enumerable<TResult> {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            var generator = self.generate()
            return GeneratorOf {
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

    :param: accumulator - An accumulator function to be invoked on each element
    :returns: An Enumerable<T> that contains results of accumulator function
    */
    final func scan(accumulator: (T, T) -> T) -> Enumerable {
        return self.scan(seed: nil, accumulator: accumulator) { $0 }
    }

    /**
    Applies an accumulator function over a sequence.
    The specified seed value is used as the initial accumulator value.

    :param: seed - The initial accumulator value
    :param: accumulator - An accumulator function to be invoked on each element
    :returns: An Enumerable<TAccumulate> that contains results of accumulator function
    */
    final func scan<TAccumulate>(
        seed: TAccumulate,
        accumulator: (TAccumulate, T) -> TAccumulate
        ) -> Enumerable<TAccumulate>
    {
        return self.scan(seed: seed, accumulator: accumulator) { $0 }
    }

    /**
    Applies an accumulator function over a sequence.
    The specified seed value is used as the initial accumulator value,
    and the specified function is used to select the result value.

    :param: seed - The initial accumulator value
    :param: accumulator - An accumulator function to be invoked on each element
    :param: resultSelector - A function to transform the final accumulator value into the result value
    :returns: An Enumerable<T> that contains results of accumulator function
    */
    final func scan<TAccumulate, TResult>(
        seed: TAccumulate,
        accumulator: (TAccumulate, T) -> TAccumulate,
        resultSelector: TAccumulate -> TResult
        ) -> Enumerable<TResult>
    {
        return self.scan(seed: seed, accumulator: accumulator, resultSelector: resultSelector)
    }

    /**
    Projects each element of a sequence into a new form

    :param: selector - A transform function to apply to each element
    :returns: An Enumerable<T> whose elements are the result of invoking the transform function on each element of source
    */
    final func select<TResult>(selector: T -> TResult) -> Enumerable<TResult> {
        return self.select { (x, _) -> TResult in selector(x) }
    }

    /**
    Projects each element of a sequence into a new form by incorporating the element's index

    :param: selector - A transform function to apply to each source element; the second parameter of the function represents the index of the source element
    :returns: An Enumerable<T> whose elements are the result of invoking the transform function on each element of source
    */
    final func select<TResult>(selector: (T, Int) -> TResult) -> Enumerable<TResult> {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            var generator = self.generate()
            var index = 0
            return GeneratorOf {
                while let element = generator.next() {
                    return selector(element, index++)
                }
                return nil
            }
        }
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    and flattens the resulting sequences into one sequence.

    :param: collectionSelector - A transform function to apply to each element
    :returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function on each element of the input sequence
    */
    final func selectMany<TCollection: SequenceType>
        (collectionSelector: T -> TCollection) -> Enumerable<TCollection.Generator.Element>
    {
        return self.selectMany({ (x, _) -> TCollection in collectionSelector(x) }, resultSelector: { (_, x) in x } )
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    and flattens the resulting sequences into one sequence.
    The index of each source element is used in the projected form of that element.

    :param: collectionSelector - A transform function to apply to each source element; the second parameter of the function represents the index of the source element
    :returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function on each element of the input sequence
    */
    final func selectMany<TCollection: SequenceType>
        (collectionSelector: (T, Int) -> TCollection) -> Enumerable<TCollection.Generator.Element>
    {
        return self.selectMany(collectionSelector, resultSelector: { (_, x) in x } )
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    flattens the resulting sequences into one sequence,
    and invokes a result selector function on each element therein

    :param: collectionSelector - A transform function to apply to each element
    :param: resultSelector - A transform function to apply to each element of the intermediate sequence
    :returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function collectionSelector on each element of source and then mapping each of those sequence elements and their corresponding source element to a result element
    */
    final func selectMany<TCollection: SequenceType, TResult>(
        collectionSelector: T -> TCollection,
        resultSelector: (T, TCollection.Generator.Element) -> TResult
        ) -> Enumerable<TResult>
    {
        return self.selectMany({ (x, _) -> TCollection in collectionSelector(x) }, resultSelector: resultSelector)
    }

    /**
    Projects each element of a sequence to an Enumerable<T>,
    flattens the resulting sequences into one sequence,
    and invokes a result selector function on each element therein.
    The index of each source element is used in the intermediate projected form of that element

    :param: collectionSelector - A transform function to apply to each source element; the second parameter of the function represents the index of the source element
    :param: resultSelector - A transform function to apply to each element of the intermediate sequence
    :returns: An Enumerable<T> whose elements are the result of invoking the one-to-many transform function collectionSelector on each element of source and then mapping each of those sequence elements and their corresponding source element to a result element
    */
    final func selectMany<TCollection: SequenceType, TResult>(
        collectionSelector: (T, Int) -> TCollection,
        resultSelector: (T, TCollection.Generator.Element) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            typealias TElement = TCollection.Generator.Element
            var index = 0
            var generator = self.generate()
            var middleGenerator: SequenceOf<TElement>.Generator? = nil
            var element: T? = nil

            return GeneratorOf {
                if middleGenerator == nil {
                    if let first = generator.next() {
                        element = first
                    } else {
                        return nil
                    }
                }
                do {
                    if (middleGenerator == nil)
                    {
                        var middleSequence = collectionSelector(element!, index++);
                        middleGenerator = Enumerable<TElement>.from(middleSequence).generate();
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

    :param: predicate - A function to test each element for a condition
    :returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    func where$(predicate: T -> Bool) -> Enumerable {
        return self.where$ { (x, _) -> Bool in predicate(x) }
    }

    /**
    Filters a sequence of values based on a predicate
    Each element's index is used in the logic of the predicate function

    :param: predicate - A function to test each element for a condition; the second parameter of the function represents the index of the source element
    :returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    func where$(predicate: (T, Int) -> Bool) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            var index = 0
            return GeneratorOf {
                while let element = generator.next() {
                    if predicate(element, index++) {
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

    :param: second - The second sequence to merge
    :param: resultSelector - A function that specifies how to merge the elements from the two sequences
    :returns: An IEnumerable<TResult> that contains merged elements of two input sequences
    */
    final func zip<TSequence: SequenceType, TResult>(
        second: TSequence,
        resultSelector: (T, TSequence.Generator.Element) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            var firstGenerator = self.generate()
            var secondGenerator = second.generate()
            return GeneratorOf {
                switch (firstGenerator.next(), secondGenerator.next()) {
                case (.Some(let first), .Some(let second)):
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

    :param: inner - The sequence to join to the first sequence
    :param: outerKeySelector - A function to extract the join key from each element of the first sequence
    :param: innerKeySelector - A function to extract the join key from each element of the second sequence
    :param: resultSelector - A function to create a result element from an element from the first sequence and a collection of matching elements from the second sequence
    :returns: An Enumerable<TResult> that are obtained by performing a grouped join on two sequences
    */
    final func groupJoin<TInner: SequenceType, TKey: Hashable, TResult>(
        inner: TInner,
        outerKeySelector: T -> TKey,
        innerKeySelector: TInner.Generator.Element -> TKey,
        resultSelector: (T, Enumerable<TInner.Generator.Element>) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            let innerGroups = self.sequenceToGroupDictionary(inner, keySelector: innerKeySelector)
            var outerGenerator = self.generate()

            return GeneratorOf {
                if let element = outerGenerator.next() {
                    let key = outerKeySelector(element)
                    if let group = innerGroups[key] {
                        return resultSelector(element, Enumerable<TInner.Generator.Element>.from(group))
                    } else {
                        return resultSelector(element, Enumerable<TInner.Generator.Element>.empty())
                    }
                } else {
                    return nil
                }
            }

        }
    }

    /**
    Correlates the elements of two sequences based on matching keys

    :param: inner - The sequence to join to the first sequence
    :param: outerKeySelector - A function to extract the join key from each element of the first sequence
    :param: innerKeySelector - A function to extract the join key from each element of the second sequence
    :param: resultSelector - A function to create a result element from two matching elements
    :returns: An Enumerable<T> that are obtained by performing an inner join on two sequences
    */
    final func join<TInner: SequenceType, TKey: Hashable, TResult>(
        inner: TInner,
        outerKeySelector: T -> TKey,
        innerKeySelector: TInner.Generator.Element -> TKey,
        resultSelector: (T, TInner.Generator.Element) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            let innerGroups = self.sequenceToGroupDictionary(inner, keySelector: innerKeySelector)
            var outerGenerator = self.generate()
            var outerElement: T? = nil
            var innerGenerator = Array<TInner.Generator.Element>().generate()

            return GeneratorOf {
                while let element = innerGenerator.next() {
                    return resultSelector(outerElement!, element)
                }
                while let element = outerGenerator.next() {
                    let key = outerKeySelector(element)
                    if let group = innerGroups[key] {
                        innerGenerator = group.generate()
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

    :param: predicate - A function to test each element for a condition
    :returns: true if every element of the source sequence passes the test in the specified predicate, or if the sequence is empty; otherwise, false
    */
    final func all(predicate: T -> Bool) -> Bool {
        for element in self {
            if !predicate(element) {
                return false
            }
        }
        return true
    }

    /**
    Determines whether a sequence contains any elements.

    :returns: true if the source sequence contains any elements; otherwise, false
    */
    final func any() -> Bool {
        for element in self {
            return true
        }
        return false
    }

    /**
    Determines whether any element of a sequence satisfies a condition.

    :param: predicate - A function to test each element for a condition
    :returns: true if any elements in the source sequence pass the test in the specified predicate; otherwise, false
    */
    final func any(predicate: T -> Bool) -> Bool {
        for element in self {
            if predicate(element) {
                return true
            }
        }
        return false
    }

    /**
    Concatenates two sequences.

    :param: second - The sequence to concatenate to the first sequence
    :returns: An Enumerable<T> that contains the concatenated elements of the two input sequences
    */
    final func concat<TSequence: SequenceType where TSequence.Generator.Element == T>
        (second: TSequence) -> Enumerable
    {
        return Enumerable { () -> GeneratorOf<T> in
            var firstGenerator = self.generate()
            var secondGenerator = second.generate()
            return GeneratorOf {
                if let f = firstGenerator.next() {
                    return f
                }
                return secondGenerator.next()
            }
        }
    }

    /**
    Determines whether a sequence contains a specified element by using a specified comparer.

    :param: value - The value to locate in the sequence
    :param: comparer - An equality comparer to compare values
    :returns: true if the source sequence contains an element that has the specified value; otherwise, false
    */
    final func contains(value: T, comparer: (T, T) -> Bool) -> Bool {
        var generator = self.generate()
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

    :param: defaultValue - The value to return if the sequence is empty
    :returns: An Enumerable<T> that contains defaultValue if source is empty; otherwise, source
    */
    final func defaultIfEmpty(defaultValue: T) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            var isFirst = true
            return GeneratorOf {
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

    :param: keySelector - A function to generate the keys to compare
    :returns: An Enumerable<T> that contains distinct elements from the source sequence
    */
    final func distinct<TKey: Hashable>(keySelector: T -> TKey) -> Enumerable
    {
        return self.except(Enumerable<T>.empty(), keySelector: keySelector)
    }

    /**
    Returns distinct elements from a sequence by using a specified comparer

    :param: comparer - An equality comparer to compare values
    :returns: An Enumerable<T> that contains distinct elements from the source sequence
    */
    final func distinct(comparer: (T, T) -> Bool) -> Enumerable
    {
        return self.except(Enumerable<T>.empty(), comparer: comparer)
    }

    /**
    Produces the set difference of two sequences by using the key selector

    :param: second - A sequence whose elements that also occur in the first sequence will cause those elements to be removed from the returned sequence
    :param: keySelector - A function to generate the keys to compare
    :returns: A sequence that contains the set difference of the elements of two sequences
    */
    final func except<TKey: Hashable, TSequence: SequenceType where TSequence.Generator.Element == T>
        (second: TSequence, keySelector: T -> TKey) -> Enumerable
    {
        return Enumerable { () -> GeneratorOf<T> in
            var firstGenerator = self.generate()
            var returnedElements = [TKey:Bool]()
            Enumerable.from(second).each { returnedElements[keySelector($0)] = true }
            return GeneratorOf {
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

    :param: second - A sequence whose elements that also occur in the first sequence will cause those elements to be removed from the returned sequence
    :param: comparer - An equality comparer to compare values
    :returns: A sequence that contains the set difference of the elements of two sequences
    */
    final func except<TSequence: SequenceType where TSequence.Generator.Element == T>
        (second: TSequence, comparer: (T, T) -> Bool) -> Enumerable
    {
        return Enumerable { () -> GeneratorOf<T> in
            var firstGenerator = self.generate()
            var returnedElements = [T](second)
            return GeneratorOf {
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

    :param: second - An sequence whose distinct elements that also appear in the first sequence will be returned
    :param: keySelector - A function to generate the keys to compare
    :returns: A sequence that contains the elements that form the set intersection of two sequences
    */
    final func intersect<TKey: Hashable, TSecond: SequenceType where TSecond.Generator.Element == T>
        (second: TSecond, keySelector: T -> TKey) -> Enumerable<T>
    {
        return Enumerable { () -> GeneratorOf<T> in
            var first = self.generate()
            var returnedElements = [TKey:Bool]()
            let secondDictionary = Enumerable.from(second).toDictionary(keySelector)
            return GeneratorOf {
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

    :param: second - An sequence whose distinct elements that also appear in the first sequence will be returned
    :param: comparer - An equality comparer to compare values
    :returns: A sequence that contains the elements that form the set intersection of two sequences
    */
    final func intersect<TSecond: SequenceType where TSecond.Generator.Element == T>
        (second: TSecond, comparer: (T, T) -> Bool) -> Enumerable<T>
    {
        return Enumerable { () -> GeneratorOf<T> in
            var firstGenerator = self.distinct(comparer).generate()
            let secondEnumerable = Enumerable.from(second)
            var returnedElements = [T]()
            return GeneratorOf {
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

    :param: second - A sequence to compare to the first sequence
    :returns: true if the two source sequences are of equal length and their corresponding elements compare equal according to comparer; otherwise, false
    */
    final func sequenceEqual<TSequence: SequenceType where TSequence.Generator.Element == T>
        (second: TSequence, comparer: (T, T) -> Bool) -> Bool
    {
        var firstGenerator = self.generate()
        var secondGenerator = second.generate()
        while let first = firstGenerator.next() {
            if let second: T = secondGenerator.next() {
                if !comparer(first, second) {
                    return false
                }
            } else {
                return false
            }
        }
        if let second: T = secondGenerator.next() {
            return false
        }
        return true
    }

    /**
    Produces the set union of two sequences by using the comparer

    :param: second - A sequence whose distinct elements form the second set for the union
    :param: comparer - The equality comparer to compare values
    :returns: An Enumerable<T> that contains the elements from both input sequences, excluding duplicates
    */
    final func union<TSequence: SequenceType where TSequence.Generator.Element == T>
        (second: TSequence, comparer: (T, T) -> Bool) -> Enumerable<T>
    {
        return Enumerable { () -> GeneratorOf<T> in
            var firstGenerator = self.generate()
            var secondGenerator: TSequence.Generator? = nil
            var returnedElements = [T]()

            return GeneratorOf {
                var returned = Enumerable.from(returnedElements)
                if secondGenerator == nil {
                    while let firstElement = firstGenerator.next() {
                        if !returned.contains(firstElement, comparer: comparer) {
                            returnedElements.append(firstElement)
                            return firstElement
                        }
                    }
                    secondGenerator = second.generate()
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

    :param: second - A sequence whose distinct elements form the second set for the union
    :param: keySelector - A function to generate the keys to compare
    :returns: An Enumerable<T> that contains the elements from both input sequences, excluding duplicates
    */
    final func union<TKey: Hashable, TSequence: SequenceType where TSequence.Generator.Element == T>
        (second: TSequence, keySelector: T -> TKey) -> Enumerable<T>
    {
        return Enumerable { () -> GeneratorOf<T> in
            var firstGenerator = self.generate()
            var secondGenerator: TSequence.Generator? = nil
            var returnedElements = [TKey:Bool]()

            return GeneratorOf {
                if secondGenerator == nil {
                    while let firstElement = firstGenerator.next() {
                        var key = keySelector(firstElement)
                        if let _ = returnedElements[key] {
                            continue
                        }
                        returnedElements[key] = true
                        return firstElement
                    }
                    secondGenerator = second.generate()
                }
                while let secondElement: T = secondGenerator?.next() {
                    var key = keySelector(secondElement)
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

    :param: keySelector - A function to extract a key from an element
    :returns: An OrderedEnumerable<T> whose elements are sorted according to a key
    */
    final func orderBy<TKey: Comparable>(keySelector: T -> TKey) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: source, comparer: { keySelector($0) < keySelector($1) })
    }

    /**
    Sorts the elements of a sequence in descending order according to a key

    :param: keySelector - A function to extract a key from an element
    :returns: An OrderedEnumerable<T> whose elements are sorted in descending order according to a key
    */
    final func orderByDescending<TKey: Comparable>(keySelector: T -> TKey) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: source, comparer: { keySelector($0) > keySelector($1) })
    }

    /**
    Inverts the order of the elements in a sequence

    :returns: A sequence whose elements correspond to those of the input sequence in reverse order
    */
    final func reverse() -> Enumerable<T> {
        return Enumerable { () -> IndexingGenerator<[T]> in
            self.toArray().reverse().generate()
        }
    }

    /*------------------*/
    /* grouping methods */
    /*------------------*/

    /**
    Groups the elements of a sequence according to a specified key selector function

    :param: keySelector - A function to extract the key for each element
    :returns: A collection of Grouping<TKey, T> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable>(keySelector: T -> TKey) -> Enumerable<Grouping<TKey, T>> {
        return self.groupBy(keySelector) { $0 }
    }

    /**
    Groups the elements of a sequence according to a specified key selector function
    and projects the elements for each group by using a specified function

    :param: keySelector - A function to extract the key for each element
    :param: elementSelector - A function to map each source element to an element in the Grouping<TKey, TElement>
    :returns: A collection of Grouping<TKey, TElement> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable, TElement>
        (keySelector: T -> TKey, elementSelector: T -> TElement) -> Enumerable<Grouping<TKey, TElement>>
    {
        return Enumerable<Grouping<TKey, TElement>> { () -> GeneratorOf<Grouping<TKey, TElement>> in
            let groups = self.sequenceToGroupDictionary(self, keySelector: keySelector)
            var keysGenerator = groups.keys.generate()

            return GeneratorOf {
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

    :param: keySelector - A function to extract the key for each element
    :param: resultSelector - A function to create a result value from each group
    :returns: A collection of Grouping<TKey, TResult> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable, TResult>
        (keySelector: T -> TKey, resultSelector: (TKey, Enumerable<T>) -> TResult) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            let groups = self.sequenceToGroupDictionary(self, keySelector: keySelector)
            var keysGenerator = groups.keys.generate()

            return GeneratorOf {
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

    :param: keySelector - A function to extract the key for each element
    :param: elementSelector - A function to map each source element to an element in the Grouping<TKey, TElement>
    :param: resultSelector - A function to create a result value from each group
    :returns: A collection of Grouping<TKey, TResult> objects, one for each distinct key that was encountered
    */
    final func groupBy<TKey: Hashable, TElement, TResult>(
        keySelector: T -> TKey,
        elementSelector: T -> TElement,
        resultSelector: (TKey, Enumerable<TElement>) -> TResult
        ) -> Enumerable<TResult>
    {
        return Enumerable<TResult> { () -> GeneratorOf<TResult> in
            let groups = self.sequenceToGroupDictionary(self, keySelector: keySelector)
            var keysGenerator = groups.keys.generate()

            return GeneratorOf {
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

    :param: accumulator - An accumulator function to be invoked on each element
    :returns: The final accumulator value or nil
    */
    final func aggregate(accumulator:  (T, T) -> T) -> T? {
        var generator = self.generate()
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

    :param: seed - The initial accumulator value
    :param: accumulator - An accumulator function to be invoked on each element
    :returns: The final accumulator value
    */
    final func aggregate<TAccumulate>(
        seed: TAccumulate,
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

    :param: seed - The initial accumulator value
    :param: accumulator - An accumulator function to be invoked on each element
    :param: resultSelector - A function to transform the final accumulator value into the result value
    :returns: The transformed final accumulator value
    */
    final func aggregate<TAccumulate, TResult>(
        seed: TAccumulate,
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

    :param: selector - A transform function to apply to each element
    :returns: The average of the sequence of values
    */
    final func average<N: NumericType>(selector: T -> N) -> Double {
        var total: N = 0
        var count = 0

        self.each {
            total += selector($0)
            count += 1
        }

        return total.toDouble() / Double(count)
    }

    /**
    Returns the number of elements in a sequence.

    :returns: The number of elements in the input sequence
    */
    final func count() -> Int {
        var count = 0
        self.each { (_: T) -> Void in count += 1 }
        return count
    }

    /**
    Returns a number that represents how many elements in the specified sequence satisfy a condition.

    :param: predicate - A function to test each element for a condition
    :returns: A number that represents how many elements in the sequence satisfy the condition in the predicate function
    */
    final func count(predicate: T -> Bool) -> Int {
        var count = 0
        self.each {
            if predicate($0) {
                count += 1
            }
        }
        return count
    }

    /**
    Returns the maximum value in a sequence

    :param: selector - A transform function to apply to each element
    :returns: The maximum value in the sequence or nil if the sequence is empty
    */
    final func max<TValue: Comparable>(selector: T -> TValue) -> TValue? {
        var generator = self.generate()
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

    :param: selector - A transform function to apply to each element
    :returns: The minimum value in the sequence or nil if the sequence is empty
    */
    final func min<TValue: Comparable>(selector: T -> TValue) -> TValue? {
        var generator = self.generate()
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

    :param: selector - A transform function to apply to each element
    :returns: The sum of the projected values
    */
    final func sum<N: NumericType>(selector: T -> N) -> N {
        return self.select(selector).aggregate(0) { $0 + $1 }
    }

    /*----------------*/
    /* paging methods */
    /*----------------*/

    /**
    Returns the element at a specified index in a sequence.

    :param: index - The zero-based index of the element to retrieve
    :returns: The element at the specified position in the source sequence or nil if the index is out of range
    */
    final func elementAt(index: Int) -> T? {
        return self.elementAt(index, defaultValue: nil)
    }

    /**
    Returns the element at a specified index in a sequence or a default value if the index is out of range

    :param: index - The zero-based index of the element to retrieve
    :param: defaultValue - The value to return if the index is out of range
    :returns: defaultValue if the index is outside the bounds of the source sequence; otherwise, the element at the specified position in the source sequence
    */
    final func elementAtOrDefault(index: Int, defaultValue: T) -> T {
        return self.elementAt(index, defaultValue: defaultValue)!
    }

    /**
    Returns the first element of a sequence

    :returns: The first element in the specified sequence, or nil if sequence is empty
    */
    final func first() -> T? {
        var generator = self.generate()
        return generator.next()
    }

    /**
    Returns the first element in a sequence that satisfies a specified condition

    :param: predicate - A function to test each element for a condition
    :returns: The first element in the sequence that passes the test in the specified predicate function, or nil If no elements pass the test in the predicate function
    */
    final func first(predicate: T -> Bool) -> T? {
        var generator = self.where$(predicate).generate()
        return generator.next()
    }

    /**
    Returns the first element of a sequence, or a default value if the sequence contains no elements

    :param: defaultValue - The value to return if the source sequence is empty
    :returns: defaultValue if source is empty; otherwise, the first element in source
    */
    final func firstOrDefault(defaultValue: T) -> T {
        var generator = self.generate()
        return self.firstOrDefault(generator, defaultValue: defaultValue)
    }

    /**
    Returns the first element of the sequence that satisfies a condition or a default value
    if no such element is found.

    :param: defaultValue - The value to return if source is empty or if no element passes the test specified by predicate
    :param: predicate - A function to test each element for a condition
    :returns: defaultValue if source is empty or if no element passes the test specified by predicate; otherwise, the first element in source that passes the test specified by predicate
    */
    final func firstOrDefault(defaultValue: T, predicate: T -> Bool) -> T {
        var generator = self.where$(predicate).generate()
        return self.firstOrDefault(generator, defaultValue: defaultValue)
    }

    /**
    Returns the last element of a sequence

    :returns: The value at the last position in the source sequence or nil if sequence is empty
    */
    final func last() -> T? {
        var generator = self.generate()
        var lastElement: T? = nil
        while let element = generator.next() {
            lastElement = element
        }
        return lastElement
    }

    /**
    Returns the last element of a sequence that satisfies a specified condition

    :param: predicate - A function to test each element for a condition
    :returns: The last element in the sequence that passes the test in the specified predicate function, or nil If no elements pass the test in the predicate function
    */
    final func last(predicate: T -> Bool) -> T? {
        var generator = self.generate()
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

    :param: defaultValue - The value to return if the source sequence is empty
    :returns: defaultValue if the source sequence is empty; otherwise, the last element in the sequence
    */
    final func lastOrDefault(defaultValue: T) -> T {
        if let lastElement = last() {
            return lastElement
        }
        return defaultValue
    }

    /**
    Returns the last element of a sequence that satisfies a condition
    or a default value if no such element is found

    :param: defaultValue - The value to return if the sequence is empty or if no elements pass the test in the predicate function
    :param: predicate - A function to test each element for a condition
    :returns: defaultValue if the sequence is empty or if no elements pass the test in the predicate function; otherwise, the last element that passes the test in the predicate function
    */
    final func lastOrDefault(defaultValue: T, predicate: T -> Bool) -> T {
        if let lastElement = last(predicate) {
            return lastElement
        }
        return defaultValue
    }

    /**
    Returns the only element of a sequence,
    or returns nil if there is not exactly one element in the sequence

    :returns: nil if the sequence is empty or not single element; otherwise, The single element of the input sequence
    */
    final func single() -> T? {
        var generator = self.generate()
        return self.single(generator, defaultValue: nil)
    }

    /**
    Returns the only element of a sequence that satisfies a specified condition,
    or returns nil if more than one such element exists

    :param: predicate - A function to test an element for a condition
    :returns: The single element of the input sequence that satisfies a condition, or nil if more than one such element exists
    */
    final func single(predicate: T -> Bool) -> T? {
        var generator = self.where$(predicate).generate()
        return self.single(generator, defaultValue: nil)
    }

    /**
    Returns the only element of a sequence, or a default value if the sequence is empty.
    This method returns nil if there is more than one element in the sequence

    :param: defaultValue - The value to return if the sequence is empty
    :returns: The single element of the input sequence, or defaultValue if the sequence contains no elements, or nil if there is more than one element in the sequence
    */
    final func singleOrDefault(defaultValue: T) -> T? {
        var generator = self.generate()
        return self.single(generator, defaultValue: defaultValue)
    }

    /**
    Returns the only element of a sequence that satisfies a specified condition
    or a default value if no such element exists.
    This method returns nil if more than one element satisfies the condition

    :param: defaultValue - The value to return if the sequence is empty
    :param: predicate - A function to test an element for a condition
    :returns: The single element of the input sequence that satisfies the condition, or defaultValue if no such element is found, or nil if more than one element satisfies the condition
    */
    final func singleOrDefault(defaultValue: T, predicate: T -> Bool) -> T? {
        var generator = self.where$(predicate).generate()
        return self.single(generator, defaultValue: defaultValue)
    }

    /**
    Bypasses a specified number of elements in a sequence and then returns the remaining elements

    :param: count - The number of elements to skip before returning the remaining elements
    :returns: An Enumerable<T> that contains the elements that occur after the specified index in the input sequence
    */
    final func skip(count: Int) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            for i in 0..<count { generator.next() }
            return generator
        }
    }

    /**
    Bypasses elements in a sequence as long as a specified condition is true
    and then returns the remaining elements

    :param: predicate - A function to test each element for a condition
    :returns: An Enumerable<T> that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate
    */
    final func skipWhile(predicate: T -> Bool) -> Enumerable {
        return self.skipWhile { (x, _) -> Bool in predicate(x) }
    }

    /**
    Bypasses elements in a sequence as long as a specified condition is true
    and then returns the remaining elements.
    The element's index is used in the logic of the predicate function

    :param: predicate - A function to test each source element for a condition; the second parameter of the function represents the index of the source element
    :returns: An IEnumerable<T> that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate
    */
    final func skipWhile(predicate: (T, Int) -> Bool) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            var index = 0
            var isSkipEnd = false
            return GeneratorOf {
                while !isSkipEnd {
                    if let element = generator.next() {
                        if !predicate(element, index++) {
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

    :param: count - The number of elements to return
    :returns: An Enumerable<T> that contains the specified number of elements from the start of the input sequence
    */
    final func take(count: Int) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            var index = 0
            return GeneratorOf {
                if count <= index {
                    return nil
                }
                index++
                return generator.next()
            }
        }
    }

    /**
    Returns elements from a sequence as long as a specified condition is true

    :param: predicate - A function to test each element for a condition
    :returns: An Enumerable<T> that contains the elements from the input sequence that occur before the element at which the test no longer passes
    */
    final func takeWhile(predicate: T -> Bool) -> Enumerable {
        return self.takeWhile { (x, _) -> Bool in predicate(x) }
    }

    /**
    Returns elements from a sequence as long as a specified condition is true.
    The element's index is used in the logic of the predicate function

    :param: predicate - A function to test each source element for a condition; the second parameter of the function represents the index of the source element
    :returns: An Enumerable<T> that contains elements from the input sequence that occur before the element at which the test no longer passes
    */
    final func takeWhile(predicate: (T, Int) -> Bool) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            var index = 0
            return GeneratorOf {
                while let element = generator.next() {
                    if !predicate(element, index++) {
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

    :returns: An array that contains the elements from the input sequence
    */
    final func toArray() -> Array<T> {
        return [T](self)
    }

    /**
    Creates a Dictionary<TKey, T> from an Enumerable<T> according to a specified key selector function.
    This method returns nil if duplicate key exists

    :param: keySelector - A function to extract a key from each element
    :returns: A Dictionary<TKey, T> that contains keys and values, or nil if duplicate key exists
    */
    final func toDictionary<TKey: Hashable>(keySelector: T -> TKey) -> Dictionary<TKey, T>? {
        return self.toDictionary(keySelector) { $0 }
    }

    /**
    Creates a Dictionary<TKey, TValue> from an Enumerable<T> according to specified key selector
    and element selector functions.
    This method returns nil if duplicate key exists

    :param: keySelector - A function to extract a key from each element
    :param: elementSelector - A transform function to produce a result element value from each element
    :returns: A Dictionary<TKey, TValue> that contains values of type TValue selected from the input sequence, or nil if duplicate key exists
    */
    final func toDictionary<TKey: Hashable, TValue>
        (keySelector: T -> TKey, elementSelector: T -> TValue) -> Dictionary<TKey, TValue>?
    {
        var dict = [TKey: TValue]()
        for element in self {
            var key = keySelector(element)
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

    :param: keySelector - A function to extract a key from each element
    :returns: A Lookup<TKey, T> that contains keys and values
    */
    final func toLookup<TKey: Hashable>(keySelector: T -> TKey) -> Lookup<TKey, T> {
        return Lookup(source: sequenceToGroupDictionary(self, keySelector: keySelector))
    }

    /**
    Creates a Lookup<TKey, TElement> from an Enumerable<T> according to specified key selector
    and element selector functions

    :param: keySelector - A function to extract a key from each element
    :param: elementSelector - A transform function to produce a result element value from each element
    :returns: A Lookup<TKey, TElement> that contains values of type TElement selected from the input sequence
    */
    final func toLookup<TKey: Hashable, TElement>
        (keySelector: T -> TKey, elementSelector: T -> TElement) -> Lookup<TKey, TElement>
    {
        return Lookup(source: sequenceToGroupDictionary(self, keySelector: keySelector, valueSelector: elementSelector))
    }

    /*----------------*/
    /* action methods */
    /*----------------*/

    /**
    Performs the specified action on each element of the sequence

    :param: action - A function to perform on each element of the source sequence
    */
    final func each(action: T -> Void) {
        self.eachWithIndex { (x, _) in action(x) }
    }

    /**
    Performs the specified action on each element of the sequence
    Each element's index is used in the logic of the action

    :param: action - A function to perform on each element of the source sequence; the second parameter of the function represents the index of the source element
    */
    final func eachWithIndex(action: (T, Int) -> Void) {
        var index = 0
        for element in self {
            action(element, index++)
        }
    }

    /**
    Executes the query that has been delayed
    */
    final func force() -> Void {
        var generator = self.generate()
        while let element = generator.next() {
            // nothing
        }
    }

    /*-------------------*/
    /* for debug methods */
    /*-------------------*/

    /**
    Dump each element of the sequence

    :returns: The sequence
    */
    final func dump() -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            return GeneratorOf {
                if let element = generator.next() {
                    Swift.dump(element)
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence

    :returns: The sequence
    */
    final func print() -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            return GeneratorOf {
                if let element = generator.next() {
                    Swift.print(element)
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence with separator

    :param: formatter - A function to format to string
    :returns: The sequence
    */
    final func print(formatter: T -> String) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            return GeneratorOf {
                if let element = generator.next() {
                    Swift.print(formatter(element))
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence and a newline character

    :returns: The sequence
    */
    final func println() -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            return GeneratorOf {
                if let element = generator.next() {
                    Swift.println(element)
                    return element
                }
                return nil
            }
        }
    }

    /**
    Prints each element of a sequence and a newline character

    :param: formatter - A function to format to string
    :returns: The sequence
    */
    final func println(formatter: T -> String) -> Enumerable {
        return Enumerable { () -> GeneratorOf<T> in
            var generator = self.generate()
            return GeneratorOf {
                if let element = generator.next() {
                    Swift.println(formatter(element))
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

    :param: index - The zero-based index of the element to retrieve
    :param: defaultValue - The value to return if the index is out of range
    :returns: defaultValue if the index is outside the bounds of the source sequence; otherwise, the element at the specified position in the source sequence
    */
    private final func elementAt(index: Int, defaultValue: T?) -> T? {
        var i = 0
        var value = defaultValue
        for x in self {
            if (i == index) {
                value = x
                break
            }
            i++
        }
        return value
    }

    /**
    Common component for firstOrDefault

    :param: generator - The generator of target sequence
    :param: defaultValue - The value to return if source is empty
    :returns: defaultValue if source is empty; otherwise, the first element in source sequence
    */
    private final func firstOrDefault(var generator: GeneratorOf<T>, defaultValue: T) -> T {
        while let element = generator.next() {
            return element
        }
        return defaultValue
    }

    /**
    Common component for scan

    :param: seed - The initial accumulator value
    :param: accumulator - An accumulator function to be invoked on each element
    :param: resultSelector - A function to transform the final accumulator value into the result value
    :returns: An Enumerable<T> that contains results of accumulator function
    */
    private final func scan<TAccumulate, TResult>(
        #seed: TAccumulate?,
        accumulator: (TAccumulate, T) -> TAccumulate,
        resultSelector: TAccumulate -> TResult
        ) -> Enumerable<TResult> {
            return Enumerable<TResult> { () -> GeneratorOf<TResult> in
                var generator = self.generate()
                var working: TAccumulate? = nil
                return GeneratorOf {
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

    :param: defaultValue - The value to return if the sequence is empty
    :returns: The single element of the input sequence, or defaultValue if the sequence contains no elements, or nil if there is more than one element in the sequence
    */
    private final func single(var generator: GeneratorOf<T>, defaultValue: T?) -> T? {
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

    :param: sequence - The target sequence
    :param: keySelector - A function to extract a key from each element
    :returns: A Dictionary that contains values of Array<TSequence.Generator.Element>
    */
    private final func sequenceToGroupDictionary<TSequence: SequenceType, TKey: Hashable>(
        sequence: TSequence,
        keySelector: TSequence.Generator.Element -> TKey
        ) -> Dictionary<TKey, Array<TSequence.Generator.Element>>
    {
        return sequenceToGroupDictionary(sequence, keySelector: keySelector) { $0 }
    }

    /**
    convert source to group dictionary

    :param: sequence - The target sequence
    :param: keySelector - A function to extract a key from each element
    :param: valueSelector - A transform function to produce a result element value from each element
    :returns: A Dictionary that contains values of Array<TValue>
    */
    private final func sequenceToGroupDictionary<TSequence: SequenceType, TKey: Hashable, TValue>(
        sequence: TSequence,
        keySelector: TSequence.Generator.Element -> TKey,
        valueSelector: TSequence.Generator.Element -> TValue
        ) -> Dictionary<TKey, Array<TValue>>
    {
        var dict = [TKey: [TValue]]()
        for element in sequence {
            var key = keySelector(element)
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
public protocol NumericType: Equatable, IntegerLiteralConvertible {
    func +(lhs: Self, rhs: Self) -> Self
    func +=(inout lhs: Self, rhs: Self)
    func -(lhs: Self, rhs: Self) -> Self
    func -=(inout lhs: Self, rhs: Self)
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

extension Grouping: SequenceType {
    typealias GeneratorType = Enumerable<TElement>.Generator
    public func generate() -> GeneratorType { return elements.generate() }
}

/**
Represents a collection of keys each mapped to one or more values
*/
public class Lookup<TKey: Hashable, TElement> {
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

    func contains(key: TKey) -> Bool {
        return data[key] != nil
    }
}

/**
Represents a sorted sequence
*/
public class OrderedEnumerable<T> : Enumerable<T>, SequenceType {

    public override func generate() -> GeneratorOf<T> {
        var array = Enumerable.from(source).toArray()
        sort(&array) {
            (a: T, b: T) in
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
        return GeneratorOf(array.generate())
    }

    public init<S: SequenceType where S.Generator.Element == T>(source: S, comparer: (T, T) -> Bool) {
        self.comparers = [comparer]
        super.init(source)
    }

    public init<S: SequenceType where S.Generator.Element == T>(source: S, comparers: Array<(T, T) -> Bool>) {
        self.comparers = comparers
        super.init(source)
    }

    private let comparers : Array<(T, T) -> Bool>

    /**
    Performs a subsequent ordering of the elements in a sequence in ascending order according to a key

    :param: keySelector - A function to extract a key from each element
    :returns: An OrderedEnumerable<T> whose elements are sorted according to a key
    */
    public final func thenBy<TKey: Comparable>(keySelector: T -> TKey) -> OrderedEnumerable<T> {
        var newComparers = comparers
        newComparers.append { keySelector($0) < keySelector($1) }
        return OrderedEnumerable(source: source, comparers: newComparers)
    }

    /**
    Performs a subsequent ordering of the elements in a sequence in descending order, according to a key

    :param: keySelector - A function to extract a key from each element
    :returns: An OrderedEnumerable<T> whose elements are sorted in descending order according to a key
    */
    public final func thenByDescending<TKey: Comparable>(keySelector: T -> TKey) -> OrderedEnumerable<T> {
        var newComparers = comparers
        newComparers.append { keySelector($0) > keySelector($1) }
        return OrderedEnumerable(source: source, comparers: newComparers)
    }

    /**
    Filters a sequence of values based on a predicate

    :param: predicate - A function to test each element for a condition
    :returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    public final override func where$(predicate: T -> Bool) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: Enumerable.from(source).where$(predicate), comparers: comparers)
    }

    /**
    Filters a sequence of values based on a predicate
    Each element's index is used in the logic of the predicate function

    :param: predicate - A function to test each element for a condition; the second parameter of the function represents the index of the source element
    :returns: An Enumerable<T> that contains elements from the input sequence that satisfy the condition
    */
    public final override func where$(predicate: (T, Int) -> Bool) -> OrderedEnumerable<T> {
        return OrderedEnumerable(source: Enumerable.from(source).where$(predicate), comparers: comparers)
    }
}
