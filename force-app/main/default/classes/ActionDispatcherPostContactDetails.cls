/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "onsubmit" event defined in the 'create_account', 'create_contact',
    and 'create_opportunty' views.
*/
public class ActionDispatcherPostContactDetails extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        // The slack action handler should immediately be returned.
        return Slack.ActionHandler.updateModal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            // Process the form data and return the modal view that corresponds to the requested object.
            Slack.ModalView modalView;
            try {
                modalView = submitContact();
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
            return modalView;
        }

        private Slack.ModalView submitContact() {
            try {
                /* Map<String, Object> formData = this.context.getFormData();
                if (!formData.isEmpty()) {
                    Contact contact = new Contact();
                    contact.AccountId = (formData.containsKey('account_lookup') ? (String) formData.get('account_lookup') : null);
                    contact.FirstName = (formData.containsKey('FirstName') ? (String) formData.get('FirstName') : null);
                    contact.LastName = (formData.containsKey('LastName') ? (String) formData.get('LastName') : null);
                    contact.Phone = (formData.containsKey('Phone') ? (String) formData.get('Phone') : null);
                    contact.Email = (formData.containsKey('Email') ? (String) formData.get('Email') : null);
                    insert contact;
                } */
                String contactId = (String) this.parameters.get('contactId');
                Slack.App app = Slack.App.ApexSlackApp.get();
                Slack.UserClient userClient = app.getUserClientForTeam(this.context.getTeamId(), this.context.getUserId());
                // Slack.UserClient userClient = app.getUserClientForTeam('T02M0RAEZC4', 'U02LRSEJ5F0');
                Slack.ViewReference viewReference = Slack.View.contact_detail_message.get();
                viewReference.setParameter('contactId', contactId);
                Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
                    //.channel((String) this.parameters.get('channelId'))
                    .channel('C03QUC9PNJJ')
                    //TODO should text be required if you are setting a view reference?
                    .text('Details for the contact' + contactId)
                    .viewReference(viewReference)
                    .build();

                Slack.ChatPostMessageResponse response = userClient.ChatPostMessage(req);
                if (response.getError() != null) {
                    System.debug(response.getResponseMetadata().getMessages());
                }
                String title = 'Posted';
                String body = 'Contact posted to channel.';
                return MessageModal.getMessageModalView(title, new List<String>{ body });
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
        }

        private Slack.ModalView getMessageModal(String errorMessage) {
            String title = 'Error Record Creation';
            String body = 'There was a problem creating your record.' + '\n' + errorMessage;
            return MessageModal.getMessageModalView(title, new List<String>{ body });
        }
    }
}
