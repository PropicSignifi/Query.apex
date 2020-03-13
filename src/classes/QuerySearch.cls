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
        return find(new SearchExpression(text));
    }

    public QuerySearch find(SearchExpression expression) {
        if (this.searchExpression == null) {
            this.searchExpression = expression;
        } else {
            this.searchExpression = doAnd(this.searchExpression, expression);
        }

        return this;
    }

    public static SearchExpression doAnd(SearchExpression left, SearchExpression right) {
        return left.doAnd(right);
    }

    public static SearchExpression doAnd(SearchExpression left, String right) {
        return left.doAnd(right);
    }

    public static SearchExpression doAnd(String left, SearchExpression right) {
        return new SearchExpression(left).doAnd(right);
    }

    public static SearchExpression doAnd(String left, String right) {
        return new SearchExpression(left).doAnd(right);
    }

    public static SearchExpression doOr(SearchExpression left, SearchExpression right) {
        return left.doOr(right);
    }

    public static SearchExpression doOr(SearchExpression left, String right) {
        return left.doOr(right);
    }

    public static SearchExpression doOr(String left, SearchExpression right) {
        return new SearchExpression(left).doOr(right);
    }

    public static SearchExpression doOr(String left, String right) {
        return new SearchExpression(left).doOr(right);
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

    public QuerySearch setLimit(Integer n) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).setLimit(n);
        }
        return this;
    }

    public QuerySearch orderBy(String fieldName, String direction) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).orderBy(fieldName, direction);
        }
        return this;
    }

    public QuerySearch addConditionEq(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionEq(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionEq(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size() - 1).addConditionEq(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionNotEq(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionNotEq(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionNotEq(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0 ){
            returningList.get(returningList.size()-1).addConditionNotEq(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionLike(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionNotEq(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionLike(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionLike(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionIn(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionIn(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionIn(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionIn(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionNotIn(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionNotIn(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionNotIn(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionNotIn(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionLt(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionLt(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionLt(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionLt(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionLe(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionLe(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionLe(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionLe(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionGt(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionGt(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionGt(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionGt(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionGe(String lhs, Object rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionGe(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionGe(Schema.SObjectField lhs, Object rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionGe(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionIncludes(String lhs, String rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionIncludes(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionIncludes(Schema.SObjectField lhs, String rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionIncludes(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionExcludes(String lhs, String rhs) {
        if (returningList.size() > 0) {
            returningList.get(returningList.size()-1).addConditionExcludes(lhs, rhs);
        }
        return this;
    }

    public QuerySearch addConditionExcludes(Schema.SObjectField lhs, String rhs) {
        if (returningList.size() > 0){
            returningList.get(returningList.size()-1).addConditionExcludes(lhs, rhs);
        }
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
    private SearchExpression searchExpression;
    private List<Query> returningList = new List<Query>();

    private String formSearchString() {
        String result = 'FIND {' + searchExpression.expression + '}';

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

    public class SearchExpression {
        public SearchExpression(String text) {
            this.expression = '"' + text + '"';
        }

        public SearchExpression doAnd(String other) {
            return doAnd(new SearchExpression(other));
        }

        public SearchExpression doAnd(SearchExpression other) {
            SearchExpression newExpression = new SearchExpression();
            newExpression.expression = '(' +
                    this.expression + ') AND (' + other.expression + ')';
            return newExpression;
        }

        public SearchExpression doOr(String other) {
            return doOr(new SearchExpression(other));
        }

        public SearchExpression doOr(SearchExpression other) {
            SearchExpression newExpression = new SearchExpression();
            newExpression.expression = '(' +
                    this.expression + ') OR (' + other.expression + ')';
            return newExpression;
        }

        private SearchExpression() {}
        private String expression;
    }
}
