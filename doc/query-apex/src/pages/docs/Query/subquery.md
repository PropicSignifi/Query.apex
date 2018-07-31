---
title: "Subquery"
description: "Subquery methods in Query"
layout: "guide"
icon: "code-file"
weight: 4
---

###### {$page.description}

<article id="1">

## addSubquery

Add a subquery to the query, selecting an SObject list from a specific child
relationship.

For example, in this query, the expression enclosed in parentheses is a
subquery:

```javascript

SELECT Name, (SELECT LastName FROM Contacts) FROM Account

```

#### public Query addSubquery(String relationshipName)

relationshipName: Name of the child relationship

```javascript

Query q =
    new Query('Account').
    addSubquery('Contacts');

```

#### public Query addSubquery(String relationshipName, String fields)

relationshipName: Name of the child relationship

fields: One or more field names in the child relationship that will be
selected. If there are more than one field, they will be separated by a
comma ','.

```javascript

Query q =
    new Query('Account').
    addSubquery('Contacts', 'FirstName, LastName').
    addSubquery('Notes', 'Title');

```

#### public Query addSubquery(String relationshipName, Set\<String\> fieldSet)

relationshipName: Name of the child relationship

fieldSet: A set of field names in the child relationship that will be
selected

```javascript

Query q =
    new Query('Account').
    addSubquery('Contacts', new Set<String>{'FirstName', 'LastName'});

```

#### public Query addSubquery(String relationshipName, List\<String\> fieldList)

relationshipName: Name of the child relationship

fieldList: A list of field names in the child relationship that will be
selected

```javascript

Query q =
    new Query('Account').
    addSubquery('Contacts', new List<String>{'FirstName', 'LastName'});

```

#### public Query addSubquery(Query subquery)

subquery: A subquery instance constructed by the static method
`Query.subquery`

```javascript

Query q =
    new Query('Account').
    addSubquery(Query.subquery('Contacts'));

```

</article>

<article id="1">

## subquery

Creates a subquery instance.

The instance can be linked to the main query using the `addSubquery` method
afterwards.

#### public static Query subquery(String relationshipName)

relationshipName: Name of the child relationship

```javascript

Query q =
    new Query('Account').
    addSubquery(Query.subquery('Contacts'));

```

</article>
