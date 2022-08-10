/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "submit" event on view_opportunity_by_account view.

    This command will open a modal to view record details for Accounts, Contacts, or Opportunities
    based on the formData parameters passed in the context.
 */

public class ActionDispatcherViewSelectedRecord extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.modal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            String objectApiName = (String) this.parameters.get('objectApiName');
            Map<String, Object> formData = this.context.getFormData();

            String recordId = (String) formData.get('select_opportunity');
            if (recordId == null) {
                return MessageModal.getMessageModalView('Error Occurred', new List<String> {'Missing record id.'});
            }
            return viewRecord(objectApiName, recordId);
        }

        private Slack.ModalView viewRecord(String objectApiName, String recordId) {
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
                    return MessageModal.getMessageModalView(
                        'Invalid Object',
                        new List<String> {'The objectApiName was not a valid option. The view record command supports Account, Contact, or Opportunity'}
                    );
                }
            }
            viewReference.setParameter('recordId', recordId);
            viewReference.setParameter('channelId', context.getchannelId());
            Slack.ModalView modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
            return modalView;
        }
    }
}
