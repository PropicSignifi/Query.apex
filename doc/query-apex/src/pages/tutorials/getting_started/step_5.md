---
title: "Conditions"
description: "Add one condition to the query"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 150
weight: 5
---

## {$page.title}

Most of the time, we want to make a query with conditions, typically querying
a record with a specific Id or a lookup field, then we can use the
'addConditionEq' method:

```javascript
Account account =
    (Account)new Query('Account').
    addConditionEq('Id', '0010l00000QJN3MAAX').
    fetch();
```

This statement is querying an Account record with Id '0010l00000QJN3MAAX',
equivalent to this statement:

```javascript
Account account =
    [ SELECT Id FROM Account WHERE Id = '0010l00000QJN3MAAX' ];
```

In previous tutorials we saw another statement which has the same functionality,
using the 'byId' method:

```javascript
Account account =
    (Account)new Query('Account').
    byId('0010l00000QJN3MAAX').
    fetch();
```

Now let's try querying the accounts owned by the current user:

```javascript
List<Account> accounts =
    new Query('Account').
    addConditionEq('OwnerId', UserInfo.getUserId()).
    run();
```

equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Id FROM Account WHERE OwnerId = :UserInfo.getUserId() ];
```

'addConditionEq(String field, Object arg)' is limiting the query with a field
equals to the variable 'arg', while Query.apex provides other operators for
conditions, including
'addConditionNotEq',
'addConditionIn',
'addConditionNotIn',
'addConditionLt',
'addConditionLe',
'addConditionGt',
'addConditionGe' and
'addConditionLike'.

Examples are:

```javascript
new Query('Account').
    addConditionNotEq('Name', 'N/A').
    run();

new Query('Account').
    addConditionIn('Name', new Set<String>{'ABC'}).
    run();

new Query('Account').
    addConditionNotIn('Name', new Set<String>{'N/A'}).
    run();

new Query('Account').
    addConditionLt('NumberOfEmployees', 15).
    run();

new Query('Account').
    addConditionLe('NumberOfEmployees', 10).
    run();

new Query('Account').
    addConditionGt('NumberOfEmployees', 5).
    run();

new Query('Account').
    addConditionGe('NumberOfEmployees', 10).
    run();

new Query('Account').
    addConditionLike('Name', '%ABC%').
    run();
```

