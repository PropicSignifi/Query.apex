---
title: "Simple queries"
description: "Some simple queries"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 2
---

## {$page.title}

Lets start with a simplest query: querying all Account records:

```javascript
List<Account> accounts = new Query('Account').run();
```

The 'run' method executes the query and returns the type 'List&lt;SObject&gt;'.

This is equivalent to this statement, selecting only the ID field in the
Account records.

```sql
List<Account> accounts = [ SELECT Id FROM Account ];
```

We can now move further by querying an Account record with a specific Id,
which is quite an common case in development.

```javascript
Account account =
    (Account)new Query('Account').
    byId('0010l00000QJN3MAAX').
    fetch();
```

The 'byId' method limits the result with a specific Id.

The 'fetch' method executes the query and returns the first record in the result.

The statement is equivalent to:

```sql
Account account =
    [ SELECT Id FROM Account WHERE Id = '0010l00000QJN3MAAX' ];
```

That's our first tutorial of Query.apex. We just learned to build a simple query
from Query.apex.
