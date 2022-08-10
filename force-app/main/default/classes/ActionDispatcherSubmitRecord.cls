/*
    This example apex class extends Slack.ActionDispatcher and is responsible for
    responding to the "onsubmit" event defined in the 'create_account', 'create_contact',
    and 'create_opportunty' views.
*/
public class ActionDispatcherSubmitRecord extends Slack.ActionDispatcher {
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
            String objectApiName = (this.parameters.containsKey('objectApiName') ? (String) this.parameters.get('objectApiName') : null);
            try {
                switch on objectApiName {
                    when 'Account' {
                        modalView = submitAccount();
                    }
                    when 'Contact' {
                        modalView = submitContact();
                    }
                    when 'Opportunity' {
                        modalView = submitOpportunity();
                    }
                    when 'Product_Gap__c' {
                        modalView = submitProductGap();
                    }
                }
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
            return modalView;
        }

        private Slack.ModalView submitAccount() {
            try {
                Map<String, Object> formData = this.context.getFormData();
                if (!formData.isEmpty() && formData.containsKey('Name')) {
                    Account account = new Account();
                    account.Name = (String) formData.get('Name');
                    insert account;
                }
                String title = 'Record Created';
                String body = (String) formData.get('Name') + ' Account was created successfully.';
                return MessageModal.getMessageModalView(title, new List<String>{ body });
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
        }

        private Slack.ModalView submitContact() {
            try {
                Map<String, Object> formData = this.context.getFormData();
                if (!formData.isEmpty()) {
                    Contact contact = new Contact();
                    contact.AccountId = (formData.containsKey('account_lookup') ? (String) formData.get('account_lookup') : null);
                    contact.FirstName = (formData.containsKey('FirstName') ? (String) formData.get('FirstName') : null);
                    contact.LastName = (formData.containsKey('LastName') ? (String) formData.get('LastName') : null);
                    contact.Phone = (formData.containsKey('Phone') ? (String) formData.get('Phone') : null);
                    contact.Email = (formData.containsKey('Email') ? (String) formData.get('Email') : null);
                    insert contact;
                }
                String title = 'Record Created';
                String body = (String) formData.get('FirstName') + ' ' + (String) formData.get('LastName') + ' Contact was created successfully.';
                return MessageModal.getMessageModalView(title, new List<String>{ body });
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
        }

        private Slack.ModalView submitOpportunity() {
            try {
                Map<String, Object> formData = this.context.getFormData();
                if (!formData.isEmpty()) {
                    Opportunity oppty = new Opportunity();
                    oppty.AccountId = (formData.containsKey('account_lookup') ? (String) formData.get('account_lookup') : null);
                    oppty.Name = (formData.containsKey('Name') ? (String) formData.get('Name') : null);
                    oppty.Amount = (formData.containsKey('Amount') ? Double.valueOf(formData.get('Amount')) : null);
                    oppty.StageName = (formData.containsKey('StageName') ? (String) formData.get('StageName') : null);
                    oppty.CloseDate = (formData.containsKey('CloseDate') ? Date.valueOf((String) formData.get('CloseDate')) : null);
                    insert oppty;
                }
                String title = 'Record Created';
                String body = (String) formData.get('Name') + ' Opportunity was created successfully.';
                return MessageModal.getMessageModalView(title, new List<String>{ body });
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
        }

        private Slack.ModalView submitProductGap() {
            try {
                Map<String, Object> formData = this.context.getFormData();
                if (!formData.isEmpty() && formData.containsKey('Name')) {
                    Product_Gap__c pg = new Product_Gap__c();
                    pg.Name = (String) formData.get('Name');
                    insert pg;
                }
                String title = 'Record Created';
                String body = (String) formData.get('Name') + ' Product Gap was created successfully.';
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
