//
//  ChangeEqualitySpec.swift
//  ChangesTests
//
//  Created by Chris Amanse on 1/21/16.
//  Copyright © 2016 Joe Christopher Paul Amanse. All rights reserved.
//

import Quick
import Nimble
import Changes

class ChangeEqualitySpec: QuickSpec {
    override func spec() {
        describe("Insertion Change Equality") {
            let insertion = Change.Insertion(value: 1, destination: 0)
            
            it("should be equal to itself") {
                expect(insertion).to(equal(Change.Insertion(value: 1, destination: 0)))
            }
            
            it("should not be equal to other types") {
                expect(insertion).toNot(equal(Change.Deletion(value: 1, destination: 0)))
                expect(insertion).toNot(equal(Change.Substitution(value: 1, destination: 0)))
                expect(insertion).toNot(equal(Change.Move(value: 1, origin: 0, destination: 0)))
            }
            
            it("should not be equal to the same type with different arguments") {
                expect(insertion).toNot(equal(Change.Insertion(value: 0, destination: 0)))
                expect(insertion).toNot(equal(Change.Insertion(value: 0, destination: 1)))
                expect(insertion).toNot(equal(Change.Insertion(value: 1, destination: 1)))
            }
        }
        
        describe("Deletion Change Equality") {
            let deletion = Change.Deletion(value: 1, destination: 0)
            
            it("should be equal to itself") {
                expect(deletion).to(equal(Change.Deletion(value: 1, destination: 0)))
            }
            
            it("should not be equal to other types") {
                expect(deletion).toNot(equal(Change.Insertion(value: 1, destination: 0)))
                expect(deletion).toNot(equal(Change.Substitution(value: 1, destination: 0)))
                expect(deletion).toNot(equal(Change.Move(value: 1, origin: 0, destination: 0)))
            }
            
            it("should not be equal to the same type with different arguments") {
                expect(deletion).toNot(equal(Change.Deletion(value: 0, destination: 0)))
                expect(deletion).toNot(equal(Change.Deletion(value: 0, destination: 1)))
                expect(deletion).toNot(equal(Change.Deletion(value: 1, destination: 1)))
            }
        }
        
        describe("Substitution Change Equality") {
            let substitution = Change.Substitution(value: 1, destination: 0)
            
            it("should be equal to itself") {
                expect(substitution).to(equal(Change.Substitution(value: 1, destination: 0)))
            }
            
            it("should not be equal to other types") {
                expect(substitution).toNot(equal(Change.Insertion(value: 1, destination: 0)))
                expect(substitution).toNot(equal(Change.Deletion(value: 1, destination: 0)))
                expect(substitution).toNot(equal(Change.Move(value: 1, origin: 0, destination: 0)))
            }
            
            it("should not be equal to the same type with different arguments") {
                expect(substitution).toNot(equal(Change.Substitution(value: 0, destination: 0)))
                expect(substitution).toNot(equal(Change.Substitution(value: 0, destination: 1)))
                expect(substitution).toNot(equal(Change.Substitution(value: 1, destination: 1)))
            }
        }
        
        describe("Move Change Equality") {
            let move = Change.Move(value: 1, origin: 0, destination: 0)
            
            it("should be equal to itself") {
                expect(move).to(equal(Change.Move(value: 1, origin: 0, destination: 0)))
            }
            
            it("should not be equal to other types") {
                expect(move).toNot(equal(Change.Insertion(value: 0, destination: 0)))
                expect(move).toNot(equal(Change.Deletion(value: 0, destination: 0)))
                expect(move).toNot(equal(Change.Substitution(value: 0, destination: 0)))
            }
            
            it("should not be equal to the same type with different value") {
                expect(move).toNot(equal(Change.Move(value: 0, origin: 0, destination: 0)))
                expect(move).toNot(equal(Change.Move(value: 0, origin: 0, destination: 1)))
                expect(move).toNot(equal(Change.Move(value: 0, origin: 1, destination: 0)))
                expect(move).toNot(equal(Change.Move(value: 1, origin: 1, destination: 0)))
                expect(move).toNot(equal(Change.Move(value: 1, origin: 1, destination: 1)))
                expect(move).toNot(equal(Change.Move(value: 1, origin: 0, destination: 1)))
            }
        }
    }
}
