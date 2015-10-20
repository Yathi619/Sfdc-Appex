<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_for_technical_head_when_project_is_selected_by_customer</fullName>
        <description>Email alert for technical head when project is selected by customer</description>
        <protected>false</protected>
        <recipients>
            <field>Technical_Head_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RBI_EmailTemplates/Alert_to_Technical_Head_When_Project_is_selected_is_by_customer</template>
    </alerts>
    <fieldUpdates>
        <fullName>Technical_Head_Field_update_in_CusPrj</fullName>
        <field>Technical_Head_Email__c</field>
        <formula>Project_Id__r.Technical_Head__r.Email</formula>
        <name>Technical Head Field update in CusPrj</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Selection of project by the customer</fullName>
        <actions>
            <name>Email_alert_for_technical_head_when_project_is_selected_by_customer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Technical_Head_Field_update_in_CusPrj</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Projects__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow updates a field and sends a email alert to the technical head when a customer selects the project</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
