---
title: "Field Selection"
description: "Field selection methods in Query"
layout: "guide"
icon: "code-file"
weight: 2
---

###### {$page.description}

<article id="1">

## selectFields

Select specific fields.

#### public Query selectFields(String field)

field: Name of one field, or multiple field names separated by ','.

```javascript

Query query =
    new Query('Account').
    selectFields('Name').
    selectFields('OwnerId, CreatedById');

```

#### public Query selectFields(List\<String\> fieldList)

fieldList: A list of field names.

```javascript

Query query =
    new Query('Account').
    selectFields(new List<String>{'OwnerId', 'CreatedById'});

```

#### public Query selectFields(Set\<String\> fieldSet)

fieldSet: A Set of field names.

```javascript

Query query =
    new Query('Account').
    selectFields(new Set<String>{'OwnerId', 'CreatedById'});

```

</article>

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
