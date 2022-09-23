public with sharing class EmailUtils {

    @future
    public static void sendEmail(String emailAddress) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>{emailAddress});
        mail.setSubject('Test Email');
        mail.setPlainTextBody('Test Email Body');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}