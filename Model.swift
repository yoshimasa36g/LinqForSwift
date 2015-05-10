//
//  Model.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/24.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Foundation
import CoreData

public class Model: NSManagedObject {

    @NSManaged public var someString: String
    @NSManaged public var someInt: NSNumber

}
