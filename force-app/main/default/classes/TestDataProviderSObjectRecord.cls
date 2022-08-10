@isTest
private class TestDataProviderSObjectRecord {
    @testSetup
    static void setup() {
        Account acc = new Account(Name = 'UniqueAccountTestCompany');
        insert acc;

        Contact con = new Contact(AccountId = acc.Id, FirstName = 'Betty', LastName = 'White', Email = 'testCon@forBettyWhite.com');
        insert con;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'TestOppForABCCompany',
            StageName = 'Prospecting',
            CloseDate = Date.today() + 30
        );
        insert opp;
    }

    @isTest
    private static void testGetAccountRecord() {
        Account acc = [SELECT Id FROM Account WHERE Name = :'UniqueAccountTestCompany'];
        List<FieldData> returnData = DataProviderSObjectRecord.getRecord(acc.Id, 'Account');
        System.assertEquals(2, returnData.size());
        for (FieldData data : returnData) {
            if (data.label == 'Name') {
                System.assertEquals('UniqueAccountTestCompany', data.value);
            }
            if (data.label == 'Id') {
                System.assertEquals(acc.Id, data.value);
            }
        }
    }

    @isTest
    private static void testGetAcountRecordById() {
        Account acc = [SELECT Id FROM Account WHERE Name = :'UniqueAccountTestCompany'];
        Account returnedData = DataProviderSObjectRecord.getAccountById(acc.Id);
        System.assertEquals('UniqueAccountTestCompany', returnedData.Name);
    }

    @isTest
    private static void testGetContactRecord() {
        Account acc = [SELECT Id FROM Account WHERE Name = :'UniqueAccountTestCompany'];
        Contact con = [SELECT Id, AccountId, FirstName, LastName, Email FROM Contact WHERE AccountId = :acc.Id];

        Test.startTest();
        List<FieldData> returnData = DataProviderSObjectRecord.getRecord(con.Id, 'Contact');
        System.assertEquals(4, returnData.size());
        for (FieldData data : returnData) {
            if (data.label == 'FirstName') {
                System.assertEquals(con.FirstName, data.value);
            }
            if (data.label == 'LastName') {
                System.assertEquals(con.LastName, data.value);
            }
            if (data.label == 'AccountId') {
                System.assertEquals(acc.Id, data.value);
            }
            if (data.label == 'Email') {
                System.assertEquals(con.Email, data.value);
            }
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetContactRecordById() {
        Account acc = [SELECT Id FROM Account WHERE Name = :'UniqueAccountTestCompany'];
        Contact con = [SELECT Id, AccountId, Name, Email FROM Contact WHERE AccountId = :acc.Id];
        Contact returnedData = DataProviderSObjectRecord.getContactById(con.Id);
        System.assertEquals(con.Name, returnedData.Name);
    }

    @isTest
    private static void testGetOpportunityRecord() {
        Account acc = [SELECT Id FROM Account WHERE Name = :'UniqueAccountTestCompany'];
        Opportunity opp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE AccountId = :acc.Id];

        Test.startTest();
        List<FieldData> returnData = DataProviderSObjectRecord.getRecord(opp.Id, 'Opportunity');
        System.assertEquals(4, returnData.size());
        for (FieldData data : returnData) {
            if (data.label == 'Name') {
                System.assertEquals(opp.Name, data.value);
            }
            if (data.label == 'StageName') {
                System.assertEquals(opp.StageName, data.value);
            }
            if (data.label == 'CloseDate') {
                System.assertEquals(opp.CloseDate, data.value);
            }
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetOpportunityRecordById() {
        Account acc = [SELECT Id FROM Account WHERE Name = :'UniqueAccountTestCompany'];
        Opportunity opp = [SELECT Id, Name, StageName, CloseDate FROM Opportunity WHERE AccountId = :acc.Id];
        Opportunity returnedData = DataProviderSObjectRecord.getOpportunityById(opp.Id);
        System.assertEquals(opp.Name, returnedData.Name);
    }
}
