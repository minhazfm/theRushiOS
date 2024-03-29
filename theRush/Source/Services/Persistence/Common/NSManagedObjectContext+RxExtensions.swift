//
//  NSManagedObjectContext+RxExtensions.swift
//  theRush
//
//  Created by Minhaz Mohammad on 8/29/19.
//  Copyright © 2019 SMPL Inc. All rights reserved.
//

import CoreData
import Foundation
import RxSwift

extension NSManagedObjectContext {
    
    func create<T: NSFetchRequestResult>() -> T {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: self) as? T else {
            fatalError()
        }
        return entity
    }
    
}

extension Reactive where Base: NSManagedObjectContext {
    
    /**
     Executes a fetch request and returns the fetched objects as an `Observable` array of `NSManagedObjects`.
     - parameter fetchRequest: an instance of `NSFetchRequest` to describe the search criteria used to retrieve data from a persistent store
     - parameter sectionNameKeyPath: the key path on the fetched objects used to determine the section they belong to; defaults to `nil`
     - parameter cacheName: the name of the file used to cache section information; defaults to `nil`
     - returns: An `Observable` array of `NSManagedObjects` objects that can be bound to a table view.
     */
    func entities<T: NSFetchRequestResult>(fetchRequest: NSFetchRequest<T>, sectionNameKeyPath: String? = nil, cacheName: String? = nil) -> Observable<[T]> {
        return Observable.create { observer in
            
            let observerAdapter = FetchedResultsControllerEntityObserver(observer: observer,
                                                                         fetchRequest: fetchRequest,
                                                                         managedObjectContext: self.base,
                                                                         sectionNameKeyPath: sectionNameKeyPath,
                                                                         cacheName: cacheName)
            
            return Disposables.create {
                observerAdapter.dispose()
            }
        }
    }
    
    func save() -> Observable<Void> {
        return Observable.create { observer in
            do {
                try self.base.save()
                observer.onNext(())
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func delete<T: NSManagedObject>(entity: T) -> Observable<Void> {
        return Observable.create { observer in
            self.base.delete(entity)
            observer.onNext(())
            return Disposables.create()
            }.flatMapLatest {
                self.save()
        }
    }
    
    func deleteWithoutSave<T: NSManagedObject>(entity: T) -> Observable<Void> {
        return Observable.create { observer in
            self.base.delete(entity)
            observer.onNext(())
            return Disposables.create()
        }
    }
    
    func first<T: NSFetchRequestResult>(ofType: T.Type = T.self, with predicate: NSPredicate?) -> Observable<T?> {
        return Observable.deferred {
            let entityName = String(describing: T.self)
            let request = NSFetchRequest<T>(entityName: entityName)
            request.predicate = predicate
            do {
                let result = try self.base.fetch(request).first
                return Observable.just(result)
            } catch {
                return Observable.error(error)
            }
        }
    }
    
    func sync<C: CoreDataRepresentable, P: Persistable>(entity: C, update: @escaping (P) -> Void) -> Observable<P> {
        let predicate: NSPredicate? = entity.id != -1 ? NSPredicate(format: "id == %d", entity.id) : nil
        return first(ofType: P.self, with: predicate)
            .flatMap { obj -> Observable<P> in
                let object = obj ?? self.base.create()
                update(object)
                return Observable.just(object)
        }
    }
    
}
