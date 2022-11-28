import Foundation
import GRDB

// MARK: - DataBaseServicing

public protocol DataBaseServicing {
  var dbAccessor: any DatabaseWriter { get }
}

public extension DataBaseServicing {
  @discardableResult
  func read<T>(_ block: (Database) throws -> T) throws -> T {
    try dbAccessor.read(block)
  }

  @discardableResult
  func write<T>(_ updates: (Database) throws -> T) throws -> T {
    try dbAccessor.write(updates)
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataBaseServicing {
  @discardableResult
  func read<T>(_ block: @Sendable @escaping (Database) throws -> T) async throws -> T {
    try await dbAccessor.read(block)
  }

  @discardableResult
  func write<T>(_ updates: @Sendable @escaping (Database) throws -> T) async throws -> T {
    try await dbAccessor.write(updates)
  }

  @discardableResult
  func insert<T>(_ element: T, compare: @escaping (T) -> some Hashable) -> Task<Void, Error> where T: MutablePersistableRecord & FetchableRecord {
    insert(contentsOf: [element], compare: compare)
  }

  @discardableResult
  func insert<T>(contentsOf elements: [T], compare: @escaping (T) -> some Hashable) -> Task<Void, Error> where T: MutablePersistableRecord & FetchableRecord {
    Task {
      try await insert(contentsOf: elements, compare: compare)
    }
  }

  func insert<T>(_ element: T, compare: @escaping (T) -> some Hashable) async throws where T: MutablePersistableRecord & FetchableRecord {
    try await insert(contentsOf: [element], compare: compare)
  }

  func insert<T>(contentsOf elements: [T], compare: @escaping (T) -> some Hashable) async throws where T: MutablePersistableRecord & FetchableRecord {
    try await write { db in
      let all = try T.fetchAll(db)
      let keys = Set(all.map(compare))

      let candidates = elements.filter { e in
        !keys.contains(compare(e))
      }

      for var record in candidates {
        try record.save(db)
      }
    }
  }

  @discardableResult
  func update<T>(_ element: T) -> Task<Void, Error> where T: MutablePersistableRecord {
    update(contentsOf: [element])
  }

  @discardableResult
  func update<T>(contentsOf elements: [T]) -> Task<Void, Error> where T: MutablePersistableRecord {
    Task {
      try await update(contentsOf: elements)
    }
  }

  func update<T>(_ element: T) async throws where T: MutablePersistableRecord {
    try await update(contentsOf: [element])
  }

  func update<T>(contentsOf elements: [T]) async throws where T: MutablePersistableRecord {
    try await write { db in
      for record in elements {
        try record.update(db)
      }
    }
  }

  @discardableResult
  func save<T>(_ element: T) -> Task<Void, Error> where T: MutablePersistableRecord {
    save(contentsOf: [element])
  }

  @discardableResult
  func save<T>(contentsOf elements: [T]) -> Task<Void, Error> where T: MutablePersistableRecord {
    Task {
      try await save(contentsOf: elements)
    }
  }

  func save<T>(_ element: T) async throws where T: MutablePersistableRecord {
    try await save(contentsOf: [element])
  }

  func save<T>(contentsOf elements: [T]) async throws where T: MutablePersistableRecord {
    try await write { db in
      for var record in elements {
        try record.save(db)
      }
    }
  }

  @discardableResult
  func delete<T>(_ element: T) -> Task<Void, Error> where T: MutablePersistableRecord {
    delete(contentsOf: [element])
  }

  @discardableResult
  func delete<T>(contentsOf elements: [T]) -> Task<Void, Error> where T: MutablePersistableRecord {
    Task {
      try await delete(contentsOf: elements)
    }
  }

  func delete<T>(_ element: T) async throws where T: MutablePersistableRecord {
    try await delete(contentsOf: [element])
  }

  func delete<T>(contentsOf elements: [T]) async throws where T: MutablePersistableRecord {
    try await write { db in
      try elements.forEach { element in
        try element.delete(db)
      }
    }
  }

  func values<T>(of type: T.Type, orderings: SQLOrderingTerm? = nil) -> AsyncValueObservation<[T]> where T: TableRecord & FetchableRecord {
    var requset = T.all()
    if let orderings = orderings {
      requset = requset.order(orderings)
    }
    return values(for: requset)
  }

  func values<T>(for request: QueryInterfaceRequest<T>) -> AsyncValueObservation<[T]> where T: FetchableRecord {
    ValueObservation.tracking { db in
      try request.fetchAll(db)
    }.values(in: dbAccessor)
  }

  func publisher<T>(of type: T.Type, orderings: SQLOrderingTerm? = nil) -> DatabasePublishers.Value<[T]> where T: TableRecord & FetchableRecord {
    var requset = T.all()
    if let orderings = orderings {
      requset = requset.order(orderings)
    }
    return publisher(for: requset)
  }

  func publisher<T>(for request: QueryInterfaceRequest<T>) -> DatabasePublishers.Value<[T]> where T: FetchableRecord {
    ValueObservation.tracking { db in
      try request.fetchAll(db)
    }.publisher(in: dbAccessor)
  }
}
