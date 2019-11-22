---
title: "Aggregate Functions Part 3"
description: "Construct aggregate functions with having clauses"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 120
weight: 11
---

## {$page.title}

With HAVING clauses, aggregate functions can be even more powerful. See this
example:

Suppose we have a parent object Account, and a child object Opportunity, I
want to query all the Accounts with at least one Opportunity. If we use
child relationship query (subquery), we might still get all the Accounts,
with some of them having the Opportunity child as an empty list. And then we
need to do the filter manually, removing the Accounts with empty Opportunity
list. Apparently, such way costs unnecessary memory.

But we can actually do it in one query, using GROUP BY and HAVING clauses.

```javascript
List<AggregateResult> results =
    new Query('Opportunity').
    selectField('AccountId').
    count('Name', 'countName').
    groupBy('AccountId').
    addHaving(Query.conditionGe('Count(Name)', 1)).
    aggregate();

// Loop the aggregate result to get the account ids
List<Id> accountIds = new List<Id>();
for (AggregateResult result : results) {
    accountIds.add((Id)result.get('AccountId'));
}
```
