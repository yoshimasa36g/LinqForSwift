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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func examples() {
        class Person {
            var name: String
            var age: Int
            var gender: Gender
            init(name: String, age: Int, gender: Gender) {
                self.name = name
                self.age = age
                self.gender = gender
            }
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
            println(male.name)
        }
        // females
        for female in result2[.female] {
            println(female.name)
        }
        // others
        for other in result2[.other] {
            println(other.name)
        }
    }
}

