public with sharing class WorklogTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert() {
        WorklogTriggerService.validateWorklog((List<Worklog__c>)Trigger.new, null);
        WorklogTriggerService.specifyDefaultValues((List<Worklog__c>)Trigger.new);
        WorklogTriggerService.setBillableHours((List<Worklog__c>)Trigger.new);
    }
    
    public override void beforeUpdate() {
        WorklogTriggerService.validateWorklog((List<Worklog__c>)Trigger.new, (Map<Id, Worklog__c>)Trigger.oldMap);
        WorklogTriggerService.validateBillableHoursToDate((List<Worklog__c>)Trigger.new);
        WorklogTriggerService.rollUpTotalHoursToProject((List<Worklog__c>)Trigger.new, (Map<Id, Worklog__c>)Trigger.oldMap);
    }

    public override void afterInsert() {
        WorklogTriggerService.rollUpTotalHoursToProject((List<Worklog__c>)Trigger.new, (Map<Id, Worklog__c>)Trigger.oldMap);
    }

    protected override void afterDelete(){
        WorklogTriggerService.rollUpTotalHoursToProject((List<Worklog__c>)Trigger.new, (Map<Id, Worklog__c>)Trigger.oldMap);
    }

    protected override void afterUndelete(){
        WorklogTriggerService.rollUpTotalHoursToProject((List<Worklog__c>)Trigger.new, (Map<Id, Worklog__c>)Trigger.oldMap);
    }
}