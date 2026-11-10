@isTest
private class WeekTwoHomeworkTest {

    @testSetup
    static void setupTestData() {

        // Create a test Account
        Account testAccount = new Account(
            Name = 'RAD Women Test Account',
            Industry = 'Technology'
        );
        insert testAccount;

        // Create a test Contact
        Contact testContact = new Contact(
            FirstName = 'RAD',
            LastName = 'Student',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a Closed Won Opportunity
        Opportunity wonOpp = new Opportunity(
            Name = 'RAD Women Won Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 10000
        );
        insert wonOpp;

        // Create an Open Opportunity
        Opportunity openOpp = new Opportunity(
            Name = 'RAD Women Open Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 5000
        );
        insert openOpp;
    }

    @isTest
    static void testContactsWithAccounts() {

        Test.startTest();

        WeekTwoHomework.getContactsWithAccounts();

        Test.stopTest();
    }

    @isTest
    static void testAccountsWithWonOpportunities() {

        Test.startTest();

        WeekTwoHomework.getAccountsWithWonOpportunities();

        Test.stopTest();
    }

    @isTest
    static void testOpportunityMap() {

        Test.startTest();

        Map<Id, Opportunity> oppMap =
            WeekTwoHomework.getOpportunityMap();

        Test.stopTest();

        System.assert(
            oppMap.size() > 0,
            'Opportunity Map should contain records'
        );
    }

    @isTest
    static void testOpenOpportunityCount() {

        Test.startTest();

        Integer openCount =
            WeekTwoHomework.getOpenOpportunityCount();

        Test.stopTest();

        System.assertEquals(
            1,
            openCount,
            'There should be one open Opportunity'
        );
    }
}