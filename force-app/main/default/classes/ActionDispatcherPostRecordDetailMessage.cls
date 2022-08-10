/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "onsubmit" event defined in the 'view_opportuniy', 'view_account',
    and 'view_contact' view.
*/
public class ActionDispatcherPostRecordDetailMessage extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public void run() {
            Slack.App app = Slack.App.ApexSlackApp.get();
            Slack.UserClient userClient = app.getUserClientForTeam(this.context.getTeamId(), this.context.getUserId());

            String recordId = (String) this.parameters.get('recordId');
            String objectApiName = (String) this.parameters.get('objectApiName');

            Slack.ViewReference viewReference = Slack.View.record_detail_message.get();
            viewReference.setParameter('headerText', objectApiName + ' Record Details');
            viewReference.setParameter('recordId', recordId);
            viewReference.setParameter('objectApiName', objectApiName);

            Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
                .channel((String) this.parameters.get('channelId'))
                //TODO should text be required if you are setting a view reference?
                .text('Details for record id' + recordId)
                .viewReference(viewReference)
                .build();

            Slack.ChatPostMessageResponse response = userClient.ChatPostMessage(req);
            if (response.getError() != null) {
                System.debug(response.getResponseMetadata().getMessages());
            }
        }
    }
}
