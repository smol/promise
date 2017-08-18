//
//  Promise.swift
//  Promise
//
//  Created by BigInt on 08/08/2017.
//  Copyright © 2017 BigInt. All rights reserved.
//

import Foundation

//protocol PromiseProtocol {
//	func duplicate<U : Any>(promise: Promise<U>)
//}
//
//class StackPromiseCallbacks<T> {
//	var successCallback: (_ data: T) -> Any?
//	var errorCallback: ((_ data: T?, _ statusCode: Int) -> Any?)?
//	
//	init() {
//		self.errorCallback = nil
//		self.successCallback = {_ -> Void in}
//		print("INIT CALLBACKS")
//	}
//	
//	deinit {
//		print("DEINIT CALLBACKS")
//	}
//}



public class Deferred {
	let promise : Promise
	
	private(set) var isResolved : Bool = false
	private(set) var isRejected : Bool = false
	
	init() {
		self.promise = Promise()
	}
	
	
	public func resolve<T : Any>(_ value : T) {
		var value = value
		
		
		let _ : Void? = self.promise.success(value: &value)
	}
	
	public func reject() {
		
	}
}

typealias successThen<T : Any, U : Any> = ((_ value : T) -> U)

fileprivate protocol ThenCallbacksProtocol {
	func getValue() -> Any
	func getReturned() -> Any
	func getSuccess() -> (_ value : Any) -> Any
}

fileprivate class ThenCallbacks<T : Any, U : Any> {
	private var success : (_ value : T) -> U

	var value : T? = nil
	var returned : U? = nil
	
	init(success : @escaping successThen<T, U>) {
		self.success = success
	}
	
	func getValue() -> T? {
		return self.value
	}
	
	func getReturned() -> U? {
		return self.returned
	}
	
	func getSuccess() -> (_ value : T) -> U {
		return self.success
	}
}

class Promise {
	private var callbacks : Unmanaged<AnyObject>? = nil
	private var next : Promise? = nil
	private var valueType : Any.Type = Void.self
	private var returnedType : Any.Type = Void.self

	init() {
		
	}
	
	func success<T: Any, U : Any>(value : inout T) -> U? {
		let callbacks = self.callbacks?.takeRetainedValue() as? ThenCallbacksProtocol
		if callbacks != nil {
			var temp : Any? = callbacks?.getSuccess()(callbacks!.getReturned())
			return self.next?.success(value: &temp)
		}
//		if callbacks?.success != nil {
//			var temp : U = callbacks!.success(value)
//
//		}
		
		
		print("\(T.self), \(U.self), \(self.valueType), \(self.returnedType)")
		if let result : Any = self.next?.success(value: &value) {
			return result as? U
		}
		
		return nil
//		return callbacks(value)
	}
	
	public func then<T : Any, U : Any>(success : @escaping successThen<T, U>) -> Promise {
		self.next = Promise()
		self.returnedType = U.self
		self.valueType = T.self

		let temp = ThenCallbacks<T, U>(success: success)
		
		self.next?.callbacks = Unmanaged<AnyObject>.passRetained(temp as AnyObject)
		
		return self.next!
	}
	
	
}


//public class Promise : PromiseProtocol {
//	private var stack: [StackPromiseCallbacks<T>]
//	
//	private var isResolved: Bool
//	private var isRejected: Bool
//	
//	private var tempData: T? = nil
//	private var tempStatusCode: Int = 0
//	private weak var parent : Promise<T>? = nil
//	
//	private var children : [Promise<T>] = []
//	private var index : Int = -1
//	
//	public init(){
//		self.stack = []
//		self.isResolved = false
//		self.isRejected = false
//	}
//	
//	deinit {
//		self.tempData = nil
//		self.parent = nil
//		self.children.removeAll()
//		self.stack.removeAll()
//	}
//	
//	public func resolve(with data: T){
//		self.isResolved = true
//		self.isRejected = false
//		
//		self.tempData = data
//		
//		self.callSuccesses(data)
//	}
//	
//	public func reject(with data: T?, statusCode: Int){
//		self.isResolved = false
//		self.isRejected = true
//		
//		self.tempData = data
//		self.tempStatusCode = statusCode
//		
//		self.callRejects(data, statusCode)
//	}
//	
//	private func callSuccesses(_ data: T){
//		if self.stack.count > 0 && self.children.count == 0 {
//			let returned : Any? = self.stack.removeFirst().successCallback(data)
//			
//			if returned == nil {
//				self.callSuccesses(data)
//			} else if let promise : PromiseProtocol = returned as? PromiseProtocol {
//				promise.duplicate(promise: self)
//				//				self.stack.removeAll()
//			} else if let json : T = returned as? T {
//				self.callSuccesses(json)
//			}
//		} else {
//			if self.index > -1 {
//				self.parent?.children.remove(at: self.index)
//			}
//			
//			self.parent?.callSuccesses(data)
//		}
//		
//		
//	}
//	
//	private func callRejects(_ data: T?, _ statusCode: Int){
//		if self.stack.count > 0 {
//			let returned : Any? = self.stack.removeFirst().errorCallback?(data, statusCode)
//			
//			if returned == nil {
//				self.callRejects(data, statusCode)
//			} else if let promise : PromiseProtocol = returned as? PromiseProtocol {
//				promise.duplicate(promise: self)
//			} else if let json : T = returned as? T {
//				self.callRejects(json, statusCode)
//			}
//		} else {
//			if self.index > -1 {
//				self.parent?.children.remove(at: self.index)
//			}
//			
//			self.parent?.callRejects(data, statusCode)
//		}
//	}
//	
//	internal func duplicate<U : Any>(promise: Promise<U>){
//		self.parent = promise as? Promise<T>
//		self.index = self.parent?.children.count ?? -1
//		self.parent?.children.append(self)
//		
//		//		self.stack = promise.stack as! [(successCallback: (_ data: T) -> Any?, errorCallback: ((_ data: T?, _ statusCode: Int) -> Any?)?)]
//		
//		if self.isResolved && self.tempData != nil {
//			self.callSuccesses(self.tempData!)
//		} else if self.isRejected {
//			self.callRejects(self.tempData ?? nil, self.tempStatusCode)
//		}
//	}
//	
//	@discardableResult public func then(_ successCallback : @escaping (_ data: T) -> Any?,_ errorCallback: ((_ data: T?, _ statusCode: Int) -> Any?)? = nil) -> Promise {
//		let callbacks = StackPromiseCallbacks<T>()
//		callbacks.successCallback = successCallback
//		callbacks.errorCallback = errorCallback
//		
//		self.stack.append(callbacks)
//		
//		if self.isRejected {
//			self.callRejects(self.tempData, self.tempStatusCode)
//		} else if self.isResolved {
//			self.callSuccesses(self.tempData!)
//		}
//		
//		return self
//	}
//}
