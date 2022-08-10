public class CommandDispatcherSearchAccount extends Slack.SlashCommandDispatcher {
    public override Slack.ActionHandler invoke(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.modal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Slack.SlashCommandParameters parameters;
        Slack.RequestContext context;

        public Handler(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            String commandText = this.parameters.getText();
            String[] commandSegments = commandText.split(' ');
            String errMessage = 'The view record command requires 1 argument: accountName.';
            if (commandSegments.size() != 1) {
                return MessageModal.getMessageModalView('Invalid Parameters', new List<String>{ errMessage });
            }

            String accountName = commandSegments[0];
            // String recordId = commandSegments[1];

            return viewRecord(accountName);
        }

        private Slack.ModalView viewRecord(String accountName) {
            String errMessage = 'The accountName was not a valid option. The view record command supports Account, Contact, or Opportunity.';
            Slack.ViewReference viewReference;
            /* switch on accountName {
                when 'Account' {
                    viewReference = Slack.View.view_account.get();
                }
                when 'Contact' {
                    viewReference = Slack.View.view_contact.get();
                }
                when 'Opportunity' {
                    viewReference = Slack.View.view_opportunity.get();
                }
                when else {
                    return MessageModal.getMessageModalView('Invalid Object', new List<String>{ errMessage });
                }
            } */
            if(String.isNotBlank(accountName)) {
                viewReference = Slack.View.search_account.get();
            }
            viewReference.setParameter('accountName', accountName);
            // viewReference.setParameter('channelId', this.context.getchannelId());
            Slack.ModalView modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
            System.debug('modalView: ' + modalView);
            return modalView;
        }
    }
}