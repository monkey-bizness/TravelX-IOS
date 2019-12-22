//
//  SqliteHelper.swift
//  TravelX
//
//  Created by Fawzi Bedidi on 12/22/19.
//  Copyright © 2019 Fawzi Bedidi. All rights reserved.
//

import Foundation
import SQLite3

class SqliteHelper {
    init() {
           db = openDatabase()
           createTable()
       }
    
    let dbPath: String = "myDb.sqlite"
    var db:OpaquePointer?
    
    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }

    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS photo(Id INTEGER PRIMARY KEY, localIdentifier TEXT, latitude DOUBLE, longitude DOUBLE, country TEXT, city TEXT, state TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("photo table created.")
            } else {
                print("photo table could not be created.")
            }
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertPhoto(photo : Photo) {
        let insertStatementString = "INSERT INTO photo (localIdentifier, latitude, longitude, country, city, state) VALUES(?, ?, ?, ?, ?, ?)";
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, photo.localIdentifier, -1, nil)
            sqlite3_bind_double(insertStatement, 2, photo.latitude)
            sqlite3_bind_double(insertStatement, 3, photo.longitude)
            sqlite3_bind_text(insertStatement, 4, photo.country, -1, nil)
            sqlite3_bind_text(insertStatement, 5, photo.city, -1, nil)
            sqlite3_bind_text(insertStatement, 6, photo.state, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
             print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func photoAlreadyExists(identifier: String) -> Bool {
        let queryStatementString = "SELECT * FROM photo WHERE localIdentifier = ?;"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(queryStatement, 1, identifier, -1, nil)
            let res = sqlite3_step(queryStatement) == SQLITE_ROW;
            sqlite3_finalize(queryStatement)
            return res;
        } else {
            print("SELECT statement could not be prepared")
            sqlite3_finalize(queryStatement)
            return true;
        }
//        print(sqlite3_finalize(queryStatement))
    }
    
    func getPhotos() -> Array<Photo> {
        let queryStatementString = "SELECT * FROM photo;"
        var queryStatement: OpaquePointer? = nil
        var psns : Array<Photo> = Array<Photo>();
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id =  String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let latitude = sqlite3_column_double(queryStatement, 2);
                let longitude = sqlite3_column_double(queryStatement, 3);
                let country =  String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                let city =  String(describing: String(cString: sqlite3_column_text(queryStatement, 5)))
                let state =  String(describing: String(cString: sqlite3_column_text(queryStatement, 6)))
                psns.append(Photo(id:id, lat:latitude, lng:longitude, country: country, state:state, city:city))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return psns
    }
}
