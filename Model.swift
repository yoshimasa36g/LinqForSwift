//
//  Model.swift
//  LinqForSwift
//
//  Created by Yoshimasa Aoki on 2015/04/24.
//  Copyright (c) 2015年 Yoshimasa Aoki. All rights reserved.
//

import Foundation
import CoreData

open class Model: NSManagedObject {

    @NSManaged open var someString: String
    @NSManaged open var someInt: NSNumber

}
