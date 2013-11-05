//
//  NSArray+LinqExtensions.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 02/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSArray+LinqExtensions.h"

@implementation NSArray (QueryExtension)

- (NSArray *)where:(QECondition)predicate
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for(id item in self) {
       if (predicate(item)) {
           [result addObject:item];
       }
    }
    return result;
}

- (NSArray *)select:(QESelector)transform
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
    for(id item in self) {
        id object = transform(item);
        [result addObject:(object) ? object : [NSNull null]];
    }
    return result;
}

- (NSArray *)sort:(QESelector)keySelector
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        id valueOne = keySelector(obj1);
        id valueTwo = keySelector(obj2);
        NSComparisonResult result = [valueOne compare:valueTwo];
        return result;
    }];
}

- (NSArray *)sort
{
    return [self sort:^id(id item) { return item;} ];
}

- (NSArray *)ofType:(Class)type
{
    return [self where:^BOOL(id item) {
        return [[item class] isSubclassOfClass:type];
    }];
}

- (NSArray *)selectMany:(QESelector)transform
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for(id item in self) {
        for(id child in transform(item)){
            [result addObject:child];
        }
    }
    return result;
}

- (NSArray *)distinct
{
    NSMutableArray* distinctSet = [[NSMutableArray alloc] init];
    for (id item in self) {
        if (![distinctSet containsObject:item]) {
            [distinctSet addObject:item];
        }
    }
    return distinctSet;
}

- (NSArray *)distinct:(QESelector)keySelector
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

- (id)aggregate:(QEAccumulator)accumulator
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

- (id)firstOrNil
{
    return self.count == 0 ? nil : [self objectAtIndex:0];
}

- (id)lastOrNil
{
    return self.count == 0 ? nil : [self objectAtIndex:self.count - 1];
}

- (NSArray*)skip:(NSUInteger)count
{
    if (count < self.count) {
        NSRange range = {.location = count, .length = self.count - count};
        return [self subarrayWithRange:range];
    } else {
        return @[];
    }
}

- (NSArray*)take:(NSUInteger)count
{
    NSRange range = { .location=0,
        .length = count > self.count ? self.count : count};
    return [self subarrayWithRange:range];
}

- (BOOL)any:(QECondition)condition
{
    for (id item in self) {
        if (condition(item)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)all:(QECondition)condition
{
    for (id item in self) {
        if (!condition(item)) {
            return NO;
        }
    }
    return YES;
}

- (NSDictionary*)groupBy:(QESelector)groupKeySelector
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

- (NSDictionary *)toDictionaryWithKeySelector:(QESelector)keySelector valueSelector:(QESelector)valueSelector
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

- (NSDictionary *)toDictionaryWithKeySelector:(QESelector)keySelector
{
    return [self toDictionaryWithKeySelector:keySelector valueSelector:nil];
}

- (NSUInteger)count:(QECondition)condition
{
    return [self where:condition].count;
}

- (NSArray *)concat:(NSArray *)array
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count + array.count];
    [result addObjectsFromArray:self];
    [result addObjectsFromArray:array];
    return result;
}

- (NSArray *)reverse
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.count];
    for (id item in [self reverseObjectEnumerator]) {
        [result addObject:item];
    }
    return result;
}


@end
