@IsTest
public class WorklogTriggerHandlerTest {
    
    @TestSetup
    public static void setupTestData() {
        Employee__c testEmployee = new Employee__c(
        	Name = 'Anatoly'
        );
        insert testEmployee;
        Project__c testProject = new Project__c(
                Name = 'test'
        );
        insert testProject;
    }
	
    @IsTest
    public static void specifyDefaultValuesTest() {
        // given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];
        
        // when
        Worklog__c testWorklog = new Worklog__c(
        	Employee__c = testEmployee.Id,
            Description__c = 'Research documentation'
        );
        insert testWorklog;
        
        // then
        testWorklog = [SELECT Id, Date__c FROM Worklog__c WHERE Id =:testWorklog.Id];
        System.assert(testWorklog.Date__c != null);
    }
    
     @IsTest
    public static void validateWorklogTest() {
        // given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];
        
        Worklog__c testWorklog = new Worklog__c(
        	Employee__c = testEmployee.Id,
            Description__c = ''
        );

        // when & then
        try {
        	insert testWorklog;
            System.assert(false, 'Exception was expected');
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(Label.Description_should_not_be_blank));
        }
        
        // when & then
        try {
            testWorklog.Description__c = 'Documentation';
        	insert testWorklog;
        } catch(Exception ex) {
            System.assert(false, 'Exception was not expected. Course is Draft.');
        }
        
        // when & then
        try {
            testWorklog.Description__c = null;
        	update testWorklog;
            System.assert(false, 'Exception was expected');
        } catch(Exception ex) {
            System.assert(ex.getMessage().contains(Label.Description_should_not_be_blank));
        }
    }

    @IsTest
    public static void setBillableHoursTest() {
        //given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];

        //when
        Worklog__c testWorklog = new Worklog__c(
                Employee__c = testEmployee.Id, Actual_hours__c = 11, Description__c = 'test'
        );
        insert testWorklog;
        //then
        Worklog__c testWorklogThen = [SELECT Id, Actual_hours__c, Billable_hours__c
                    FROM Worklog__c
                    WHERE Id =:testWorklog.Id
                    LIMIT 1];
        System.assertEquals(testWorklogThen.Actual_hours__c, testWorklogThen.Billable_hours__c);
        System.assertNotEquals(null, testWorklogThen.Billable_hours__c);
    }

    @IsTest
    public static void validateBillableHoursToDateTest() {
        //given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];
        Worklog__c testWorklog = new Worklog__c(
                Employee__c = testEmployee.Id, Billable_hours__c = 11,
                Date__c = System.today() - 5, Description__c = 'test'
        );
        insert testWorklog;
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='john2222222123123123@acme.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='john2222222123123123@acme.com');
        insert u;


        //when & then
        List<Worklog__c> testWorkLogWhen = [SELECT Id, Billable_hours__c, Date__c
                    FROM Worklog__c
                    WHERE Id =: testWorklog.Id];

        System.runAs(u) {
            for (Worklog__c worklog_i : testWorkLogWhen){
                worklog_i.Billable_hours__c = 42;
            }
            try {
                update testWorkLogWhen;
            } catch (Exception e) {
                System.assert(true, 'exception');
                System.assert(e.getMessage().contains(Label.Prevent_billable_hours_change_on_Worklog_from_the_past));
            }
        }
        Worklog__c testWorklogThen = [SELECT Id, Billable_hours__c, Date__c
                    FROM Worklog__c
                    WHERE Id =:testWorklog.Id
                    LIMIT 1];
        System.debug(testWorklog.Billable_hours__c);
        System.assertNotEquals(42, testWorklogThen.Billable_hours__c);
        System.assertEquals(11, testWorklogThen.Billable_hours__c);
    }

    @IsTest
    public static void validateBillableHoursToDateAsSysAdminTest() {
        //given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];
        Worklog__c testWorklog = new Worklog__c(
                Employee__c = testEmployee.Id, Billable_hours__c = 11,
                Date__c = System.today() - 5, Description__c = 'test'
        );
        insert testWorklog;
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='john22222221231231223@acme.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='john22222221231231223@acme.com');
        insert u;


        //when & then
        List<Worklog__c> testWorkLogWhen = [SELECT Id, Billable_hours__c, Date__c
        FROM Worklog__c
        WHERE Id =: testWorklog.Id];

        System.runAs(u) {
            for (Worklog__c worklog_i : testWorkLogWhen){
                worklog_i.Billable_hours__c = 42;
            }
            update testWorkLogWhen;

        }
        Worklog__c testWorklogThen = [SELECT Id, Billable_hours__c, Date__c
        FROM Worklog__c
        WHERE Id =:testWorklog.Id
        LIMIT 1];
        System.assertNotEquals(11, testWorklogThen.Billable_hours__c);
        System.assertEquals(42, testWorklogThen.Billable_hours__c);

    }

    @IsTest
    public static void rollUpTotalHoursToProjectInsertTest() {

        //given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];
        Project__c testProject = [SELECT Id FROM Project__c LIMIT 1];
        List<Worklog__c> testWorklogs = new List<Worklog__c>();

        //when
        testWorklogs.add(new Worklog__c(Employee__c = testEmployee.Id, Billable_hours__c = 11, Actual_hours__c = 24,
                Description__c = 'test', Project__c = testProject.Id));
        testWorklogs.add(new Worklog__c(Employee__c = testEmployee.Id, Billable_hours__c = 12, Actual_hours__c = 26,
                Description__c = 'test', Project__c = testProject.Id));

        insert testWorklogs;
        //then

        Project__c testProjectThen = [
                SELECT Id, Total_Actual_Hours__c, Total_Billable_Hours__c
                FROM Project__c
        ];
        System.assertEquals(23, testProjectThen.Total_Billable_Hours__c);
        System.assertEquals(50, testProjectThen.Total_Actual_Hours__c);
    }

    @IsTest
    public static void rollUpTotalHoursToProjectDeleteTest() {

        //given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];
        Project__c testProject = [SELECT Id FROM Project__c LIMIT 1];
        List<Worklog__c> testWorklogs = new List<Worklog__c>();

        //when
        testWorklogs.add(new Worklog__c(Employee__c = testEmployee.Id, Billable_hours__c = 11, Actual_hours__c = 24,
                Description__c = 'test', Project__c = testProject.Id));
        testWorklogs.add(new Worklog__c(Employee__c = testEmployee.Id, Billable_hours__c = 12, Actual_hours__c = 26,
                Description__c = 'test', Project__c = testProject.Id));

        insert testWorklogs;

        delete [
                SELECT Id
                FROM Worklog__c
                WHERE Actual_hours__c = 24
                LIMIT 1
                ];
        //then

        Project__c testProjectThen = [
                SELECT Id, Total_Actual_Hours__c, Total_Billable_Hours__c
                FROM Project__c
        ];
        System.assertEquals(12, testProjectThen.Total_Billable_Hours__c);
        System.assertEquals(26, testProjectThen.Total_Actual_Hours__c);
    }

    @IsTest
    public static void rollUpTotalHoursToProjectUnDeleteTest() {

        //given
        Employee__c testEmployee = [SELECT Id FROM Employee__c LIMIT 1];
        Project__c testProject = [SELECT Id FROM Project__c LIMIT 1];
        List<Worklog__c> testWorklogs = new List<Worklog__c>();

        //when
        testWorklogs.add(new Worklog__c(Employee__c = testEmployee.Id, Billable_hours__c = 11, Actual_hours__c = 24,
                Description__c = 'test', Project__c = testProject.Id));
        testWorklogs.add(new Worklog__c(Employee__c = testEmployee.Id, Billable_hours__c = 12, Actual_hours__c = 26,
                Description__c = 'test', Project__c = testProject.Id));

        insert testWorklogs;

        delete [
                SELECT Id
                FROM Worklog__c
                WHERE Actual_hours__c = 24
                LIMIT 1
                ];

        Project__c testProjectThenAfterDelete = [
                SELECT Id, Total_Actual_Hours__c, Total_Billable_Hours__c
                FROM Project__c
        ];
        System.assertEquals(12, testProjectThenAfterDelete.Total_Billable_Hours__c);
        System.assertEquals(26, testProjectThenAfterDelete.Total_Actual_Hours__c);

        //then

        undelete [
                SELECT Id
                FROM Worklog__c
                WHERE IsDeleted =: true ALL ROWS
                ];

        Project__c testProjectThen = [
                SELECT Id, Total_Actual_Hours__c, Total_Billable_Hours__c
                FROM Project__c
        ];
        System.assertEquals(23, testProjectThen.Total_Billable_Hours__c);
        System.assertEquals(50, testProjectThen.Total_Actual_Hours__c);
    }
}
