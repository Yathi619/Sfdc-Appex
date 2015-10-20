<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Infrastructure_Update</fullName>
        <field>ProjInfraUniqueKey__c</field>
        <formula>Project_Id__r.Name +  Infrastructure_Near_Project__r.Name</formula>
        <name>Infrastructure Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Infrastructure Near Project Unique Key Update</fullName>
        <actions>
            <name>Infrastructure_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(ISBLANK ( Visit__c )) &amp;&amp; (ISNEW()  || (ISCHANGED(  Project_Id__c  ) || ISCHANGED(  Infrastructure_Near_Project__c  )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
