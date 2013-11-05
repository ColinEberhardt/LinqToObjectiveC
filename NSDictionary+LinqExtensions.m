//
//  NSDictionary+LinqExtensions.m
//  LinqToObjectiveC
//
//  Created by Colin Eberhardt on 25/02/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NSDictionary+LinqExtensions.h"

@implementation NSDictionary (QueryExtension)

- (NSDictionary *)qeWhere:(QEKeyValueCondition)predicate
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (predicate(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];
    return result;
}

- (NSDictionary *)qeSelect:(QEKeyValueSelector)selector
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id object = selector(key, obj);
        if (!object)
            object = [NSNull null];
        
        [result setObject:object forKey:key];
    }];
    return result;
}

- (NSArray *)qeToArray:(QEKeyValueSelector)selector
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id object = selector(key, obj);
        if (!object)
            object = [NSNull null];
        [result addObject:object];
    }];
    return result;
}

- (BOOL)qeAll:(QEKeyValueCondition)condition
{
    __block BOOL all = TRUE;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!condition(key, obj)){
            all = FALSE;
            *stop = TRUE;
        }
    }];
    return all;
}

- (BOOL)qeAny:(QEKeyValueCondition)condition
{
    __block BOOL any = FALSE;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (condition(key, obj)){
            any = TRUE;
            *stop = TRUE;
        }
    }];
    return any;
}

- (NSUInteger)qeCount:(QEKeyValueCondition)condition
{
    return [self qeWhere:condition].count;
}

- (NSDictionary *)qeMerge:(NSDictionary *)dictionary
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] initWithDictionary:self];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![result objectForKey:key]) {
            [result setObject:obj forKey:key];
        }
    }];
    return result;
}

@end
