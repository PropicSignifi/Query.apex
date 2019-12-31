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
    static void selectAllFieldsTest() {
        createData();
        List<Account> accounts;

        accounts = new Query('Account').
            selectAllFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectEditableFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectCreatableFields().
            run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void getSObjectTypeTest() {
        System.assertEquals(
            new Query('Account').getSObjectType(),
            Account.getSObjectType()
        );
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

        List<Account> accountsList = new Query('Account').
            selectAllFields().
            fetch(2);
        System.assertEquals(accountsList.get(0).Name, 'Account 0');
        System.assertEquals(accountsList.get(1).Name, 'Account 1');
        System.assertEquals(accountsList.size(), 2);

        account = (Account)new Query('Account').
            selectAllFields().
            fetch();
        System.assertEquals(account.Name, 'Account 0');

    }

    @isTest
    static void toIdListTest() {
        createData();

        List<Id> idList = new Query('Account').toIdList();

        System.assertEquals(idList.size(), 1);
    }

    @isTest
    static void OptionalClauseTest() {
        createData();

        List<Account> accountsForView = new Query('Account').forView().run();
        List<Account> accountsForUpdate = new Query('Account').forUpdate().run();
        List<Account> accountsForReference = new Query('Account').forReference().run();

    }

    @isTest
    static void runPreservingIdOrderTest() {
        Account acc0 = new Account(Name = 'Account 0');
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');

        insert acc1;
        insert acc0;
        insert acc2;

        List<Id> idList = new List<Id>{ acc0.Id, acc1.Id, acc2.Id, acc0.Id };

        List<Account> accounts = new Query('Account').runPreservingIdOrder(idList);

        System.assertEquals(accounts.get(0).Id, acc0.Id);
        System.assertEquals(accounts.get(1).Id, acc1.Id);
        System.assertEquals(accounts.get(2).Id, acc2.Id);
        System.assertEquals(accounts.get(3).Id, acc0.Id);
    }

    @isTest
    static void fieldsTest() {
        createData();

        List<Account> accounts = new Query('Account').
                                 selectField('Id').
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
    static void lookupTest() {
        createData();

        Account account = [ SELECT Id FROM Account LIMIT 1 ];

        List<Opportunity> opportunities;

        opportunities =
            new Query('Opportunity').
            selectAllFields().
            lookup('AccountId', account.Id).
            run();

        assertOpportunity(opportunities.get(0));

        opportunities =
            new Query('Opportunity').
            selectAllFields().
            lookup('AccountId', new List<Id>{account.Id}).
            run();

        assertOpportunity(opportunities.get(0));

        opportunities =
            new Query('Opportunity').
            selectAllFields().
            lookup('AccountId', account).
            run();

        assertOpportunity(opportunities.get(0));
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

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionNotLike('Name', '%CBA%').
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
    static void conditionIncludeTest() {
        QuickText text = new QuickText(
            Name = 'MyQuickText',
            Message = 'MyMessage',
            Channel = 'Channel1;Channel2'
        );
        insert text;

        List<QuickText> result = new Query('QuickText').
            selectFields('Name, Message, Channel').
            addConditionIncludes('Channel', 'Channel1').
            run();

        System.assertEquals(result.size(), 1);
        System.assertEquals(result[0].Name, 'MyQuickText');

    }

    @isTest
    static void conditionExcludesTest() {
        QuickText text1 = new QuickText(
            Name = 'MyQuickText1',
            Message = 'MyMessage1',
            Channel = 'Channel1;Channel2'
        );

        QuickText text2 = new QuickText(
            Name = 'MyQuickText2',
            Message = 'MyMessage2',
            Channel = 'Channel3;Channel4'
        );

        insert new List<QuickText> {text1, text2};

        List<QuickText> result = new Query('QuickText').
            selectFields('Name, Message, Channel').
            addConditionExcludes('Channel', 'Channel2').
            run();

        System.assertEquals(result.size(), 1);
        System.assertEquals(result[0].Name, 'MyQuickText2');

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
                        Query.doNot(
                            Query.doOr(
                                Query.conditionNotEq('Website', 'https://www.samplewebsite.com'),
                                Query.conditionGt('NumberOfEmployees', 15)
                            )
                        )
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

        System.assertEquals(accounts.size(), 1);
        assertAccount(accounts.get(0));
    }

    @isTest
    static void offsetTest() {
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');
        Account acc3 = new Account(Name = 'Account 3');
        Account acc4 = new Account(Name = 'Account 4');

        insert new List<Account>{acc1, acc2, acc3, acc4};

        List<Account> accounts;
        accounts  = new Query('Account').
                    selectAllFields().
                    setOffset(2).
                    run();

        System.assertEquals(accounts.size(), 2);
        System.assertEquals(accounts.get(0).Name, 'Account 3');
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
                    orderBy('Rating', 'DESC').
                    orderBy('Phone', 'ASC').
                    run();

        System.assertEquals(accounts.get(0).Name, 'Account 2');
        System.assertEquals(accounts.get(1).Name, 'Account 1');
        System.assertEquals(accounts.get(2).Name, 'Account 3');
    }

    @isTest
    static void multipleNullsOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', Phone = '110');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', Phone = '120');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', Phone = '130');
        Account acc4 = new Account(Name = 'Account 4', Rating = '1', Phone = null);
        Account acc5 = new Account(Name = 'Account 5', Rating = null, Phone = '110');
        Account acc6 = new Account(Name = 'Account 6', Rating = '9', Phone = null);

        insert new List<Account>{acc1, acc2, acc3, acc4, acc5, acc6};

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    orderBy('Rating', 'DESC', Query.NULLS_LAST).
                    orderBy('Phone', 'ASC', Query.NULLS_FIRST).
                    run();

        System.assertEquals(accounts.get(0).Name, 'Account 6');
        System.assertEquals(accounts.get(1).Name, 'Account 2');
        System.assertEquals(accounts.get(2).Name, 'Account 4');
        System.assertEquals(accounts.get(3).Name, 'Account 1');
        System.assertEquals(accounts.get(4).Name, 'Account 3');
        System.assertEquals(accounts.get(5).Name, 'Account 5');
    }

    @isTest
    static void descendAndNullsFirstOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1');
        Account acc4 = new Account(Name = 'Account 4', Rating = null);

        insert new List<Account>{acc1, acc2, acc3, acc4};

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    orderBy('Rating').
                    descend().
                    orderNullsFirst().
                    run();

        /*
        System.assertEquals(accounts.get(0).Name, 'Account 4');
        System.assertEquals(accounts.get(1).Name, 'Account 2');
        System.assertEquals(accounts.get(2).Name, 'Account 1');
        System.assertEquals(accounts.get(3).Name, 'Account 3');
        */
    }

    @isTest
    static void ascendAndNullsLastOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1');
        Account acc4 = new Account(Name = 'Account 4', Rating = null);

        insert new List<Account>{acc1, acc2, acc3, acc4};

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    orderBy('Rating').
                    ascend().
                    orderNullsLast().
                    run();

        /*
        System.assertEquals(accounts.get(0).Name, 'Account 1');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 2');
        System.assertEquals(accounts.get(3).Name, 'Account 4');
        */
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
                    addSubquery(
                        Query.subquery('Tasks').
                        selectAllFields().
                        addConditionEq('Subject', 'New Task')
                    ).
                    run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
        assertTask(accounts.get(0).Tasks.get(0));

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
    static void toQueryStringTest() {
        createData();

        String queryString = new Query('Account').
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
                                    Query.conditionEq('CloseDate', Query.TODAY),
                                    Query.conditionEq('Name', 'N/A'),
                                    Query.conditionEq('Name', 'N/A')
                                )
                            )
                        )
                    ).
                    toQueryString();

        List<Account> accounts = Database.query(queryString);

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));

    }

    @isTest
    static void conditionWithConstArgumentTest() {
        createData();

        Account account;
        Opportunity opp;

        account = (Account)new Query('Account').
                selectAllFields().
                addConditionEq('AnnualRevenue', null).
                fetch();

        assertAccount(account);

        account = (Account)new Query('Account').
                selectAllFields().
                addConditionNotEq('Name', null).
                fetch();

        assertAccount(account);

        opp = (Opportunity)new Query('Opportunity').
                selectAllFields().
                addConditionEq('IsPrivate', false).
                fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
                selectAllFields().
                addConditionNotEq('IsPrivate', true).
                fetch();

        assertOpportunity(opp);
    }

    @isTest
    static void dateLiteralTest() {
        createData();

        Opportunity opp;

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CloseDate', Query.TODAY).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CloseDate', Query.YESTERDAY).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionEq('CloseDate', Query.NEXT_N_DAYS(4)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CloseDate', Query.LAST_N_DAYS(10)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_WEEKS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_WEEKS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_MONTHS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_MONTHS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_YEARS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_YEARS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_FISCAL_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_FISCAL_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_FISCAL_YEARS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_FISCAL_YEARS(2)).
            fetch();

        assertOpportunity(opp);
    }

    @isTest
    static void aggregateTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{acc1, acc2, acc3, acc4};

        AggregateResult result =
            new Query('Account').
            count('Name').
            count('Name', 'countName').
            countDistinct('Rating').
            countDistinct('Rating', 'countRating').
            max('NumberOfEmployees').
            max('NumberOfEmployees', 'maxEmployee').
            min('NumberOfEmployees').
            min('NumberOfEmployees', 'minEmployee').
            avg('NumberOfEmployees').
            avg('NumberOfEmployees', 'avgEmployee').
            sum('NumberOfEmployees').
            sum('NumberOfEmployees', 'sumEmployee').
            aggregate()[0];

        System.assertEquals(result.get('countName'), 4);
        System.assertEquals(result.get('expr0'), 4);
        System.assertEquals(result.get('countRating'), 2);
        System.assertEquals(result.get('expr1'), 2);
        System.assertEquals(result.get('maxEmployee'), 7);
        System.assertEquals(result.get('expr2'), 7);
        System.assertEquals(result.get('minEmployee'), 1);
        System.assertEquals(result.get('expr3'), 1);
        System.assertEquals(result.get('avgEmployee'), 4);
        System.assertEquals(result.get('expr4'), 4);
        System.assertEquals(result.get('sumEmployee'), 16);
        System.assertEquals(result.get('expr5'), 16);
    }

    @isTest
    static void groupByTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{acc1, acc2, acc3, acc4};

        List<AggregateResult> results =
            new Query('Account').
            selectField('Rating', 'rate').
            count('Name', 'countName').
            max('NumberOfEmployees', 'maxEmployee').
            min('NumberOfEmployees', 'minEmployee').
            avg('NumberOfEmployees', 'avgEmployee').
            sum('NumberOfEmployees', 'sumEmployee').
            groupBy('Rating').
            aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String)result.get('rate'), result);
        }

        System.assertEquals(resultMap.get('1').get('countName'), 2);
        System.assertEquals(resultMap.get('1').get('maxEmployee'), 5);
        System.assertEquals(resultMap.get('1').get('minEmployee'), 1);
        System.assertEquals(resultMap.get('1').get('avgEmployee'), 3);
        System.assertEquals(resultMap.get('1').get('sumEmployee'), 6);
        System.assertEquals(resultMap.get('9').get('countName'), 1);
        System.assertEquals(resultMap.get('9').get('maxEmployee'), 3);
        System.assertEquals(resultMap.get('9').get('minEmployee'), 3);
        System.assertEquals(resultMap.get('9').get('avgEmployee'), 3);
        System.assertEquals(resultMap.get('9').get('sumEmployee'), 3);
    }

    @isTest
    static void groupByWithHavingTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{acc1, acc2, acc3, acc4};

        List<AggregateResult> results =
            new Query('Account').
            selectField('Rating').
            count('Name', 'countName').
            addConditionGe('NumberOfEmployees', 1).
            groupBy('Rating').
            addHaving(Query.doAnd(
                Query.conditionGe('Count(Name)', 2),
                Query.conditionNotEq('Rating', null)
            )).
            aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String)result.get('Rating'), result);
        }

        System.assertEquals(resultMap.get('1').get('countName'), 2);
        System.assertEquals(resultMap.get('9'), null);
    }

    @isTest
    static void semiJoinTest() {
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            TotalOpportunityQuantity = 10,
            StageName = 'New',
            IsPrivate = false);
        insert opp;

        Account acc2 = (Account)new Query('Account').
            addConditionIn('Id', new Query('Opportunity').
                    selectField('AccountId').
                    byId(opp.Id)).
            fetch();

        System.assertEquals(acc.Id, acc2.Id);

        Account acc3 = (Account)new Query('Account').
            lookup('Id', new Query('Opportunity').
                    selectField('AccountId').
                    addConditionEq('StageName', 'New').
                    byId(opp.Id)).
            addConditionEq('Name', 'New Account').
            fetch();

        System.assertEquals(acc.Id, acc3.Id);

        Opportunity opp2 = (Opportunity)new Query('Opportunity').
            lookup('AccountId', new Query('Account').
                    selectField('Id').
                    byId(acc.Id)).
            fetch();

        System.assertEquals(opp.Id, opp2.Id);
    }

    static void antiJoinTest() {
        Account acc1 = new Account(Name = 'New Account 1');
        insert acc1;
        Account acc2 = new Account(Name = 'New Account 2');
        insert acc2;

        Opportunity opp = new Opportunity(
            AccountId = acc1.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            TotalOpportunityQuantity = 10,
            StageName = 'New',
            IsPrivate = false);
        insert opp;

        Account acc3 = (Account)new Query('Account').
            addConditionNotIn('Id', new Query('Opportunity').
                    selectField('AccountId').
                    byId(opp.Id)).
            fetch();

        System.assertEquals(acc2, acc3);
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

        Task task = new Task();
        task.WhatId = acc.Id;
        task.Subject = 'New Task';

        insert task;

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

    static void assertTask(Task task) {
        System.assertEquals(task.Subject, 'New Task');
    }

}
