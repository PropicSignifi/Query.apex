---
title: "Conditions Part 3"
description: "Add more complex conditions"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 180
weight: 7
---

## {$page.title}

We have learned to add multiple conditions in the previous section, but
those conditions were very limited. What if we want to construct a condition
with a combination of both boolean operators? 

In order to do that, we have to construct a 'Condition' variable, before
combining these conditions with the boolean operations, followed by an
'addCondition' method to link the condition with the query.

A typical example would be:

```javascript
List<Account> accounts =
    new Query('Account').
    addCondition(
        Query.doOr(
            Query.conditionEq('Name', 'Sam'),
            Query.doAnd(
                Query.conditionGt('NumberOfEmployees', 0),
                Query.conditionIn('Phone', new Set<String>{'+61 400 000 000'})
            )
        )
    ).
    run();
```

This statement is equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Id FROM Account
      WHERE Name = 'Sam' OR
      (
        NumberOfEmployees > 0 AND
        Phone IN :new Set<String>{'+61 400 000 000'}
      )
    ];
```

Let me explain the example step by step. 'Query.conditionXX' are a series
static methods that construct a 'Condition' variable, similar to the member
methods 'addCondtionXX', these include:
'conditionNotEq',
'conditionIn',
'conditionNotIn',
'conditionLt',
'conditionLe',
'conditionGt',
'conditionGe' and
'conditionLike'.

Then, we can run boolean operations on any 'Condition' variables. Because the
fact that 'AND' and 'OR' have been reserved keyword in apex language, we have
to use 'doAnd' and 'doOr' as replacement method names. These two methods are
both static methods, with 'Condition' as the return type, so that the return
value can be a parameter of another boolean operation.

A sample code from the example above:

```javascript
Query.Condition condition =
    Query.doAnd(
        Query.conditionGt('NumberOfEmployees', 0),
        Query.conditionIn('Phone', new Set<String>{'+61 400 000 000'})
    );
```

A more complicated example from above:

```javascript
Query.Condition condition =
    Query.doOr(
        Query.conditionEq('Name', 'Sam'),
        Query.doAnd(
            Query.conditionGt('NumberOfEmployees', 0),
            Query.conditionIn('Phone', new Set<String>{'+61 400 000 000'})
        )
    );
```

It's also possible to pass up to 4 parameters in each boolean operation:

```javascript
Query.Condition condition =
    Query.doOr(
        Query.conditionEq('Name', 'Sam'),
        Query.conditionGt('NumberOfEmployees', 0),
        Query.conditionIn('Phone', new Set<String>{'+61 400 000 000'}),
        Query.conditionEq('Email', 'sam@tarly.com')
    );
```

Once we have constructed our Condition variable, we can pass the condition to
the query, using its member method 'addCondition'. Let's try a simple
condition first:

```javascript
Query.Condition condition = Query.conditionEq('Name', 'Sam');
List<Account> accounts =
    new Query('Account').
    addCondition(condition).
    run();
```

which is indeed equivalent to:

```javascript
List<Account> accounts =
    new Query('Account').
    addConditionEq('Name', 'Sam').
    run();
```

But this time, we can create more complicated conditions:

```javascript
Query.Condition condition =
    Query.doOr(
        Query.conditionEq('Name', 'Sam'),
        Query.doAnd(
            Query.conditionGt('NumberOfEmployees', 0),
            Query.conditionIn('Phone', new Set<String>{'+61 400 000 000'})
        )
    );

List<Account> accounts =
    new Query('Account').
    addCondition(condition).
    run();
```

or we can write it in one statement, which is identical to the first example
we saw in this section.

```javascript
List<Account> accounts =
    new Query('Account').
    addCondition(
        Query.doOr(
            Query.conditionEq('Name', 'Sam'),
            Query.doAnd(
                Query.conditionGt('NumberOfEmployees', 0),
                Query.conditionIn('Phone', new Set<String>{'+61 400 000 000'})
            )
        )
    ).
    run();
```

We can still call 'addConditionXX' methods and 'addCondition' simultaneously,
which by default, will combine the conditions with boolean 'and' operations,
unless calling the 'switchToDisjunction' method explicitly:

```javascript
List<Account> accounts =
    new Query('Account').
    addCondition(
        Query.doOr(
            Query.conditionEq('Name', 'Sam'),
            Query.conditionGt('NumberOfEmployees', 0)
        )
    ).
    addConditionIn('Phone', new Set<String>{'+61 400 000 000'}).
    run();
```

which is equivalent to:

```javascript
List<Account> accounts =
    new Query('Account').
    addCondition(
        Query.doAnd(
            Query.doOr(
                Query.conditionEq('Name', 'Sam'),
                Query.conditionGt('NumberOfEmployees', 0)
            ),
            Query.conditionIn('Phone', new Set<String>{'+61 400 000 000'})
        )
    ).
    run();
```

After this section, you will be capable of creating a query with any complex
conditions.
