<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_new_exception_record_created</fullName>
        <description>Email new exception record created</description>
        <protected>false</protected>
        <recipients>
            <field>PAS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Exception_record_Creation</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_PAS_Manager</fullName>
        <description>Send Email to PAS Manager</description>
        <protected>false</protected>
        <recipients>
            <field>PAS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Exception_record_Creation</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_PAS_Manager_Customer</fullName>
        <description>Send Email to PAS Manager</description>
        <protected>false</protected>
        <recipients>
            <field>PAS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Exception_record_Creation_Customer</template>
    </alerts>
    <fieldUpdates>
        <fullName>Closed_date_update_in_Qury_Exception</fullName>
        <field>Query_Resolved_Date__c</field>
        <formula>TODAY()</formula>
        <name>Closed date update in Query/exception</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PAS_Manager_Email</fullName>
        <field>PAS_Manager_Email__c</field>
        <formula>Visit__r.Project__r.Team_Lead_Email__c</formula>
        <name>Update PAS Manager Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PAS_Manager_Email_Portal</fullName>
        <description>Update PAS Manager Email id</description>
        <field>PAS_Manager_Email__c</field>
        <formula>Customer_Project__r.Project_Id__r.Team_Lead_Email__c</formula>
        <name>Update PAS Manager Email - Portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Closed date update when the status of the exception is closed</fullName>
        <actions>
            <name>Closed_date_update_in_Qury_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updating close date to today when status of exception is closed</description>
        <formula>(ISCHANGED(Exception_Status__c)  &amp;&amp;   ISPICKVAL(Exception_Status__c, &quot;Closed&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Exception record creation</fullName>
        <actions>
            <name>Email_new_exception_record_created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_PAS_Manager_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send an email to PAS Manager whenever a record with exception is created</description>
        <formula>AND(ISPICKVAL(Exception_Status__c, &apos;Open&apos;), RecordType.DeveloperName = &apos;Exception&apos;,  NOT(ISBLANK(Visit__c)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Exception record creation by Customer</fullName>
        <actions>
            <name>Send_Email_to_PAS_Manager_Customer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_PAS_Manager_Email_Portal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send an email to PAS Manager whenever a record with exception is created</description>
        <formula>AND(ISPICKVAL(Exception_Status__c, &apos;Open&apos;), RecordType.DeveloperName = &apos;Exception&apos;,  ISBLANK(Visit__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populating Owner of Exception</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Query__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Exception</value>
        </criteriaItems>
        <description>Use to populate the ower of exception of the perticular project Technical head.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
