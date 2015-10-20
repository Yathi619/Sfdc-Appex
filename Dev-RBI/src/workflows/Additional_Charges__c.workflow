<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Additional_Charge_Project_Unique_Key_Upd</fullName>
        <field>ProjAddnChgUniqueKey__c</field>
        <formula>Project__r.Name  +  TEXT(Charge_Type__c)  +  TEXT(Charge_Detail__c)  +  TEXT(From_Floor__c)  +  TEXT(To_Floor__c)</formula>
        <name>Additional Charge Project Unique Key Upd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Additional Charge Unique Key Update</fullName>
        <actions>
            <name>Additional_Charge_Project_Unique_Key_Upd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISBLANK ( Visit__c )) &amp;&amp; (ISNEW() || (ISCHANGED( Project__c ) || ISCHANGED( Charge_Type__c ) || ISCHANGED( Charge_Detail__c ) || ISCHANGED( From_Floor__c ) || ISCHANGED( To_Floor__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
