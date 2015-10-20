<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ProjectFeedbackFieldUpdate</fullName>
        <field>ProjFeedUniqueKey__c</field>
        <formula>Project__r.Name  +  List_of_Values_Id__r.Name</formula>
        <name>ProjectFeedbackFieldUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Feedback Unique Key Update</fullName>
        <actions>
            <name>ProjectFeedbackFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISBLANK ( Visit__c )) &amp;&amp; (ISNEW() || (ISCHANGED( Project__c ) || ISCHANGED( List_of_Values_Id__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
