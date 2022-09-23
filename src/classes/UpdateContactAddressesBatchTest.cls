@IsTest
public class UpdateContactAddressesBatchTest {

    @IsTest
    private static void executeBatchWihoutParamTest() {

        Account testAccount = new Account(
                Name = 'Google',
                BillingCountry = 'USA'
        );
        insert testAccount;
        Contact testContact = new Contact(
                LastName = 'Green',
                AccountId = testAccount.Id
        );
        insert testContact;

        Test.startTest();
        Id batchId = Database.executeBatch(new UpdateContactAddressesBatch());
        Test.stopTest();

        // then
        // TODO Assert
    }
}