<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PriceUniqueKeyUpdate</fullName>
        <field>ProjPriceUniqueKey__c</field>
        <formula>Project__r.Name  + Tower__r.Id</formula>
        <name>PriceUniqueKeyUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Detail Price Unique Key Update</fullName>
        <actions>
            <name>PriceUniqueKeyUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISBLANK ( Visit__c )) &amp;&amp; (ISNEW() || (ISCHANGED( Project__c )) || (ISCHANGED( Tower__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
