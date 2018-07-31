---
title: "Fields Selection Continued"
description: "Select parental fields"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 4
---

## {$page.title}

It's also possible to include fields from a parent. The easiest way would be
passing the parent name to the 'selectAllFields' method:

```javascript
List<Account> accounts =
    new Query('Account').
    selectAllFields('Owner').
    run();
```

This would select the Id field in Account object, as weel as all the user
accessible fields in the Owner reference, which is a User object.

The statement is equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Id, Owner.Id, Owner.Name, Owner.CreatedById ... FROM Account ];
```

Another way would be simply passing the parent field along with the
relationship to the 'selectFields' method:

```javascript
List<Account> accounts =
    new Query('Account').
    selectFields('Owner.Name, Owner.CreatedById').
    run();
```

equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Id, Owner.Name, Owner.CreatedById FROM Account ];
```

Meanwhile, multiple layer parent relationship is supported:

```javascript
List<Account> accounts =
    new Query('Contact').
    selectFields('Account.Owner.Name').
    run();
```

