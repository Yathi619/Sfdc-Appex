<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Construction_Status_Unique_Key</fullName>
        <field>ProjConsStatusUniqueKey__c</field>
        <formula>Project__r.Name  + Tower__r.Id</formula>
        <name>Construction Status Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Construction Status Unique Key Update</fullName>
        <actions>
            <name>Construction_Status_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISBLANK ( Visit__c )) &amp;&amp; (ISNEW() || (ISCHANGED( Tower__c ) || ISCHANGED( Project__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
