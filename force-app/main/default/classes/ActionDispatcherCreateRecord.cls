/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "button click" events in the 'create_record' view.
*/
public class ActionDispatcherCreateRecord extends Slack.ActionDispatcher {
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
            String objectApiName = (this.parameters.containsKey('objectApiName') ? (String) this.parameters.get('objectApiName') : null);

            // Returns the modal view that corresponds to the requested object.
            try {
                switch on objectApiName {
                    when 'Account' {
                        viewReference = Slack.View.create_account.get();
                    }
                    when 'Contact' {
                        viewReference = Slack.View.create_contact.get();
                    }
                    when 'Opportunity' {
                        viewReference = Slack.View.create_opportunity.get();
                    }
                    when 'Product_Gap__c' {
                        viewReference = Slack.View.create_product_gap.get();
                    }
                }
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
