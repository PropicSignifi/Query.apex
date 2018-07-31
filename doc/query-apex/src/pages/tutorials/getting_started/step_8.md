---
title: "Subqueries"
description: "Querying child relationships"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 120
weight: 8
---

## {$page.title}

In this section, we will see how a child relationship query, sometimes called
subquery, can be constructed. But before that, let's review how a subquery
works in Salesforce:

Take the objects Account and Contact as an example. Contact object has a
lookup field (foreign key) pointing to a Contact, so Account is the parent of
Contact, and in reverse Contact is the child of Account. We already saw that
in previous sections, when querying the Contact object, it's also possible to
get the fields in the parent object, which is Account object in this case.
However, it would be slightly more complicated when trying to query a field
from a child.

Here is an example of such a query in SOQL:

```

SELECT Name, (SELECT FirstName, LastName FROM Contacts) FROM Account

```

In this case, 'Contacts' is the child relationship name, and the query inside
the parentheses is a subquery.

Let's see how to construct such a query using Query.apex:

```javascript

List<Account> accounts =
    new Query('Account').
    addSubquery(
        Query.subquery('Contacts').
        selectFields('FirstName, LastName')
    ).
    run();

```

Similar to the condition, we need to construct a subquery using the static
method 'subquery', which takes a child relationship name as a parameter,
before calling the 'addSubquery' member method.

Here is another example of a subquery with conditions and limits:

```javascript

List<Account> accounts =
    new Query('Account').
    addSubquery(
        Query.subquery('Contacts').
        addConditionEq('FirstName', 'Sam').
        addConditionIn('LastName', new List<String>{'Tarly'})
    ).
    run();

```

As we can see, after constructing the subquery, we can still do field selection
and add conditions using the same methods in Query. Using a combination of the
methods above, we should be able to build a query with a subquery in any
complexity.
