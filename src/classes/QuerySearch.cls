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
public class QuerySearch {
    public static final String VERSION = '1.2.0';

    public QuerySearch() {}

    public QuerySearch find(String text) {
        this.searchText = '"' + text + '"';
        return this;
    }

    public final static String ALL_FIELDS = 'ALL FIELDS';
    public final static String EMAIL_FIELDS = 'EMAIL FIELDS';
    public final static String NAME_FIELDS = 'NAME FIELDS';
    public final static String PHONE_FIELDS = 'PHONE FIELDS';
    public final static String SIDEBAR_FIELDS = 'SIDEBAR FIELDS';

    public QuerySearch inAllFields() {
        this.searchGroup = ALL_FIELDS;
        return this;
    }

    public QuerySearch inEmailFields() {
        this.searchGroup = EMAIL_FIELDS;
        return this;
    }

    public QuerySearch inNameFields() {
        this.searchGroup = NAME_FIELDS;
        return this;
    }

    public QuerySearch inPhoneFields() {
        this.searchGroup = PHONE_FIELDS;
        return this;
    }

    public QuerySearch inSidebarFields() {
        this.searchGroup = SIDEBAR_FIELDS;
        return this;
    }

    public QuerySearch returning(String sobjectName) {
        returningList.add(new Query(sobjectName));
        return this;
    }

    public QuerySearch selectFields(Set<String> fields) {
        if (returningList.isEmpty()) {
            throw new QueryException('Cannot select fields without specifiying ' + 
                    'a returning sObject');
        }

        Query q = returningList[returningList.size() - 1];
        q.selectFields(fields);

        return this;
    }

    public QuerySearch selectFields(List<String> fields) {
        return selectFields(new Set<String>(fields));
    }

    public QuerySearch selectFields(String fields) {
        if (fields.contains(',')) {
            // parse the fieldNames separated by ','
            return selectFields(new Set<String>(fields.split(', *')));
        } else {
            return selectField(fields);
        }
    }

    public QuerySearch selectField(String field) {
        return selectFields(new Set<String>{field});
    }

    public String toSearchString() {
        return formSearchString();
    }

    public List<List<SObject>> run() {
        return Search.query(formSearchString());
    }

    private String searchGroup;
    private String searchText = '';
    private List<Query> returningList = new List<Query>();

    private String formSearchString() {
        String result = 'FIND {' + searchText + '}';

        if (searchGroup != null) {
            result += ' IN ' + searchGroup;
        }

        if (!returningList.isEmpty()) {
            result += ' RETURNING ';
        }

        for (Query returning : returningList) {
            final String sobjectName = returning.getSObjectType().getDescribe().getName();
            result += sobjectName;

            result += '(';

            String query = returning.toQueryString();

            query = query.removeStart('SELECT ');
            query = query.replaceFirst(' FROM ' + sobjectName, ' ');

            result += query;

            result += '), ';
        }

        result = result.removeEnd(', ');

        return result;
    }

}
