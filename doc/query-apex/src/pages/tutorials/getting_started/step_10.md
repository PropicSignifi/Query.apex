---
title: "Aggregate Functions Part 2"
description: "Construct aggregate functions with group by clauses"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 120
weight: 10
---

## {$page.title}

Aggregate functions are more useful combined with the 'groupBy' method, so that
each group can have its own aggregate result. Similar to the simple aggregate
functions, the 'aggregate' method is needed to get the aggregate results, which
will return a list of 'AggregateResult' items.

```javascript
List<AggregateResult> results =
    new Query('Account').
    selectField('Rating').
    count('Name', 'countName').
    max('NumberOfEmployees', 'maxEmployees').
    groupBy('Rating').
    aggregate();
```

This example tries to group the accounts based on their rating, and for each
rating group it tries to find the maximum number of employees.

```javascript
for (AggregateResult result : results) {
    System.debug('Rating: ' + result.get('Rating'));
    System.debug('maxEmployees: ' + result.get('maxEmployees'));
}
```

Note that we can only select fields that appear in the group by method. In
this example, only the 'Rating' field appears in the group by clause, so only
the 'Rating' field can be selected.
