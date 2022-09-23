@IsTest
public class EmailUtilsTest {

    @IsTest
    private static void sendEmailTest() {
        // given
        Contact testContact = new Contact(
                LastName = 'Green'
        );
        insert testContact;
        testContact = [SELECT Id FROM Contact WHERE Id = :testContact.Id];

        Test.startTest();
        // async
        Test.stopTest();

        // then

    }
}