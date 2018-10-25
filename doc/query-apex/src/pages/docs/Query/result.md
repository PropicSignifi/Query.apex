---
title: "Result"
description: "Methods to get the Query result"
layout: "guide"
icon: "code-file"
weight: 0
---

###### {$page.description}

<article id="1">

## run

#### public List\<SObject\> run()

Run the query as if running `Database.query()`

Returns a list of SObject

Alias to `toSObjectList()`

```javascript
List<Account> accounts =
    new Query('Account').
    run();
```

## fetch

Fetch a subset of the result

#### public SObject fetch()

Fetch the first SObject from the result

Returns an SObject

```javascript
Account account =
    (Account)
    new Query('Account').
    fetch();
```

#### public SObject fetch(Integer n)

Fetch the nth SObject from the result

Returns an SObject

```javascript
Account account =
    (Account)
    new Query('Account').
    fetch(2);
```

#### public List\<SObject\> fetch(Integer first, Integer last)

Fetch a subset of result in the range [first, last)

Returns a list of SObject

```javascript
List<Account> accounts =
    new Query('Account').
    fetch(2, 4);
```

## toSObjectList

#### public List\<SObject\> toSObjectList()

Run the query as if running `Database.query()`

Returns a list of SObject

Alias to `run()`

```javascript
List<Account> accounts =
    new Query('Account').
    toSObjectList();
```

## toIdList

#### public List\<Id\> toIdList()

Run the query and return the Id list of the result

```javascript
List<Account> accounts =
    new Query('Account').
    toIdList();
```
