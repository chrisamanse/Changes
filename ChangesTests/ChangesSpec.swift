//
//  ChangesSpec.swift
//  Changes
//
//  Created by Chris Amanse on 1/21/16.
//  Copyright © 2016 Joe Christopher Paul Amanse. All rights reserved.
//

import Quick
import Nimble
import Changes

class ChangesSpec: QuickSpec {
    override func spec() {
        describe("Changes from an empty string") {
            let oldValue = ""
            
            it("should have insertions only") {
                expect("abcd".changesSince(oldValue)).to(
                    equal([Change.Insertion(element: "a", destination: 0),
                        Change.Insertion(element: "b", destination: 1),
                        Change.Insertion(element: "c", destination: 2),
                        Change.Insertion(element: "d", destination: 3)])
                )
            }
            
            describe("Change from empty string to empty string") {
                it("should be empty") {
                    expect("".changesSince(oldValue)).to(beEmpty())
                }
            }
        }
        
        describe("Changes to an empty string") {
            let newValue = ""
            
            it("should have insertions only") {
                expect(newValue.changesSince("abcd")).to(
                    equal([Change.Deletion(element: "a", destination: 0),
                        Change.Deletion(element: "b", destination: 1),
                        Change.Deletion(element: "c", destination: 2),
                        Change.Deletion(element: "d", destination: 3)])
                )
            }
            
            describe("Change from empty string to empty string") {
                it("should be empty") {
                    expect(newValue.changesSince("")).to(beEmpty())
                }
            }
        }
        
        describe("Totally different new value") {
            let oldValue = "abcd"
            let newValue = "ABCD"
            
            it("should have substitutions only") {
                expect(newValue.changesSince(oldValue)).to(
                    equal([Change.Substitution(element: "A", destination: 0),
                        Change.Substitution(element: "B", destination: 1),
                        Change.Substitution(element: "C", destination: 2),
                        Change.Substitution(element: "D", destination: 3)])
                )
            }
        }
        
        describe("Changes of kitten from sitting") {
            let oldValue = "sitting"
            let newValue = "kitten"
            
            it("should be have substitutions and deletions") {
                expect(newValue.changesSince(oldValue)).to(
                    equal([Change.Substitution(element: "k", destination: 0),
                        Change.Substitution(element: "e", destination: 4),
                        Change.Deletion(element: "g", destination: 6)])
                )
            }
        }
        
        describe("Move changes - backward") {
            let oldValue = [1,2,3,4,5]
            let newValue = [1,3,2,4]
            
            it("should have a move then a deletion") {
                expect(newValue.changesSince(oldValue)).to(
                    equal([Change.Move(element: 3, origin: 2, destination: 1),
                        Change.Deletion(element: 5, destination: 4)])
                )
            }
        }
        
        describe("Move changes - forward") {
            let oldValue = [1,2,3,4,5]
            let newValue = [1,2,4,5,3]
            
            it("should have a move then a deletion") {
                expect(newValue.changesSince(oldValue)).to(
                    equal([Change.Move(element: 3, origin: 2, destination: 4)])
                )
            }
        }
    }
}
