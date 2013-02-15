//
//  LinqToObjectiveCTests.m
//  LinqToObjectiveCTests
//
//  Created by Colin Eberhardt on 02/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "LinqToObjectiveCTests.h"
#import "Person.h"
#import "NSArray+LinqExtensions.h"

@implementation LinqToObjectiveCTests

- (NSArray*) createTestData
{
    return @[[Person personWithName:@"bob" age:@25],
    [Person personWithName:@"frank" age:@45],
    [Person personWithName:@"ian" age:@35],
    [Person personWithName:@"jim" age:@25],
    [Person personWithName:@"joe" age:@55]];
}

- (void)testWhere
{
    NSArray* input = [self createTestData];
    
    NSArray* peopleWhoAre25 = [input where:^BOOL(id person) {
        return [[person age] isEqualToNumber:@25];
    }];
    
    STAssertEquals(peopleWhoAre25.count, 2U, @"There should have been 2 items returned");
    STAssertEquals([peopleWhoAre25[0] name], @"bob", @"Bob is 25!");
    STAssertEquals([peopleWhoAre25[1] name], @"jim", @"Jim is 25!");
}

- (void)testSelect
{
    NSArray* input = [self createTestData];
    
    NSArray* names = [input select:^id(id person) {
        return [person name];
    }];
    
    STAssertEquals(names.count, 5U, nil);
    // 'spot' check a few values
    STAssertEquals(names[0], @"bob", nil);
    STAssertEquals(names[4], @"joe", nil);
}

- (void)testSort
{
    NSArray* input = @[@21, @34, @25];
    
    NSArray* sortedInput = [input sort];
    
    STAssertEquals(sortedInput.count, 3U, nil);
    STAssertEqualObjects(sortedInput[0], @21, nil);
    STAssertEqualObjects(sortedInput[1], @25, nil);
    STAssertEqualObjects(sortedInput[2], @34, nil);
}

- (void)testSortWithKeySelector
{
    NSArray* input = [self createTestData];
    
    NSArray* sortedByName = [input sort:^id(id person) {
        return [person name];
    }];
    
    STAssertEquals(sortedByName.count, 5U, nil);
    STAssertEquals([sortedByName[0] name], @"bob", nil);
    STAssertEquals([sortedByName[1] name], @"frank", nil);
    STAssertEquals([sortedByName[2] name], @"ian", nil);
    STAssertEquals([sortedByName[3] name], @"jim", nil);
    STAssertEquals([sortedByName[4] name], @"joe", nil);
}

- (void)testOfType
{
    NSArray* mixed = @[@"foo", @25, @"bar", @33];
    
    NSArray* strings = [mixed ofType:[NSString class]];
    
    STAssertEquals(strings.count, 2U, nil);
    STAssertEqualObjects(strings[0], @"foo", nil);
    STAssertEqualObjects(strings[1], @"bar", nil);
}

- (void)testSelectMany
{
    NSArray* data = @[@"foo, bar", @"fubar"];
    
    NSArray* components = [data selectMany:^id(id string) {
        return [string componentsSeparatedByString:@", "];
    }];
    
    STAssertEquals(components.count, 3U, nil);
    STAssertEqualObjects(components[0], @"foo", nil);
    STAssertEqualObjects(components[1], @"bar", nil);
    STAssertEqualObjects(components[2], @"fubar", nil);
}

- (void)testDistinct
{
    NSArray* names = @[@"bill", @"bob", @"bob", @"brian", @"bob"];
    
    NSArray* distinctNames = [names distinct];
    
    STAssertEquals(distinctNames.count, 3U, nil);
    STAssertEqualObjects(distinctNames[0], @"bill", nil);
    STAssertEqualObjects(distinctNames[1], @"bob", nil);
    STAssertEqualObjects(distinctNames[2], @"brian", nil);
}

- (void)testAggregate
{
    NSArray* names = @[@"bill", @"bob", @"brian"];
    
    id aggregate = [names aggregate:^id(id item, id aggregate) {
        return [NSString stringWithFormat:@"%@, %@", aggregate, item];
    }];
    
    STAssertEqualObjects(aggregate, @"bill, bob, brian", nil);
}

@end
