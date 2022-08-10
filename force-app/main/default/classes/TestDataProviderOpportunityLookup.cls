/*
	This example test suite is responsible for testing the DataProviderOpportunityLookup.
*/
@isTest
public class TestDataProviderOpportunityLookup {
    @TestSetup
    static void setup() {
        Account account = new Account(Name = 'Joe Co UniqueAcc');
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Acme Co.',
            Amount = 50000.00,
            StageName = 'Qualification',
            CloseDate = Date.today() + 30,
            AccountId = account.Id
        );
        insert opportunity;
    }

    // This test runs the OpportunityLookupProvider with an account with a single opportunity.
    @isTest
    static void testSingleOpportunity() {
        Account account = [SELECT Id FROM Account WHERE Name = :'Joe Co UniqueAcc'];
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE AccountId = :account.Id];

        Test.startTest();
        List<Slack.Option> options = DataProviderOpportunityLookup.getOpportunitiesByAccount(account.Id);
        Test.stopTest();

        System.assertEquals(1, options.size());
        System.assertEquals(opp.Name, options.get(0).getText());
        System.assertEquals(opp.Id, options.get(0).getValue());
    }

    // This test runs the OpportunityLookupProvider with an account with multiple opportunities.
    @Istest
    static void testMultipleOpportunities() {
        Account account = [SELECT Id FROM Account WHERE Name = :'Joe Co UniqueAcc'];
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE AccountId = :account.Id];
        Opportunity opp2 = new Opportunity(
            Name = 'Global Media Co.',
            Amount = 50000.00,
            StageName = 'Qualification',
            CloseDate = Date.today() + 30,
            AccountId = account.Id
        );

        Test.startTest();
        insert opp2;
        List<Opportunity> opps = new List<Opportunity>{ opp, opp2 };
        List<Slack.Option> options = DataProviderOpportunityLookup.getOpportunitiesByAccount(account.Id);
        Test.stopTest();

        System.assertEquals(2, options.size());
        System.assertEquals(opps[0].Name, options.get(0).getText());
        System.assertEquals(opps[0].Id, options.get(0).getValue());
        System.assertEquals(opps[1].Name, options.get(1).getText());
        System.assertEquals(opps[1].Id, options.get(1).getValue());
    }

    // This test runs the OpportunityLookupProvider with an account with no opportunity.
    @isTest
    static void testNoOpportunity() {
        // create new account record
        Test.startTest();
        Account account = new Account(Name = 'HelloAccount');
        insert account;
        List<Slack.Option> options = DataProviderOpportunityLookup.getOpportunitiesByAccount(account.Id);
        Test.stopTest();

        System.assertEquals(1, options.size());
        System.assertEquals('Account has no Opportunity', options.get(0).getText());
        System.assertEquals('Account has no Opportunity', options.get(0).getValue());
    }

    // This test runs the OpportunityLookupProvider with a blank value.
    @Istest
    static void testBlankValue() {
        List<Slack.Option> options = DataProviderOpportunityLookup.getOpportunitiesByAccount('');
        System.assertEquals(1, options.size());
        System.assertEquals('Account Id is missing or is incorrect', options.get(0).getText());
        System.assertEquals('Account Id is missing or is incorrect', options.get(0).getValue());
    }

    // This test runs the OpportunityLookupProvider with a null value.
    @isTest
    static void testNullValue() {
        List<Slack.Option> options = DataProviderOpportunityLookup.getOpportunitiesByAccount(null);
        System.assertEquals(1, options.size());
        System.assertEquals('Account Id is missing or is incorrect', options.get(0).getText());
        System.assertEquals('Account Id is missing or is incorrect', options.get(0).getValue());
    }

    @isTest
    static void testGetOpportunitiesByStage() {
        Account account = [SELECT Id FROM Account WHERE Name = :'Joe Co UniqueAcc'];

        Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE AccountId = :account.Id];
        opp.StageName = 'New';

        List<Opportunity> additionalOpps = new List<Opportunity>();
        for (Integer i = 0; i < 2; i++) {
            Opportunity o = new Opportunity();
            o.AccountId = account.Id;
            o.Name = 'TestOpp' + i;
            o.CloseDate = Date.today() + 30;

            if (i == 0) {
                o.StageName = 'In Progress';
            } else if (i == 1) {
                o.StageName = 'Closed';
            }
            additionalOpps.add(o);
        }

        Test.startTest();
        update opp;
        insert additionalOpps;
        List<Slack.OptionGroup> returnedOptionGroups = DataProviderOpportunityLookup.getOpportunitiesByStage(account.Id);
        Test.stopTest();

        System.assertEquals(3, returnedOptionGroups.size());
        for (Slack.OptionGroup optionGroup : returnedOptionGroups) {
            if (optionGroup.getLabel() == 'New Opportunities') {
                List<Slack.Option> options1 = optionGroup.getOptions();
                System.assertEquals(1, options1.size());
                System.assertEquals('Acme Co.', options1.get(0).getValue());
            }
            if (optionGroup.getLabel() == 'In Progress Opportunities') {
                List<Slack.Option> options2 = optionGroup.getOptions();
                System.assertEquals('TestOpp0', options2.get(0).getValue());
                System.assertEquals(1, options2.size());
            }
            if (optionGroup.getLabel() == 'Closed Opportunities') {
                List<Slack.Option> options3 = optionGroup.getOptions();
                System.assertEquals('TestOpp1', options3.get(0).getValue());
                System.assertEquals(1, options3.size());
            }
        }
    }

    @isTest
    static void testQueryOpportunities() {
        Account account = [SELECT Id FROM Account WHERE Name = :'Joe Co UniqueAcc'];

        Test.startTest();
        List<Opportunity> opps = DataProviderOpportunityLookup.queryOpportunities(account.Id);
        Test.stopTest();

        System.assertEquals(1, opps.size());
        System.assertEquals('Qualification', opps[0].StageName);
    }

    @isTest
    static void testGetEmptyOptionGroup() {
        Slack.OptionGroup optionGroup = DataProviderOpportunityLookup.getEmptyOptionGroup();
        System.assertNotEquals(null, optionGroup);
        System.assertEquals('Account has no Opportunity', optionGroup.getLabel());
        System.assert(optionGroup.getOptions().isEmpty());
    }
}
