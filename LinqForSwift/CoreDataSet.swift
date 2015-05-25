//
//  CoreDataSet.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/17.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import UIKit
import CoreData

/**
Provides a set of methods for querying objects that implement NSManagedObject
*/
@availability(iOS, introduced=3.0)
public class CoreDataSet<T: NSManagedObject> {
    private let context: NSManagedObjectContext
    private var predicates: [NSPredicate]
    private var sorts: [NSSortDescriptor]
    private var take: Int
    private var skip: Int
    
    /**
    Creates a CoreDataSet
    
    :param: context - The NSManagedObjectContext
    */
    init(_ context: NSManagedObjectContext) {
        self.context = context
        predicates = []
        sorts = []
        take = 0
        skip = 0
    }
    
    /**
    Creates a new CoreDataSet
    
    :param: new - The new CoreDataSEt
    */
    private init(_ new: CoreDataSet<T>) {
        self.context = new.context
        predicates = new.predicates
        sorts = new.sorts
        take = new.take
        skip = new.skip
    }
    
    /**
    Sorts the elements of a sequence in ascending order according to a key
    
    :param: fieldName - A fieldName for NSSortDescriptor
    :returns: A CoreDataSet that added the sort order condition
    */
    public final func orderBy(fieldName: String) -> CoreDataSet {
        return addSortDescriptor(NSSortDescriptor(key: fieldName, ascending: true))
    }
    
    /**
    Sorts the elements of a sequence in ascending order according to a key
    
    :param: fieldName - A fieldName for NSSortDescriptor
    :param: comparator - A comparator for NSSortDescriptor
    :returns: A CoreDataSet that added the sort order condition
    */
    public final func orderBy(fieldName: String, comparator: NSComparator) -> CoreDataSet {
        return addSortDescriptor(NSSortDescriptor(key: fieldName, ascending: true, comparator: comparator))
    }
    
    /**
    Sorts the elements of a sequence in ascending order according to a key
    
    :param: fieldName - A fieldName for NSSortDescriptor
    :param: selector - A selector for NSSortDescriptor
    :returns: A CoreDataSet that added the sort order condition
    */
    public final func orderBy(fieldName: String, selector: Selector) -> CoreDataSet {
        return addSortDescriptor(NSSortDescriptor(key: fieldName, ascending: true, selector: selector))
    }
    
    /**
    Sorts the elements of a sequence in descending order according to a key
    
    :param: fieldName - A fieldName for NSSortDescriptor
    :returns: A CoreDataSet that added the sort order condition
    */
    public final func orderByDescending(fieldName: String) -> CoreDataSet {
        return addSortDescriptor(NSSortDescriptor(key: fieldName, ascending: false))
    }
    
    /**
    Sorts the elements of a sequence in descending order according to a key
    
    :param: fieldName - A fieldName for NSSortDescriptor
    :param: comparator - A comparator for NSSortDescriptor
    :returns: A CoreDataSet that added the sort order condition
    */
    public final func orderByDescending(fieldName: String, comparator: NSComparator) -> CoreDataSet {
        return addSortDescriptor(NSSortDescriptor(key: fieldName, ascending: false, comparator: comparator))
    }
    
    /**
    Sorts the elements of a sequence in descending order according to a key
    
    :param: fieldName - A fieldName for NSSortDescriptor
    :param: selector - A selector for NSSortDescriptor
    :returns: A CoreDataSet that added the sort order condition
    */
    public final func orderByDescending(fieldName: String, selector: Selector) -> CoreDataSet {
        return addSortDescriptor(NSSortDescriptor(key: fieldName, ascending: false, selector: selector))
    }
    
    /**
    Bypasses a specified number of elements in a sequence and then returns the remaining elements
    
    :param: count - A number of elements to skip before returning the remaining elements
    :returns: A CoreDataSet that added the skip condition
    */
    public final func skip(count: Int) -> CoreDataSet {
        let new = CoreDataSet(self)
        new.skip = count
        return new
    }
    
    /**
    Returns a specified number of contiguous elements from the start of a sequence
    
    :param: count - A number of elements to return
    :returns: A CoreDataSet that added the take condition
    */
    public final func take(count: Int) -> CoreDataSet {
        let new = CoreDataSet(self)
        new.take = count
        return new
    }
    
    /**
    Execute fetch request and convert result to Array<T>
    
    :returns: An array that contains the result of fetch request
    */
    public final func toArray() -> [T] {
        let entity = NSEntityDescription.entityForName(T.getName(), inManagedObjectContext: context)
        var request = NSFetchRequest()
        request.entity = entity
        request.sortDescriptors = sorts
        request.fetchOffset = skip
        request.fetchLimit = take
        if predicates.count > 1 {
            request.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        } else if predicates.count == 1 {
            request.predicate = predicates[0]
        }
        var error: NSError? = nil
        
        if let result = context.executeFetchRequest(request, error: &error) {
            return result as! [T]
        }
        println(error?.description)
        return []
    }
    
    /**
    Execute fetch request and convert result to Enumerable<T>
    
    :returns: An Enumerable<T> that contains the result of fetch request
    */
    public final func toEnumerable() -> Enumerable<T> {
        return Enumerable.from(toArray())
    }
    
    /**
    Filters a sequence of values based on a NSPredicate
    
    :param: format - A predicate format for NSPredicate
    :param: args - Some arguments of CVarArgType for NSPredicate
    :returns: A CoreDataSet that added the predicate
    */
    public final func where$(format predicateFormat: String, _ args: CVarArgType...) -> CoreDataSet {
        let anyArgs = args.map { $0 as! AnyObject }
        return addPredicate(NSPredicate(format: predicateFormat, argumentArray: anyArgs))
    }
    
    /**
    Filters a sequence of values based on a NSPredicate
    
    :param: format - A predicate format for NSPredicate
    :param: argumentArray - An argument array for NSPredicate
    :returns: A CoreDataSet that added the predicate
    */
    public final func where$(format predicateFormat: String, argumentArray arguments: [AnyObject]?) -> CoreDataSet {
        return addPredicate(NSPredicate(format: predicateFormat, argumentArray: arguments))
    }
    
    /**
    Filters a sequence of values based on a NSPredicate
    
    :param: format - A predicate format for NSPredicate
    :param: arguments - An CVaListPointer of argument list for NSPredicate
    :returns: A CoreDataSet that added the predicate
    */
    public final func where$(format predicateFormat: String, arguments argList: CVaListPointer) -> CoreDataSet {
        return addPredicate(NSPredicate(format: predicateFormat, arguments: argList))
    }
    
    /**
    Filters a sequence of values based on a NSPredicate
    
    :param: value - A boolean value for NSPredicate
    :returns: A CoreDataSet that added the predicate
    */
    public final func where$(value: Bool) -> CoreDataSet {
        return addPredicate(NSPredicate(value: value))
    }
    
    /**
    Filters a sequence of values based on a NSPredicate
    
    :param: block - A predicate block for NSPredicate
    :returns: A CoreDataSet that added the predicate
    */
    @availability(iOS, introduced=4.0)
    public final func Where(block: (AnyObject!, [NSObject : AnyObject]!) -> Bool) -> CoreDataSet {
        return addPredicate(NSPredicate(block: block))
    }
    
    /**
    Add predicate to condition of fetch request
    
    :param: predicate - A NSPredicate object
    :returns: A CoreDataSet that added the predicate
    */
    private final func addPredicate(predicate: NSPredicate) -> CoreDataSet {
        let new = CoreDataSet(self)
        new.predicates.append(predicate)
        return new
    }
    
    /**
    Add sort descriptor to condition of fetch request
    
    :param: sortDescriptor - A NSSortDescriptor object
    :returns: A CoreDataSet that added the sort descriptor
    */
    private final func addSortDescriptor(sortDescriptor: NSSortDescriptor) -> CoreDataSet {
        let new = CoreDataSet(self)
        new.sorts.append(sortDescriptor)
        return new
    }
}

public extension NSManagedObject {
    
    /**
    Get class name
    
    :returns: A class name
    */
    public class func getName() -> String {
        var name = NSStringFromClass(self)
        var range = name.rangeOfString(".")
        return name.substringFromIndex(range!.endIndex)
    }
}