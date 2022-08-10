public with sharing class ActionDispatcherEditContactDetails extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        // The slack action handler should immediately be returned.
        if (parameters != null && parameters.containsKey('pushModal') && (Boolean) parameters.get('pushModal')) {
            return Slack.ActionHandler.pushModal(new Handler(parameters, context));
        } else {
            return Slack.ActionHandler.updateModal(new Handler(parameters, context));
        }
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            Slack.ViewReference viewReference;
            String contactId = (String)this.parameters.get('contactId');

            // Returns the modal view that corresponds to the requested object.
            try {
                viewReference = Slack.View.edit_contact_details.get();
                viewReference.setParameter('contactId', contactId);
            } catch (Exception e) {
                viewReference = Slack.View.message_modal.get();
                viewReference.setParameter('title', 'Error Record Creation');
                viewReference.setParameter('message', e.getMessage());
            }

            Slack.ModalView modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
            return modalView;
        }
    }
}
