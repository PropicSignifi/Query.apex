---
title: "Aggregate Functions"
description: "Aggregate Functions in Query"
layout: "guide"
icon: "code-file"
weight: 6
---

###### {$page.description}

This section describes methods related to aggregate functions. When using any of
these methods, you can only get the result using the `aggregate()` method in the
end.

<article id="1">

## count

Apply `COUNT()` function to a field.

#### public Query count(String field)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

```javascript
new Query('Account').
    count('Id');
```

#### public Query count(String field, String alias)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: The alias set to the aggregate function.

```javascript
new Query('Account').
    count('Id', 'idCount');
```

## countDistinct

Apply `COUNT_DISTINCT()` function to a field.

#### public Query countDistinct(String field)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

```javascript
new Query('Account').
    countDistinct('Id');
```

#### public Query countDistinct(String field, String alias)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: The alias set to the aggregate function.

```javascript
new Query('Account').
    countDistinct('Id', 'idCount');
```

## max

Apply `MAX()` function to a field

#### public Query max(String field)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

```javascript
new Query('Account').
    max('Id');
```

#### public Query max(String field, String alias)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: The alias set to the aggregate function.

```javascript
new Query('Account').
    max('NumberOfEmployees', 'maxEmployees');
```

## min

Apply `MIN()` function to a field

#### public Query min(String field)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

```javascript
new Query('Account').
    min('Id');
```

#### public Query min(String field, String alias)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: The alias set to the aggregate function.

```javascript
new Query('Account').
    min('NumberOfEmployees', 'minEmployees');
```

## avg

Apply `AVG()` function to a field

#### public Query avg(String field)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

```javascript
new Query('Account').
    avg('Id');
```

#### public Query avg(String field, String alias)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: The alias set to the aggregate function.

```javascript
new Query('Account').
    avg('NumberOfEmployees', 'avgEmployees');
```

## sum

Apply `SUM()` function to a field

#### public Query sum(String field)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

```javascript
new Query('Account').
    sum('Id');
```

#### public Query sum(String field, String alias)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: The alias set to the aggregate function.

```javascript
new Query('Account').
    sum('NumberOfEmployees', 'sumEmployees');
```

</article>

<article id="2">

## groupBy

Add the field to the GROUP BY clause.

#### public Query groupBy(String fields)

field: API name of the field, or multiple field names separated by ','.

```javascript
new Query('Account').
    groupBy('Name').
    groupBy('OwnerId, CreatedById');
```

#### public Query groupBy(Set\<String\> fieldSet)

field: A set of fields.

```javascript
new Query('Account').
    groupBy(new Set<String>{'Name', 'CreatedById'});
```

</article>

<article id="3">

## selectField

Select a specific field and set an alias to it.

This method is only available when using aggregate functions.

#### public Query selectField(String field, String alias)

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: Name of the alias.

```javascript
Query query =
    new Query('Account').
    selectField('Name', 'myName').
    groupBy('Name');
```

#### public Query selectField(Schema.SObjectField field, String alias)

field: A Schema.SObjectField.

alias: Name of the alias.

```javascript
Query query =
    new Query(Account.getSObjectType()).
    selectField(Account.Name, 'myName').
    groupBy('Name');
```

</article>

<article id="4">

## addHaving

Add a HAVING clause as conditions of the aggregated query.

#### public Query addHaving(Condition condition)

condition: A Query.Condition.

```javascript
new Query('Account').
count('Name', 'countName').
groupBy('Rating').
addHaving(Query.conditionGe('Count(Name)', 2));
```

</article>

<article id="5">

## aggregate

Get the result of the aggregated query.

Can only be used with aggregate functions.

#### public List\<AggregateResult\> aggregate()

Get the result of the aggregated query.

The returned list is guaranteed to be non-empty.

```javascript
new Query('Account').
    count('Name').
    aggregate();
```

</article>
