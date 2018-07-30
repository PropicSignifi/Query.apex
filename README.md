# Query.apex

Query.apex provides a flexible and dynamic way of building a SOQL query on the
Salesforce platform.

## Why Query.apex

Although Salesforce provides Database.query method to dynamically execute a
query from a string, it is far from easy to construct such a string in a
structural and flexible way. Query.apex is made to improve the flexibility
of the code and consequently enhance the productivity of the development.

## Features

- Allows both functional programming and object oriented programming paradigm

- Supports complex queries including parent/child relationships, and nested
conditions in a flexible way

- Manages the namespace of the object names and field names, while also
providing the Field Level Security checking

## Documentation

https://click-to-cloud.github.io/query-apex/

## Examples

### Get all accounts

This will return a list of all Accounts from the database.

By default it will select only the Id field.

```javascript

List<Account> accounts = new Query('Account').run();

```

### Select all fields

This will return a list of all Accounts from the database, selecting all
fields which the user has access privilege on.

```javascript

List<Account> accounts =
    new Query('Account').
    selectAllFields().
    run();

```

### Get an account based on its Id

This will query the Accounts with a specific Id, and return only one SObject as
a result.

```javascript

Account account =
    (Account)new Query('Account').
    byIds('001O000001HMWZVIA5').
    fetch(0);

```

### Get an account based on a foreign key

This will query the Contacts given the foreign key AccountId

```javascript

List<Contact> contacts =
    new Query('Contact').
    addConditionEq('AccountId', '001O000001HMWZVIA5').
    run();

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

