//
//  ScenarioTests.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 07/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "ScenarioTests.h"
#import "Person.h"
#import "NSDictionary+LinqExtensions.h"
#import "NSArray+LinqExtensions.h"


/**
 Tests for specific scenarious that I have seen on the internet.
 */
@implementation ScenarioTests


- (void)testDictionaryToQuerystring
{
    NSDictionary* input = @{@"page" : @"24",
    @"lang" : @"en-US",
    @"q" : @"how+many+kittens",
    @"key" : @"1234"};
    
    id result = [[input qeToArray:^id(id key, id value) {
                            return [NSString stringWithFormat:@"%@=%@", key, value];
                        }]
                        qeAggregate:^id(id item, id aggregate) {
                            return [NSString stringWithFormat:@"%@&%@", item, aggregate];
                        }];
    
    STAssertEqualObjects(@"lang=en-US&q=how+many+kittens&key=1234&page=24", result, nil);
}

- (void)testCountingPeopleWithSurnamesStartingWithEachLetter
{
    NSArray* people = @[[Person personWithName:@"bob" age:@25],
    [Person personWithName:@"frank" age:@45],
    [Person personWithName:@"ian" age:@35],
    [Person personWithName:@"jim" age:@25],
    [Person personWithName:@"joe" age:@55]];
    
    id result = [[people qeGroupBy:^id(id person) {
                                return [[[person name] substringToIndex:1] uppercaseString];
                            }]
                         qeSelect:^id(id key, id value) {
                                return [NSNumber numberWithInt:[value count]];
                            }];
    
    NSLog(@"%@", result);
}

- (void)testSO_15375528
{
    NSArray *array = @[@{@"groupId" : @"1", @"name" : @"matt"},
    @{@"groupId" : @"2", @"name" : @"john"},
    @{@"groupId" : @"3", @"name" : @"steve"},
    @{@"groupId" : @"4", @"name" : @"alice"},
    @{@"groupId" : @"1", @"name" : @"bill"},
    @{@"groupId" : @"2", @"name" : @"bob"},
    @{@"groupId" : @"3", @"name" : @"jack"},
    @{@"groupId" : @"4", @"name" : @"dan"},
    @{@"groupId" : @"1", @"name" : @"kevin"},
    @{@"groupId" : @"2", @"name" : @"mike"},
    @{@"groupId" : @"3", @"name" : @"daniel"},
    ];
    
    NSArray* grouped = [[array qeGroupBy:^id(id app) {
        return [app objectForKey:@"groupId"];
    }] qeToArray:^id(id key, id value) {
        int __block index = 0;
        id dic = [[value qeToDictionaryWithKeySelector:^id(id item) {
                                return [NSString stringWithFormat:@"name%d", index++ + 1];
                            } valueSelector:^id(id item) {
                                return [item objectForKey:@"name"];
                            }]
                         qeMerge: @{@"groupId" : key}];
        return dic;
    }];
    
    NSLog(@"%@", grouped);;
}

@end
