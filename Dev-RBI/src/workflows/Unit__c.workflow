<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update1_UnitUniqueKey</fullName>
        <field>Unit_UniqueKey__c</field>
        <formula>Tower_Id__c + Name</formula>
        <name>Update UnitUniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_UnitUniqueKey</fullName>
        <description>Update uniquekey  based on tower and unitname changed</description>
        <field>Unit_UniqueKey__c</field>
        <formula>Tower_Id__c + Name</formula>
        <name>Update UnitUniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Unit Name Unique Key Update</fullName>
        <actions>
            <name>Update_UnitUniqueKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the unique key in the unit  so that there are no duplicate unit records for a tower</description>
        <formula>ISNEW()|| ISCHANGED( Tower_Id__c ) || ISCHANGED(Name)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
