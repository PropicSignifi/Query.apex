/*
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
@isTest
public class QueryTest {
    @isTest
    static void simpleTest() {
        createData();
        List<Account> accounts = new Query('Account').run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void fieldsTest() {
        createData();

        List<Account> accounts = new Query('Account').
                                 selectFields('Id').
                                 selectFields('Name').
                                 selectFields('FirstName, LastName').
                                 selectFields(new List<String>{'PersonMobilePhone', 'PersonEmail'}).
                                 selectFields(new Set<String>{'PersonHomePhone', 'NumberOfEmployees'}).
                                 run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void parentFieldsTest() {
        createData();

        List<Contact> contacts;

        contacts = new Query('Contact').
            selectParentFields('Account').
            selectParentFields('CreatedBy', 'Name').
            selectParentFields('LastModifiedBy', 'FirstName, LastName').
            selectParentFields('Owner', new Set<String>{'FirstName', 'LastName'}).
            run();

        assertContact(contacts.get(0));

        System.assertEquals(contacts.get(0).Account.Name, 'Sam Tarly');
        System.assertNotEquals(contacts.get(0).CreatedBy.Name, null);
        System.assertNotEquals(contacts.get(0).Owner.FirstName, null);
        System.assertNotEquals(contacts.get(0).LastModifiedBy.LastName, null);
    }

    @isTest
    static void idTest() {
        createData();

        Id accId = [ SELECT Id FROM Account LIMIT 1 ].Id;

        List<Account> accounts;

        accounts = new Query('Account').
                   byIds(accId).
                   run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                   byIds(new Set<Id>{accId}).
                   run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                   byIds(new List<Id>{accId}).
                   run();

        assertAccount(accounts.get(0));

        // negative cases
        final Id wrongId = 'a0EO000000DjJeJMAV';
        accounts = new Query('Account').
                   byIds(wrongId).
                   run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void lookupIdsTest() {
        createData();

        Id accId = [ SELECT Id FROM Account LIMIT 1 ].Id;

        List<Contact> contacts;

        contacts = new Query('Contact').
                   lookupIds('AccountId', accId).
                   run();

        assertContact(contacts.get(0));

        contacts = new Query('Contact').
                   lookupIds('AccountId', new Set<Id>{accId}).
                   run();

        assertContact(contacts.get(0));

        contacts = new Query('Contact').
                   lookupIds('AccountId', new List<Id>{accId}).
                   run();

        assertContact(contacts.get(0));

        // negative cases
        final Id wrongId = 'a0EO000000DjJeJMAV';
        contacts = new Query('Contact').
                   lookupIds('AccountId', wrongId).
                   run();

        System.assert(contacts.isEmpty());
    }

    @isTest
    static void simpleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                   addConditionEq('FirstName', 'Sam').
                   addConditionEq('LastName', 'Tarly').
                   run();

        assertAccount(accounts.get(0));

        // negative cases
        accounts = new Query('Account').
                   addConditionEq('FirstName', 'Sam').
                   addConditionEq('LastName', 'Not Tarly').
                   run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void singleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    addConditionEq('FirstName', 'Sam').
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionNotEq('FirstName', 'Not Sam').
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionIn('FirstName', new Set<String>{'Sam'}).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionNotIn('FirstName', new Set<String>{'Not Sam'}).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionLt('NumberOfEmployees', 15).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionLe('NumberOfEmployees', 10).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionGt('NumberOfEmployees', 5).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionGe('NumberOfEmployees', 10).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    addConditionLike('Name', '%Sam%').
                    run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void disjunctionConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                   switchToDisjunction().
                   addConditionEq('FirstName', 'Sam').
                   addConditionEq('LastName', 'Not Tarly').
                   run();

        assertAccount(accounts.get(0));

        // negative cases

        accounts = new Query('Account').
                   switchToDisjunction().
                   addConditionEq('FirstName', 'Sam').
                   addConditionEq('LastName', 'Not Tarly').
                   switchToConjunction().
                   run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void conditionTypeSimpleTest() {
        createData();

        List<Account> accounts = new Query('Account').
                                 addCondition(Query.conditionEq('FirstName', 'Sam')).
                                 run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void complexConditionTest() {
        createData();

        String firstName = 'Sam';
        List<String> lastName = new List<String>{'Tarly'};
        final Id wrongId = 'a0EO000000DjJeJMAV';

        List<Account> accounts = new Query('Account').
                                    addCondition(
                                        Query.doAnd(
                                            Query.doOr(
                                                Query.conditionEq('FirstName', firstName),
                                                Query.conditionEq('ID', wrongId)
                                            ),
                                            Query.conditionIn('LastName', lastName),
                                            Query.conditionEq('PersonEmail', 'sam@tarly.com'),
                                            Query.conditionLe('NumberOfEmployees', 15)
                                        )
                                    ).
                                    run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void limitTest() {
        createData();
        createData();
        createData();

        List<Account> accounts = new Query('Account').
                                 setLimit(1).
                                 run();

        System.assert(accounts.size() == 1);
        assertAccount(accounts.get(0));
    }

    @isTest
    static void orderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '5');

        insert new List<Account>{acc1, acc2, acc3};

        List<Account> accounts;

        accounts = new Query('Account').
                    orderBy('Rating').
                    descend().
                    run();

        System.assertEquals(accounts.get(0).Name, 'Account 2');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 1');

        accounts = new Query('Account').
                    orderBy('Rating', 'DESC').
                    run();

        System.assertEquals(accounts.get(0).Name, 'Account 2');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 1');
    }

    @isTest
    static void multipleOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', Phone = '110');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', Phone = '120');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', Phone = '130');

        insert new List<Account>{acc1, acc2, acc3};

        List<Account> accounts;

        accounts = new Query('Account').
                    orderBy('Rating').
                    orderBy('Phone').
                    ascend().
                    run();

        System.assertEquals(accounts.get(0).Name, 'Account 1');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 2');
    }

    @isTest
    static void simpleSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                   addSubquery('Contacts').
                   run();

        assertAccount(accounts.get(0));
        assertContact(accounts.get(0).Contacts.get(0));

        accounts = new Query('Account').
                   addSubquery(Query.subquery('Contacts')).
                   run();

        assertAccount(accounts.get(0));
        assertContact(accounts.get(0).Contacts.get(0));
    }

    @isTest
    static void conditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    addSubquery(
                        Query.subquery('Contacts').
                        addConditionEq('Email', 'sam@tarly.com')
                    ).
                    run();

        assertAccount(accounts.get(0));
        assertContact(accounts.get(0).Contacts.get(0));

    }

    @isTest
    static void complexConditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    addCondition(
                        Query.doOr(
                            Query.conditionIn('FirstName', new Set<String>{'Sam'}),
                            Query.conditionEq('Lastname', 'N/A')
                        )
                    ).
                    addSubquery(
                        Query.subquery('Contacts').
                        addCondition(
                            Query.doOr(
                                Query.conditionIn('Email', new Set<String>{'sam@tarly.com'}),
                                Query.conditionEq('Email', 'N/A'),
                                Query.doAnd(
                                    Query.conditionEq('Email', 'N/A'),
                                    Query.conditionEq('HomePhone', 'N/A'),
                                    Query.conditionEq('MobilePhone', 'N/A')
                                )
                            )
                        )
                    ).
                    run();

        assertAccount(accounts.get(0));
        assertContact(accounts.get(0).Contacts.get(0));

    }
    static void createData() {
        Account acc = new Account();
        acc.FirstName = 'Sam';
        acc.LastName = 'Tarly';
        acc.PersonMobilePhone = '+61 410 000 000';
        acc.PersonHomePhone = '+61 2 0000 0000';
        acc.PersonEmail = 'sam@tarly.com';
        acc.NumberOfEmployees = 10;

        insert acc;
    }

    static void assertAccount(Account acc) {
        System.assertEquals(acc.Name, 'Sam Tarly');
        System.assertEquals(acc.FirstName, 'Sam');
        System.assertEquals(acc.LastName, 'Tarly');
        System.assertEquals(acc.PersonMobilePhone, '+61 410 000 000');
        System.assertEquals(acc.PersonHomePhone, '+61 2 0000 0000');
        System.assertEquals(acc.PersonEmail, 'sam@tarly.com');
        System.assertEquals(acc.NumberOfEmployees, 10);
    }

    static void assertContact(Contact con) {
        System.assertEquals(con.Name, 'Sam Tarly');
        System.assertEquals(con.FirstName, 'Sam');
        System.assertEquals(con.LastName, 'Tarly');
        System.assertEquals(con.MobilePhone, '+61 410 000 000');
        System.assertEquals(con.HomePhone, '+61 2 0000 0000');
        System.assertEquals(con.Email, 'sam@tarly.com');
    }

}
