---
title: "Result"
description: "Methods to get the Query result"
layout: "guide"
icon: "code-file"
weight: 2
---

###### {$page.description}

<article id="1">

## run

Run the query as if running `Database.query()`

#### public List\<SObject\> run()

Returns a list of SObject

Alias to `toSObjectList()`

```javascript
List<Account> accounts =
    new Query('Account').
    run();
```

</article>

<article id="2">

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

n: Indicates the nth SObject in the result list, starting with 0

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

</article>

<article id="3">

## toSObjectList

Run the query as if running `Database.query()`

#### public List\<SObject\> toSObjectList()

Returns a list of SObject

Alias to `run()`

```javascript
List<Account> accounts =
    new Query('Account').
    toSObjectList();
```

</article>

<article id="4">

## toIdList

Run the query and return the Id list of the result

#### public List\<Id\> toIdList()

Returns a list of Id

```javascript
List<Id> accounts =
    new Query('Account').
    toIdList();
```

</article>
