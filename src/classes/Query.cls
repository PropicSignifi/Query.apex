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
public class Query {

    /* Public members */
    public Query(String objectName) {
        this(objectName, getNamespaceFromClass());
    }

    public Query(String objectName, String namespace) {
        this();

        setNamespace(namespace);

        // Get Schema.SObjectType
        Map<String, Schema.SObjectType> globalDescribe =
            Schema.getGlobalDescribe();

        this.objectName = appendNamespace(objectName);
        this.objectType = globalDescribe.get(this.objectName);

        if (null == this.objectType) {
            throw new QueryException('Cannot find corresponding ' +
                    'SObject type from the SObject name ' + this.objectName);
        }

        childRelationships = getChildRelationships();
    }

    public Query(Schema.SObjectType objectType) {
        this();

        this.objectName = objectType.getDescribe().getName();
        this.objectType = objectType;

        childRelationships = getChildRelationships();
    }

    /*
     * Specify the selected fields
     * If this function is not called, it would by default select all the fields
     *      with read permission
     */
    public Query selectFields(Set<String> fieldSet) {
        for (String fieldName : fieldSet) {
            selectFields(fieldName);
        }
        return this;
    }

    public Query selectFields(List<String> fieldList) {
        return selectFields(new Set<String>(fieldList));
    }

    /*
     * This function allows user provide a single field, or multiple fields
     *      concatenated by ','
     */
    public Query selectfields(String fieldNames) {
        if (fieldNames.contains(',')) {
            // parse the fieldNames separated by ','
            List<String> fieldList = fieldNames.split(', *');

            return selectfields(new Set<String>(fieldList));
        } else {
            final String fieldName = fieldNames;

            addToFieldSet(fieldName);
            return this;
        }
    }

    /*
     * This function allows user provide a single field
     */
    public Query selectfield(String fieldName) {
        addToFieldSet(fieldName);
        return this;
    }

    /*
     * Select all user accessible fields
     */
    public Query selectAllFields() {
        isSelectingAllFields = true;
        return this;
    }

    /*
     * Select all user accessible fields from a parent field
     */
    public Query selectAllFields(String parentField) {
        return selectParentfields(parentField);
    }

    /*
     * Specify the Id of the object
     */
    public Query byId(Set<Id> idSet) {
        return addConditionIn('Id', idSet);
    }

    public Query byId(List<Id> idList) {
        return byId(new Set<Id>(idList));
    }

    public Query byId(Id id) {
        return byId(new Set<Id>{id});
    }

    /*
     * Specify the Id of the a lookup field
     */
    public Query lookup(String fieldName, Set<Id> idSet) {
        return addConditionIn(fieldName, idSet);
    }

    public Query lookup(String fieldName, List<Id> idList) {
        return lookup(fieldName, new Set<Id>(idList));
    }

    public Query lookup(String fieldName, Id id) {
        return lookup(fieldName, new Set<Id>{id});
    }

    public Query lookup(String fieldName, List<SObject> sObjectList) {
        Set<Id> idSet = new Set<Id>();
        for (SObject sobj : sObjectList) {
            idSet.add(sobj.Id);
        }
        return lookup(fieldName, idSet);
    }

    public Query lookup(String fieldName, SObject sobj) {
        return lookup(fieldName, new List<SObject>{sobj});
    }

    /*
     * Add a condition
     * Example: addConditionEq('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate = :Datetime.now()"
     */
    public Query addConditionEq(String lhs, Object rhs) {
        return addCondition(conditionEq(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionNotEq('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate != :Datetime.now()"
     */
    public Query addConditionNotEq(String lhs, Object rhs) {
        return addCondition(conditionNotEq(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionIn('Name', mySet)
     *          the condition is equivalent to "Name IN :mySet"
     */
    public Query addConditionIn(String lhs, Object rhs) {
        return addCondition(conditionIn(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionNotIn('Name', mySet)
     *          the condition is equivalent to "Name NOT IN :mySet"
     */
    public Query addConditionNotIn(String lhs, Object rhs) {
        return addCondition(conditionNotIn(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionLt('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public Query addConditionLt(String lhs, Object rhs) {
        return addCondition(conditionLt(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionLe('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate <= :Datetime.now()"
     */
    public Query addConditionLe(String lhs, Object rhs) {
        return addCondition(conditionLe(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionGt('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public Query addConditionGt(String lhs, Object rhs) {
        return addCondition(conditionGt(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionGe('CreatedDate', Datetime.now())
     *          is equivaGent to "CreatedDate <= :Datetime.now()"
     */
    public Query addConditionGe(String lhs, Object rhs) {
        return addCondition(conditionGe(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionLike('Name', '%Sam%')
     *          the condition is equivalent to "Name LIKE '%Sam%'"
     */
    public Query addConditionLike(String lhs, Object rhs) {
        return addCondition(conditionLike(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionNotLike('Name', '%Sam%')
     *          the condition is equivalent to "NOT Name LIKE '%Sam%'"
     */
    public Query addConditionNotLike(String lhs, Object rhs) {
        return addCondition(conditionNotLike(lhs, rhs));
    }

    /*
     * Add condition with a Condition object
     */
    public Query addCondition(Condition condition) {
        String newConditionString =
            shiftFormatStringIndice(condition.conditionString, conditionArgsIdx);
        newConditionString = '(' + newConditionString + ')';
        saveConditionArg(condition.args);
        return addComplexCondition(newConditionString, condition.args);
    }

    /*
     * Create a condition
     * Example: conditionEq('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate = :Datetime.now()"
     */
    public static Condition conditionEq(String lhs, Object rhs) {
        final String formatString = lhs + ' = {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionNotEq('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate != :Datetime.now()"
     */
    public static Condition conditionNotEq(String lhs, Object rhs) {
        final String formatString = lhs + ' != {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionIn('Name', mySet)
     *          the condition is equivalent to "Name IN :mySet"
     */
    public static Condition conditionIn(String lhs, Object rhs) {
        final String formatString = lhs + ' IN {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionNotIn('Name', mySet)
     *          the condition is equivalent to "Name NOT IN :mySet"
     */
    public static Condition conditionNotIn(String lhs, Object rhs) {
        final String formatString = lhs + ' NOT IN {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionLt('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static Condition conditionLt(String lhs, Object rhs) {
        final String formatString = lhs + ' < {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionLe('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate <= :Datetime.now()"
     */
    public static Condition conditionLe(String lhs, Object rhs) {
        final String formatString = lhs + ' <= {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionGt('CreatedDate', Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static Condition conditionGt(String lhs, Object rhs) {
        final String formatString = lhs + ' > {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionGe('CreatedDate', Datetime.now())
     *          is equivaGent to "CreatedDate <= :Datetime.now()"
     */
    public static Condition conditionGe(String lhs, Object rhs) {
        final String formatString = lhs + ' >= {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionLike('Name', '%Sam%')
     *          the condition is equivalent to "Name LIKE '%Sam%'"
     */
    public static Condition conditionLike(String lhs, Object rhs) {
        final String formatString = lhs + ' LIKE {0}';
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionNotLike('Name', '%Sam%')
     *          the condition is equivalent to "NOT Name LIKE '%Sam%'"
     */
    public static Condition conditionNotLike(String lhs, Object rhs) {
        final String formatString = 'NOT ' + lhs + ' LIKE {0}';
        return new Condition(formatString, rhs);
    }

    public static Condition doAnd(Condition lhs, Condition rhs) {
        return lhs.doAnd(rhs);
    }

    public static Condition doAnd(Condition condition0,
                                  Condition condition1,
                                  Condition condition2) {
        return doAnd(
                new List<Condition>{
                    condition0,
                    condition1,
                    condition2
                }
            );
    }

    public static Condition doAnd(Condition condition0,
                                  Condition condition1,
                                  Condition condition2,
                                  Condition condition3) {
        return doAnd(
                new List<Condition>{
                    condition0,
                    condition1,
                    condition2,
                    condition3
                }
            );
    }

    public static Condition doAnd(List<Condition> conditions) {
        if (null == conditions || conditions.isEmpty()) {
            return null;
        }

        Condition ret = conditions.get(0);

        for (Integer i = 1; i < conditions.size(); i++) {
            ret = ret.doAnd(conditions[i]);
        }

        return ret;
    }

    public static Condition doOr(Condition lhs, Condition rhs) {
        return lhs.doOr(rhs);
    }

    public static Condition doOr(Condition condition0,
                                     Condition condition1,
                                     Condition condition2) {
        return doOr(
                new List<Condition>{
                    condition0,
                    condition1,
                    condition2
                }
            );
    }

    public static Condition doOr(Condition condition0,
                                 Condition condition1,
                                 Condition condition2,
                                 Condition condition3) {
        return doOr(
                new List<Condition>{
                    condition0,
                    condition1,
                    condition2,
                    condition3
                }
            );
    }


    public static Condition doOr(List<Condition> conditions) {
        if (null == conditions || conditions.isEmpty()) {
            return null;
        }

        Condition ret = conditions.get(0);

        for (Integer i = 1; i < conditions.size(); i++) {
            ret = ret.doOr(conditions[i]);
        }

        return ret;
    }

    public static Condition doNot(Condition condition) {
        return condition.doNot();
    }

    /*
     * By default, all the conditions are concatenated by 'AND' keyword
     * Calling switchToDisjunction() will switch the operator to 'OR'
     * Calling switchToConjunction() will switch the operator to 'AND'
     * If anyone wants to use a combination of conjunction and disjunction,
     *      consider using customizeCondition() instead
     */

    /*
     * After calling this function, all conditions will be concatenated by 'AND'
     */
    public Query switchToConjunction() {
        conditionOperator = 'AND';
        return this;
    }

    /*
     * After calling this function, all conditions will be concatenated by 'OR'
     */
    public Query switchToDisjunction() {
        conditionOperator = 'OR';
        return this;
    }

    public Query resetCondition() {
        conditions.clear();
        conditionArgs.clear();

        return this;
    }

    public static final DateLiteral YESTERDAY = new DateLiteral('YESTERDAY');
    public static final DateLiteral TODAY = new DateLiteral('TODAY');
    public static final DateLiteral TOMORROW = new DateLiteral('TOMORROW');
    public static final DateLiteral LAST_WEEK = new DateLiteral('LAST_WEEK');
    public static final DateLiteral THIS_WEEK = new DateLiteral('THIS_WEEK');
    public static final DateLiteral NEXT_WEEK = new DateLiteral('NEXT_WEEK');
    public static final DateLiteral LAST_MONTH = new DateLiteral('LAST_MONTH');
    public static final DateLiteral THIS_MONTH = new DateLiteral('THIS_MONTH');
    public static final DateLiteral NEXT_MONTH = new DateLiteral('NEXT_MONTH');
    public static final DateLiteral LAST_90_DAYS = new DateLiteral('LAST_90_DAYS');
    public static final DateLiteral NEXT_90_DAYS = new DateLiteral('NEXT_90_DAYS');
    public static final DateLiteral THIS_QUARTER = new DateLiteral('THIS_QUARTER');
    public static final DateLiteral LAST_QUARTER = new DateLiteral('LAST_QUARTER');
    public static final DateLiteral NEXT_QUARTER = new DateLiteral('NEXT_QUARTER');
    public static final DateLiteral THIS_YEAR = new DateLiteral('THIS_YEAR');
    public static final DateLiteral LAST_YEAR = new DateLiteral('LAST_YEAR');
    public static final DateLiteral NEXT_YEAR = new DateLiteral('NEXT_YEAR');
    public static final DateLiteral THIS_FISCAL_QUARTER =
        new DateLiteral('THIS_FISCAL_QUARTER');
    public static final DateLiteral LAST_FISCAL_QUARTER =
        new DateLiteral('LAST_FISCAL_QUARTER');
    public static final DateLiteral NEXT_FISCAL_QUARTER =
        new DateLiteral('NEXT_FISCAL_QUARTER');
    public static final DateLiteral THIS_FISCAL_YEAR =
        new DateLiteral('THIS_FISCAL_YEAR');
    public static final DateLiteral LAST_FISCAL_YEAR =
        new DateLiteral('LAST_FISCAL_YEAR');
    public static final DateLiteral NEXT_FISCAL_YEAR =
        new DateLiteral('NEXT_FISCAL_YEAR');

    public static DateLiteral LAST_N_DAYS(Integer n) {
        return new DateLiteral('LAST_N_DAYS', n);
    }

    public static DateLiteral NEXT_N_DAYS(Integer n) {
        return new DateLiteral('NEXT_N_DAYS', n);
    }

    public static DateLiteral LAST_N_WEEKS(Integer n) {
        return new DateLiteral('LAST_N_WEEKS', n);
    }

    public static DateLiteral NEXT_N_WEEKS(Integer n) {
        return new DateLiteral('NEXT_N_WEEKS', n);
    }

    public static DateLiteral LAST_N_MONTHS(Integer n) {
        return new DateLiteral('LAST_N_MONTHS', n);
    }

    public static DateLiteral NEXT_N_MONTHS(Integer n) {
        return new DateLiteral('NEXT_N_MONTHS', n);
    }

    public static DateLiteral LAST_N_QUARTERS(Integer n) {
        return new DateLiteral('LAST_N_QUARTERS', n);
    }

    public static DateLiteral NEXT_N_QUARTERS(Integer n) {
        return new DateLiteral('NEXT_N_QUARTERS', n);
    }

    public static DateLiteral LAST_N_YEARS(Integer n) {
        return new DateLiteral('LAST_N_YEARS', n);
    }

    public static DateLiteral NEXT_N_YEARS(Integer n) {
        return new DateLiteral('NEXT_N_YEARS', n);
    }

    public static DateLiteral LAST_N_FISCAL_QUARTERS(Integer n) {
        return new DateLiteral('LAST_N_FISCAL_QUARTERS', n);
    }

    public static DateLiteral NEXT_N_FISCAL_QUARTERS(Integer n) {
        return new DateLiteral('NEXT_N_FISCAL_QUARTERS', n);
    }

    public static DateLiteral LAST_N_FISCAL_YEARS(Integer n) {
        return new DateLiteral('LAST_N_FISCAL_YEARS', n);
    }

    public static DateLiteral NEXT_N_FISCAL_YEARS(Integer n) {
        return new DateLiteral('NEXT_N_FISCAL_YEARS', n);
    }

    public Query setLimit(Integer n) {
        sizeLimit = n;

        return this;
    }

    public Query setOffset(Integer n) {
        resultOffset = n;
        return this;
    }

    public Query orderBy(String fieldName) {
        orderList.add(new OrderTuple(fieldName));
        return this;
    }

    public Query orderBy(String fieldName, String orderDirection) {
        OrderTuple singleOrder;
        if (orderDirection.equalsIgnoreCase('ASC')) {
            singleOrder = new OrderTuple(fieldName, true);
        } else if (orderDirection.equalsIgnoreCase('DESC')) {
            singleOrder = new OrderTuple(fieldName, false);
        }
        orderList.add(singleOrder);
        return this;
    }

    public Query orderBy(String fieldName, String orderDirection, Boolean nullsFirst) {
        OrderTuple singleOrder;
        if (orderDirection.equalsIgnoreCase('ASC')) {
            singleOrder = new OrderTuple(fieldName, true, nullsFirst);
        } else if (orderDirection.equalsIgnoreCase('DESC')) {
            singleOrder = new OrderTuple(fieldName, false, nullsFirst);
        }
        orderList.add(singleOrder);
        return this;
    }

    public Query ascend() {
        for (OrderTuple singleOrder : orderList) {
            singleOrder.ascending = true;
        }
        return this;
    }

    public Query descend() {
        for (OrderTuple singleOrder : orderList) {
            singleOrder.ascending = false;
        }
        return this;
    }

    public Query orderNullsFirst() {
        for (OrderTuple singleOrder : orderList) {
            singleOrder.nullsFirst = true;
        }
        return this;
    }

    public Query orderNullsLast() {
        for (OrderTuple singleOrder : orderList) {
            singleOrder.nullsFirst = false;
        }
        return this;
    }

    public static final Boolean NULLS_FIRST = true;
    public static final Boolean NULLS_LAST = false;

    public Query addSubquery(String relationshipName) {
        addChildRelationship(relationshipName);
        return this;
    }

    public Query addSubquery(String relationshipName,
                             Set<String> fieldSet) {
        addChildRelationship(relationshipName).selectFields(fields);

        return this;
    }

    public Query addSubquery(String relationshipName,
                             List<String> fieldList) {
        addChildRelationship(relationshipName).selectFields(fields);

        return this;
    }

    public Query addSubquery(String relationshipName, String fields) {
        addChildRelationship(relationshipName).selectFields(fields);

        return this;
    }

    public Query addSubquery(Query subquery) {

        addChildRelationship(subquery);

        return this;
    }

    public static Query subquery(String relationshipName) {
        Query childQuery = new Query();

        childQuery.objectName = childQuery.appendNamespace(relationshipName);

        return childQuery;
    }

    public Query debug() {
        System.debug(toQueryString());

        for (Integer i = 0; i < conditionArgsIdx; i++) {
            debugDeep(i);
        }
        return this;
    }

    public Query setNamespace(String namespace) {
        if (String.isBlank(namespace)) {
            this.namespace = '';
        } else {
            this.namespace = namespace;
        }
        return this;
    }

    public String toQueryString() {
        return formQueryString();
    }

    public SObject fetch() {
        return fetch(0);
    }

    public List<SObject> fetch(Integer first, Integer last) {
        List<SObject> retList = new List<SObject>();
        final List<SObject> fetchedList = run();

        for (Integer i = first; i < fetchedList.size() && i < last; i++) {
            retList.add(fetchedList.get(i));
        }

        return retList;
    }

    public SObject fetch(Integer idx) {
        final List<SObject> fetchedList = run();

        if (idx < fetchedList.size()) {
            return fetchedList.get(idx);
        } else {
            return null;
        }
    }

    public List<SObject> run() {
        return toSObjectList();
    }

    public List<SObject> runWithOrderedIds(List<Id> idList) {
        Query cloned = this.clone();
        cloned.byId(idList);

        Map<Id, SObject> mapIdToSObject = new Map<Id, SObject>(cloned.run());

        List<SObject> ret = new List<SObject>();

        for (Id id : idList) {
            ret.add(mapIdToSObject.get(id));
        }

        return ret;
    }

    public List<SObject> toSObjectList() {
        String queryString = toQueryString();
        return Database.query(queryString);
    }

    public List<Id> toIdList() {
        List<Id> ret = new List<Id>();

        for (SObject item : run()) {
            ret.add(item.Id);
        }

        return ret;
    }

    public Database.QueryLocator getQueryLocator() {
        String queryString = toQueryString();
        return Database.getQueryLocator(queryString);
    }

    /* Private members */

    private Query() {
        fields = new Set<String>();
        conditions = new List<String>();
        childQuerys = new Map<String, Query>();
        conditionArgs = new List<Object>();
        parentReferences = new Set<String>();
        orderList = new List<OrderTuple>();
    }

    // State variables
    private Set<String> fields;
    private Set<String> parentReferences;
    private Boolean isSelectingAllFields = false;

    private List<String> conditions;
    private static final Integer maxArgSize = 20;
    private Integer conditionArgsIdx = 0;
    private List<Object> conditionArgs;
    private Object conditionArgs0;
    private Object conditionArgs1;
    private Object conditionArgs2;
    private Object conditionArgs3;
    private Object conditionArgs4;
    private Object conditionArgs5;
    private Object conditionArgs6;
    private Object conditionArgs7;
    private Object conditionArgs8;
    private Object conditionArgs9;
    private Object conditionArgs10;
    private Object conditionArgs11;
    private Object conditionArgs12;
    private Object conditionArgs13;
    private Object conditionArgs14;
    private Object conditionArgs15;
    private Object conditionArgs16;
    private Object conditionArgs17;
    private Object conditionArgs18;
    private Object conditionArgs19;

    private String conditionOperator = 'AND';
    private Integer sizeLimit = -1;
    private Integer resultOffset = -1;
    private Map<String, Query> childQuerys;

    private List<OrderTuple> orderList;
    private class OrderTuple {
        private String fieldName;
        private Boolean ascending = true;
        private Boolean nullsFirst = true;

        private OrderTuple(String fieldName) {
            this.fieldName = fieldName;
        }

        private OrderTuple(String fieldName, Boolean ascending) {
            this.fieldName = fieldName;
            this.ascending = ascending;
        }

        private OrderTuple(String fieldName, Boolean ascending, Boolean nullsFirst) {
            this.fieldName = fieldName;
            this.ascending = ascending;
            this.nullsFirst = nullsFirst;
        }
    }

    // Object Schema variables
    private String objectName;
    private Schema.SObjectType objectType;
    private Map<String, Schema.SObjectType> childRelationships;

    private Query addAllFields() {
        // Get all the fields
        final Map<String, Schema.SObjectField> fieldMap =
            objectType.getDescribe().fields.getMap();

        // Add the field if it is accessible by the user
        for (String fieldName : fieldMap.keySet()) {
            if (fieldMap.get(fieldName).getDescribe().isAccessible()) {
                fields.add(fieldName.toLowerCase());
            }
        }
        return this;
    }

    private Schema.SObjectType getParentObjectType(Schema.SObjectType objType, String parentPath) {
        final String nextItem =
            appendNamespace(translateParentField(parentPath.substringBefore('.')));

        Schema.SObjectField field = objType.getDescribe().fields.getMap().get(nextItem);

        if (null == field) {
            throw new QueryException('Cannot find field ' + nextItem +
                    ' from the object ' + objType.getDescribe().getName());
        }

        if (!field.getDescribe().isAccessible()) {
            throw new QueryException('Permission denied: cannot read ' +
                    nextItem + ' from object ' + objType.getDescribe().getName());
        }

        List<Schema.SObjectType> referenceTo =
            field.getDescribe().getReferenceTo();

        if (null == referenceTo || referenceTo.isEmpty()) {
            throw new QueryException('Cannot find parent relationship ' + nextItem +
                    ' from the object ' + objType.getDescribe().getName());
        }

        Schema.SObjectType nextObj = referenceTo.get(0);

        if (!parentPath.contains('.')) {
            return nextObj;
        } else {
            return getParentObjectType(nextObj, parentPath.substringAfter('.'));
        }
    }

    private static String translateParentField(String parentName) {
        // translate the reference name
        if (parentName.endsWithIgnoreCase('__r')) {
            parentName = parentName.removeEnd('__r') + '__c';
        } else if (parentName.endsWithIgnoreCase('Id')) {
            parentName = parentName;
        } else {
            parentName = parentName + 'Id';
        }

        return parentName;
    }

    private static Boolean isParentField(String fieldName) {
        if (fieldName.endsWithIgnoreCase('__c') || fieldName.endsWithIgnoreCase('__pc')) {
            return false;
        } else if (fieldName.endsWithIgnoreCase('__r')) {
            return true;
        } else if (fieldName.endsWithIgnoreCase('Id')) {
            return false;
        } else {
            return true;
        }
    }

    private String addToFieldSet(String fieldName) {
        if (fieldName.contains('.')) {
            List<String> oldFields = fieldName.split('\\.');
            List<String> newFields = new List<String>();
            for (String field : oldFields) {
                newFields.add(appendNamespace(field));
            }

            fieldName = String.join(newFields, '.');
        } else {
            fieldName = appendNamespace(fieldName);
        }

        fieldName = fieldName.toLowerCase();

        fields.add(fieldName);

        return fieldName;
    }

    private Map<String, Schema.SObjectType> getChildRelationships() {
        Map<String, Schema.SObjectType> childMap =
            new Map<String, Schema.SObjectType>();
        final List<Schema.ChildRelationship> childList =
            objectType.getDescribe().getChildRelationships();

        for (Schema.ChildRelationship child: childList) {
            childMap.put(child.getRelationshipName(), child.getChildSObject());
        }
        return childMap;
    }

    /*
     * Select all fields from a parent relationship
     * For example, in Contact object, we can call selectParentFields('Account') to select
     *      Account.Name, Account.FirstName, Account.LastName, etc.
     */
    private Query selectParentFields(String parentName) {
        parentReferences.add(parentName);
        return this;
    }

    private Query addParentFields(String parentName) {
        // Get all the fields from the parent object
        final Map<String, Schema.SObjectField> fieldMap =
            getParentObjectType(objectType, parentName).getDescribe().fields.getMap();

        // Add the field if it is accessible by the user
        for (String fieldName : fieldMap.keySet()) {
            if (fieldMap.get(fieldName).getDescribe().isAccessible()) {
                fields.add((parentName + '.' + fieldName).toLowerCase());
            }
        }
        return this;
    }

    /*
     * Add complex condition with a format string and multiple arguments
     * Example: addComplexCondition('CreatedDate <= {0} AND Name = {1}',
                    new List<Object>{Datetime.now(), 'Sam'})
     */
    @testVisible
    private Query addComplexCondition(String formatString,
                                      List<Object> args) {
        List<String> argStringList = new List<String>();

        conditions.add(String.escapeSingleQuotes(formatString));
        conditionArgs.addAll(args);

        return this;
    }

    /*
     * Save the arg to the member variable
     */
    private void saveConditionArg(List<Object> args) {
        for (Object arg : args) {
            saveConditionArg(conditionArgsIdx, arg);
            conditionArgsIdx++;
        }
    }

    private void saveConditionArg(Integer idx, Object arg) {
        if (idx >= maxArgSize) {
            throw new QueryException('The number of arguments exceeds the limit');
        }

        if (idx == 0) {
            conditionArgs0 = arg;
        } else if (idx == 1) {
            conditionArgs1 = arg;
        } else if (idx == 2) {
            conditionArgs2 = arg;
        } else if (idx == 3) {
            conditionArgs3 = arg;
        } else if (idx == 4) {
            conditionArgs4 = arg;
        } else if (idx == 5) {
            conditionArgs5 = arg;
        } else if (idx == 6) {
            conditionArgs6 = arg;
        } else if (idx == 7) {
            conditionArgs7 = arg;
        } else if (idx == 8) {
            conditionArgs8 = arg;
        } else if (idx == 9) {
            conditionArgs9 = arg;
        } else if (idx == 10) {
            conditionArgs10 = arg;
        } else if (idx == 11) {
            conditionArgs11 = arg;
        } else if (idx == 12) {
            conditionArgs12 = arg;
        } else if (idx == 13) {
            conditionArgs13 = arg;
        } else if (idx == 14) {
            conditionArgs14 = arg;
        } else if (idx == 15) {
            conditionArgs15 = arg;
        } else if (idx == 16) {
            conditionArgs16 = arg;
        } else if (idx == 17) {
            conditionArgs17 = arg;
        } else if (idx == 18) {
            conditionArgs18 = arg;
        } else if (idx == 19) {
            conditionArgs19 = arg;
        }
    }

    private String formQueryString() {
        conditionArgsIdx = 0;

        String query = 'SELECT ';

        query += formFieldString();

        query += ' FROM ' + objectName;

        final String conditionString = formConditionString();

        if (String.isNotBlank(conditionString)) {
            query += ' WHERE ' + conditionString;
        }

        if (!orderList.isEmpty()) {
            query += ' ORDER BY ' + formOrderByString();
        }

        if (sizeLimit >= 0) {
            query += ' LIMIT ' + sizeLimit;
        }

        if (resultOffset >= 0) {
            query += ' OFFSET ' + resultOffset;
        }

        return query;
    }

    private String formFieldString() {
        String fieldString = '';

        for (String field : fields) {
            checkFieldLevelSecurity(objectType, field);
        }

        for (String parentName : parentReferences) {
            addParentFields(parentName);
        }

        if (isSelectingAllFields) {
            addAllFields();
        }

        if (fields.isEmpty()) {
            addToFieldSet('Id');
        }

        for (String field: fields) {
            fieldString += field + ', ';
        }

        fieldString += formSubqueryString();

        fieldString = fieldString.removeEnd(', ');

        return fieldString;
    }

    private String formConditionString() {
        String conditionString = '';

        for (String condition : conditions) {
            conditionString += condition;
            // either 'AND' or 'OR'
            conditionString += ' ' + conditionOperator +  ' ';
        }

        // remove either 'AND' or 'OR' in the end
        conditionString = conditionString.removeEnd(' ' + conditionOperator + ' ');

        // shift the arg index
        conditionString = shiftFormatStringIndice(conditionString, conditionArgsIdx);
        saveConditionArg(conditionArgs);

        // format the arguments
        List<String> args = new List<String>();
        for (Integer i = 0; i < conditionArgsIdx; i++) {
            args.add(':conditionArgs' + i);
        }
        conditionString = format(conditionString, args);

        return conditionString;
    }

    private String formSubqueryString() {
        String subqueryString = '';

        for (String key: childQuerys.keySet()) {
            Query childQuery = childQuerys.get(key);

            subqueryString += '(';
            subqueryString += shiftArgStringIndice(childQuery.toQueryString(), conditionArgsIdx);
            subqueryString += ')';
            subqueryString += ', ';

            saveConditionArg(childQuery.conditionArgs);
        }

        return subqueryString;
    }

    private String formOrderByString() {
        String orderByString = '';
        Integer count = 0;
        for (OrderTuple singleOrder : orderList) {
            // check if the orderTuple is the first in list
            if (count != 0) {
                orderByString += ', ';
            }
            orderByString += singleOrder.fieldName;
            if (singleOrder.ascending) {
                orderByString += ' ASC';
            } else {
                orderByString += ' DESC';
            }

            if (singleOrder.nullsFirst) {
                orderByString += ' NULLS FIRST';
            } else {
                orderbyString += ' NULLS LAST';
            }
            count++;
        }
        return orderByString;
    }

    private Boolean checkFieldLevelSecurity(Schema.SObjectType objType, String fieldPath) {
        String nextItem =
            fieldPath.substringBefore('.');

        if (!fieldPath.contains('.')) {
            nextItem = appendNamespace(nextItem);

            final Map<String, Schema.SObjectField> fieldMap =
                objType.getDescribe().fields.getMap();

            if (null == fieldMap.get(nextItem)) {
                throw new QueryException('Cannot find ' + nextItem +
                        ' in object ' + objType.getDescribe().getName());
            }
            if (!fieldMap.get(nextItem).getDescribe().isAccessible()) {
                throw new QueryException('Permission denied: cannot read ' +
                        nextItem + ' from object ' + objType.getDescribe().getName());
            }
        } else {
            return checkFieldLevelSecurity(
                    getParentObjectType(objType, nextItem),
                    fieldPath.substringAfter('.')
                );
        }

        return true;
    }

    /*
     * Convert a String set to String
     * Sample result format: ('00190000020tGy4AAE', 'a0390000017tZFpAAM')
     */
    private static String convertStringSetToString(Set<Object> items) {
        String result = '(';

        for (Object item : items) {
            result += '\'' + String.escapeSingleQuotes(String.valueOf(item)) + '\', ';
        }
        result = result.removeEnd(', ');
        result += ')';

        return result;
    }

    /*
     * Convert a Value set to String
     * Sample result format: (123.2, 324)
     */
    private static String convertValueSetToString(Set<Object> items) {
        String result = '(';

        for (Object item : items) {
            result += String.valueOf(item) + ', ';
        }
        result = result.removeEnd(', ');
        result += ')';

        return result;
    }

    /*
     * This function shifts the index in the given format string
     * Example:
     *  after passing
     *      'The {0} quick {1} brown {2} fox {3} jumps over the {4} lazy {5} dog',
     *      and shift 2,
     *  The returned string is
     *      'The {2} quick {3} brown {4} fox {5} jumps over the {6} lazy {7} dog'.
     */
    private static String shiftFormatStringIndice(String formatString, Integer shift) {
        for (Integer i = maxArgSize - shift - 1; i >= 0; i--) {
            final String target = '{' + i + '}';
            final String replacement = '{' + (i + shift) + '}';

            formatString = formatString.replace(target, replacement);
        }

        return formatString;
    }

    /*
     * This function shifts the conditionArg index in the given string
     * Example:
     *  after passing
     *      'Name = :conditionArgs0 AND Phone = :conditionArgs1'
     *      and shift 2,
     *  The returned string is
     *      'Name = :conditionArgs2 AND Phone = :conditionArgs3'
     */
    private static String shiftArgStringIndice(String argString, Integer shift) {
        for (Integer i = maxArgSize - shift - 1; i >= 0; i--) {
            final String target = ':conditionArgs' + i;
            final String replacement = ':conditionArgs' + (i + shift);

            argString = argString.replace(target, replacement);
        }

        return argString;
    }

    /*
     * Replacement of String.format
     */
    private static String format(String formatString, List<String> args) {
        for (Integer i = 0; i < args.size(); i++) {
            formatString = formatString.replaceAll('\\{' + i + '\\}', args[i]);
        }
        return formatString;
    }

    private void debugDeep(Integer idx) {
        if (idx == 0) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs0));
        } else if (idx == 1) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs1));
        } else if (idx == 2) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs2));
        } else if (idx == 3) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs3));
        } else if (idx == 4) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs4));
        } else if (idx == 5) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs5));
        } else if (idx == 6) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs6));
        } else if (idx == 7) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs7));
        } else if (idx == 8) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs8));
        } else if (idx == 9) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs9));
        } else if (idx == 10) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs10));
        } else if (idx == 11) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs11));
        } else if (idx == 12) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs12));
        } else if (idx == 13) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs13));
        } else if (idx == 14) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs14));
        } else if (idx == 15) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs15));
        } else if (idx == 16) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs16));
        } else if (idx == 17) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs17));
        } else if (idx == 18) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs18));
        } else if (idx == 19) {
            System.debug('conditionArgs' + idx + ': ' + toString(conditionArgs19));
        }
    }

    /*
     * Convert an argument to a part of a query string
     * If the argument is a list or a set, the string has brackets surrounded
     * Otherwise it returns the string representation of the input
     */
    private static String toString(Object obj) {
        if (obj instanceOf Set<Id>) {
            return toString((Set<Id>)obj);
        } else if (obj instanceOf Set<String>) {
            return toString((Set<String>)obj);
        } else if (obj instanceOf Set<Integer>) {
            return toString((Set<Integer>)obj);
        } else if (obj instanceOf Set<Decimal>) {
            return toString((Set<Decimal>)obj);
        } else if (obj instanceOf List<String> ||
                   obj instanceOf List<Id>) {
            return toString((List<String>)obj);
        } else if (obj instanceOf List<Decimal> ||
                   obj instanceOf List<Integer>) {
            return toString((List<Decimal>)obj);
        } else if (obj instanceOf Id ||
                   obj instanceOf String) {
            return '\'' + String.valueOf(obj) + '\'';
        } else {
            return String.valueOf(obj);
        }
    }

    private static String toString(Set<Id> items) {
        return convertStringSetToString(toObjectSet(items));
    }

    private static String toString(Set<String> items) {
        return convertStringSetToString(toObjectSet(items));
    }

    private static String toString(Set<Integer> items) {
        return convertValueSetToString(toObjectSet(items));
    }

    private static String toString(Set<Decimal> items) {
        return convertValueSetToString(toObjectSet(items));
    }

    private static String toString(List<String> items) {
        return convertStringSetToString(toObjectSet(items));
    }

    private static String toString(List<Decimal> items) {
        return convertValueSetToString(toObjectSet(items));
    }

    /*
     * Convert a collection to Set<Object>
     */
    private static Set<Object> toObjectSet(Set<Id> items) {
        Set<Object> result = new Set<Object>();
        for (Id item: items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(Set<String> items) {
        Set<Object> result = new Set<Object>();
        for (String item: items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(Set<Integer> items) {
        Set<Object> result = new Set<Object>();
        for (Integer item: items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(Set<Decimal> items) {
        Set<Object> result = new Set<Object>();
        for (Decimal item: items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(List<Object> items) {
        Set<Object> result = new Set<Object>();
        for (Object item: items) {
            result.add(item);
        }
        return result;
    }

    private Query addChildRelationship(String relationshipName) {
        relationshipName = appendNamespace(relationshipName);
        if (null == childRelationships.get(relationshipName)) {
            throw new QueryException('Invalid child relationship ' +
                    relationshipName + ' in object ' + objectName);
        }
        Query childQuery = new Query();

        childQuery.objectName = relationshipName;
        childQuery.objectType =
            childRelationships.get(relationshipName);

        childQuerys.put(relationshipName, childQuery);

        return childQuery;
    }

    private Query addChildRelationship(Query childQuery) {
        final String relationshipName = childQuery.objectName;

        if (null == childRelationships.get(relationshipName)) {
            throw new QueryException('Invalid child relationship ' +
                    relationshipName + ' in object ' + objectName);
        }

        childQuery.objectType =
            childRelationships.get(relationshipName);

        childQuerys.put(relationshipName, childQuery);

        return childQuery;
    }

    private String appendNamespace(String src) {

        if (src.countMatches('__') == 1) {
            /*
             * Append the namespace when '__' occurs only once
             * In this case, '__' can only be '__c', '__r' or '__pc' as a suffix
             * If '__' occurs more than once, we will assume it contains a namespace prefix
             */
            src = namespace + src;
        } else if (src.endsWithIgnoreCase('__s') && src.countMatches('__') == 2) {
            /*
             * Append the namespace when it ends with '__s' and '__' occurs twice
             */
            src = namespace + src;
        }

        return src;
    }

    private String namespace = getNamespaceFromClass();

    private static String getNamespaceFromClass() {
        final String className = Query.class.getName();
        final List<String> nameSplit = className.split('\\.');

        if (nameSplit.size() > 1) {
            return nameSplit.get(0) + '__';
        } else {
            return '';
        }
    }

    private class QueryException extends Exception {
    }

    public class DateLiteral {
        private DateLiteral(String name) {
            this.name = name;
        }

        private DateLiteral(String name, Integer n) {
            this.name = name;
            this.num = n;
        }

        private String name;
        private Integer num;
    }

    public class Condition {
        public Condition doAnd(Condition other) {
            Condition newCondition = this.clone();

            newCondition.conditionString =
                '(' + this.conditionString + ') AND (' +
                shiftFormatStringIndice(other.conditionString, this.args.size()) +
                ')';

            newCondition.args.addAll(other.args);

            return newCondition;
        }

        public Condition doOr(Condition other) {
            Condition newCondition = this.clone();

            newCondition.conditionString =
                '(' + this.conditionString + ') OR (' +
                shiftFormatStringIndice(other.conditionString, this.args.size()) +
                ')';
            newCondition.args.addAll(other.args);

            return newCondition;
        }

        public Condition doNot() {
            Condition newCondition = this.clone();

            newCondition.conditionString =
                '(NOT (' + this.conditionString + '))';

            return newCondition;
        }

        private Condition() {
            args = new List<Object>();
        }

        private Condition(String formatString, Object arg) {
            this();
            if (arg instanceOf DateLiteral) {
                DateLiteral literal = (DateLiteral)arg;
                String literalExpression = literal.name;

                if (literal.num != null) {
                    literalExpression += ': ' + literal.num;
                }
                this.conditionString = formatString.replace('{0}', literalExpression);
            } else {
                this.conditionString = formatString;
                this.args.add(arg);
            }
        }

        private String conditionString;
        private List<Object> args;
    }
}
