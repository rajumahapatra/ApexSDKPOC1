public with sharing class ActionDispatcherSaveContact extends Slack.ActionDispatcher {
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
                Map<String, Object> formData = this.context.getFormData();
                if (!formData.isEmpty()) {
                    Contact contact = new Contact(Id = (String)this.parameters.get('contactId'));
                    contact.AccountId = (formData.containsKey('account_lookup') ? (String) formData.get('account_lookup') : null);
                    contact.FirstName = (formData.containsKey('FirstName') ? (String) formData.get('FirstName') : null);
                    contact.LastName = (formData.containsKey('LastName') ? (String) formData.get('LastName') : null);
                    contact.Phone = (formData.containsKey('Phone') ? (String) formData.get('Phone') : null);
                    contact.Email = (formData.containsKey('Email') ? (String) formData.get('Email') : null);
                    update contact;
                }
                String title = 'Record Updated';
                String body = (String) formData.get('FirstName') + ' ' + (String) formData.get('LastName') + ' Contact was updated successfully.';
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
