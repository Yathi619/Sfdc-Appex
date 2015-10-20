<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_is_sent_to_newly_assigned_surveyor_of_the_project</fullName>
        <description>Email alert is sent to newly assigned surveyor of the project</description>
        <protected>false</protected>
        <recipients>
            <field>Surveyor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Surveyor_Change_Template</template>
    </alerts>
    <alerts>
        <fullName>New_Project_created</fullName>
        <description>New Project created</description>
        <protected>false</protected>
        <recipients>
            <field>Technical_Head__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/New_Project_Creation</template>
    </alerts>
    <alerts>
        <fullName>PAS_Manager_Email_Alert_when_the_PAS_Manager_is_changed</fullName>
        <description>PAS Manager Email Alert when the PAS Manager is changed</description>
        <protected>false</protected>
        <recipients>
            <field>PAS_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/PAS_Manager_change_Template</template>
    </alerts>
    <alerts>
        <fullName>Technical_Head_change_in_the_Project</fullName>
        <description>Technical Head change in the Project</description>
        <protected>false</protected>
        <recipients>
            <field>Technical_Head_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Technical_Head_Change_template</template>
    </alerts>
    <fieldUpdates>
        <fullName>PAS_Manager_Field_Update</fullName>
        <field>PAS_Manager_Email__c</field>
        <formula>Team_Leader__r.Email</formula>
        <name>PAS Manager Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Surveyor_Change_Field_Update</fullName>
        <description>Surveyor Email field is updated whenever there is a change in the Surveyor</description>
        <field>Surveyor_Email__c</field>
        <formula>Surveyor__r.Email</formula>
        <name>Surveyor Change Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Head_Field_update</fullName>
        <field>Technical_Head_Email__c</field>
        <formula>Technical_Head__r.Email</formula>
        <name>Technical Head Field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>New Projects Created by Customers</fullName>
        <actions>
            <name>New_Project_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.To_Be_Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PAS Manager change</fullName>
        <actions>
            <name>PAS_Manager_Email_Alert_when_the_PAS_Manager_is_changed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>PAS_Manager_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow sends email alert to the newly allocated PAS Manager for a Project</description>
        <formula>ISCHANGED(Team_Leader__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Surveyor Change</fullName>
        <actions>
            <name>Email_alert_is_sent_to_newly_assigned_surveyor_of_the_project</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Surveyor_Change_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Surveyor__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Technical Head Change</fullName>
        <actions>
            <name>Technical_Head_change_in_the_Project</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Technical_Head_Field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This is used to send email to new technical head who is allocated to particular project</description>
        <formula>ISCHANGED(Technical_Head__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
