Linq To Objective-C
================

Bringing a Linq-style fluent query API to Objective-C.

This project contains a collection of `NSArray` methods that allow you to execute query using a fluent syntax, inspired by Linq. In order to use *Linq to Objective-C* simply copy the `NSArray+LinqExtensions.h`and `NSArray+LinqExtensions.m` files into your project and import the header within any file where you wish to use the API.

As an example of the types of query this API makes possible, let's say you have an array of `Person` instances, each with a `surname` property. The following query will create a sorted, comma-separated list of the unique surnames from the array:

```objc
Selector surnameSelector = ^id(id person){
    return [person name];
};

Accumulator csvAccumulator = ^id(id item, id aggregate) {
    return [NSString stringWithFormat:@"%@, %@", aggregate, item];
};

NSArray* surnamesList = [[[[people select:surnameSelector]
                                   sort]
                                   distinct]
                                   aggregate:csvAccumulator];
```

For a detailed discussion of the history of Linq and why I implemented this API, see the [related blog post](http://www.scottlogic.co.uk/blog/colin/2013/02/linq-to-objective-c/).

API Overview
==

The following extension methods are provided:

- where
- select
- sort
- ofType
- selectMany
- distinct
- aggregate
- firstOrNil
- lastOrNil
- skip
- take
- any
- all

API Details
==

This section provides a few brief examples of each of the API methods. A number of these examples use an array of Person instances:

```objc
interface Person : NSObject

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSNumber* age;

@end
```

where
-

```objc
- (NSArray*) where:(Predicate)predicate;
```

Filters a sequence of values based on a predicate.

The following example uses the where method to find people who are 25:

```objc
NSArray* peopleWhoAre25 = [input where:^BOOL(id person) {
    return [[person age] isEqualToNumber:@25];
}];
```

select
-

```objc
- (NSArray*) select:(Selector)selector;
```

Projects each element of a sequence into a new form. Each element in the array is transformed by a 'selector' into a new form, which is then used to populate the output array.

The following example uses a selector that returns the name of each `Person` instance. The output will be an array of `NSString` instances.

```objc
NSArray* names = [input select:^id(id person) {
    return [person name];
}];
```

sort
-

```objc
- (NSArray*) sort;
- (NSArray*) sort:(Selector)keySelector;
```

Sorts the elements of an array, either via their 'natural' sort order, or via a `keySelector`.

As an example of natural sort, the following sorts a collection of `NSNumber` instances: 

```objc
NSArray* input = @[@21, @34, @25];
NSArray* sortedInput = [input sort];
```

In order to sort an array of Person instances, you can use the key selector:

```objc
NSArray* sortedByName = [input sort:^id(id person) {
    return [person name];
}];
```
    
ofType
-

```objc
- (NSArray*) ofType:(Class)type;
```

Filters the elements of an an array based on a specified type.

In the following example a mixed array of `NSString` and `NSNumber` instances is filtered to return just the `NSString` instances:

```objc
NSArray* mixed = @[@"foo", @25, @"bar", @33];
NSArray* strings = [mixed ofType:[NSString class]];
```
    
selectMany
-

```objc
- (NSArray*) selectMany:(Selector)transform;
```

Projects each element of a sequence to an `NSArray` and flattens the resulting sequences into one sequence.

This is an interesting one! This is similar to the `select` method, however the selector must return an `NSArray`, with the select-many operation flattening the returned arrays into a single sequence.

Here's a quick example:

```objc
NSArray* data = @[@"foo, bar", @"fubar"];

NSArray* components = [data selectMany:^id(id string) {
    return [string componentsSeparatedByString:@", "];
}];
```

A more useful example might use select-many to return all the order-lines for an array of orders.

distinct
-

```objc
- (NSArray*) distinct;
```

Returns distinct elements from a sequence. This simply takes an array of ties, returning an array of the distinct (i.e. unique) values in source order.

Here's an example:

```objc
NSArray* names = @[@"bill", @"bob", @"bob", @"brian", @"bob"];
NSArray* distinctNames = [names distinct];
// returns bill, bob and brian
```

aggregate
-

```objc
- (id) aggregate:(Accumulator)accumulator;
```

Applies an accumulator function over a sequence. This method transforms an array into a single value by applying an accumulator function to each successive element.

Here's an example that creates a comma separated list from an array of strings:

```objc
NSArray* names = @[@"bill", @"bob", @"brian"];

id aggregate = [names aggregate:^id(id item, id aggregate) {
    return [NSString stringWithFormat:@"%@, %@", aggregate, item];
}];
// returns "bill, bob, brian"
```

Here's another example that returns the largest value from an array of numbers:

```objc
NSArray* numbers = @[@22, @45, @33];

id biggestNumber = [numbers aggregate:^id(id item, id aggregate) {
    return [item compare:aggregate] == NSOrderedDescending ? item : aggregate;
}];
// returns 45 
```

firstOrNil
-

```objc
- (id) firstOrNil;
```

Returns the first element of an array, or nil if the array is empty.

lastOrNil
-

```objc
- (id) lastOrNil;
```

Returns the last element of an array, or nil if the array is empty

skip
-

```objc
- (NSArray*) skip:(NSUInteger)count;
```

Returns an array that skips the first 'n' elements of the source array, including the rest.

take
-

```objc
- (NSArray*) take:(NSUInteger)count;
```

Returns an array that contains the first 'n' elements of the source array.

any
-

```objc
- (BOOL) any:(Condition)condition;
```

Tests whether any item in the array passes the given condition.

As an example, you can check whether any number in an array is equal to 25:

```objc
NSArray* input = @[@25, @44, @36];
BOOL isAnyEqual = [input any:^BOOL(id item) {
        return [item isEqualToNumber:@25];
    }];
// returns YES
```

all
-

```objc
- (BOOL) all:(Condition)condition;
```

Tests whether all the items in the array pass the given condition.

As an example, you can check whether all the numbers in an array are equal to 25:

```objc
NSArray* input = @[@25, @44, @36];
BOOL areAllEqual = [input all:^BOOL(id item) {
        return [item isEqualToNumber:@25];
    }];
// returns NO
```




