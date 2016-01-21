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
                    equal([Change.Insertion(value: "a", destination: 0),
                        Change.Insertion(value: "b", destination: 1),
                        Change.Insertion(value: "c", destination: 2),
                        Change.Insertion(value: "d", destination: 3)])
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
                    equal([Change.Deletion(value: "a", destination: 0),
                        Change.Deletion(value: "b", destination: 1),
                        Change.Deletion(value: "c", destination: 2),
                        Change.Deletion(value: "d", destination: 3)])
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
                    equal([Change.Substitution(value: "A", destination: 0),
                        Change.Substitution(value: "B", destination: 1),
                        Change.Substitution(value: "C", destination: 2),
                        Change.Substitution(value: "D", destination: 3)])
                )
            }
        }
        
        describe("Changes of kitten from sitting") {
            let oldValue = "sitting"
            let newValue = "kitten"
            
            it("should be have substitutions and deletions") {
                expect(newValue.changesSince(oldValue)).to(
                    equal([Change.Substitution(value: "k", destination: 0),
                        Change.Substitution(value: "e", destination: 4),
                        Change.Deletion(value: "g", destination: 6)])
                )
            }
        }
    }
}
