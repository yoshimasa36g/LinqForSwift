//
//  CoreDataSetSpec.swift
//  LinqForSwiftTests
//
//  Created by Yoshimasa Aoki on 2015/04/17.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Quick
import Nimble
import UIKit
import CoreData
import LinqForSwift

class CoreDataSetSpec: QuickSpec {
    
    override func spec() {
        
        generateTestData()
        
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let models = CoreDataSet<Model>(appDelegate.managedObjectContext!)
        
        describe("toEnumerable") {
            it("is execute fetch request and convert result to Enumerable") {
                let result: Enumerable<Model> = models.toEnumerable()
                expect(result.count()).to(equal(5))
                expect(result.any { $0.someString == "AAA" }).to(beTrue())
                expect(result.any { $0.someString == "BBB" }).to(beTrue())
                expect(result.any { $0.someString == "CCC" }).to(beTrue())
                expect(result.any { $0.someString == "DDD" }).to(beTrue())
                expect(result.any { $0.someString == "EEE" }).to(beTrue())
            }
        }
        
        describe("where$") {
            it("is filters a CoreData of values based on a predicate") {
                let result: Enumerable<Model> = models
                    .where$(format: "%K > %d", "someInt", 200)
                    .where$(format: "%K = %@ || %K = %@", "someString", "CCC", "someString", "EEE")
                    .toEnumerable()
                expect(result.count()).to(equal(2))
                expect(result.any { $0.someString == "CCC" }).to(beTrue())
                expect(result.any { $0.someString == "EEE" }).to(beTrue())
            }
        }
        
        describe("orderBy") {
            it("is add order by ascending") {
                let result: Enumerable<Model> = models
                    .where$(format: "%K > %d", "someInt", 200)
                    .orderBy("someString")
                    .toEnumerable()
                expect(result.count()).to(equal(3))
                expect(result.first()!.someString).to(equal("CCC"))
            }
        }
        
        describe("orderByDescending") {
            it("is add order by descending") {
                let result: Enumerable<Model> = models
                    .where$(format: "%K > %d", "someInt", 200)
                    .orderByDescending("someString")
                    .toEnumerable()
                expect(result.count()).to(equal(3))
                expect(result.first()!.someString).to(equal("EEE"))
            }
        }
        
        describe("skip") {
            it("is set skip count") {
                let result: Enumerable<Model> = models.orderBy("someInt").skip(3).toEnumerable()
                expect(result.count()).to(equal(2))
                expect(result.first()!.someInt).to(equal(400))
            }
        }
        
        describe("take") {
            it("is set take count") {
                let result: Enumerable<Model> = models.orderBy("someInt").skip(2).take(1).toEnumerable()
                expect(result.count()).to(equal(1))
                expect(result.first()!.someInt).to(equal(300))
            }
        }
        
        describe("toArray") {
            it("is execute fetch request and convert result to Array") {
                let result: [Model] = models.orderBy("someString").toArray()
                expect(result.count).to(equal(5))
                expect(result[0].someString == "AAA").to(beTrue())
                expect(result[1].someString == "BBB").to(beTrue())
                expect(result[2].someString == "CCC").to(beTrue())
                expect(result[3].someString == "DDD").to(beTrue())
                expect(result[4].someString == "EEE").to(beTrue())
            }
        }
    }
    
    func generateTestData() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let managedObjectContext: NSManagedObjectContext = appDelegate.managedObjectContext {

            let entity: NSEntityDescription? = NSEntityDescription.entityForName("Model", inManagedObjectContext: managedObjectContext)
            let fetchRequest: NSFetchRequest = NSFetchRequest()
            fetchRequest.entity = entity
            var error: NSError? = nil
            var existsTestData: Bool = false
            if var results: [AnyObject] = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) {
                for m: AnyObject in results {
                    let model: Model = m as! Model
                    println("test data: \(model.someString), \(model.someInt)")
                    existsTestData = true
                }
            }
            if existsTestData {
                return
            }
            
            for data in [("AAA", 100), ("BBB", 200), ("CCC", 300), ("DDD", 400), ("EEE", 500)] {
                let entity: NSEntityDescription? = NSEntityDescription.entityForName("Model", inManagedObjectContext: managedObjectContext)
                let model: Model = Model(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
                model.someString = data.0
                model.someInt = data.1
            }
            appDelegate.saveContext()
        }
    }
}
