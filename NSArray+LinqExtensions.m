//
//  NSArray+LinqExtensions.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 02/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSArray+LinqExtensions.h"

@implementation NSArray (QueryExtension)

- (NSArray *)linq_where:(LINQCondition)predicate
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for(id item in self) {
       if (predicate(item)) {
           [result addObject:item];
       }
    }
    return result;
}

- (NSArray *)linq_select:(LINQSelector)transform
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
    for(id item in self) {
        id object = transform(item);
        [result addObject:(object) ? object : [NSNull null]];
    }
    return result;
}

- (NSArray *)linq_sort:(LINQSelector)keySelector
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        id valueOne = keySelector(obj1);
        id valueTwo = keySelector(obj2);
        NSComparisonResult result = [valueOne compare:valueTwo];
        return result;
    }];
}

- (NSArray *)linq_sort
{
    return [self linq_sort:^id(id item) { return item;} ];
}

- (NSArray *)linq_ofType:(Class)type
{
    return [self linq_where:^BOOL(id item) {
        return [[item class] isSubclassOfClass:type];
    }];
}

- (NSArray *)linq_selectMany:(LINQSelector)transform
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for(id item in self) {
        for(id child in transform(item)){
            [result addObject:child];
        }
    }
    return result;
}

- (NSArray *)linq_distinct
{
    NSMutableArray* distinctSet = [[NSMutableArray alloc] init];
    for (id item in self) {
        if (![distinctSet containsObject:item]) {
            [distinctSet addObject:item];
        }
    }
    return distinctSet;
}

- (NSArray *)linq_distinct:(LINQSelector)keySelector
{
    NSMutableSet* keyValues = [[NSMutableSet alloc] init];
    NSMutableArray* distinctSet = [[NSMutableArray alloc] init];
    for (id item in self) {
        id keyForItem = keySelector(item);
        if (!keyForItem)
            keyForItem = [NSNull null];
        if (![keyValues containsObject:keyForItem]) {
            [distinctSet addObject:item];
            [keyValues addObject:keyForItem];
        }
    }
    return distinctSet;
}

- (id)linq_aggregate:(LINQAccumulator)accumulator
{
    id aggregate = nil;
    for (id item in self) {
        if (aggregate == nil) {
            aggregate = item;
        } else {
            aggregate = accumulator(item, aggregate);
        }
    }
    return aggregate;
}

- (id)linq_firstOrNil
{
    return self.count == 0 ? nil : [self objectAtIndex:0];
}

- (id)linq_lastOrNil
{
    return self.count == 0 ? nil : [self objectAtIndex:self.count - 1];
}

- (NSArray*)linq_skip:(NSUInteger)count
{
    if (count < self.count) {
        NSRange range = {.location = count, .length = self.count - count};
        return [self subarrayWithRange:range];
    } else {
        return @[];
    }
}

- (NSArray*)linq_take:(NSUInteger)count
{
    NSRange range = { .location=0,
        .length = count > self.count ? self.count : count};
    return [self subarrayWithRange:range];
}

- (BOOL)linq_any:(LINQCondition)condition
{
    for (id item in self) {
        if (condition(item)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)linq_all:(LINQCondition)condition
{
    for (id item in self) {
        if (!condition(item)) {
            return NO;
        }
    }
    return YES;
}

- (NSDictionary*)linq_groupBy:(LINQSelector)groupKeySelector
{
    NSMutableDictionary* groupedItems = [[NSMutableDictionary alloc] init];
    for (id item in self) {
        id key = groupKeySelector(item);
        if (!key)
            key = [NSNull null];
        NSMutableArray* arrayForKey;
        if (!(arrayForKey = [groupedItems objectForKey:key])){
            arrayForKey = [[NSMutableArray alloc] init];
            [groupedItems setObject:arrayForKey forKey:key];
        }
        [arrayForKey addObject:item];
    }
    return groupedItems;
}

- (NSDictionary *)linq_toDictionaryWithKeySelector:(LINQSelector)keySelector valueSelector:(LINQSelector)valueSelector
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    for (id item in self) {
        id key = keySelector(item);
        id value = valueSelector!=nil ? valueSelector(item) : item;
        
        if (!key)
            key = [NSNull null];
        if (!value)
            value = [NSNull null];
        
        [result setObject:value forKey:key];
    }
    return result;
}

- (NSDictionary *)linq_toDictionaryWithKeySelector:(LINQSelector)keySelector
{
    return [self linq_toDictionaryWithKeySelector:keySelector valueSelector:nil];
}

- (NSUInteger)linq_count:(LINQCondition)condition
{
    return [self linq_where:condition].count;
}

- (NSArray *)linq_concat:(NSArray *)array
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count + array.count];
    [result addObjectsFromArray:self];
    [result addObjectsFromArray:array];
    return result;
}

- (NSArray *)linq_reverse
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id item in [self reverseObjectEnumerator]) {
        [result addObject:item];
    }
    return result;
}


@end
