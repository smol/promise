//
//  ViewController.swift
//  Promise
//
//  Created by BigInt on 08/08/2017.
//  Copyright © 2017 BigInt. All rights reserved.
//

import UIKit

class ModelObject {
	var id : Int
	
	init(_ id : Int) {
		self.id = id
		print("INIT \(self.id)")
	}
	
	deinit {
		print("DEINIT \(self.id)")
	}
}

class RetainedObject {
	var objects : [ModelObject]
	
	init(count : Int) {
		self.objects = [];
		
		print("COUNT \(count)")
		autoreleasepool {
			for i in 0..<count {
				self.objects.append(ModelObject(i))
			}
		}
	}
	
	deinit {
		self.objects.removeAll()
		self.objects = []
		
		print("DEINIT RETAINED OBJECT")
	}
}

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
//		RetainedObject(count: Int(arc4random_uniform(50)))
		
		let _ = self.populate().then { (object : RetainedObject) -> Int in
			for prime in object.objects {
				print("ID \(prime.id)")
				usleep(1)
			}
			
			return 10
		}.then { (value : Int) in
			print("RETURN \(value)")
		}
		
		
		
//		self.populate().then({ [unowned self] (object) -> Void in
//
//		})
		
		
	}
	
	func populate() -> Promise {
		let deferred : Deferred = Deferred()
		let promise : Promise = deferred.promise
		
		DispatchQueue.global().async {
			
			usleep(10)
			deferred.resolve(RetainedObject(count: Int(arc4random_uniform(50))))
		}
		
		
		return promise;
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

