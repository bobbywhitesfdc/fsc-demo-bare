@IsTest()
public class EmailSendTest {
    private static testMethod void testLimitNone() {
        Test.startTest();
        final integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.AssertEquals(0,emailInvocations,'Email Invocations count expected zero');
    }
    private static testMethod void testLimitSendToEmailAddress() {
        final Messaging.SingleEmailMessage mail = compose();
        
        mail.setToAddresses(new String[] {'bobby.white@boltsolutions.net'});

        Test.startTest();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
        final integer emailInvocations = Limits.getEmailInvocations();
        
        Test.stopTest();
        System.AssertEquals(1,emailInvocations,'Email Invocations count expected one');
    }
    
    private static testMethod void testLimitSendToInternalUser() {
        final Messaging.SingleEmailMessage mail = compose();
        
        // Email my UserObject
        mail.setSaveAsActivity(false); // Required when sending to internal users
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTreatTargetObjectAsRecipient(true);

        Test.startTest();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
        final integer emailInvocations = Limits.getEmailInvocations();
        
        Test.stopTest();
        System.AssertEquals(0,emailInvocations,'Email Invocations count expected zero');
    }

    
    private static Messaging.SingleEmailMessage compose() {
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Test Email Limits');
        final string msgBody = 'Test email limits body';
        mail.setHtmlBody('<html><body>'+msgBody+'</body></html>');
        mail.setPlainTextBody(msgBody);
        return mail;
    }

}