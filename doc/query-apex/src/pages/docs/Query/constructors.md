---
title: "Constructors"
description: "Constructors of Query"
layout: "guide"
icon: "code-file"
weight: 1
---

###### {$page.description}

<article id="1">

## Constructors

Creates a new Query instance.

#### public Query(String objectName)

objectName: Name of the expected object.

```javascript
Query query = new Query('Account');
```

#### public Query(Schema.SObjectType objectType)

objectType: An schema SObject type

```javascript
Query query = new Query(Account.getSObjectType());
```

</article>

