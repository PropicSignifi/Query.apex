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
        List<Account> accounts;

        accounts = new Query('Account').
            selectAllFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectAllFields().
            run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void fetchTest() {
        Account acc0 = new Account(Name = 'Account 0');
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');

        insert new List<Account>{acc0, acc1, acc2};

        List<Account> accounts = new Query('Account').
            selectAllFields().
            fetch(1, 3);

        System.assertEquals(accounts.size(), 2);
        System.assertEquals(accounts.get(0).Name, 'Account 1');
        System.assertEquals(accounts.get(1).Name, 'Account 2');

        Account account;

        account = (Account)new Query('Account').
            selectAllFields().
            fetch(1);
        System.assertEquals(account.Name, 'Account 1');

        account = (Account)new Query('Account').
            selectAllFields().
            fetch();
        System.assertEquals(account.Name, 'Account 0');

    }

    @isTest
    static void fieldsTest() {
        createData();

        List<Account> accounts = new Query('Account').
                                 selectFields('Id').
                                 selectFields('Name').
                                 selectFields('Phone, Sic').
                                 selectFields(new List<String>{'NumberOfEmployees', 'Website'}).
                                 selectFields(new Set<String>{'Fax', 'Site'}).
                                 selectAllFields().
                                 run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void parentFieldsTest() {
        createData();

        List<Opportunity> opportunities;

        opportunities = new Query('Opportunity').
            selectAllFields().
            selectAllFields('CreatedBy').
            selectAllFields('Account.LastModifiedBy').
            selectFields('Account.CreatedBy.FirstName').
            selectFields('LastModifiedBy.FirstName, LastModifiedBy.LastName').
            selectFields(new List<String>{'Owner.FirstName', 'Owner.LastName'}).
            run();

        assertOpportunity(opportunities.get(0));

        System.assertNotEquals(opportunities.get(0).CreatedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Account.CreatedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Account.LastModifiedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).LastModifiedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).LastModifiedBy.LastName, null);
        System.assertNotEquals(opportunities.get(0).Owner.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Owner.LastName, null);
    }

    @isTest
    static void idTest() {
        createData();

        Id accId = [ SELECT Id FROM Account LIMIT 1 ].Id;

        List<Account> accounts;

        accounts = new Query('Account').
                   selectAllFields().
                   byId(accId).
                   run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                   selectAllFields().
                   byId(new Set<Id>{accId}).
                   run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                   selectAllFields().
                   byId(new List<Id>{accId}).
                   run();

        assertAccount(accounts.get(0));

        // negative cases
        final Id wrongId = 'a0EO000000DjJeJMAV';
        accounts = new Query('Account').
                   selectAllFields().
                   byId(wrongId).
                   run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void simpleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionEq('Name', 'ABC Ltd').
                    addConditionEq('Phone', '+61 410 000 000').
                    run();

        assertAccount(accounts.get(0));

        // negative cases
        accounts = new Query('Account').
                    selectAllFields().
                    addConditionEq('Name', 'ABC Ltd').
                    addConditionEq('Phone', '+61 410 111 111').
                    run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void singleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionEq('Name', 'ABC Ltd').
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionNotEq('Name', 'CDE Ltd').
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionIn('Name', new Set<String>{'ABC Ltd'}).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionNotIn('Name', new Set<String>{'CDE Ltd'}).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionLt('NumberOfEmployees', 15).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionLe('NumberOfEmployees', 10).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionGt('NumberOfEmployees', 5).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionGe('NumberOfEmployees', 10).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionLike('Name', '%ABC%').
                    run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void disjunctionConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                   selectAllFields().
                   switchToDisjunction().
                   addConditionEq('Name', 'ABC Ltd').
                   addConditionEq('Phone', '+61 410 111 111').
                   run();

        assertAccount(accounts.get(0));

        // negative cases

        accounts = new Query('Account').
                   selectAllFields().
                   switchToDisjunction().
                   addConditionEq('Name', 'ABC Ltd').
                   addConditionEq('Phone', '+61 410 111 111').
                   switchToConjunction().
                   run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void conditionTypeSimpleTest() {
        createData();

        List<Account> accounts = new Query('Account').
                                 selectAllFields().
                                 addCondition(Query.conditionEq('Name', 'ABC Ltd')).
                                 run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void complexConditionTest() {
        createData();

        String accName = 'ABC Ltd';
        List<String> accPhone = new List<String>{'+61 410 000 000'};
        final Id wrongId = 'a0EO000000DjJeJMAV';

        List<Account> accounts =
                new Query('Account').
                selectAllFields().
                addCondition(
                    Query.doAnd(
                        Query.doOr(
                            Query.conditionEq('Name', accName),
                            Query.conditionEq('Id', wrongId)
                        ),
                        Query.conditionIn('Phone', accPhone),
                        Query.conditionEq('Website', 'https://www.samplewebsite.com'),
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
                                 selectAllFields().
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
                    selectAllFields().
                    orderBy('Rating').
                    descend().
                    run();

        System.assertEquals(accounts.get(0).Name, 'Account 2');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 1');

        accounts = new Query('Account').
                    selectAllFields().
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
                    selectAllFields().
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
                   selectAllFields().
                   addSubquery('Opportunities').
                   run();

        assertAccount(accounts.get(0));
        System.assert(accounts.get(0).Opportunities.get(0).Id != null);

        accounts = new Query('Account').
                   selectAllFields().
                   addSubquery(Query.subquery('Opportunities').selectAllFields()).
                   run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
    }

    @isTest
    static void conditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addSubquery(
                        Query.subquery('Opportunities').
                        selectAllFields().
                        addConditionEq('TotalOpportunityQuantity', 10)
                    ).
                    run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));

    }

    @isTest
    static void complexConditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addCondition(
                        Query.doOr(
                            Query.conditionIn('Name', new Set<String>{'ABC Ltd'}),
                            Query.conditionEq('Phone', 'N/A')
                        )
                    ).
                    addSubquery(
                        Query.subquery('Opportunities').
                        selectFields('Name, CloseDate, TotalOpportunityQuantity').
                        addCondition(
                            Query.doOr(
                                Query.conditionIn('TotalOpportunityQuantity',
                                        new Set<Integer>{10}),
                                Query.conditionEq('Name', 'N/A'),
                                Query.doAnd(
                                    Query.conditionEq('CloseDate', Date.today().addDays(1)),
                                    Query.conditionEq('Name', 'N/A'),
                                    Query.conditionEq('Name', 'N/A')
                                ),
                                Query.doOr(
                                    Query.conditionEq('CloseDate', Date.today().addDays(1)),
                                    Query.conditionEq('Name', 'N/A'),
                                    Query.conditionEq('Name', 'N/A')
                                )
                            )
                        )
                    ).
                    run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));

    }

    @isTest
    static void literalConditionTest() {
        createData();

        Account account;
        Opportunity opp;

        account = (Account)new Query('Account').
                selectAllFields().
                addConditionEq('AnnualRevenue', Query.Literal.NIL).
                fetch();

        assertAccount(account);

        opp = (Opportunity)new Query('Opportunity').
                selectAllFields().
                addConditionEq('IsPrivate', Query.Literal.F).
                fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
                selectAllFields().
                addConditionNotEq('IsPrivate', Query.Literal.T).
                fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
                selectAllFields().
                addConditionGe('CloseDate', Query.Literal.TODAY).
                fetch();

        assertOpportunity(opp);
    }

    @isTest
    static void debugTest() {
        Id id = '001O000000qkv3KIAQ';
        List<Id> idList = new List<Id>{id};
        Set<Id> idSet = new Set<Id>{id};
        List<String> stringList = new List<String>();
        Set<String> stringSet = new Set<String>();
        List<Decimal> decimalList = new List<Decimal>{1.234};
        Set<Decimal> decimalSet = new Set<Decimal>{1.234};
        List<Integer> integerList = new List<Integer>{1};
        Set<Integer> integerSet = new Set<Integer>{1};

        Query query = new Query('Account').
            addConditionEq('RecordTypeId', id).
            addConditionEq('OwnerId', id).
            addConditionEq('CreatedBy', id).
            addConditionEq('LastModifiedBy', id).
            addConditionEq('Owner', id).
            addConditionEq('RecordTypeId', idList).
            addConditionEq('OwnerId', idList).
            addConditionEq('CreatedBy', idList).
            addConditionEq('RecordTypeId', idSet).
            addConditionEq('OwnerId', idSet).
            addConditionEq('CreatedBy', idSet).
            addConditionIn('LastModifiedBy', stringList).
            addConditionIn('Owner', stringList).
            addConditionIn('LastModifiedBy', stringSet).
            addConditionIn('Owner', stringSet).
            addConditionIn('AnnualRevenue', decimalList).
            addConditionIn('AnnualRevenue', decimalSet).
            addConditionIn('NumberOfEmployees', integerList).
            addConditionIn('NumberOfEmployees', integerSet).
            addConditionEq('NumberOfEmployees', 1).
            debug();

        System.assert(query != null);
    }

    static void createData() {
        Account acc = new Account();
        acc.Name = 'ABC Ltd';
        acc.Phone = '+61 410 000 000';
        acc.Sic = 'D001';
        acc.NumberOfEmployees = 10;
        acc.Website = 'https://www.samplewebsite.com';
        acc.Fax = '+61 2 0000 0000';
        acc.Site = 'Sydney';

        insert acc;

        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'New Opportunity';
        opp.CloseDate = Date.today().addDays(3);
        opp.TotalOpportunityQuantity = 10;
        opp.StageName = 'New';
        opp.IsPrivate = false;

        insert opp;
    }

    static void assertAccount(Account acc) {
        System.assertEquals(acc.Name, 'ABC Ltd');
        System.assertEquals(acc.Phone, '+61 410 000 000');
        System.assertEquals(acc.Sic, 'D001');
        System.assertEquals(acc.NumberOfEmployees, 10);
        System.assertEquals(acc.Website, 'https://www.samplewebsite.com');
        System.assertEquals(acc.Fax, '+61 2 0000 0000');
        System.assertEquals(acc.Site, 'Sydney');
    }

    static void assertOpportunity(Opportunity opp) {
        System.assertEquals(opp.Name, 'New Opportunity');
        System.assertEquals(opp.CloseDate, Date.today().addDays(3));
        System.assertEquals(opp.TotalOpportunityQuantity, 10);
    }

}
