public with sharing class WorklogTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert() {
        WorklogTriggerService.validateWorklog((List<Worklog__c>)Trigger.new, null);
        WorklogTriggerService.specifyDefaultValues((List<Worklog__c>)Trigger.new);
        WorklogTriggerService.setBillableHours((List<Worklog__c>)Trigger.new);
    }
    
    public override void beforeUpdate() {
        WorklogTriggerService.validateWorklog((List<Worklog__c>)Trigger.new, (Map<Id, Worklog__c>)Trigger.oldMap);
        WorklogTriggerService.validateBillableHoursToDate((List<Worklog__c>)Trigger.new);
    }

    public override void afterInsert() {
        WorklogTriggerService.rollUpTotalHoursToProject();
    }

    protected override void afterDelete(){
        //this.countNumberOfContacts(null, (Map<Id, Contact>)Trigger.oldMap);
        //this.countNumberOfContacts2(null, (Map<Id, Contact>)Trigger.oldMap);
    }

    protected override void afterUndelete(){
        //this.countNumberOfContacts((List<Contact>)Trigger.new, null);
        //this.countNumberOfContacts2((List<Contact>)Trigger.new, null);
    }
	



}