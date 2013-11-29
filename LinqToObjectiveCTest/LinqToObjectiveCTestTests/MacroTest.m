//
//  MacroTest.m
//  LinqToObjectiveCTest
//
//  Created by Colin Eberhardt on 29/11/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "MacroTest.h"
#import "Person.h"
#import "NSArray+LinqExtensions.h"

@implementation MacroTest

- (NSArray*) createTestData
{
    return @[[Person personWithName:@"bob" age:@25],
             [Person personWithName:@"frank" age:@45],
             [Person personWithName:@"ian" age:@35],
             [Person personWithName:@"jim" age:@25],
             [Person personWithName:@"joe" age:@55]];
}

- (void)testSelect
{
    NSArray* input = [self createTestData];
    
    NSArray* names = [input linq_select:LINQSel(name)];
    
    STAssertEquals(names.count, 5U, nil);
    // 'spot' check a few values
    STAssertEquals(names[0], @"bob", nil);
    STAssertEquals(names[4], @"joe", nil);
}

- (void)testSelectCast
{
    NSArray* input = [self createTestData];
    
    NSArray* ages = [input linq_select:LINQSelUInt(intAge)];
    
    STAssertEquals(ages.count, 5U, nil);
    // 'spot' check a few values
    STAssertEqualObjects(ages[0], @25, nil);
    STAssertEqualObjects(ages[4], @55, nil);
}

- (void)testSelectViaKey
{
    NSArray* input = [self createTestData];
    
    NSArray* names = [input linq_select:LINQKey(name)];
    
    STAssertEquals(names.count, 5U, nil);
    // 'spot' check a few values
    STAssertEquals(names[0], @"bob", nil);
    STAssertEquals(names[4], @"joe", nil);
}

- (void)testSelectViaKeyPath
{
    NSArray* input = [self createTestData];
    
    NSArray* names = [input linq_select:LINQKeyPath(name)];
    
    STAssertEquals(names.count, 5U, nil);
    // 'spot' check a few values
    STAssertEquals(names[0], @"bob", nil);
    STAssertEquals(names[4], @"joe", nil);
}

@end
