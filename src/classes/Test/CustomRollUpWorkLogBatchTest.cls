
@IsTest
private class CustomRollUpWorkLogBatchTest {

    @TestSetup
    static void setup() {

        Employee__c testEmployee = new Employee__c(
        Name = 'Anatoly'
        );
        insert testEmployee;
        Project__c testProject = new Project__c(
                Name = 'test'
        );
        insert testProject;


        List<Project__c> projects = new List<Project__c>();

        for(Integer i=0;i<2;i++){
            projects.add(new Project__c(Name='test' + i));
        }
        insert projects;
        Project__c project = [SELECT Id
                              FROM Project__c
                                LIMIT 1];

        List<Worklog__c> worklogs = new List<Worklog__c>();

        for(Integer i=0;i<5;i++) {
            worklogs.add(new Worklog__c(Description__c = 'test', Employee__c = testEmployee.Id, Project__c = project.Id,
                    Actual_hours__c = 10, Billable_hours__c = 5));
        }
        insert worklogs;

        Project__c proj = new Project__c(Name = 'TestProj', Total_Billable_Hours__c = 100, Total_Actual_Hours__c = 250);
        insert proj;



    }

    @IsTest
    static void testOneProjectPositive() {
        Test.startTest();

        CustomRollUpWorkLogBatch batch = new CustomRollUpWorkLogBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        Project__c res = [SELECT Id, Total_Billable_Hours__c, Total_Actual_Hours__c
                            FROM Project__c
                            WHERE Name <> 'TestProj' AND Total_Actual_Hours__c > 0 AND Total_Billable_Hours__c > 0];
        Project__c res2 = [SELECT Id, Total_Billable_Hours__c, Total_Actual_Hours__c
                            FROM Project__c
                            WHERE Name = 'TestProj'];

        System.assertEquals(1, [SELECT count() FROM Project__c WHERE Total_Actual_Hours__c > 0 AND
                                Total_Billable_Hours__c > 0 AND Name <> 'TestProj']);
        System.assertEquals(50, res.Total_Actual_Hours__c);
        System.assertEquals(25, res.Total_Billable_Hours__c);
        System.assertEquals(100, res2.Total_Billable_Hours__c);
        System.assertEquals(250, res2.Total_Actual_Hours__c);
    }
}