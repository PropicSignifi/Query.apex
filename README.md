# Query.apex

Query.apex provides a flexible and dynamic way of building a SOQL query on the
Salesforce platform.

## Why Query.apex

Although Salesforce provides Database.query method to dynamically execute a
query from a string, it is far from easy to construct such a string in a
structural and flexible way. Query.apex is made to improve the flexibility
of the code and consequently enhance the productivity of the development.

## Features

- Allows object oriented programming paradigm and function chaining

- Supports complex queries including parent/child relationships, and nested
conditions in a flexible way

- Supports aggregate functions including group by methods

- Manages the namespace of the object names and field names, while also
providing the Field Level Security checking

## Documentation

You can find the documentation in

https://click-to-cloud.github.io/query-apex/

As well as the tutorial

https://click-to-cloud.github.io/query-apex/tutorials/getting_started/

## Examples

### Get all accounts

This will return a list of all Accounts from the database.

By default it will select only the Id field.

```javascript

List<Account> accounts = new Query('Account').run();

```

### Select all fields

This will query all Accounts from the database, selecting all fields which
the user has access privilege on.

```javascript

List<Account> accounts =
    new Query('Account').
    selectAllFields().
    run();

```

### Select specific fields

This will query all Accounts from the database, selecting specified fields only.

```javascript

List<Account> accounts =
    new Query('Account').
    selectField('Name').
    selectFields('CreatedById').
    selectFields('CreatedDate, LastModifiedDate').
    selectFields(new List<String>{'LastActivityDate', 'LastViewedDate'}).
    run();

```

### Get an account based on its Id

This will query the Accounts with a specific Id, and return only one SObject as
a result.

```javascript

Account account =
    (Account)new Query('Account').
    byId('001O000001HMWZVIA5').
    fetch();

```

### Get a list of contacts based on a foreign key

This will query the Contacts given the foreign key AccountId.

```javascript

List<Contact> contacts =
    new Query('Contact').
    lookup('AccountId', '001O000001HMWZVIA5').
    run();

```

### Get a list of Id of the query result

This will query all the Accounts and return a list of Id as a result.

```javascript

List<Account> accounts =
    new Query('Account').
    toIdList();

```

### Select parent fields

This will select all the fields from the parent object Account.

```javascript

List<Contact> contacts =
    new Query('Contact').
    selectAllFields('Account').
    run();

```

### Query with simple conditions

This will query all the accounts whose 'FirstName' is 'Sam' and 'LastName' is
'Tarly'.

By default, all the conditions are joined by the 'AND' operator.

```javascript

List<Account> accounts =
    new Query('Account').
    addConditionEq('Name', 'Sam').
    addConditionLt('NumberOfEmployees', 10).
    run();

```

### Query with complex conditions

For more complicated conditions, we can use the method 'conditionXX' to create a
condition variable, before using the 'doOr' method or 'doAnd' boolean operation
methods to join these conditions.

```javascript

List<Account> accounts =
    new Query('Account').
    addCondition(
        Query.doAnd(
            Query.doOr(
                Query.conditionEq('FirstName', 'Sam'),
                Query.conditionEq('Id', '001O000001HMWZVIA5')
            ),
            Query.conditionLe('NumberOfEmployees', 15)
        )
    ).
    run();

```

### Query with date literal conditions

We can also use date literals in conditions.

```javascript

List<Account> accounts =
    new Query('Account').
    addConditionLe('LastModifiedDate', Query.TODAY).
    addConditionEq('CreatedDate', Query.LAST_N_WEEKS(3)).
    run();

```

### Query with conditions with INCLUDES/EXCLUDES operator

INCLUDES and EXCLUDES operator can be used on multi-picklist fields.

The following example is querying `QuickText` with the `Channel` field that
includes both the two values at the same time:

```javascript
List<QuickText> result = new Query('QuickText').
    addConditionIncludes('Channel', 'MyChannel;OtherChannel').
    run();
```

In contrast, this example is a condition that includes any of the two values: 

```javascript
List<QuickText> result = new Query('QuickText').
    addConditionIncludes('Channel', new List<String>{'MyChannel', 'OtherChannel'}).
    run();
```

### Query with subqueries

Query.apex also allows selecting child relationships (subqueries), in a
functional style similar to the conditions.

```javascript

List<Account> accounts =
    new Query('Account').
    addSubquery(
        Query.subquery('Contacts').
        addConditionEq('FirstName', 'Sam').
        addConditionIn('LastName', new List<String>{'Tarly'})
    ).
    run();

```

### Simple aggregate functions

Aggregate functions including 'count', 'countDistinct', 'max', 'min', 'avg',
'sum' are supported, but user needs to call another method named 'aggregate'
to get the result.

The 'aggregate' method returns a list of 'AggregateResult' items.

```javascript
AggregateResult result =
    new Query('Account').
    count('Name', 'countName').
    countDistinct('Rating', 'countRating').
    max('NumberOfEmployees', 'maxEmployee').
    min('NumberOfEmployees', 'minEmployee').
    avg('NumberOfEmployees', 'avgEmployee').
    sum('NumberOfEmployees', 'sumEmployee').
    aggregate()[0];

Integer countName = (Integer)result.get('countName');
Integer countRating = (Integer)result.get('countRating');
Integer maxEmployee = (Integer)result.get('maxEmployee');
Integer minEmployee = (Integer)result.get('minEmployee');
Decimal avgEmployee = (Decimal)result.get('avgEmployee');
Integer sumEmployee = (Integer)result.get('sumEmployee');
```

In this example, 'countName', 'maxEmployee', and so forth are the alias for
the aggregate functions. Since there is no group by clauses used, the returned
list has one and only one item. You can get the value of an aggregated field
using the 'get' method in the first 'AggregateResult' item.

### Aggregate functions combined with group by clause

Aggregate functions are more useful combined with the 'groupBy' method, so that
each group can have its own aggregate result. Similar to the simple aggregate
functions, the 'aggregate' method is needed to get the aggregate results, which
will return a list of 'AggregateResult' items.

```javascript
List<AggregateResult> results =
    new Query('Account').
    selectField('Rating').
    count('Name', 'countName').
    max('NumberOfEmployees', 'maxEmployee').
    min('NumberOfEmployees', 'minEmployee').
    avg('NumberOfEmployees', 'avgEmployee').
    sum('NumberOfEmployees', 'sumEmployee').
    groupBy('Rating').
    aggregate();

for (AggregateResult result : results) {
    System.debug('Rating: ' + result.get('Rating'));
    System.debug('maxEmployee: ' + result.get('maxEmployee'));
    System.debug('minEmployee: ' + result.get('minEmployee'));
    System.debug('avgEmployee: ' + result.get('avgEmployee'));
    System.debug('sumEmployee: ' + result.get('sumEmployee'));
}
```

Note that we can only select fields that appear in the group by method. In
this example, only the 'Rating' field is in the group by clause, so only the
'Rating' field can be selected.
