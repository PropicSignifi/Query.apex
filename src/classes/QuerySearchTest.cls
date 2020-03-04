/*
 * MIT License
 *
 * Copyright (c) 2018 - 2020 Click to Cloud Pty Ltd, Propic Pty Ltd
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
public class QuerySearchTest {
    @isTest
    static void simpleTest() {
        QuerySearch qs = new QuerySearch()
            .find('ABC')
            .inNameFields()
            .returning('Account')
            .selectFields('Name, Phone');

        String str = qs.toSearchString();

        System.assertEquals(getFindClause(str), '"ABC"');

        Account acc = new Account(Name = 'ABC Ltd',
                Phone = '+61 410 000 000');
        insert acc;

        Test.setFixedSearchResults(new List<Id>{acc.Id});

        List<Account> accounts = qs.run()[0];

        System.assert(!accounts.isEmpty());
        System.assertEquals(accounts[0].Id, acc.Id);
        System.assertEquals(accounts[0].Name, 'ABC Ltd');
        System.assertEquals(accounts[0].Phone, '+61 410 000 000');
    }
    @isTest
    static void limitTest() {
        Account acc0 = new Account(Name = 'Account 0',Phone = '+61 410 000 000');
        Account acc1 = new Account(Name = 'Account 0',Phone = '+61 410 000 000');
        Account acc2 = new Account(Name = 'Account 0',Phone = '+61 410 000 000');

        insert new List<Account>{acc0, acc1, acc2};
        QuerySearch qs = new QuerySearch()
            .find('Account')
            .inNameFields()
            .returning('Account')
            .selectFields('Name, Phone')
            .setLimit(2);

        String str = qs.toSearchString();
		Test.setFixedSearchResults(new List<Id>{acc0.Id, acc1.Id, acc2.Id});
        List<Account> accounts = qs.run()[0];
        System.assertEquals(accounts.size(), 2);
    }

    @isTest
    static void runIdOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '5');

        insert new List<Account>{acc1, acc2, acc3};

        List<Account> accounts;
		Test.setFixedSearchResults(new List<Id>{acc1.Id, acc2.Id, acc3.Id});

        accounts = new QuerySearch()
            .find('Account')
            .inNameFields()
            .returning('Account')
            .selectFields('Name, Rating')
            .orderBy('Rating', 'DESC')
            .run()[0];
	
        System.assertEquals(accounts.get(0).Name, 'Account 2');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 1');
    }

    @isTest
    static void findClauseTest() {
        String str;

        str = new QuerySearch()
            .find('ABC')
            .find('CBA')
            .toSearchString();

        System.assertEquals(getFindClause(str), '("ABC") AND ("CBA")');

        str = new QuerySearch()
            .find(QuerySearch.doAnd('ABC', 'CBA'))
            .toSearchString();

        System.assertEquals(getFindClause(str), '("ABC") AND ("CBA")');

        str = new QuerySearch()
            .find(QuerySearch.doOr('ABC', 'CBA'))
            .toSearchString();

        System.assertEquals(getFindClause(str), '("ABC") OR ("CBA")');

        str = new QuerySearch()
            .find(QuerySearch.doOr(QuerySearch.doAnd('ABC', 'BCA'), 'CBA'))
            .toSearchString();

        System.assertEquals(getFindClause(str), '(("ABC") AND ("BCA")) OR ("CBA")');
    }

    /*
     * The FIND clause is irrelevant to the SOSL result in APEX test code, so we
     * need an extra step to test the FIND clause.
     * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_SOSL.htm
     */
    private static String getFindClause(String searchString) {
        Matcher m = Pattern.compile('FIND \\{(.*)\\}.*').matcher(searchString);
        System.assert(m.matches());
        return m.group(1);
    }
}
