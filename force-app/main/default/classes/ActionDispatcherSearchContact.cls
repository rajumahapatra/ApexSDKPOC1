public with sharing class ActionDispatcherSearchContact extends Slack.ActionDispatcher{
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
                Slack.ViewReference viewReference;
                viewReference = Slack.View.view_searched_contacts.get();
                
                Map<String, Object> formData = this.context.getFormData();
                System.debug('formData: ' + formData);
                if (!formData.isEmpty() && formData.containsKey('Name') && formData.containsKey('Title')) {
                    viewReference.setParameter('name', (String) formData.get('Name'));
                    if((String) formData.get('Title') != null)
                        viewReference.setParameter('contactTitle', (String) formData.get('Title'));
                    else
                    viewReference.setParameter('contactTitle', '');
                    viewReference.setParameter('channelId', this.context.getchannelId());
                    modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
                }
            } catch (Exception e) {
                modalView = getMessageModal(e.getMessage());
            }
            return modalView;
        }

        private Slack.ModalView getMessageModal(String errorMessage) {
            String title = 'Error Record Creation';
            String body = 'There was a problem creating your record.' + '\n' + errorMessage;
            return MessageModal.getMessageModalView(title, new List<String>{ body });
        }
    }
}
