public with sharing class CommandDispatcherSearchContact extends Slack.SlashCommandDispatcher{
    public override Slack.ActionHandler invoke(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
        // The slack action handler should immediately be returned.
        return Slack.ActionHandler.modal(new Handler(parameters, context), 'Create Record');
    }

    public class Handler implements Slack.ModalHandler {
        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;

        public Handler(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            // Returns the modal view for the 'search_contact' view definition.
            Slack.ViewReference viewReference = Slack.View.search_contact.get();
            Slack.ModalView modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
            return modalView;
        }
    }
}
