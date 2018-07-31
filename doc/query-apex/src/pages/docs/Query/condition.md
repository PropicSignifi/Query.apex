---
title: "Condition"
description: "Condition methods in Query"
layout: "guide"
icon: "code-file"
weight: 3
---

###### {$page.description}

<article id="1">

## byId

Add a condition to the query, limiting the sObject to a specific ID or a
collection of ID. Alias to `addConditionEq('Id', ...)`

#### public Query byId(Id id)

id: The specified ID of the SObject

```javascript

Query query =
    new Query('Account').
    byId();

```

#### public Query byId(List\<Id\> idList)

idList: A List of specified IDs

```javascript

Query query =
    new Query('Account').
    byId(new List<Id>{'001O000000qkv3KIAQ'});

```

#### public Query byId(Set\<Id\> idSet)

idSet: A Set of specified IDs

```javascript

Query query =
    new Query('Account').
    byId(new Set<Id>{'001O000000qkv3KIAQ'});

```

</article>

<article id="2">

## addConditionXX

Add a condition to the query, limiting the sObject. 'XX' can be one of these
comparison operators: Eq, NotEq, In, Lt, Le, Gt, Ge, Like.

By default, all the conditions added by this method will be joined by the
boolean operator 'and', i.e. the result is true if and only if all the
conditions are true, unless calling the `switchToDisjunction` method.

#### public Query addConditionEq(String lhs, Object rhs)

Add a condition `lhs = rhs`.

The result is true if and only if the left hand side value equals to the right
hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query query =
    new Query('Account').
    addConditionEq('Id', '001O000000qkv3KIAQ');

```

#### public Query addConditionNotEq(String lhs, Object rhs)

Add a condition `lhs != rhs`.

The result is true if and only if the left hand side value does not equal to
the right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query query =
    new Query('Account').
    addConditionNotEq('Id', '001O000000qkv3KIAQ');

```

#### public Query addConditionIn(String lhs, Object rhs)

Add a condition `lhs IN rhs`.

The result is true if and only if the left hand side value equals to any
value in the right hand side collection.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a List or a
Set.

```javascript

Query query =
    new Query('Account').
    addConditionIn('Id', new Set<Id>{'001O000000qkv3KIAQ'});

```

#### public Query addConditionNotIn(String lhs, Object rhs)

Add a condition `lhs NOT IN rhs`.

The result is true if and only if the left hand side value does not equal to
any value in the right hand side collection.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a List or a
Set.

```javascript

Query query =
    new Query('Account').
    addConditionNotIn('Id', new Set<Id>{'001O000000qkv3KIAQ'});

```

#### public Query addConditionLt(String lhs, Object rhs)

Add a condition `lhs < rhs`.

The result is true if and only if the left hand side value is less than the
right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query query =
    new Query('Account').
    addConditionLt('NumberOfEmployees', 10);

```

#### public Query addConditionLe(String lhs, Object rhs)

Add a condition `lhs <= rhs`.

The result is true if and only if the left hand side value is less than, or
equals the right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query query =
    new Query('Account').
    addConditionLe('NumberOfEmployees', 10);

```

#### public Query addConditionGt(String lhs, Object rhs)

Add a condition `lhs > rhs`.

The result is true if and only if the left hand side value is greater than the
right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query query =
    new Query('Account').
    addConditionGt('NumberOfEmployees', 10);

```

#### public Query addConditionGe(String lhs, Object rhs)

Add a condition `lhs >= rhs`.

The result is true if and only if the left hand side value is greater than, or
equals the right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query query =
    new Query('Account').
    addConditionGe('NumberOfEmployees', 10);

```

#### public Query addConditionLike(String lhs, Object rhs)

Add a condition `lhs LIKE rhs`.

The result is true if and only if the left hand side value matches the right
hand side value, in a way similar to the `LIKE` operator in SQL.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a String.

```javascript

Query query =
    new Query('Account').
    addConditionLike('Name', '%Sam%');

```

</article>

<article id="3">

## addCondition

#### public Query addCondition(Condition condition)

Add a condition expression, which is a Query.Condition type instance.

condition: A Query.Condition type, which can be constructed by a static
`conditionXX` method.

```javascript

Query q =
    new Query('Account').
    addCondition(Query.conditionEq('Name', 'Sam'));

```

</article>

<article id="4">

## conditionXX

Creates a Query.Condition instance. 'XX' can be one of these comparison
operators: Eq, NotEq, In, Lt, Le, Gt, Ge, Like.

#### public static Condition conditionEq(String lhs, Object rhs)

Creates a condition `lhs = rhs`.

The result is true if and only if the left hand side value equals to the right
hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query.Condition condition =
    Query.conditionEq('Name', 'Sam');

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionNotEq(String lhs, Object rhs)

Creates a condition `lhs != rhs`.

The result is true if and only if the left hand side value does not equal to
the right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query.Condition condition =
    Query.conditionNotEq('Name', 'Sam');

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionIn(String lhs, Object rhs)

Creates a condition `lhs IN rhs`.

The result is true if and only if the left hand side value equals to any
value in the right hand side collection.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a List or a
Set.

```javascript

Query.Condition condition =
    Query.conditionIn('Name', new Set<String>{'Sam'});

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionNotIn(String lhs, Object rhs)

Creates a condition `lhs NOT IN rhs`.

The result is true if and only if the left hand side value does not equal to
any value in the right hand side collection.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a List or a
Set.

```javascript

Query.Condition condition =
    Query.conditionNotIn('Name', new Set<String>{'Sam'});

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionLt(String lhs, Object rhs)

Creates a condition `lhs < rhs`.

The result is true if and only if the left hand side value is less than the
right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query.Condition condition =
    Query.conditionLt('NumberOfEmployees', 10);

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionLe(String lhs, Object rhs)

Creates a condition `lhs <= rhs`.

The result is true if and only if the left hand side value is less than, or
equals the right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query.Condition condition =
    Query.conditionLe('NumberOfEmployees', 10);

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionGt(String lhs, Object rhs)

Creates a condition `lhs > rhs`.

The result is true if and only if the left hand side value is greater than the
right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query.Condition condition =
    Query.conditionGt('NumberOfEmployees', 10);

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionGe(String lhs, Object rhs)

Creates a condition `lhs >= rhs`.

The result is true if and only if the left hand side value is greater than, or
equals the right hand side value.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a primitive
type or a `Query.Literal`.

```javascript

Query.Condition condition =
    Query.conditionGe('NumberOfEmployees', 10);

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition conditionLike(String lhs, Object rhs)

Creates a condition `lhs LIKE rhs`.

The result is true if and only if the left hand side value matches the right
hand side value, in a way similar to the `LIKE` operator in SQL.

lhs: Left hand side of the binary expression, which can only be a field name.

rhs: Right hand side of the binary expression, which can only be a String.

```javascript

Query.Condition condition =
    Query.conditionLike('Name', '%Sam%');

Query q =
    new Query('Account').
    addCondition(condition);

```

</article>

<article id="5">

## doAnd

Join two or more Query.Condition instances with boolean operator 'and'.

The result is true if and only if all the conditions are true.

Because `and` has been a reserved keyword in Apex, we have to rename the
method to `doAnd`.

#### public static Condition doAnd(Condition lhs, Condition rhs)

lhs: Left hand side of the boolean expression

rhs: Right hand side of the boolean expression

The result is true if and only if both lhs and rhs are true.

```javascript

Query.Condition condition =
    Query.doAnd(
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionGe('NumberOfEmployees', 10)
    );

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition doAnd(Condition condition0, Condition condition1, Condition condition2)

condition0: First condition in the boolean expression
condition1: Second condition in the boolean expression
condition2: Third condition in the boolean expression

The result is true if and only if all three condtions are true.

```javascript

Query.Condition condition =
    Query.doAnd(
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionEq('Phone', '123 456 789'),
        Query.conditionGe('NumberOfEmployees', 10)
    );

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition doAnd(Condition condition0, Condition condition1, Condition condition2, Condition condition3)

condition0: First condition in the boolean expression
condition1: Second condition in the boolean expression
condition2: Third condition in the boolean expression
condition3: Fourth condition in the boolean expression

The result is true if and only if all four condtions are true.

```javascript

Query.Condition condition =
    Query.doAnd(
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionEq('Phone', '123 456 789'),
        Query.conditionIn('Id', new Set<Id>{'00190000012KXI2AAO'}),
        Query.conditionGe('NumberOfEmployees', 10)
    );

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition doAnd(List\<Condition\> conditions)

conditions: A list of conditions in the boolean expression

The result is true if and only if all the conditions in the list are true.

```javascript

List<Query.Condition> conditions =
    new List<Query.Condition>{
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionEq('Phone', '123 456 789'),
        Query.conditionIn('Id', new Set<Id>{'00190000012KXI2AAO'}),
        Query.conditionGe('NumberOfEmployees', 10)
    };

Query.Condition condition =
    Query.doAnd(conditions);

Query q =
    new Query('Account').
    addCondition(condition);

```

</article>

<article id="6">

## doOr

Join two or more Query.Condition instances with boolean operator 'or'.

The result is true if and only if at least one of the conditions is true.

Because `or` has been a reserved keyword in Apex, we have to rename the
method to `doOr`.

#### public static Condition doOr(Condition lhs, Condition rhs)

lhs: Left hand side of the boolean expression

rhs: Right hand side of the boolean expression

The result is true if and only if either lhs or rhs is true.

```javascript

Query.Condition condition =
    Query.doOr(
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionGe('NumberOfEmployees', 10)
    );

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition doOr(Condition condition0, Condition condition1, Condition condition2)

condition0: First condition in the boolean expression
condition1: Second condition in the boolean expression
condition2: Third condition in the boolean expression

The result is true if and only if at least one of the three conditions
is true.

```javascript

Query.Condition condition =
    Query.doOr(
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionEq('Phone', '123 456 789'),
        Query.conditionGe('NumberOfEmployees', 10)
    );

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition doAnd(Condition condition0, Condition condition1, Condition condition2, Condition condition3)

condition0: First condition in the boolean expression
condition1: Second condition in the boolean expression
condition2: Third condition in the boolean expression
condition3: Fourth condition in the boolean expression

The result is true if and only if at least one of the four conditions
is true.

```javascript

Query.Condition condition =
    Query.doOr(
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionEq('Phone', '123 456 789'),
        Query.conditionIn('Id', new Set<Id>{'00190000012KXI2AAO'}),
        Query.conditionGe('NumberOfEmployees', 10)
    );

Query q =
    new Query('Account').
    addCondition(condition);

```

#### public static Condition doAnd(List\<Condition\> conditions)

conditions: A list of conditions in the boolean expression

The result is true if and only if at least one condition in the list is true.

```javascript

List<Query.Condition> conditions =
    new List<Query.Condition>{
        Query.conditionLike('Name', '%Sam%'),
        Query.conditionEq('Phone', '123 456 789'),
        Query.conditionIn('Id', new Set<Id>{'00190000012KXI2AAO'}),
        Query.conditionGe('NumberOfEmployees', 10)
    };

Query.Condition condition =
    Query.doOr(conditions);

Query q =
    new Query('Account').
    addCondition(condition);

```

</article>

<article id="7">

## Misc

#### public Query switchToDisjunction()

After calling this function, all expression added by `addCondition` or
`addConditionXX` will be joined with the boolean `or` operator, i.e. the query
condition is true if and only if at least one of these expression are true.

```javascript

Query q =
    new Query('Account').
    addCondition(Query.doAnd(
        Query.conditionEq('Name', 'Jack'),
        Query.conditionEq('Phone', '123 456 789')
    )).
    addConditionEq('Name', 'David').
    switchToDisjunction();

```

The example above is equivalent to this query:

```javascript

SELECT Id FROM Account WHERE (Name = 'Jack' AND Phone = '123 456 789) OR (Name = 'David')

```

#### public Query switchToConjunction()

Reverse the effect of `switchToDisjunction`.

After calling this function, all expression added by `addCondition` or
`addConditionXX` will be joined with the boolean `and` operator, i.e. the query
condition is true if and only if all these expression are true.

```javascript

Query q =
    new Query('Account').
    addCondition(Query.doOr(
        Query.conditionEq('Name', 'Jack'),
        Query.conditionEq('Phone', '123 456 789')
    )).
    addConditionEq('Name', 'David').
    switchToDisjunction().
    switchToConjunction();

```

The example above is equivalent to this query:

```javascript

SELECT Id FROM Account WHERE (Name = 'Jack' OR Phone = '123 456 789) AND (Name = 'David')

```

#### public Query resetCondition()

Clear all conditions.

```javascript

Query q =
    new Query('Account').
    addConditionEq('Name', 'David').
    resetCondition();

```

</article>
