/*
	This example apex class is responsible for responding to the channel_rename event
*/
public class EventDispatcherEventExample extends Slack.EventDispatcher {
    public override Slack.ActionHandler invoke(Slack.EventParameters parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {
        Slack.EventParameters parameters;
        Slack.RequestContext context;

        public Handler(Slack.EventParameters parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public void run() {
            // Name must match the DeveloperName of your SlackApp.
            Slack.App app = Slack.App.ApexSlackApp.get();
            Slack.BotClient botClient = app.getBotClientForTeam(this.context.getTeamId());
            Slack.Event event = this.parameters.getEvent();
            String channelId = '';
            String channelName = '';
            String text = getBaseText(event);

            if (event instanceof Slack.GroupRenameEvent) {
                Slack.GroupRenameEvent groupRenameEvent = (Slack.GroupRenameEvent) event;
                channelId = groupRenameEvent.getChannel().getId();
                channelName = groupRenameEvent.getChannel().getName();
                text += channelName;
            } else if (event instanceof Slack.ChannelRenameEvent) {
                // Group rename will only work if the app is added as an integration to the private channel.
                Slack.ChannelRenameEvent channelRenameEvent = (Slack.ChannelRenameEvent) event;
                channelId = channelRenameEvent.getChannel().getId();
                channelName = channelRenameEvent.getChannel().getName();
                text += channelName;
            } else if (event instanceof Slack.ReactionAddedEvent) {
                Slack.ReactionAddedEvent reactionAddedEvent = (Slack.ReactionAddedEvent) event;
                channelId = reactionAddedEvent.getItem().getChannel();
                text += reactionAddedEvent.getReaction();
            } else if (event instanceof Slack.ReactionRemovedEvent) {
                Slack.ReactionRemovedEvent reactionRemovedEvent = (Slack.ReactionRemovedEvent) event;
                channelId = reactionRemovedEvent.getItem().getChannel();
                text += reactionRemovedEvent.getReaction();
            }

            Slack.ChatPostMessageResponse response = botClient.chatPostMessage(
                Slack.ChatPostMessageRequest.builder().channel(channelId).text(text).build()
            );

            if (response.getError() != null) {
                System.debug(response.getResponseMetadata().getMessages());
            }
        }

        private String getBaseText(Slack.Event event) {
            if (event instanceof Slack.GroupRenameEvent || event instanceof Slack.ChannelRenameEvent) {
                return 'The channel was renamed to: ';
            } else if (event instanceof Slack.ReactionAddedEvent) {
                return 'Reaction added is: ';
            } else if (event instanceof Slack.ReactionRemovedEvent) {
                return 'Reaction removed is: ';
            } else {
                return '';
            }
        }
    }
}
