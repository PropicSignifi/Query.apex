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

Run the query as if running `Database.query()`.

#### public List\<SObject\> run()

Returns a list of SObject.

Alias to `toSObjectList()`.

```javascript
List<Account> accounts =
    new Query('Account').
    run();
```

</article>

<article id="2">

## fetch

Fetch a subset of the result.

#### public SObject fetch()

Fetch the first SObject from the result.

Returns an SObject.

```javascript
Account account =
    (Account)
    new Query('Account').
    fetch();
```

#### public SObject fetch(Integer n)

Fetch the n elements from the result.

n: Indicates the number of elements.

Returns an SObject.

```javascript
Account account =
    (Account)
    new Query('Account').
    fetch(2);
```

#### public List\<SObject\> fetch(Integer first, Integer last)

Fetch a subset of result in the range [first, last).

Returns a list of SObject.

```javascript
List<Account> accounts =
    new Query('Account').
    fetch(2, 4);
```

</article>

<article id="3">

## toSObjectList

Run the query as if running `Database.query()`.

#### public List\<SObject\> toSObjectList()

Returns a list of SObject.

Alias to `run()`.

```javascript
List<Account> accounts =
    new Query('Account').
    toSObjectList();
```

</article>

<article id="4">

## toIdList

Run the query and return the Id list of the result.

#### public List\<Id\> toIdList()

Returns a list of Id.

```javascript
List<Id> accounts =
    new Query('Account').
    toIdList();
```

</article>

<article id="5">

## getQueryLocator

Get the QueryLocator that can be used for Batch Apex.

#### public Database.QueryLocator getQueryLocator()

Returns a Database.QueryLocator.

```javascript
Database.QueryLocator locator =
    new Query('Account').
    selectAllFields().
    getQueryLocator();
```

</article>

<article id="6">

## aggregate

Get the result of the aggregated query.

Can only be used with aggregate functions.

#### public List\<AggregateResult\> aggregate()

Get the result of the aggregated query.

Returns a List of AggregateResult.

The returned list is guaranteed to be non-empty.

```javascript
List<AggregateResult> result =
    new Query('Account').
    count('Name').
    aggregate();
```

</article>

<article id="7">

## toQueryString

Get an executable SOQL string that can be used in `Dateabase.query()`.

#### public String toQueryString()

Returns an executable SOQL string.

```javascript
String queryStr = new Query('Account').
    selectAllFields().
    run();
List<Account> accounts = Datebase.query(queryStr);
```

</article>
