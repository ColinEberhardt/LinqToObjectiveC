# Linq To Objective-C

Bringing a Linq-style fluent query API to Objective-C.

This project contains a collection of `NSArray` and `NSDictionary` methods that allow you to execute queries using a fluent syntax, inspired by [Linq](http://msdn.microsoft.com/en-us/library/vstudio/bb397926.aspx). In order to use *Linq to Objective-C* simply copy the `NSArray+LinqExtensions.h`, `NSArray+LinqExtensions.m`, `NSDictionary+LinqExtensions.h` and `NSDictionary+LinqExtensions.m` files into your project and import the header within any file where you wish to use the API.

Alternatively, you can include these files via [CocoaPods](http://cocoapods.org/).

As an example of the types of query this API makes possible, let's say you have an array of `Person` instances, each with a `surname` property. The following query will create a sorted, comma-separated list of the unique surnames from the array:

```objc
LINQSelector surnameSelector = ^id(id person){
    return [person name];
};

LINQAccumulator csvAccumulator = ^id(id item, id aggregate) {
    return [NSString stringWithFormat:@"%@, %@", aggregate, item];
};

NSArray* surnamesList = [[[[people linq_select:surnameSelector]
                                   linq_sort]
                                   linq_distinct]
                                   linq_aggregate:csvAccumulator];
```

For a detailed discussion of the history of Linq and why I implemented this API, see the [related blog post](http://www.scottlogic.co.uk/blog/colin/2013/02/linq-to-objective-c/).

#Licence

The code within project is made available under the standard MIT licence, see the included licence file.

# API Overview


`NSArray` methods:

- [linq_where](#where)
- [linq_select](#select)
- [linq_sort](#sort)
- [linq_ofType](#ofType)
- [linq_selectMany](#selectMany)
- [linq_distinct](#distinct)
- [linq_aggregate](#aggregate)
- [linq_firstOrNil](#firstOrNil)
- [linq_lastOrNil](#lastOrNil)
- [linq_skip](#skip)
- [linq_take](#take)
- [linq_any](#any)
- [linq_all](#all)
- [linq_groupBy](#groupBy)
- [linq_toDictionary](#toDictionary)
- [linq_count](#count)
- [linq_concat](#concat)
- [linq_reverse](#reverse)

`NSDictionary` methods:

- [linq_where](#dictionary-where)
- [linq_select](#dictionary-select)
- [linq_toArray](#dictionary-toArray)
- [linq_any](#dictionary-any)
- [linq_all](#dictionary-all)
- [linq_count](#dictionary-count)
- [linq_merge](#dictionary-merge)


## NSArray methods

This section provides a few brief examples of each of the API methods. A number of these examples use an array of Person instances:

```objc
interface Person : NSObject

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSNumber* age;

@end
```

### <a name="where"></a>linq_where


```objc
- (NSArray*) linq_where:(LINQCondition)predicate;
```

Filters a sequence of values based on a predicate.

The following example uses the where method to find people who are 25:

```objc
NSArray* peopleWhoAre25 = [input linq_where:^BOOL(id person) {
    return [[person age] isEqualToNumber:@25];
}];
```

### <a name="select"></a>linq_select

```objc
- (NSArray*) linq_select:(LINQSelector)transform;
```

Projects each element of a sequence into a new form. Each element in the array is transformed by a 'selector' into a new form, which is then used to populate the output array.

The following example uses a selector that returns the name of each `Person` instance. The output will be an array of `NSString` instances.

```objc
NSArray* names = [input linq_select:^id(id person) {
    return [person name];
}];
```

### <a name="sort"></a>linq_sort

```objc
- (NSArray*) linq_sort;
- (NSArray*) linq_sort:(LINQSelector)keySelector;
```

Sorts the elements of an array, either via their 'natural' sort order, or via a `keySelector`.

As an example of natural sort, the following sorts a collection of `NSNumber` instances: 

```objc
NSArray* input = @[@21, @34, @25];
NSArray* sortedInput = [input sort];
```

In order to sort an array of Person instances, you can use the key selector:

```objc
NSArray* sortedByName = [input linq_sort:^id(id person) {
    return [person name];
}];
```
    
### <a name="ofType"></a>linq_ofType

```objc
- (NSArray*) linq_ofType:(Class)type;
```

Filters the elements of an an array based on a specified type.

In the following example a mixed array of `NSString` and `NSNumber` instances is filtered to return just the `NSString` instances:

```objc
NSArray* mixed = @[@"foo", @25, @"bar", @33];
NSArray* strings = [mixed linq_ofType:[NSString class]];
```
    
### <a name="selectMany"></a>linq_selectMany

```objc
- (NSArray*) linq_selectMany:(LINQSelector)transform;
```

Projects each element of a sequence to an `NSArray` and flattens the resulting sequences into one sequence.

This is an interesting one! This is similar to the `select` method, however the selector must return an `NSArray`, with the select-many operation flattening the returned arrays into a single sequence.

Here's a quick example:

```objc
NSArray* data = @[@"foo, bar", @"fubar"];

NSArray* components = [data linq_selectMany:^id(id string) {
    return [string componentsSeparatedByString:@", "];
}];
```

A more useful example might use select-many to return all the order-lines for an array of orders.

### <a name="distinct"></a>linq_distinct

```objc
- (NSArray*) linq_distinct;
- (NSArray*) linq_distinct:(LINQSelector)keySelector;
```

Returns distinct elements from a sequence. This simply takes an array of items, returning an array of the distinct (i.e. unique) values in source order.

The no-arg version of this method uses the default method of comparing the given objects. The version that takes a key-selector allows you to specify the value to use for equality for each item.

Here's an example that returns the distinct values from an array of strings:

```objc
NSArray* names = @[@"bill", @"bob", @"bob", @"brian", @"bob"];
NSArray* distinctNames = [names linq_distinct];
// returns bill, bob and brian
```

Here's a more complex example that uses the key selector to find people instances with distinct ages:

```objc
NSArray* peopleWithUniqueAges = [input linq_distinct:^id(id person) {
    return [person age];
}];
```

### <a name="aggregate"></a>linq_aggregate

```objc
- (id) linq_aggregate:(LINQAccumulator)accumulator;
```

Applies an accumulator function over a sequence. This method transforms an array into a single value by applying an accumulator function to each successive element.

Here's an example that creates a comma separated list from an array of strings:

```objc
NSArray* names = @[@"bill", @"bob", @"brian"];

id aggregate = [names linq_aggregate:^id(id item, id aggregate) {
    return [NSString stringWithFormat:@"%@, %@", aggregate, item];
}];
// returns "bill, bob, brian"
```

Here's another example that returns the largest value from an array of numbers:

```objc
NSArray* numbers = @[@22, @45, @33];

id biggestNumber = [numbers linq_aggregate:^id(id item, id aggregate) {
    return [item compare:aggregate] == NSOrderedDescending ? item : aggregate;
}];
// returns 45 
```

### <a name="firstOrNil"></a>linq_firstOrNil

```objc
- (id) linq_firstOrNil;
```

Returns the first element of an array, or nil if the array is empty.

### <a name="lastOrNil"></a>linq_lastOrNil

```objc
- (id) linq_lastOrNil;
```

Returns the last element of an array, or nil if the array is empty

### <a name="skip"></a>linq_skip

```objc
- (NSArray*) linq_skip:(NSUInteger)count;
```

Returns an array that skips the first 'n' elements of the source array, including the rest.

### <a name="take"></a>linq_take

```objc
- (NSArray*) linq_take:(NSUInteger)count;
```

Returns an array that contains the first 'n' elements of the source array.

### <a name="any"></a>linq_any

```objc
- (BOOL) linq_any:(LINQCondition)condition;
```

Tests whether any item in the array passes the given condition.

As an example, you can check whether any number in an array is equal to 25:

```objc
NSArray* input = @[@25, @44, @36];
BOOL isAnyEqual = [input linq_any:^BOOL(id item) {
        return [item isEqualToNumber:@25];
    }];
// returns YES
```

### <a name="all"></a>linq_all

```objc
- (BOOL) linq_all:(LINQCondition)condition;
```

Tests whether all the items in the array pass the given condition.

As an example, you can check whether all the numbers in an array are equal to 25:

```objc
NSArray* input = @[@25, @44, @36];
BOOL areAllEqual = [input linq_all:^BOOL(id item) {
        return [item isEqualToNumber:@25];
    }];
// returns NO
```

### <a name="groupBy"></a>linq_groupBy

```objc
- (NSDictionary*) linq_groupBy:(LINQSelector)groupKeySelector;
```

Groups the items in an array returning a dictionary. The `groupKeySelector` is applied to each element in the array to determine which group it belongs to.

The returned dictionary has the group values (as returned by the key selector) as its keys, with an `NSArray` for each value, containing all the items within that group.

As an example, if you wanted to group a number of strings by their first letter, you could do the following:

```objc
NSArray* input = @[@"James", @"Jim", @"Bob"];
    
NSDictionary* groupedByFirstLetter = [input linq_groupBy:^id(id name) {
   return [name substringToIndex:1];
}];
// the returned dictionary is as follows:
// {
//     J = ("James", "Jim");
//     B = ("Bob");
// }
```

### <a name="toDictionary"></a>linq_toDictionary

```objc
- (NSDictionary*) linq_toDictionaryWithKeySelector:(LINQSelector)keySelector;
- (NSDictionary*) linq_toDictionaryWithKeySelector:(LINQSelector)keySelector valueSelector:(LINQSelector)valueSelector;
```

Transforms the source array into a dictionary by applying the given keySelector and (optional) valueSelector to each item in the array. If you use the `toDictionaryWithKeySelector:` method, or the `toDictionaryWithKeySelector:valueSelector:` method with a `nil` valueSelector, the value for each dictionary item is simply the item from the source array.

As an example, the following code takes an array of names, creating a dictionary where the key is the first letter of each name and the value is the name (in lower case).

```objc
NSArray* input = @[@"Frank", @"Jim", @"Bob"];

NSDictionary* dictionary = [input linq_toDictionaryWithKeySelector:^id(id item) {
    return [item substringToIndex:1];
} valueSelector:^id(id item) {
    return [item lowercaseString];
}];

// result:
// (
//    F = frank;
//    J = jim;
//    B = bob;
// )
```

Whereas in the following there is no value selector, so the strings from the source array are used directly.

```objc
NSArray* input = @[@"Frank", @"Jim", @"Bob"];

NSDictionary* dictionary = [input linq_toDictionaryWithKeySelector:^id(id item) {
    return [item substringToIndex:1];
}];

// result:
// (
//    F = Frank;
//    J = Jim;
//    B = Bob;
// )
```

### <a name="count"></a>linq_count

```objc
- (NSUInteger) linq_count:(LINQCondition)condition;
```

Counts the number of elements in an array that pass a given condition.

As an example, you can check how many numbers equal a certain value:

```objc
NSArray* input = @[@25, @35, @25];

NSUInteger numbersEqualTo25 = [input linq_count:^BOOL(id item) {
    return [item isEqualToNumber:@25];
}];
// returns 2
```

### <a name="concat"></a>linq_concat

```objc
- (NSArray*) linq_concat:(NSArray*)array;
```

Returns an array which is the result of concatonating the given array to the end of this array.

### <a name="reverse"></a>linq_reverse

```objc
- (NSArray*) linq_reverse;
```

Returns an array that has the same elements as the source but in reverse order.

## NSDictionary methods

This section provides a few brief examples of each of the API methods. 

### <a name="dictionary-where"></a>linq_where


```objc
- (NSDictionary*) linq_where:(LINQKeyValueCondition)predicate;
```

Filters a dictionary based on a predicate.

The following example uses filters a dictionary to remove any keys that are equal to their value.

```objc
NSDictionary* result = [input linq_where:^BOOL(id key, id value) {
   return [key isEqual:value];
}];
```

### <a name="dictionary-select"></a>linq_select

```objc
- (NSDictionary*) linq_select:(LINQKeyValueConditionKeyValueSelector)selector;
```

Projects each key-value pair in a dictionary into a new form. Each key-value pair is transformed by a 'selector' into a new form, which is then used to populate the values of the output dictionary. 

The following example takes a dictionary which has string values, returning a new dictionary where each value is the first character of the source string.

```objc
NSDictionary* result = [input linq_select:^id(id key, id value) {
    return [value substringToIndex:1];
}];
```

### <a name="dictionary-toArray"></a>linq_toArray

```objc
- (NSArray*) linq_toArray:(LINQKeyValueSelector)selector;
```

Projects each key-value pair in a dictionary into a new form, which is used to populate the output array. 

The following example takes a dictionary which has string values, returning an array which concatenates the key and value for each item in the dictionary.

```objc
NSDictionary* input = @{@"A" : @"Apple", @"B" : @"Banana", @"C" : @"Carrot"};

NSArray* result = [input linq_toArray:^id(id key, id value) {
    return [NSString stringWithFormat:@"%@, %@", key, value];
}];

// result:
// (
//    "A, Apple",
//    "B, Banana",
//    "C, Carrot"
// )
```

### <a name="dictionary-any"></a>linq_any

```objc
- (BOOL) linq_any:(LINQKeyValueCondition)condition;
```

Tests whether any key-value pair in the dictionary passes the given condition.

As an example, you can check whether value contains the letter 'n':

```objc
NSDictionary* input = @{@"a" : @"apple", @"b" : @"banana", @"c" : @"bat"};

BOOL anyValuesHaveTheLetterN = [input linq_any:^BOOL(id key, id value) {
    return [value rangeOfString:@"n"].length != 0;
}];
// returns YES
```

### <a name="dictionary-all"></a>linq_all

```objc
- (BOOL) linq_all:(LINQKeyValueCondition)condition;
```

Tests whether all the key-value pairs in the dictionary pass the given condition.

As an example, you can check whether all values contains the letter 'a', or use the key component of the condition to see if each value contains the string key:

```objc
NSDictionary* input = @{@"a" : @"apple", @"b" : @"banana", @"c" : @"bat"};

BOOL allValuesHaveTheLetterA = [input linq_all:^BOOL(id key, id value) {
    return [value rangeOfString:@"a"].length != 0;
}];
// returns YES

BOOL allValuesContainKey = [input linq_all:^BOOL(id key, id value) {
    return [value rangeOfString:key].length != 0;
}];
// returns NO - the value 'bat' does not contain the letter it is keyed with 'c'
```

### <a name="dictionary-count"></a>linq_count

```objc
- (NSUInteger) linq_count:(LINQKeyValueCondition)condition;
```

Counts the number of key-value pairs that satisfy the given condition.

The following example counts how many dictionary values contain the key:

```objc
NSDictionary* input = @{@"a" : @"apple", @"b" : @"banana", @"c" : @"bat"};


NSUInteger valuesThatContainKey = [input linq_count:^BOOL(id key, id value) {
    return [value rangeOfString:key].length != 0;
}];
// returns 2 - "bat" does not contain the key "c"
```

### <a name="dictionary-merge"></a>linq_merge

```objc
- (NSDictionary*) linq_merge:(NSDictionary*)dic;
```

Merges the contents of this dictionary with the given dictionary. For any duplicates, the value from the source dictionary will be used.


The following example merges a pair of dictionaries

```objc
NSDictionary* input = @{@"a" : @"apple", @"b" : @"banana", @"c" : @"cat"};

NSDictionary* result = [input linq_merge:@{@"d" : @"dog", @"e" : @"elephant"}];

// result:
// (
//    a = apple;
//    b = banana;
//    c = cat;
//    d = dog;
//    e = elephant;
// )
```
