/*
    This example test suite is responsible for testing the CommandDispatcherViewRecord.
*/
@isTest
public class TestCommandDispatcherViewRecord {
    private static Slack.App slackApp;
    private static Slack.TestHarness testHarness;
    private static Slack.TestHarness.State slackState;
    private static Slack.TestHarness.UserSession userSession;

    static {
        // setup test harness and user session
        slackApp = Slack.App.ApexSlackApp.get();
        testHarness = new Slack.TestHarness();
        slackState = testHarness.getNewSlackState();
        userSession = slackState.createUserSession();
    }

    // this test creates an account and views it in a modal
    @isTest
    static void testViewAccount() {
        // create new account record
        Test.startTest();
        Account account = new Account(Name = 'Bob');
        insert account;
        Test.stopTest();

        // execute the 'apex-view-record' command and assert modal
        userSession.executeSlashCommand('/apex-view-record', 'Account ' + account.Id, slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('View Account', modal.getTitle());
        Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(1, Slack.TestHarness.Section.class);
        System.assertEquals('Bob', section.getText());

        modal.submit();

        // assert message contents with fields: name and id
        List<Slack.TestHarness.Message> messages = userSession.getMessages();
        System.assertEquals(1, messages.size());
        Slack.TestHarness.Message message = messages.get(0);
        System.assertEquals(4, message.getComponentCount());
        Slack.TestHarness.Header header = (Slack.TestHarness.Header) message.getComponent(0, Slack.TestHarness.Header.class);
        System.assertEquals('Account Record Details', header.getText());
        section = (Slack.TestHarness.Section) message.getComponent(2, Slack.TestHarness.Section.class);
        System.assertEquals('*Name:* Bob', section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(3, Slack.TestHarness.Section.class);
        System.assertEquals('*Id:* ' + account.Id, section.getText());
    }

    // this test creates a contact and views it in a modal
    @isTest
    static void testViewContact() {
        // create new account and contact records
        Test.startTest();
        Account account = new Account(Name = 'Joe Co');
        insert account;
        Contact contact = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            Phone = '777-777-7777',
            Email = 'joesmith@example.com',
            AccountId = account.Id
        );
        insert contact;
        Test.stopTest();

        // execute the 'apex-view-record' command and assert modal
        userSession.executeSlashCommand('/apex-view-record', 'Contact ' + contact.Id, slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('View Contact', modal.getTitle());
        Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(1, Slack.TestHarness.Section.class);
        System.assertEquals('Joe Smith', section.getText());

        modal.submit();

        // assert message contents with fields: name, id, phone, and email
        List<Slack.TestHarness.Message> messages = userSession.getMessages();
        System.assertEquals(1, messages.size());
        Slack.TestHarness.Message message = messages.get(0);
        System.assertEquals(7, message.getComponentCount());
        Slack.TestHarness.Header header = (Slack.TestHarness.Header) message.getComponent(0, Slack.TestHarness.Header.class);
        System.assertEquals('Contact Record Details', header.getText());
        section = (Slack.TestHarness.Section) message.getComponent(2, Slack.TestHarness.Section.class);
        System.assertEquals('*Name:* Joe Smith', section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(3, Slack.TestHarness.Section.class);
        System.assertEquals('*Id:* ' + contact.Id, section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(4, Slack.TestHarness.Section.class);
        System.assertEquals('*Phone:* 777-777-7777', section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(5, Slack.TestHarness.Section.class);
        System.assertEquals('*Email:* joesmith@example.com', section.getText());
    }

    // this test creates an opportunity and views it in a modal
    @isTest
    static void testViewOpportunity() {
        // create new opportunity record
        Test.startTest();
        Opportunity opportunity = new Opportunity(
            Name = 'Acme Co.',
            Amount = 50000.00,
            StageName = 'Qualification',
            CloseDate = Date.valueOf('2222-12-31')
        );
        insert opportunity;
        Test.stopTest();

        // execute the 'apex-view-record' command and assert modal
        userSession.executeSlashCommand('/apex-view-record', 'Opportunity ' + opportunity.Id, slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('View Opportunity', modal.getTitle());
        Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(1, Slack.TestHarness.Section.class);
        System.assertEquals('Acme Co.', section.getText());

        modal.submit();

        // assert message contents with fields: name, id, amount, stage name, qualification, and close date
        List<Slack.TestHarness.Message> messages = userSession.getMessages();
        System.assertEquals(1, messages.size());
        Slack.TestHarness.Message message = messages.get(0);
        System.assertEquals(7, message.getComponentCount());
        Slack.TestHarness.Header header = (Slack.TestHarness.Header) message.getComponent(0, Slack.TestHarness.Header.class);
        System.assertEquals('Opportunity Record Details', header.getText());
        section = (Slack.TestHarness.Section) message.getComponent(2, Slack.TestHarness.Section.class);
        System.assertEquals('*Name:* Acme Co.', section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(3, Slack.TestHarness.Section.class);
        System.assertEquals('*Id:* ' + opportunity.Id, section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(4, Slack.TestHarness.Section.class);
        System.assertEquals('*Amount:* 50000.00', section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(5, Slack.TestHarness.Section.class);
        System.assertEquals('*StageName:* Qualification', section.getText());
        section = (Slack.TestHarness.Section) message.getComponent(6, Slack.TestHarness.Section.class);
        System.assertEquals('*CloseDate:* Tue Dec 31 00:00:00 GMT 2222', section.getText());
    }

    // this test runs the view record command without any parameters
    @isTest
    static void testMissingParams() {
        // execute the 'apex-view-record' command without parameters
        userSession.executeSlashCommand('/apex-view-record', slackApp);

        // assert the message modal
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Invalid Parameters', modal.getTitle());
        Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(0, Slack.TestHarness.Section.class);
        System.assertEquals('The view record command requires 2 arguments: objectApiName and recordId.', section.getText());
    }

    // this test runs the view record command with invalid parameters
    @isTest
    static void testInvalidObject() {
        // execute the 'apex-view-record' command with an invalid object
        userSession.executeSlashCommand('/apex-view-record', 'Invalid_Object Invalid_Record_Id', slackApp);

        // assert the message modal
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Invalid Object', modal.getTitle());
        Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(0, Slack.TestHarness.Section.class);
        System.assertEquals(
            'The objectApiName was not a valid option. The view record command supports Account, Contact, and Opportunity.',
            section.getText()
        );
    }
}
