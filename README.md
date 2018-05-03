# Query.apex

Query.apex provides a flexible and dynamic way of building a SOQL query on the
Salesforce platform.

## Features

- Allows both functional programming and object oriented programming paradigm

- Manages object fields and provides Field Level Security checking

- Supports complex queries including parent/child relationships, and nested
conditions

## Examples

### Get all accounts

This will return a list of all Accounts from the database.

By default it will select all the fields in Account object which the user has
the access privilege on it.

```

List<Account> accounts = new Query('Account').run();

```

### Get an account based on its Id

This will query the Accounts with a specific Id, and return only one SObject as
a result.

```

Account account =
    (Account)new Query('Account').
    byIds('001O000001HMWZVIA5').
    fetch(0);

```

### Get an account based on a foreign key

This will query the Contacts given the AccountId foreign key

```

List<Contact> contacts =
    new Query('Contact').
    lookupIds('AccountId',
    '001O000001HMWZVIA5').run();

```

### Select parent fields

This will select all the fields from the parent object Account.

```

List<Contact> contacts = new Query('Contact').selectParentFields('Account').run();

```

### Query with simple conditions

This will query all the accounts whose 'FirstName' is 'Sam' and 'LastName' is
'Tarly'.

By default, all the conditions are joined by 'AND' operator.

```

List<Account> accounts =
    new Query('Account').
    addConditionEq('FirstName', 'Sam').
    addConditionEq('LastName', 'Tarly').
    run();

```


### Query with complex conditions

For more complicated conditions, we can use the method 'conditionXX' to create a
condition variable, and join these conditions with 'doOr' method or 'doAnd'
method to join these condition variables.

```

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
