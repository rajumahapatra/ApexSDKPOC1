/*
    This example test suite is responsible for testing the CommandDispatcherViewOppByAccount.
*/
@isTest
public class TestCommandDispatcherViewOppByAccount {
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

    // This test creates an account and an opportunity and runs the '/apex-find-opp-by-account-id'
    // command with the newly created account id. It asserts that the drop down in the view is properly
    // populated and submits the modal to view the selected opportunity.
    @isTest
    static void testViewOppByAccount() {
        // create new account and opportunity records
        Test.startTest();
        Account account = new Account(Name = 'Joe Co');
        insert account;
        Opportunity opportunity = new Opportunity(
            Name = 'Acme Co.',
            Amount = 50000.00,
            StageName = 'Qualification',
            CloseDate = Date.today() + 30,
            AccountId = account.Id
        );
        insert opportunity;
        Test.stopTest();

        // execute the 'apex-create-record' command and assert modal
        userSession.executeSlashCommand('/apex-find-opp-by-account-id', account.Id, slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Select an Opportunity', modal.getTitle());

        // assert and select the option in the first drop down
        Slack.TestHarness.Input input = (Slack.TestHarness.Input) modal.getComponentByName('all_opportunities', Slack.TestHarness.Input.class);
        Slack.TestHarness.SelectInput selectInput = (Slack.TestHarness.SelectInput) input.getComponent(Slack.TestHarness.SelectInput.class);
        List<Slack.TestHarness.Option> options = selectInput.getOptions();
        System.assertEquals(1, options.size());
        Slack.TestHarness.Option option = options.get(0);
        System.assertEquals(opportunity.Id, option.getIdentifier());
        System.assertEquals('Acme Co.', option.getLabel());
        selectInput.setValue(option.getIdentifier());

        // TODO: submit modal and assert resulting modal view contents
    }

    // This test creates an account and runs the '/apex-find-opp-by-account-id'command with the newly created
    // account id. It asserts that the drop down in the view does not contain an opportunity record.
    @isTest
    static void testViewOppByAccountNoOpportunity() {
        // create new account record
        Test.startTest();
        Account account = new Account(Name = 'Joe Co');
        insert account;
        Test.stopTest();

        // execute the 'apex-create-record' command and assert modal
        userSession.executeSlashCommand('/apex-find-opp-by-account-id', account.Id, slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Select an Opportunity', modal.getTitle());

        // assert and select the option in the first drop down
        Slack.TestHarness.Input input = (Slack.TestHarness.Input) modal.getComponentByName('all_opportunities', Slack.TestHarness.Input.class);
        Slack.TestHarness.SelectInput selectInput = (Slack.TestHarness.SelectInput) input.getComponent(Slack.TestHarness.SelectInput.class);
        List<Slack.TestHarness.Option> options = selectInput.getOptions();
        System.assertEquals(1, options.size());
        Slack.TestHarness.Option option = options.get(0);
        System.assertEquals('Account has no Opportunity', option.getIdentifier());
        System.assertEquals('Account has no Opportunity', option.getLabel());
    }

    // This test runs the '/apex-find-opp-by-account-id' command with an invalid id parameter.
    @isTest
    static void testInvalidId() {
        userSession.executeSlashCommand('/apex-find-opp-by-account-id', 'INVALID', slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Error Occurred', modal.getTitle());
        Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(0, Slack.TestHarness.Section.class);
        System.assertEquals('There was a problem loading the account. AccountId is missing or is invalid.', section.getText());
    }

    // This test runs the '/apex-find-opp-by-account-id' command with no id parameter.
    @isTest
    static void testNoId() {
        userSession.executeSlashCommand('/apex-find-opp-by-account-id', slackApp);
        Slack.TestHarness.Modal modal = userSession.getTopModal();
        System.assertEquals('Error Occurred', modal.getTitle());
        Slack.TestHarness.Section section = (Slack.TestHarness.Section) modal.getComponent(0, Slack.TestHarness.Section.class);
        System.assertEquals('There was a problem loading the account. AccountId is missing or is invalid.', section.getText());
    }
}
