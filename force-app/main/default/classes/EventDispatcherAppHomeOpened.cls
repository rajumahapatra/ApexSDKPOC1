/*
    This example apex class is responsible for responding to the App Home "opened" event.
*/
public class EventDispatcherAppHomeOpened extends Slack.EventDispatcher {
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
            Slack.BotClient botClient = app.getBotClientForTeam(context.getTeamId());
            Slack.AppHomeOpenedEvent appHomeOpened = (Slack.AppHomeOpenedEvent) parameters.getEvent();
            String userId = appHomeOpened.getUser();

            Slack.ViewReference viewReference = Slack.View.app_home.get();
            viewReference.setParameter('headerText', 'Welcome to the Apex Slack App Example.');
            viewReference.setParameter('bodyText', 'To see how this custom home view was created, see the EventDispatcherAppHomeOpened apex class.');
            Slack.HomeView homeView = new Slack.HomeView.builder().viewReference(viewReference).build();

            Slack.ViewsPublishRequest req = new Slack.ViewsPublishRequest.builder().userId(userId).view(homeView).build();

            Slack.ViewsPublishResponse response = botClient.viewsPublish(req);
            if (response.getError() != null) {
                System.debug(response.getResponseMetadata().getMessages());
            }
        }
    }
}
