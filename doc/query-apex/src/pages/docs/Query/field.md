---
title: "Field Selection"
description: "Field selection methods in Query"
layout: "guide"
icon: "code-file"
weight: 3
---

###### {$page.description}

<article id="1">

## selectField

#### public Query selectField(String field)

Select a specific field.

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

```javascript
Query query =
    new Query('Account').
    selectField('Name').
    selectField('Owner.Name');
```

#### public Query selectField(Schema.SObjectField field)

Select a specific field.

field: A Schema.SObjectField.

```javascript
Query query =
    new Query(Account.getSObjectType()).
    selectField(Account.Name).
    selectField(Account.OwnerId);
```

#### public Query selectField(String field, String alias)

Select a specific field and set an alias to it.

This method is only available when using aggregate functions.

field: API name of the field. Can also be a field of a parent, e.g. 'Owner.Name'.

alias: Name of the alias.

```javascript
Query query =
    new Query('Account').
    selectField('Name', 'myName').
    groupBy('Name');
```

#### public Query selectField(Schema.SObjectField field, String alias)

Select a specific field and set an alias to it.

This method is only available when using aggregate functions.

field: A Schema.SObjectField.

alias: Name of the alias.

```javascript
Query query =
    new Query(Account.getSObjectType()).
    selectField(Account.Name, 'myName').
    groupBy('Name');
```

</article>

<article id="2">

## selectFields

Select specific fields.

#### public Query selectFields(String field)

field: API name of the field, or multiple field names separated by ','.

```javascript
Query query =
    new Query('Account').
    selectFields('Name').
    selectFields('OwnerId, CreatedById');
```

#### public Query selectFields(List\<String\> fieldList)

fieldList: A list of field API names.

```javascript
Query query =
    new Query('Account').
    selectFields(new List<String>{'OwnerId', 'CreatedById'});
```

#### public Query selectFields(Set\<String\> fieldSet)

fieldSet: A Set of field API names.

```javascript
Query query =
    new Query('Account').
    selectFields(new Set<String>{'OwnerId', 'CreatedById'});
```

#### public Query selectFields(Schema.SObjectField field)

Alias of `selectField(Schema.SObjectField field)`

field: A Schema.SObjectField

```javascript
Query query =
    new Query(Account.getSObjectType()).
    selectField(Account.Name).
    selectField(Account.OwnerId);
```

#### public Query selectFields(Set\<Schema.SObjectField\> fields)

fields: A Set of Schema.SObjectField

```javascript
Query query =
    new Query(Account.getSObjectType()).
    selectFields(new Set<Schema.SObjectField>{Account.Name, Account.OwnerId});
```

#### public Query selectFields(List\<Schema.SObjectField\> fields)

fields: A List of Schema.SObjectField

```javascript
Query query =
    new Query(Account.getSObjectType()).
    selectFields(new List<Schema.SObjectField>{Account.Name, Account.OwnerId});
```

</article>

<article id="3">

## selectAllFields

#### public Query selectAllFields()

Select all accessible fields in the current object

```javascript
Query query =
    new Query('Account').
    selectAllFields();
```

#### public Query selectAllFields(String parentField)

Select all accessible fields in the parent field

```javascript

Query query =
    new Query('Account').
    selectAllFields('Owner');

```

</article>
