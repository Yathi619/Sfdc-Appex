<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Final_Approval</fullName>
        <description>Final Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/FinalApproved_Template</template>
    </alerts>
    <alerts>
        <fullName>Final_Rejection</fullName>
        <description>Final Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/FinalRejection_Template</template>
    </alerts>
    <alerts>
        <fullName>Whenever_a_visit_owner_is_changed_notify_a_new_owner</fullName>
        <description>Whenever a visit owner is changed, notify a new owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Visit_Technical_Head_or_surveyor_Change</template>
    </alerts>
    <alerts>
        <fullName>submitted_for_approval</fullName>
        <description>submitted for approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Initial_Submission</template>
    </alerts>
    <fieldUpdates>
        <fullName>Closed_Date_Update</fullName>
        <field>Closed_Date__c</field>
        <formula>Today()</formula>
        <name>Closed Date Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Change</fullName>
        <description>Status will be changed to Approved.</description>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Date</fullName>
        <description>Closed Date will be updated to Today</description>
        <field>Closed_Date__c</field>
        <formula>Today()</formula>
        <name>Update Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Visit_Status</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Visit Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Visit_Unique_Key</fullName>
        <field>ProjecIdVisitType__c</field>
        <formula>ProjectId__c &amp; &apos;-&apos; &amp;  TEXT(Visit_Report__c)</formula>
        <name>Visit Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TSR DVU Visit Closed Date Update</fullName>
        <actions>
            <name>Update_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To update the Closed Date field on TSR &amp; DVU Visits</description>
        <formula>ISCHANGED( Status__c )  &amp;&amp; (( ISPICKVAL(Status__c , &apos;Positive&apos;)  || ISPICKVAL(Status__c , &apos;Negative&apos;))  &amp;&amp;( ISPICKVAL(Visit_Report__c ,&apos;DVU Report&apos;)  || ISPICKVAL(Visit_Report__c,&apos;TSR Report&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Visit Owner Change</fullName>
        <actions>
            <name>Whenever_a_visit_owner_is_changed_notify_a_new_owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to notify a new owner of visit.(Surveyor, Technical Head)</description>
        <formula>AND(RecordType.DeveloperName != &apos;Tower&apos;, ISCHANGED(OwnerId))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Visit Unique key Update</fullName>
        <actions>
            <name>Visit_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Visit__c.Visit_Report__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
