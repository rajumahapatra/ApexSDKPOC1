@isTest
private class TestDataProviderAccountLookup {
    @isTest
    private static void testGetAccountByName() {
        Account acc = new Account(Name = 'MetaAccount');
        Test.startTest();
        insert acc;
        Slack.OptionDataResponse returnedData = DataProviderAccountLookup.getAccountsByName('MetaAccount');
        System.assertEquals(null, returnedData.getOptionGroups());
        System.assertNotEquals(null, returnedData.getOptions());
        List<Slack.Option> options = returnedData.getOptions();
        for (Slack.Option option : options) {
            System.assertEquals('MetaAccount', option.getText());
            System.assertEquals(acc.Id, option.getValue());
        }
        Test.stopTest();
    }
}
