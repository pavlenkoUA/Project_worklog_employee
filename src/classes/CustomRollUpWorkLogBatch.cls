
public with sharing class CustomRollUpWorkLogBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Total_Billable_Hours__c, Total_Actual_Hours__c, ' +
                '(SELECT Id, Billable_hours__c, Actual_hours__c FROM Worklogs__r) FROM Project__c');
    }

    public void execute(Database.BatchableContext bc, List<Project__c> scope) {

        List<AggregateResult> aggResList = [
                SELECT Project__c, sum(Billable_hours__c), sum(Actual_hours__c)
                FROM Worklog__c
                WHERE Project__c <> NULL
                GROUP BY Project__c
        ];

        for (AggregateResult ar_i : aggResList) {
            for (Project__c project_i : scope) {
                if ((ar_i.get('Project__c') == project_i.Id) && (project_i.Total_Billable_Hours__c <>
                        Integer.valueOf(ar_i.get('expr0'))) && project_i.Total_Actual_Hours__c <>
                        Integer.valueOf(ar_i.get('expr1'))) {
                    project_i.Total_Billable_Hours__c = Integer.valueOf(ar_i.get('expr0'));
                    project_i.Total_Actual_Hours__c = Integer.valueOf(ar_i.get('expr1'));
                }
            }
        }
        update scope;
}
    public void finish(Database.BatchableContext bc) {
    }
}