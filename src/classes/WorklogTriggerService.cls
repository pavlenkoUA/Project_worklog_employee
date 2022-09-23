public with sharing class WorklogTriggerService {

    public static void specifyDefaultValues(List<Worklog__c> newList) {
        for (Worklog__c worklog_i : newList) {
            if (worklog_i.Date__c == null) {
                worklog_i.Date__c = Date.today();
            }
        }
    }

    public static void validateWorklog(List<Worklog__c> newList, Map<Id, Worklog__c> oldMap) {
        for (Worklog__c worklog_i : newList) {
            if (String.isBlank(worklog_i.Description__c) &&
                    (Trigger.isInsert || Trigger.isUpdate && worklog_i.Description__c != oldMap.get(worklog_i.Id).Description__c)) {

                worklog_i.addError(Label.Description_should_not_be_blank);
            }
        }
    }

    public static void setBillableHours(List<Worklog__c> newList) {
        for (Worklog__c worklog_i :newList) {
            if (worklog_i.Billable_hours__c == null) {
                worklog_i.Billable_hours__c = worklog_i.Actual_hours__c;
            }
        }
    }

    public static void validateBillableHoursToDate(List<Worklog__c> newList) {
        for (Worklog__c worklog_i :newList) {
            if (worklog_i.Date__c != Date.today()) {
                worklog_i.addError(Label.Prevent_billable_hours_change_on_Worklog_from_the_past);
            }
        }
    }
//
    public static void rollUpTotalHoursToProject(List<Worklog__c> newList, Map<Id, Worklog__c> oldMap) {
        List<Project__c> projectsToUpdate = new List<Project__c>();
        Set<Id> projectIdSet = new Set<Id>();

        List<Project__c> worklogToProcessList = (!Trigger.isDelete)
                ? newList
                : oldMap.values();

        for (Worklog__c worklog_i : worklogToProcessList) {
            if ((Trigger.isInsert || Trigger.isDelete || Trigger.isUndelete) && worklog_i.Project__c != null) {
                projectIdSet.add(worklog_i.Project__c);
            }

            if (Trigger.isUpdate && worklog_i.Project__c != oldMap.get(worklog_i.Id).Project__c) {
                if (worklog_i.Project__c != null) {
                    projectIdSet.add(worklog_i.Project__c);
                }
                if (oldMap.get(worklog_i.Id).Project__c != null) {
                    projectIdSet.add(oldMap.get(worklog_i.Id).Project__c);
                }
            }
        }
        if (projectIdSet.isEmpty()) {
            return;
        }

        for (Project__c project_i : [
                SELECT Id, (SELECT Id FROM Worklogs__r)
                FROM Project__c
                WHERE Id IN :projectIdSet
        ]) {

        update projectsToUpdate;


    }
}