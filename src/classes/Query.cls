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
public class Query {
    public static final String VERSION = '2.0.0-pre';
    
    private static Map<String, SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        set;
    }

    /* Public members */
    public Query(String objectName) {
        this(objectName, getNamespaceFromClass());
    }

    public Query(String objectName, String namespace) {
        setNamespace(namespace);

        this.objectType = globalDescribe.get(appendNamespace(objectName));

        if (null == this.objectType) {
            throw new QueryException('Cannot find corresponding ' +
                    'SObject type from the SObject name ' + this.objectName);
        }

        this.objectName = this.objectType.getDescribe().getName();

        childRelationships = getChildRelationships();
    }

    public Query(Schema.SObjectType objectType) {
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
    public Query selectFields(String fieldNames) {
        if (fieldNames.contains(',')) {
            // parse the fieldNames separated by ','
            List<String> fieldList = fieldNames.split(', *');

            return selectFields(new Set<String>(fieldList));
        } else {
            final String fieldName = fieldNames;

            addToFieldSet(fieldName);
            return this;
        }
    }

    public Query selectFields(Schema.SObjectField field) {
        return selectField(field.getDescribe().getName());
    }

    public Query selectFields(Set<Schema.SObjectField> fields) {
        return selectFields(new List<Schema.SObjectField>(fields));
    }

    public Query selectFields(List<Schema.SObjectField> fields) {
        List<String> fieldStrings = new List<String>();
        for (Schema.SObjectField field : fields) {
            fieldStrings.add(field.getDescribe().getName());
        }
        return selectFields(fieldStrings);
    }

    /*
     * This function allows user provide a single field
     */
    public Query selectField(String fieldName) {
        addToFieldSet(fieldName);
        return this;
    }

    /*
     * This function allows user provide a single field
     */
    public Query selectField(Schema.SObjectField field) {
        return selectFields(field);
    }

    /*
     * Select a single field providing an alias
     * Only available in aggregate functions
     */
    public Query selectField(String fieldName, String alias) {
        functionFieldList.add(new FunctionFieldTuple(EMPTY, fieldName, alias));
        return this;
    }

    /*
     * Select a single field providing an alias
     * Only available in aggregate functions
     */
    public Query selectField(Schema.SObjectField field, String alias) {
        return selectField(field.getDescribe().getName(), alias);
    }

    public Query count(String field) {
        functionFieldList.add(new FunctionFieldTuple(COUNT, field));
        return this;
    }

    public Query count(String field, String alias) {
        functionFieldList.add(new FunctionFieldTuple(COUNT, field, alias));
        return this;
    }

    public Query toLabel(String field) {
        functionFieldList.add(new FunctionFieldTuple(TO_LABEL, field));
        return this;
    }

    public Query toLabel(String field, String alias) {
        functionFieldList.add(new FunctionFieldTuple(TO_LABEL, field, alias));
        return this;
    }

    public Query max(String field) {
        functionFieldList.add(new FunctionFieldTuple(MAX, field));
        return this;
    }

    public Query max(String field, String alias) {
        functionFieldList.add(new FunctionFieldTuple(MAX, field, alias));
        return this;
    }

    public Query min(String field) {
        functionFieldList.add(new FunctionFieldTuple(MIN, field));
        return this;
    }

    public Query min(String field, String alias) {
        functionFieldList.add(new FunctionFieldTuple(MIN, field, alias));
        return this;
    }

    public Query avg(String field) {
        functionFieldList.add(new FunctionFieldTuple(AVG, field));
        return this;
    }

    public Query avg(String field, String alias) {
        functionFieldList.add(new FunctionFieldTuple(AVG, field, alias));
        return this;
    }

    public Query sum(String field) {
        functionFieldList.add(new FunctionFieldTuple(SUM, field));
        return this;
    }

    public Query sum(String field, String alias) {
        functionFieldList.add(new FunctionFieldTuple(SUM, field, alias));
        return this;
    }

    public Query countDistinct(String field) {
        functionFieldList.add(new FunctionFieldTuple(COUNT_DISTINCT, field));
        return this;
    }

    public Query countDistinct(String field, String alias) {
        functionFieldList.add(new FunctionFieldTuple(COUNT_DISTINCT, field, alias));
        return this;
    }

    public Query groupBy(String fields) {
        if (fields.contains(',')) {
            // parse the fieldNames separated by ','
            List<String> fieldList = fields.split(', *');

            return groupBy(new Set<String>(fieldList));
        } else {
            return groupBy(new Set<String>{fields});
        }
    }

    public Query groupBy(Set<String> fieldSet) {
        for (String field : fieldSet) {
            field = appendNamespaceToField(field);
            field = field.toLowerCase();
            groupByFields.add(field);
        }
        return this;
    }

    /*
     * Select all fields of the object
     */
    public Query selectAllFields() {
        this.fieldSetting = initFieldSetting();
        this.fieldSetting.isSystemContext = true;
        return this;
    }

    /*
     * Select all user accessible fields
     */
    public Query selectReadableFields() {
        this.fieldSetting = initFieldSetting();
        return this;
    }

    /*
     * Select all user editable fields
     */
    public Query selectEditableFields() {
        this.fieldSetting = initFieldSetting();
        this.fieldSetting.isUpdateable = true;
        return this;
    }

    /*
     * Select all user creatable fields
     */
    public Query selectCreatableFields() {
        this.fieldSetting = initFieldSetting();
        this.fieldSetting.isCreateable = true;
        return this;
    }

    /*
     * Select all fields from a parent field
     */
    public Query selectAllFields(String parentField) {
        this.parentFieldSetting = initParentFieldSetting();
        this.parentFieldSetting.isSystemContext = true;
        return selectParentFields(parentField);
    }

    /*
     * Select all user accessible fields from a parent field
     */
    public Query selectReadableFields(String parentField) {
        this.ParentFieldSetting = initParentFieldSetting();
        return selectParentFields(parentField);
    }

    public Query selectAllFields(FieldSetting config) {
        this.fieldSetting = config;
        return this;
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

    public Query lookup(String fieldName, Query query) {
        return addConditionIn(fieldName, query);
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
     * Example: addConditionEq(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate = :Datetime.now()"
     */
    public Query addConditionEq(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionEq(lhs.getDescribe().getName(), rhs));
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
     * Example: addConditionNotEq(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate != :Datetime.now()"
     */
    public Query addConditionNotEq(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionNotEq(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition
     * Example: addConditionNull('Name')
     *          the condition is equivalent to "Name = null"
     */
    public Query addConditionNull(String field) {
        return addCondition(conditionNull(field));
    }

    /*
     * Add a condition
     * Example: addConditionNull(Account.Name)
     *          the condition is equivalent to "Name = null"
     */
    public Query addConditionNull(Schema.SObjectField field) {
        return addCondition(conditionNull(field.getDescribe().getName()));
    }

    /*
     * Add a condition
     * Example: addConditionNotNull('Name')
     *          the condition is equivalent to "Name != null"
     */
    public Query addConditionNotNull(String field) {
        return addCondition(conditionNotNull(field));
    }

    /*
     * Add a condition
     * Example: addConditionNotNull(Account.Name)
     *          the condition is equivalent to "Name != null"
     */
    public Query addConditionNotNull(Schema.SObjectField field) {
        return addCondition(conditionNotNull(field.getDescribe().getName()));
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
     * Example: addConditionIn(Account.Name, mySet)
     *          the condition is equivalent to "Name IN :mySet"
     */
    public Query addConditionIn(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionIn(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a semi-join condition
     * Example: addConditionIn('Id', new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id IN (SELECT AccountId FROM Opportunity)"
     */
    public Query addConditionIn(String lhs, Query rhs) {
        return addCondition(conditionIn(lhs, rhs));
    }

    /*
     * Add a semi-join condition
     * Example: addConditionIn(Account.Id, new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id IN (SELECT AccountId FROM Opportunity)"
     */
    public Query addConditionIn(Schema.SObjectField lhs, Query rhs) {
        return addCondition(conditionIn(lhs.getDescribe().getName(), rhs));
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
     * Example: addConditionNotIn(Account.Name, mySet)
     *          the condition is equivalent to "Name NOT IN :mySet"
     */
    public Query addConditionNotIn(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionNotIn(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add an anti-join condition
     * Example: addConditionNotIn('Id', new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id NOT IN (SELECT AccountId FROM Opportunity)"
     */
    public Query addConditionNotIn(String lhs, Query rhs) {
        return addCondition(conditionNotIn(lhs, rhs));
    }

    /*
     * Add an anti-join condition
     * Example: addConditionNotIn(Account.Id, new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id NOT IN (SELECT AccountId FROM Opportunity)"
     */
    public Query addConditionNotIn(Schema.SObjectField lhs, Query rhs) {
        return addCondition(conditionNotIn(lhs.getDescribe().getName(), rhs));
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
     * Example: addConditionLt(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public Query addConditionLt(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionLt(lhs.getDescribe().getName(), rhs));
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
     * Example: addConditionLe(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate <= :Datetime.now()"
     */
    public Query addConditionLe(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionLe(lhs.getDescribe().getName(), rhs));
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
     * Example: addConditionGt(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public Query addConditionGt(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionGt(lhs.getDescribe().getName(), rhs));
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
     * Example: addConditionGe(Account.CreatedDate, Datetime.now())
     *          is equivaGent to "CreatedDate <= :Datetime.now()"
     */
    public Query addConditionGe(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionGe(lhs.getDescribe().getName(), rhs));
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
     * Example: addConditionLike(Account.CreatedDate, '%Sam%')
     *          the condition is equivalent to "Name Like :Datetime.now()"
     */
    public Query addConditionLike(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionLike(lhs.getDescribe().getName(), rhs));
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
     * Add a condition
     * Example: addConditionNotLike(Account.CreatedDate, '%Sam%')
     *          the condition is equivalent to "NOT Name LIKE '%Sam%'"
     */
    public Query addConditionNotLike(Schema.SObjectField lhs, Object rhs) {
        return addCondition(conditionNotLike(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition
     * Example: addConditionIncludes('Channel', 'MyChannel')
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public Query addConditionIncludes(String lhs, String rhs) {
        return addCondition(conditionIncludes(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionIncludes(QuckText.Channel, 'MyChannel')
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public Query addConditionIncludes(Schema.SObjectField lhs, String rhs) {
        return addCondition(conditionIncludes(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition
     * Example: addConditionIncludes('Channel', new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public Query addConditionIncludes(String lhs, List<String> rhs) {
        return addCondition(conditionIncludes(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionIncludes(QuckText.Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public Query addConditionIncludes(Schema.SObjectField lhs, List<String> rhs) {
        return addCondition(conditionIncludes(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition
     * Example: addConditionIncludes('Channel', new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public Query addConditionIncludes(String lhs, Set<String> rhs) {
        return addCondition(conditionIncludes(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionIncludes(QuckText.Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public Query addConditionIncludes(Schema.SObjectField lhs, Set<String> rhs) {
        return addCondition(conditionIncludes(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition
     * Example: addConditionExcludes('Channel', 'MyChannel')
     *          the condition is equivalent to "Channel EXCLUDES ('MyChannel')"
     */

    public Query addConditionExcludes(String lhs, String rhs) {
        return addCondition(conditionExcludes(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionExcludes(QuckText.Channel, 'MyChannel')
     *          the condition is equivalent to "Channel EXCLUDES ('MyChannel')"
     */

    public Query addConditionExcludes(Schema.SObjectField lhs, String rhs) {
        return addCondition(conditionExcludes(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition
     * Example: addConditionExcludes('Channel', new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel EXCLUDES ('MyChannel')"
     */

    public Query addConditionExcludes(String lhs, List<String> rhs) {
        return addCondition(conditionExcludes(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionExcludes(QuckText.Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel EXCLUDES ('MyChannel')"
     */

    public Query addConditionExcludes(Schema.SObjectField lhs, List<String> rhs) {
        return addCondition(conditionExcludes(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition
     * Example: addConditionExcludes('Channel', new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel EXCLUDES ('MyChannel')"
     */

    public Query addConditionExcludes(String lhs, Set<String> rhs) {
        return addCondition(conditionExcludes(lhs, rhs));
    }

    /*
     * Add a condition
     * Example: addConditionExcludes(QuckText.Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel EXCLUDES ('MyChannel')"
     */

    public Query addConditionExcludes(Schema.SObjectField lhs, Set<String> rhs) {
        return addCondition(conditionExcludes(lhs.getDescribe().getName(), rhs));
    }

    /*
     * Add a condition directly from String
     * Example: addConditionString('Channel EXCLUDES (\'MyChannel\')');
     *          the condition is equivalent to "Channel EXCLUDES ('MyChannel')"
     */
    public Query addConditionString(String conditionString){
        return addCondition(conditionString(conditionString));
    }
    /*
     * Add condition with a Condition object
     */
    public Query addCondition(Condition condition) {
        String newConditionString =
                shiftFormatStringIndice(condition.conditionString, conditionArgs.size());
        newConditionString = '(' + newConditionString + ')';
        conditions.add(newConditionString);
        conditionArgs.addAll(condition.args);
        return this;
    }

    /*
     * Add having condition for group by clauses
     */
    public Query addHaving(Condition condition) {
        havingCondition = condition;
        return this;
    }

    /*
     * Add all rows option for query
     */
    public Query allRows() {
        addAllRows = true;
        return this;
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
     * Example: conditionEq(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate = :Datetime.now()"
     */
    public static Condition conditionEq(Schema.SObjectField lhs, Object rhs) {
        return conditionEq(lhs.getDescribe().getName(), rhs);
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
     * Example: conditionNotEq(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate != :Datetime.now()"
     */
    public static Condition conditionNotEq(Schema.SObjectField lhs, Object rhs) {
        return conditionNotEq(lhs.getDescribe().getName(), rhs);
    }

    /*
     * Create a condition
     * Example: conditionNull('Name')
     *          the condition is equivalent to "Name = null"
     */
    public static Condition conditionNull(String field) {
        return conditionEq(field, null);
    }

    /*
     * Add a condition
     * Example: conditionNull(Account.Name)
     *          the condition is equivalent to "Name = null"
     */
    public static Condition conditionNull(Schema.SObjectField field) {
        return conditionEq(field.getDescribe().getName(), null);
    }

    /*
     * Add a condition
     * Example: conditionNotNull('Name')
     *          the condition is equivalent to "Name != null"
     */
    public static Condition conditionNotNull(String field) {
        return conditionNotEq(field, null);
    }

    /*
     * Add a condition
     * Example: conditionNotNull(Account.Name)
     *          the condition is equivalent to "Name != null"
     */
    public static Condition conditionNotNull(Schema.SObjectField field) {
        return conditionNotEq(field.getDescribe().getName(), null);
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
     * Example: conditionIn(Account.Name, mySet)
     *          the condition is equivalent to "Name IN :mySet"
     */
    public static Condition conditionIn(Schema.SObjectField lhs, Object rhs) {
        return conditionIn(lhs.getDescribe().getName(), rhs);
    }

    /*
     * Create a semi-join condition
     * Example: conditionIn('Id', new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id IN (SELECT AccountId FROM Opportunity)"
     */
    public static Condition conditionIn(String lhs, Query rhs) {
        final String formatString = lhs + ' IN (' +
                rhs.formQueryStringPreformat() + ')';

        Condition condition = new Condition();

        condition.conditionString = formatString;
        condition.args = rhs.conditionArgs;

        return condition;
    }

    /*
     * Create a semi-join condition
     * Example: conditionIn(Account.Id, new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id IN (SELECT AccountId FROM Opportunity)"
     */
    public static Condition conditionIn(Schema.SObjectField lhs, Query rhs) {
        return conditionIn(lhs.getDescribe().getName(), rhs);
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
     * Example: conditionNotIn(Account.Name, mySet)
     *          the condition is equivalent to "Name NOT IN :mySet"
     */
    public static Condition conditionNotIn(Schema.SObjectField lhs, Object rhs) {
        return conditionNotIn(lhs.getDescribe().getName(), rhs);
    }

    /*
     * Create an anti-join condition
     * Example: conditionNotIn('Id', new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id NOT IN (SELECT AccountId FROM Opportunity)"
     */
    public static Condition conditionNotIn(String lhs, Query rhs) {
        final String formatString = lhs + ' NOT IN (' +
                rhs.formQueryStringPreformat() + ')';

        Condition condition = new Condition();

        condition.conditionString = formatString;
        condition.args = rhs.conditionArgs;

        return condition;
    }

    /*
     * Create an anti-join condition
     * Example: conditionNotIn(Account.Id, new Query('Opportunity').selectField('AccountId'))
     *          the condition is equivalent to "Id NOT IN (SELECT AccountId FROM Opportunity)"
     */
    public static Condition conditionNotIn(Schema.SObjectField lhs, Query rhs) {
        return conditionNotIn(lhs.getDescribe().getName(), rhs);
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
     * Example: conditionLt(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static Condition conditionLt(Schema.SObjectField lhs, Object rhs) {
        return conditionLt(lhs.getDescribe().getName(), rhs);
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
     * Example: conditionLe(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate <= :Datetime.now()"
     */
    public static Condition conditionLe(Schema.SObjectField lhs, Object rhs) {
        return conditionLe(lhs.getDescribe().getName(), rhs);
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
     * Example: conditionGt(Account.CreatedDate, Datetime.now())
     *          the condition is equivalent to "CreatedDate < :Datetime.now()"
     */
    public static Condition conditionGt(Schema.SObjectField lhs, Object rhs) {
        return conditionGt(lhs.getDescribe().getName(), rhs);
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
     * Example: conditionGe(Account.CreatedDate, Datetime.now())
     *          is equivaGent to "CreatedDate <= :Datetime.now()"
     */
    public static Condition conditionGe(Schema.SObjectField lhs, Object rhs) {
        return conditionGe(lhs.getDescribe().getName(), rhs);
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
     * Example: conditionLike(Account.Name, '%Sam%')
     *          the condition is equivalent to "Name Like :Datetime.now()"
     */
    public static Condition conditionLike(Schema.SObjectField lhs, Object rhs) {
        return conditionLike(lhs.getDescribe().getName(), rhs);
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

    /*
     * Create a condition
     * Example: conditionNotLike(Account.Name, '%Sam%')
     *          the condition is equivalent to "NOT Name LIKE '%Sam%'"
     */
    public static Condition conditionNotLike(Schema.SObjectField lhs, Object rhs) {
        return conditionNotLike(lhs.getDescribe().getName(), rhs);
    }

    /*
     * Create a condition
     * Example: conditionIncludes('Channel', 'MyChannel')
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static Condition conditionIncludes(String lhs, String rhs) {
        return conditionIncludes(lhs, new Set<String>{rhs});
    }

    /*
     * Create a condition
     * Example: conditionIncludes(QuickText.Channel, 'MyChannel')
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static Condition conditionIncludes(Schema.SObjectField lhs, String rhs) {
        return conditionIncludes(lhs.getDescribe().getName(), new Set<String>{rhs});
    }

    /*
     * Create a condition
     * Example: conditionIncludes(Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static Condition conditionIncludes(String lhs, List<String> rhs) {
        return conditionIncludes(lhs, new Set<String>(rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes(QuickText.Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static Condition conditionIncludes(Schema.SObjectField lhs, List<String> rhs) {
        return conditionIncludes(lhs.getDescribe().getName(), new Set<String>(rhs));
    }

    /*
     * Create a condition
     * Example: conditionIncludes(Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static Condition conditionIncludes(String lhs, Set<String> rhs) {
        final String formatString = lhs + ' INCLUDES ' + toString(rhs);
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionIncludes(QuickText.Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "Channel INCLUDES ('MyChannel')"
     */
    public static Condition conditionIncludes(Schema.SObjectField lhs, Set<String> rhs) {
        return conditionIncludes(lhs.getDescribe().getName(), rhs);
    }

    /*
     * Create a condition
     * Example: conditionExcludes(Channel, 'MyChannel')
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */

    public static Condition conditionExcludes(String lhs, String rhs) {
        return conditionExcludes(lhs, new Set<String>{rhs});
    }

    /*
     * Create a condition
     * Example: conditionExcludes(QuickText.Channel, 'MyChannel')
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */

    public static Condition conditionExcludes(Schema.SObjectField lhs, String rhs) {
        return conditionExcludes(lhs.getDescribe().getName(), new Set<String>{rhs});
    }

    /*
     * Create a condition
     * Example: conditionExcludes(Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static Condition conditionExcludes(String lhs, List<String> rhs) {
        return conditionExcludes(lhs, new Set<String>(rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(QuickText.Channel, new List<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static Condition conditionExcludes(Schema.SObjectField lhs, List<String> rhs) {
        return conditionExcludes(lhs.getDescribe().getName(), new Set<String>(rhs));
    }

    /*
     * Create a condition
     * Example: conditionExcludes(Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static Condition conditionExcludes(String lhs, Set<String> rhs) {
        final String formatString = lhs + ' EXCLUDES ' + toString(rhs);
        return new Condition(formatString, rhs);
    }

    /*
     * Create a condition
     * Example: conditionExcludes(QuickText.Channel, new Set<String>{'MyChannel'})
     *          the condition is equivalent to "QuickText.Channel EXCLUDES ('MyChannel')"
     */
    public static Condition conditionExcludes(Schema.SObjectField lhs, Set<String> rhs) {
        return conditionExcludes(lhs.getDescribe().getName(), rhs);
    }

    public static Condition conditionString(String conditionString){
        return new Condition(conditionString);
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

    /*
     * After calling this function, optional clause will be added to the query
     */

    public Query forView() {
        optionalClause = 'FOR VIEW';
        return this;
    }

    public Query forUpdate() {
        optionalClause = 'FOR UPDATE';
        return this;
    }

    public Query forReference() {
        optionalClause = 'FOR REFERENCE';
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

    public static DateLiteral buildDateLiteral(String name, Integer num) {
        return new DateLiteral(name, num);
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
    
    public Query orderBy(Schema.SObjectField field) {
        return orderBy(field.getDescribe().getName());
    }

    public Query orderBy(Schema.SObjectField field, String orderDirection) {
        return orderBy(field.getDescribe().getName(), orderDirection);
    }

    public Query orderBy(Schema.SObjectField field, String orderDirection, Boolean nullsFirst) {
        return orderBy(field.getDescribe().getName(), orderDirection, nullsFirst);
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

    public static void enforceGlobalSecurity(Boolean enforce) {
        Query.securityEnforcedGlobal = enforce;
    }

    public static void enforceGlobalSecurity() {
        enforceGlobalSecurity(true);
    }

    public Query enforceSecurity(Boolean enforce) {
        this.securityEnforced = enforce;
        return this;
    }

    public Query enforceSecurity() {
        return enforceSecurity(true);
    }

    public String toQueryString() {
        String rawString = formQueryStringPreformat();

        List<String> args = new List<String>();

        for (Object arg : finalConditionArgs) {
            args.add(toString(arg));
        }

        return format(rawString, args);
    }

    public SObject fetch() {
        final List<SObject> fetchedList = fetch(1);
        if (fetchedList.isEmpty()) {
            return null;
        } else {
            return fetchedList.get(0);
        }
    }

    public List<SObject> fetch(Integer first, Integer last) {
        List<SObject> retList = new List<SObject>();
        final List<SObject> fetchedList = setLimit(last).run();

        for (Integer i = first; i < fetchedList.size() && i < last; i++) {
            retList.add(fetchedList.get(i));
        }

        return retList;
    }

    public List<SObject> fetch(Integer size) {
        return fetch(0, size);
    }

    public List<SObject> run() {
        return toSObjectList();
    }

    public List<SObject> runPreservingIdOrder(List<Id> idList) {
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
        String queryString = formQueryString();
        return Database.query(queryString);
    }

    public List<AggregateResult> aggregate() {
        String queryString = formQueryString();
        return Database.query(queryString);
    }

    public Integer countQuery() {
        count('');
        String queryString = formQueryString();
        return Database.countQuery(queryString);
    }

    public List<Id> toIdList() {
        List<Id> ret = new List<Id>();

        for (SObject item : run()) {
            ret.add(item.Id);
        }

        return ret;
    }

    public Database.QueryLocator getQueryLocator() {
        String queryString = formQueryString();
        return Database.getQueryLocator(queryString);
    }

    public Schema.SObjectType getSObjectType() {
        return objectType;
    }

    /* Private members */
    private Query() {
    }

    // State variables
    private Set<String> fields = new Set<String>();
    private Set<String> parentReferences = new Set<String>();
    private FieldSetting fieldSetting;
    private ParentFieldSetting parentFieldSetting;

    private List<String> conditions = new List<String>();
    private static final Integer maxArgSize = 20;
    private Integer finalConditionArgsIdx = 0;
    private List<Object> conditionArgs = new List<Object>();
    private List<Object> finalConditionArgs = new List<Object>();
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
    private String optionalClause = '';
    private Integer sizeLimit = -1;
    private Integer resultOffset = -1;
    private Map<String, Query> childQuerys = new Map<String, Query>();
    private Boolean addAllRows = false;

    public class FieldSetting {
        public Boolean isAccessible = true;
        public Boolean isAutoNumber = false;
        public Boolean isCalculated = false;
        public Boolean isCascadeDelete = false;
        public Boolean isCaseSensitive = false;
        public Boolean isCreateable = false;
        public Boolean isCustom = false;
        public Boolean isDefaultedOnCreate = false;
        public Boolean isDependentPicklist = false;
        public Boolean isExternalID = false;
        public Boolean isFilterable = false;
        public Boolean isFormulaTreatNullNumberAsZero = false;
        public Boolean isGroupable = false;
        public Boolean isHtmlFormatted = false;
        public Boolean isIdLookup = false;
        public Boolean isNameField = false;
        public Boolean isNamePointing = false;
        public Boolean isNillable = false;
        public Boolean isPermissionable = false;
        public Boolean isRestrictedDelete = false;
        public Boolean isRestrictedPicklist = false;
        public Boolean isSearchPrefilterable = false;
        public Boolean isSortable = false;
        public Boolean isUnique = false;
        public Boolean isUpdateable = false;
        public Boolean isWriteRequiresMasterRead = false;
        public Boolean isSystemContext = false;
    }

    public class ParentFieldSetting {
        public Boolean isSystemContext = false;
    }

    private List<OrderTuple> orderList = new List<OrderTuple>();
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

    private List<FunctionFieldTuple> functionFieldList = new List<FunctionFieldTuple>();
    private class FunctionFieldTuple {
        private String function;
        private String fieldName;
        private String alias;

        private FunctionFieldTuple(String function, String fieldName, String alias) {
            this.function = function;
            this.fieldName = fieldName;
            this.alias = alias;
        }

        private FunctionFieldTuple(String function, String fieldName) {
            this(function, fieldName, null);
        }
    }

    private Set<String> groupByFields = new Set<String>();
    Condition havingCondition;

    private final String EMPTY = '';
    private final String MAX = 'MAX';
    private final String MIN = 'MIN';
    private final String AVG = 'AVG';
    private final String SUM = 'SUM';
    private final String COUNT = 'COUNT';
    private final String COUNT_DISTINCT = 'COUNT_DISTINCT';
    private final String TO_LABEL = 'TOLABEL';

    // Object Schema variables
    private String objectName;
    private Schema.SObjectType objectType;
    private Map<String, Schema.SObjectType> childRelationships;

    private Query addAllFields() {
        // Get all the fields
        final Map<String, Schema.SObjectField> fieldMap =
                objectType.getDescribe().fields.getMap();
        FieldSetting config = this.fieldSetting;

        for (String fieldName : fieldMap.keySet()) {
            Boolean flag = config.isAccessible;
            if (config.isAccessible) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isAccessible();
            }
            if (config.isExternalID) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isExternalID();
            }
            if (config.isFilterable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isFilterable();
            }
            if (config.isCreateable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isCreateable();
            }
            if (config.isUpdateable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isUpdateable();
            }
            if (config.isSortable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isSortable();
            }
            if (config.isCalculated) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isCalculated();
            }
            if (config.isCaseSensitive) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isCaseSensitive();
            }
            if (config.isCascadeDelete) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isCascadeDelete();
            }
            if (config.isAutoNumber) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isAutoNumber();
            }
            if (config.isCustom) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isCustom();
            }
            if (config.isFilterable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isFilterable();
            }
            if (config.isFormulaTreatNullNumberAsZero) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isFormulaTreatNullNumberAsZero();
            }
            if (config.isGroupable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isGroupable();
            }
            if (config.isHtmlFormatted) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isHtmlFormatted();
            }
            if (config.isIdLookup) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isIdLookup();
            }
            if (config.isNameField) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isNameField();
            }
            if (config.isNamePointing) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isNamePointing();
            }
            if (config.isNillable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isNillable();
            }
            if (config.isPermissionable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isPermissionable();
            }
            if (config.isRestrictedPicklist) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isRestrictedPicklist();
            }
            if (config.isSearchPrefilterable) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isSearchPrefilterable();
            }
            if (config.isUnique) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isUnique();
            }
            if (config.isWriteRequiresMasterRead) {
                flag = flag && fieldMap.get(fieldName).getDescribe().isWriteRequiresMasterRead();
            }
            if (config.isSystemContext) {
                flag = config.isSystemContext;
            }
            if (flag) {
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
        } else if (parentName.endsWithIgnoreCase('__pr')) {
            parentName = parentName.removeEnd('__pr') + '__pc';
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
        } else if (fieldName.endsWithIgnoreCase('__r') || fieldName.endsWithIgnoreCase('__pr')) {
            return true;
        } else if (fieldName.endsWithIgnoreCase('Id')) {
            return false;
        } else {
            return true;
        }
    }

    private String addToFieldSet(String fieldName) {
        fieldName = appendNamespaceToField(fieldName);
        fieldName = fieldName.toLowerCase();

        fields.add(fieldName);

        return fieldName;
    }

    private String appendNamespaceToField(String fieldName) {
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

        return fieldName;
    }

    private Map<String, Schema.SObjectType> getChildRelationships() {
        Map<String, Schema.SObjectType> childMap =
                new Map<String, Schema.SObjectType>();
        final List<Schema.ChildRelationship> childList =
                objectType.getDescribe().getChildRelationships();

        for (Schema.ChildRelationship child : childList) {
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
        // or query has to run in system context
        for (String fieldName : fieldMap.keySet()) {
            if (isSelectAllParentFieldsSet() ||
                fieldMap.get(fieldName).getDescribe().isAccessible())
            {
                fields.add((appendNamespaceToField(parentName) + '.' + fieldName).
                        toLowerCase());
            }
        }
        return this;
    }

    private Boolean isSelectAllParentFieldsSet(){
        return parentFieldSetting != null &&
            parentFieldSetting.isSystemContext;
    }

    private void saveConditions(List<Object> args) {
        finalConditionArgsIdx += args.size();
        finalConditionArgs.addAll(args);
    }

    /*
     * Save the arg to the member variable
     */
    private void saveConditionArg() {
        for (Integer i = 0; i < finalConditionArgs.size(); i++) {
            saveConditionArg(i, finalConditionArgs[i]);
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
        String queryStr = formQueryStringPreformat();

        saveConditionArg();

        // format the arguments
        List<String> args = new List<String>();
        for (Integer i = 0; i < finalConditionArgsIdx; i++) {
            args.add(':conditionArgs' + i);
        }
        queryStr = format(queryStr, args);

        return queryStr;
    }

    private String formQueryStringPreformat() {
        finalConditionArgsIdx = 0;

        String query = 'SELECT ';

        query += formFieldString();

        if (!functionFieldList.isEmpty()) {
            query += ' ' + formAggregateString();
        }

        query += ' FROM ' + objectName;

        final String conditionString = formConditionString();

        if (String.isNotBlank(conditionString)) {
            query += ' WHERE ' + conditionString;
        }

        if (securityEnforced != null ? securityEnforced : securityEnforcedGlobal) {
            query += ' WITH SECURITY_ENFORCED';
        }

        if (!groupByFields.isEmpty()) {
            query += ' GROUP BY ' + formGroupByString();
        }

        if (havingCondition != null) {
            query += ' HAVING ' + formHavingString();
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

        if (!String.isEmpty(optionalClause)) {
            query += ' ' + optionalClause;
            if ('FOR UPDATE'.equalsIgnoreCase(optionalClause) && addAllRows) {
                throw new QueryException('You cannot use the ALL ROWS keywords ' +
                    'with the FOR UPDATE keywords');
            }
        }

        if (addAllRows) {
            query += ' ' + 'ALL ROWS';
        }

        return query;
    }

    private String formFieldString() {
        String fieldString = '';

        for (String parentName : parentReferences) {
            addParentFields(parentName);
        }

        if (this.fieldSetting != null){
            addAllFields();
        }

        if (fields.isEmpty() && functionFieldList.isEmpty()) {
            addToFieldSet('Id');
        }

        for (String field : fields) {
            fieldString += field + ', ';
        }

        fieldString += formSubqueryString();

        fieldString = fieldString.removeEnd(', ');

        return fieldString;
    }

    private String formAggregateString() {
        String aggregateString = '';

        if (!fields.isEmpty()) {
            aggregateString += ', ';
        }

        for (FunctionFieldTuple tuple : functionFieldList) {
            String field = appendNamespaceToField(tuple.fieldName);
            if (String.isNotBlank(tuple.function)) {
                aggregateString += tuple.function + '(' + field + ')';
            } else {
                aggregateString += field + ' ';
            }
            if (tuple.alias != null) {
                aggregateString += tuple.alias;
            }
            aggregateString += ', ';
        }

        aggregateString = aggregateString.removeEnd(', ');

        return aggregateString;
    }

    private String formConditionString() {
        String conditionString = '';

        for (String condition : conditions) {
            conditionString += condition;
            // either 'AND' or 'OR'
            conditionString += ' ' + conditionOperator + ' ';
        }

        // remove either 'AND' or 'OR' in the end
        conditionString = conditionString.removeEnd(' ' + conditionOperator + ' ');

        // shift the arg index
        conditionString = shiftFormatStringIndice(conditionString, finalConditionArgsIdx);
        saveConditions(conditionArgs);

        return conditionString;
    }

    private String formHavingString() {
        String conditionString =
                shiftFormatStringIndice(havingCondition.conditionString, finalConditionArgsIdx);

        // shift the arg index
        saveConditions(havingCondition.args);

        return conditionString;
    }

    private String formSubqueryString() {
        String subqueryString = '';

        for (String key : childQuerys.keySet()) {
            Query childQuery = childQuerys.get(key);

            subqueryString += '(';
            subqueryString += shiftFormatStringIndice(childQuery.formQueryStringPreformat(),
                    finalConditionArgsIdx);
            subqueryString += ')';
            subqueryString += ', ';

            saveConditions(childQuery.conditionArgs);
        }

        return subqueryString;
    }

    private String formGroupByString() {
        String groupByString = '';

        for (String field : groupByFields) {
            groupByString += field + ', ';
        }
        groupByString = groupByString.removeEnd(', ');

        return groupByString;
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
                orderByString += ' NULLS LAST';
            }
            count++;
        }
        return orderByString;
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
     * Replacement of String.format
     */
    private static String format(String formatString, List<String> args) {
        for (Integer i = 0; i < args.size(); i++) {
            formatString = formatString.replaceAll('\\{' + i + '\\}', args[i]);
        }
        return formatString;
    }

    /*
     * Convert an argument to a part of a query string
     * If the argument is a list or a set, the string has brackets surrounded
     * Otherwise it returns the string representation of the input
     */
    private static String toString(Object obj) {
        if (obj == null) {
            return 'null';
        } else if (obj instanceof Set<Id>) {
            return toString((Set<Id>) obj);
        } else if (obj instanceof Set<String>) {
            return toString((Set<String>) obj);
        } else if (obj instanceof Set<Integer>) {
            return toString((Set<Integer>) obj);
        } else if (obj instanceof Set<Decimal>) {
            return toString((Set<Decimal>) obj);
        } else if (obj instanceof List<String> ||
                obj instanceof List<Id>) {
            return toString((List<String>) obj);
        } else if (obj instanceof List<Decimal> ||
                obj instanceof List<Integer>) {
            return toString((List<Decimal>) obj);
        } else if (obj instanceof Id ||
                obj instanceof String) {
            return '\'' + String.escapeSingleQuotes(String.valueOf(obj)) + '\'';
        } else if (obj instanceof Datetime) {
            return JSON.serialize(obj).replaceAll('"', '');
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
        for (Id item : items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(Set<String> items) {
        Set<Object> result = new Set<Object>();
        for (String item : items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(Set<Integer> items) {
        Set<Object> result = new Set<Object>();
        for (Integer item : items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(Set<Decimal> items) {
        Set<Object> result = new Set<Object>();
        for (Decimal item : items) {
            result.add(item);
        }
        return result;
    }

    private static Set<Object> toObjectSet(List<Object> items) {
        Set<Object> result = new Set<Object>();
        for (Object item : items) {
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

    private static Boolean securityEnforcedGlobal = false;
    private Boolean securityEnforced = null;

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

    private FieldSetting initFieldSetting(){
        FieldSetting config = new FieldSetting();
        return config;
    }

    private ParentFieldSetting initParentFieldSetting(){
        ParentFieldSetting config = new ParentFieldSetting();
        return config;
    }

    private class QueryException extends Exception {
    }

    private class SecurityException extends Exception {
    }

    public class QueryConditionException extends Exception{
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

        private Condition(String conditionString){
            this();
            if(!isConditionStringSafe(conditionString)){
                throw new QueryConditionException('Condition String contains either unended string literal or non-matching parentheses');
            }

            this.conditionString = '(' + conditionString + ')';
        }

        private Condition(String formatString, Object arg) {
            this();
            if (arg instanceof DateLiteral) {
                DateLiteral literal = (DateLiteral) arg;
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

        /*
         * Checks if condition string does not have unended String literal or non-matching parentheses
         */
        public Boolean isConditionStringSafe(String conditionString){
            Integer paranthesesNestLevel = 0;
            Boolean stringLiteralMode = false;

            for(Integer i = 0; i <conditionString.length(); i++){
                if(!stringLiteralMode){
                    if(conditionString.charAt(i) == '('.charAt(0)){
                        paranthesesNestLevel++;
                    }

                    if(conditionString.charAt(i) == ')'.charAt(0)){
                        paranthesesNestLevel--;
                    }
                }

                // check if quote is not escaped (or first character in the conditionString)
                if(conditionString.charAt(i) == '\''.charAt(0) && (i == 0 || conditionString.charAt(i-1) != '\\'.charAt(0))){
                    stringLiteralMode = !stringLiteralMode;
                }

                // if parantheses nest level gets negative the string is SOQL injection unsafe
                if(paranthesesNestLevel < 0){
                    return false;
                }
            }

            // if we are in string Literal mode - string is unsafe
            // otherwise return true
            return !stringLiteralMode;
        }

        private String conditionString;
        private List<Object> args;
    }
}
