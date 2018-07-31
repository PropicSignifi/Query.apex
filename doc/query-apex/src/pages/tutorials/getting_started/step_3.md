---
title: "Fields Selection"
description: "Select specific fields"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 3
---

## {$page.title}

By default Query.apex will select only the Id field in the SObject, however
we can override this if we want to select other fields.

For example, this query will only select only the Name field from the Account
object.

```javascript
List<Account> accounts =
    new Query('Account').selectFields('Name').run();
```

This is equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Name FROM Account ];
```

We can also call 'selectFields' method multiple times, the result is additive:

```javascript
List<Account> accounts =
    new Query('Account').
    selectFields('Name').
    selectFields('Phone').
    selectFields('Website').
    selectFields('Description').
    run();
```

That's equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Name, Phone, Website, Description FROM Account ];
```

Alternatively, we can put all the fields in one 'selectFields' method, still
preserving the additivity:

```javascript
List<Account> accounts =
    new Query('Account').
    selectFields('Name, Phone, Website').
    selectFields('Description').
    run();
```

Compare with:

```javascript
List<String> fields = new List<String>{'Name', 'Phone', 'Website'};
List<Account> accounts =
    new Query('Account').
    selectFields(fields).
    selectFields('Description').
    run();
```

or:

```javascript
Set<String> fields = new Set<String>{'Name', 'Phone', 'Website'};
List<Account> accounts =
    new Query('Account').
    selectFields(fields).
    selectFields('Description').
    run();
```

To make user convenient, Query.apex provides the 'selectAllFields' method to
select all user accessible fields:

```javascript
List<Account> accounts =
    new Query('Account').
    selectAllFields().
    run();
```
