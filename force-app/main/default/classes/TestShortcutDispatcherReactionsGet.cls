/*
	This example test suite is responsible for testing the ShortcutDispatcherReactionsGet.
*/
@isTest
public class TestShortcutDispatcherReactionsGet {

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

    @isTest
    static void testReactions() {
        Slack.TestHarness.Message message = userSession.postMessage('Test Message!!');
        userSession.executeMessageShortcut('apex-reactions-get', message, slackApp);
        // TODO: update when the test harness supports reactions
    }
}