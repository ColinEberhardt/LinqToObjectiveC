//
//  LinqToObjectiveCTests.m
//  LinqToObjectiveCTests
//
//  Created by Colin Eberhardt on 02/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSArrayLinqExtensionsTest.h"
#import "Person.h"
#import "NSArray+LinqExtensions.h"

@implementation NSArrayLinqExtensionsTest

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
    
    NSArray* peopleWhoAre25 = [input qeWhere:^BOOL(id person) {
        return [[person age] isEqualToNumber:@25];
    }];
    
    STAssertEquals(peopleWhoAre25.count, 2U, @"There should have been 2 items returned");
    STAssertEquals([peopleWhoAre25[0] name], @"bob", @"Bob is 25!");
    STAssertEquals([peopleWhoAre25[1] name], @"jim", @"Jim is 25!");
}

- (void)testSelect
{
    NSArray* input = [self createTestData];
    
    NSArray* names = [input qeSelect:^id(id person) {
        return [person name];
    }];
    
    STAssertEquals(names.count, 5U, nil);
    // 'spot' check a few values
    STAssertEquals(names[0], @"bob", nil);
    STAssertEquals(names[4], @"joe", nil);
}

- (void)testSelectWithNil
{
    NSArray* input = [self createTestData];
    
    NSArray* names = [input qeSelect:^id(id person) {
        return [[person name] isEqualToString:@"bob"] ? nil : [person name];
    }];
    
    STAssertEquals(names.count, 5U, nil);
    // 'spot' check a few values
    STAssertEquals(names[0], [NSNull null], nil);
    STAssertEquals(names[4], @"joe", nil);
}

- (void)testSort
{
    NSArray* input = @[@21, @34, @25];
    
    NSArray* sortedInput = [input qeSort];
    
    STAssertEquals(sortedInput.count, 3U, nil);
    STAssertEqualObjects(sortedInput[0], @21, nil);
    STAssertEqualObjects(sortedInput[1], @25, nil);
    STAssertEqualObjects(sortedInput[2], @34, nil);
}

- (void)testSortWithKeySelector
{
    NSArray* input = [self createTestData];
    
    NSArray* sortedByName = [input qeSort:^id(id person) {
        return [person name];
    }];
    
    STAssertEquals(sortedByName.count, 5U, nil);
    STAssertEquals([sortedByName[0] name], @"bob", nil);
    STAssertEquals([sortedByName[1] name], @"frank", nil);
    STAssertEquals([sortedByName[2] name], @"ian", nil);
    STAssertEquals([sortedByName[3] name], @"jim", nil);
    STAssertEquals([sortedByName[4] name], @"joe", nil);
}

- (void)testSortWithKeySelectorWithNil
{
    NSArray* input = [self createTestData];
    
    NSArray* sortedByName = [input qeSort:^id(id person) {
        return [[person name] isEqualToString:@"bob"] ? nil : [person name];

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
    
    NSArray* strings = [mixed qeOfType:[NSString class]];
    
    STAssertEquals(strings.count, 2U, nil);
    STAssertEqualObjects(strings[0], @"foo", nil);
    STAssertEqualObjects(strings[1], @"bar", nil);
}

- (void)testSelectMany
{
    NSArray* data = @[@"foo, bar", @"fubar"];
    
    NSArray* components = [data qeSelectMany:^id(id string) {
        return [string componentsSeparatedByString:@", "];
    }];
    
    STAssertEquals(components.count, 3U, nil);
    STAssertEqualObjects(components[0], @"foo", nil);
    STAssertEqualObjects(components[1], @"bar", nil);
    STAssertEqualObjects(components[2], @"fubar", nil);
}

- (void)testDistinctWithKeySelector
{
    NSArray* input = [self createTestData];
    
    NSArray* peopelWithUniqueAges = [input qeDistinct:^id(id person) {
        return [person age];
    }];
    
    STAssertEquals(peopelWithUniqueAges.count, 4U, nil);
    STAssertEquals([peopelWithUniqueAges[0] name], @"bob", nil);
    STAssertEquals([peopelWithUniqueAges[1] name], @"frank", nil);
    STAssertEquals([peopelWithUniqueAges[2] name], @"ian", nil);
    STAssertEquals([peopelWithUniqueAges[3] name], @"joe", nil);
}

- (void)testDistinctWithKeySelectorWithNil
{
    NSArray* input = [self createTestData];
    
    NSArray* peopelWithUniqueAges = [input qeDistinct:^id(id person) {
        return [[person age] isEqualToNumber:@25] ? nil : [person age];
    }];
    
    STAssertEquals(peopelWithUniqueAges.count, 4U, nil);
    STAssertEquals([peopelWithUniqueAges[0] name], @"bob", nil);
    STAssertEquals([peopelWithUniqueAges[1] name], @"frank", nil);
    STAssertEquals([peopelWithUniqueAges[2] name], @"ian", nil);
    STAssertEquals([peopelWithUniqueAges[3] name], @"joe", nil);
}

- (void)testDistinct
{
    NSArray* names = @[@"bill", @"bob", @"bob", @"brian", @"bob"];
    
    NSArray* distinctNames = [names qeDistinct];
    
    STAssertEquals(distinctNames.count, 3U, nil);
    STAssertEqualObjects(distinctNames[0], @"bill", nil);
    STAssertEqualObjects(distinctNames[1], @"bob", nil);
    STAssertEqualObjects(distinctNames[2], @"brian", nil);
}


- (void)testAggregate
{
    NSArray* names = @[@"bill", @"bob", @"brian"];
    
    id csv = [names qeAggregate:^id(id item, id aggregate) {
        return [NSString stringWithFormat:@"%@, %@", aggregate, item];
    }];
    
    STAssertEqualObjects(csv, @"bill, bob, brian", nil);
    
    NSArray* numbers = @[@22, @45, @33];
    
    id biggestNumber = [numbers qeAggregate:^id(id item, id aggregate) {
        return [item compare:aggregate] == NSOrderedDescending ? item : aggregate;
    }];
    
    STAssertEqualObjects(biggestNumber, @45, nil);
}

- (void)testFirstOrNil
{
    NSArray* input = [self createTestData];
    NSArray* emptyArray = @[];
    
    STAssertNil([emptyArray qeFirstOrNil], nil);
    STAssertEquals([[input qeFirstOrNil] name], @"bob", nil);
}

- (void)testLastOrNil
{
    NSArray* input = [self createTestData];
    NSArray* emptyArray = @[];
    
    STAssertNil([emptyArray qeLastOrNil], nil);
    STAssertEquals([[input qeLastOrNil] name], @"joe", nil);
}

- (void)testTake
{
    NSArray* input = [self createTestData];
    
    STAssertEquals([input qeTake:0].count, 0U, nil);
    STAssertEquals([input qeTake:5].count, 5U, nil);
    STAssertEquals([input qeTake:50].count, 5U, nil);
    STAssertEquals([[input qeTake:2][0] name], @"bob", nil);
}

- (void)testSkip
{
    NSArray* input = [self createTestData];
    
    STAssertEquals([input qeSkip:0].count, 5U, nil);
    STAssertEquals([input qeSkip:5].count, 0U, nil);
    STAssertEquals([[input qeSkip:2][0] name], @"ian", nil);
}


- (void)testAny
{
    NSArray* input = @[@25, @44, @36];
    
    STAssertFalse([input qeAny:^BOOL(id item) {
        return [item isEqualToNumber:@33];
    }], nil);
    
    STAssertTrue([input qeAny:^BOOL(id item) {
        return [item isEqualToNumber:@25];
    }], nil);
}

- (void)testAll
{
    NSArray* input = @[@25, @25, @25];
    
    STAssertFalse([input qeAll:^BOOL(id item) {
        return [item isEqualToNumber:@33];
    }], nil);
    
    STAssertTrue([input qeAll:^BOOL(id item) {
        return [item isEqualToNumber:@25];
    }], nil);
}

- (void)testGroupBy
{
    NSArray* input = @[@"James", @"Jim", @"Bob"];
    
    NSDictionary* groupedByFirstLetter = [input qeGroupBy:^id(id name) {
        return [name substringToIndex:1];
    }];
    
    STAssertEquals(groupedByFirstLetter.count, 2U, nil);
    
    // test the group keys
    NSArray* keys = [groupedByFirstLetter allKeys];
    STAssertEqualObjects(@"J", keys[0], nil);
    STAssertEqualObjects(@"B", keys[1], nil);
    
    // test that the correct items are in each group
    NSArray* groupOne = groupedByFirstLetter[@"J"];
    STAssertEquals(groupOne.count, 2U, nil);
    STAssertEqualObjects(@"James", groupOne[0], nil);
    STAssertEqualObjects(@"Jim", groupOne[1], nil);
    
    NSArray* groupTwo = groupedByFirstLetter[@"B"];
    STAssertEquals(groupTwo.count, 1U, nil);
    STAssertEqualObjects(@"Bob", groupTwo[0], nil);
}

- (void)testGroupByWithNil
{
    NSArray* input = @[@"James", @"Jim", @"Bob"];
    
    NSDictionary* groupedByFirstLetter = [input qeGroupBy:^id(id name) {
        NSString* firstChar = [name substringToIndex:1];
        return [firstChar isEqualToString:@"J"] ? nil : firstChar;
    }];
    
    STAssertEquals(groupedByFirstLetter.count, 2U, nil);
    
    // test the group keys
    NSArray* keys = [groupedByFirstLetter allKeys];
    STAssertEqualObjects([NSNull null], keys[1], nil);
    STAssertEqualObjects(@"B", keys[0], nil);
    
    // test that the correct items are in each group
    NSArray* groupOne = groupedByFirstLetter[[NSNull null]];
    STAssertEquals(groupOne.count, 2U, nil);
    STAssertEqualObjects(@"James", groupOne[0], nil);
    STAssertEqualObjects(@"Jim", groupOne[1], nil);
    
    NSArray* groupTwo = groupedByFirstLetter[@"B"];
    STAssertEquals(groupTwo.count, 1U, nil);
    STAssertEqualObjects(@"Bob", groupTwo[0], nil);
}

- (void)testToDictionaryWithValueSelector
{
    NSArray* input = @[@"James", @"Jim", @"Bob"];

    NSDictionary* dictionary = [input qeToDictionaryWithKeySelector:^id(id item) {
        return [item substringToIndex:1];
    } valueSelector:^id(id item) {
        return [item lowercaseString];
    }];
    
    NSLog(@"%@", dictionary);
    
    // NOTE - two items have the same key, hence the dictionary only has 2 keys
    STAssertEquals(dictionary.count, 2U, nil);
    
    // test the group keys
    NSArray* keys = [dictionary allKeys];
    STAssertEqualObjects(@"J", keys[0], nil);
    STAssertEqualObjects(@"B", keys[1], nil);
    
    // test the values
    STAssertEqualObjects(dictionary[@"J"], @"jim", nil);
    STAssertEqualObjects(dictionary[@"B"], @"bob", nil);
}

- (void)testToDictionaryWithValueSelectorWithNil
{
    NSArray* input = @[@"James", @"Jim", @"Bob"];
    
    NSDictionary* dictionary = [input qeToDictionaryWithKeySelector:^id(id item) {
        NSString* firstChar = [item substringToIndex:1];
        return [firstChar isEqualToString:@"J"] ? nil : firstChar;
    } valueSelector:^id(id item) {
        NSString* lowercaseName = [item lowercaseString];
        return [lowercaseName isEqualToString:@"bob"] ? nil : lowercaseName;
    }];
    
    NSLog(@"%@", dictionary);
    
    // NOTE - two items have the same key, hence the dictionary only has 2 keys
    STAssertEquals(dictionary.count, 2U, nil);
    
    // test the group keys
    NSArray* keys = [dictionary allKeys];
    STAssertEqualObjects([NSNull null], keys[1], nil);
    STAssertEqualObjects(@"B", keys[0], nil);
    
    // test the values
    STAssertEqualObjects(dictionary[[NSNull null]], @"jim", nil);
    STAssertEqualObjects(dictionary[@"B"], [NSNull null], nil);
}

- (void)testToDictionary
{
    NSArray* input = @[@"Jim", @"Bob"];
    
    NSDictionary* dictionary = [input qeToDictionaryWithKeySelector:^id(id item) {
        return [item substringToIndex:1];
    }];
    
    STAssertEquals(dictionary.count, 2U, nil);
    
    // test the group keys
    NSArray* keys = [dictionary allKeys];
    STAssertEqualObjects(@"J", keys[0], nil);
    STAssertEqualObjects(@"B", keys[1], nil);
    
    // test the values
    STAssertEqualObjects(dictionary[@"J"], @"Jim", nil);
    STAssertEqualObjects(dictionary[@"B"], @"Bob", nil);
}



- (void) testCount
{
    NSArray* input = @[@25, @35, @25];

    NSUInteger numbersEqualTo25 = [input qeCount:^BOOL(id item) {
        return [item isEqualToNumber:@25];
    }];

    STAssertEquals(numbersEqualTo25, 2U, nil);
}

- (void) testConcat
{
    NSArray* input = @[@25, @35];
    
    NSArray* result = [input qeConcat:@[@45, @55]];
    
    STAssertEquals(result.count, 4U, nil);
    STAssertEqualObjects(result[0], @25, nil);
    STAssertEqualObjects(result[1], @35, nil);
    STAssertEqualObjects(result[2], @45, nil);
    STAssertEqualObjects(result[3], @55, nil);
}

- (void) testReverse
{
    NSArray* input = @[@25, @35];
    
    NSArray* result = [input qeReverse];
    
    STAssertEquals(result.count, 2U, nil);
    STAssertEqualObjects(result[0], @35, nil);
    STAssertEqualObjects(result[1], @25, nil);
}

@end
