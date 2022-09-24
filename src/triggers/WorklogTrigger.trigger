trigger WorklogTrigger on Worklog__c (before insert, after insert, before update, after delete, after undelete) {

    WorklogTriggerHandler worklogTrigger = new WorklogTriggerHandler();
    worklogTrigger.run();
}