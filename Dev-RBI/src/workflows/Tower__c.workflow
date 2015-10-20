<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Tower_Unique_Key</fullName>
        <field>Unique_Tower_Name__c</field>
        <formula>Project__r.Name +&apos;-&apos; + Name</formula>
        <name>Update Tower Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Tower Name Unique Key Update</fullName>
        <actions>
            <name>Update_Tower_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the unique key in the Tower so that there are no duplicate Tower records for a project</description>
        <formula>(ISNEW()) || (ISCHANGED( Project__c ) || ISCHANGED(Name))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
