@isTest
public class TestEventDispatcherEventExample {
    private static Slack.App slackApp;
    private static Slack.TestHarness testHarness;
    private static Slack.TestHarness.State slackState;
    private static Slack.TestHarness.Team team;
    private static Slack.TestHarness.UserSession userSession;
    private static Slack.TestHarness.User user;
    private static Slack.TestHarness.Channel publicChannel;
    private static Slack.TestHarness.Channel privateChannel;

    static {
        // test setup
        slackApp = Slack.App.ApexSlackApp.get();
        testHarness = new Slack.TestHarness();
        slackState = testHarness.getNewSlackState();
        team = slackState.createTeam('team');
        publicChannel = slackState.createPublicChannel(team, 'public-channel');
        privateChannel = slackState.createPrivateChannel(team, 'private-channel');
        user = slackState.createUser('testUser@test.com', 'test', team);
        userSession = slackState.createUserSession(user, publicChannel);
        privateChannel.addUser(user);
    }

    @isTest
    static void testChannelRenameEvent() {
        Slack.ChannelRenameEvent.Channel channel = new Slack.ChannelRenameEvent.Channel();
        Slack.ChannelRenameEvent event = new Slack.ChannelRenameEvent();
        String newName = 'my-public-channel';

        channel.setId(publicChannel.getId());
        channel.setName(newName);
        event.setChannel(channel);
        event.setEventTs(String.valueOf(System.now()));
        userSession.executeEvent(event, slackApp);

        assertRename(userSession, newName, publicChannel);
    }

    @isTest
    static void testGroupRenameEvent() {
        Slack.GroupRenameEvent.Channel channel = new Slack.GroupRenameEvent.Channel();
        Slack.GroupRenameEvent event = new Slack.GroupRenameEvent();
        String newName = 'my-private-channel';

        channel.setId(privateChannel.getId());
        channel.setName(newName);
        event.setChannel(channel);
        event.setEventTs(String.valueOf(System.now()));
        userSession.executeEvent(event, slackApp);

        assertRename(userSession, newName, privateChannel);
    }

    private static void assertRename(Slack.TestHarness.UserSession userSession, String newName, Slack.TestHarness.Channel channel) {
        userSession.openChannel(channel.getId());
        System.assertEquals(1, userSession.getMessageCount(), 'A message should have been posted due to the rename.');
        String channelRenameMessageText = userSession.getMessages().get(0).getText();
        System.assertEquals(
            channelRenameMessageText,
            'The channel was renamed to ' + newName,
            'Message text should indicate the channel was renamed'
        );
    }
}
