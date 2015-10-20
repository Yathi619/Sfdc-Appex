<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ProjectPaymentPlanUpdateUniqueKey</fullName>
        <field>ProjectPaymentPlanUniqueKeyUpdate__c</field>
        <formula>Project__r.Name +  Plan_Type__r.Name</formula>
        <name>ProjectPaymentPlanUpdateUniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ProjectPaymentUniqueKeyUpdate</fullName>
        <actions>
            <name>ProjectPaymentPlanUpdateUniqueKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISBLANK ( Visit__c )) &amp;&amp; (ISNEW() || (ISCHANGED( Project_Id__c ))  || ( ISCHANGED( Plan_Type__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
