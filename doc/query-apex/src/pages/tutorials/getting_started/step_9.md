---
title: "Aggregate Functions Part 1"
description: "Construct queries with simple aggregate functions"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 120
weight: 9
---

## {$page.title}

Query.apex now supports the powerful aggregate functions. Features include
'count', 'countDistinct', 'max', 'min', 'avg', 'sum', 'group by' clauses,
and even 'having' clauses.

A simple aggregate function can be:

```javascript
List<AggregateResult> result =
    new Query('Account').
    max('NumberOfEmployees', 'maxEmployees').
    aggregate();
```

Its equivalent a static SOQL looks like this:

```javascript
List<AggregateResult> result =
    [ SELECT Max(NumberOfEmployees) maxEmployees FROM Account ];
```

In this example, the query finds the maximum number in the NumberOfEmployees
field of all available Accounts, and use 'maxEmployees' as an alias of the
aggregate function.

As you can see, the return type is a list of AggregateResult, which is a
standard Salesforce class. Since we are not using any 'group by' clauses,
we can safely assume there is one and only one element in this list. To get
the result of the aggregate function we can use the alias we just set.

```javascript
List<AggregateResult> result =
    new Query('Account').
    max('NumberOfEmployees', 'maxEmployee').
    aggregate();

Integer maxEmployee = (Integer)result[0].get('maxEmployee');
```
