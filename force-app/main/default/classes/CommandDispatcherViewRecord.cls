/*
    This example apex class extends Slack.SlashCommandDispatcher and is responsible for
    responding to the Slack slash command registered with the Slack application.

    This command will open a modal to view record details for Accounts, Contacts, and Opportunities

    sample command:
    /apex-view-record Contact 003xx000004WhrYAAS
    /apex-view-record Account 00Bxx0000029bnsEAA
    /apex-view-record Opportunity 006xx000001a3f5AAA

    If you run the command in a slack channel, you will see the option to post a message with record details there.
*/
public class CommandDispatcherViewRecord extends Slack.SlashCommandDispatcher {
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
            String errMessage = 'The view record command requires 2 arguments: objectApiName and recordId.';
            if (commandSegments.size() < 2) {
                return MessageModal.getMessageModalView('Invalid Parameters', new List<String>{ errMessage });
            }

            String objectApiName = commandSegments[0];
            String recordId = commandSegments[1];

            return viewRecord(objectApiName, recordId);
        }

        private Slack.ModalView viewRecord(String objectApiName, String recordId) {
            String errMessage = 'The objectApiName was not a valid option. The view record command supports Account, Contact, or Opportunity.';
            Slack.ViewReference viewReference;
            switch on objectApiName {
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
            }
            viewReference.setParameter('recordId', recordId);
            viewReference.setParameter('channelId', this.context.getchannelId());
            Slack.ModalView modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
            System.debug('modalView: ' + modalView);
            return modalView;
        }
    }
}
