---
title: "Conditions Part 2"
description: "Add multiple conditions"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 6
---

## {$page.title}

In the previous section, we have learned to add a single condition to the
query. In many cases, however, that is far from enough. So Query.apex allows
calling 'addConditionXX' multiple times, resulting in combining all the
conditions with boolean 'and' operation.

Example:

```javascript
List<Account> accounts =
    new Query('Account').
    addConditionEq('Name', 'Sam').
    addConditionGt('NumberOfEmployees', 0).
    addConditionIn('Phone', new Set<String>{'+61 400 000 000'}).
    run();
```

equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Id FROM Account
      WHERE Name = 'Sam'
      AND NumberOfEmployees > 0
      AND Phone IN :new Set<String>{'+61 400 000 000'} ];
```

Meanwhile, Query.apex provides a method 'switchToDisjunction' to change the
boolean 'and' operator to the boolean 'or' operator. Appending an extra
'switchToDisjunction' method to the same example above:

```javascript
List<Account> accounts =
    new Query('Account').
    addConditionEq('Name', 'Sam').
    addConditionGt('NumberOfEmployees', 0).
    addConditionIn('Phone', new Set<String>{'+61 400 000 000'}).
    switchToDisjunction().
    run();
```

equivalent to:

```javascript
List<Account> accounts =
    [ SELECT Id FROM Account
      WHERE Name = 'Sam'
      OR NumberOfEmployees > 0
      OR Phone IN :new Set<String>{'+61 400 000 000'} ];
```

