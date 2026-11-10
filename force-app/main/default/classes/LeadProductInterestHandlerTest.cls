@isTest
private class LeadProductInterestHandlerTest {

    // Test 1: Create Task when Lead is inserted
    // with a Product Interest
    @isTest
    static void testAfterInsert() {

        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Smith',
            Company = 'RAD Women',
            ProductInterest__c = 'GC1000 series'
        );

        Test.startTest();
        insert testLead;
        Test.stopTest();

        List<Task> tasks = [
            SELECT Id, Subject, WhoId
            FROM Task
            WHERE WhoId = :testLead.Id
        ];

        System.assertEquals(
            1,
            tasks.size(),
            'One follow-up Task should be created'
        );

        System.assert(
            tasks[0].Subject.contains('GC1000 series'),
            'Task Subject should contain Product Interest'
        );
    }

    // Test 2: Create Task when Product Interest changes
    @isTest
    static void testAfterUpdateWithChange() {

        Lead testLead = new Lead(
            FirstName = 'Mary',
            LastName = 'Johnson',
            Company = 'RAD Women'
        );

        insert testLead;

        testLead.ProductInterest__c = 'GC1000 series';

        Test.startTest();
        update testLead;
        Test.stopTest();

        List<Task> tasks = [
            SELECT Id, Subject
            FROM Task
            WHERE WhoId = :testLead.Id
        ];

        System.assertEquals(
            1,
            tasks.size(),
            'A Task should be created when Product Interest changes'
        );
    }

    // Test 3: Do not create another Task
    // when an unrelated field changes
    @isTest
    static void testAfterUpdateWithoutChange() {

        Lead testLead = new Lead(
            FirstName = 'Sarah',
            LastName = 'Williams',
            Company = 'RAD Women',
            ProductInterest__c = 'GC1000 series'
        );

        insert testLead;

        // Update Company only
        testLead.Company = 'RAD Women Updated';

        Test.startTest();
        update testLead;
        Test.stopTest();

        List<Task> tasks = [
            SELECT Id
            FROM Task
            WHERE WhoId = :testLead.Id
        ];

        System.assertEquals(
            1,
            tasks.size(),
            'No additional Task should be created'
        );
    }

    // Test 4: No Task when Product Interest is blank
    @isTest
    static void testNoProductInterest() {

        Lead testLead = new Lead(
            FirstName = 'James',
            LastName = 'Brown',
            Company = 'RAD Women'
        );

        Test.startTest();
        insert testLead;
        Test.stopTest();

        List<Task> tasks = [
            SELECT Id
            FROM Task
            WHERE WhoId = :testLead.Id
        ];

        System.assertEquals(
            0,
            tasks.size(),
            'No Task should be created without Product Interest'
        );
    }

    // Test 5: Bulk insert multiple Leads
    @isTest
    static void testBulkLeadInsert() {

        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < 10; i++) {

            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'RAD Women',
                ProductInterest__c = 'GC1000 series'
            ));
        }

        Test.startTest();
        insert leads;
        Test.stopTest();

        Set<Id> leadIds = new Set<Id>();

        for (Lead ld : leads) {
            leadIds.add(ld.Id);
        }

        Integer taskCount = [
            SELECT COUNT()
            FROM Task
            WHERE WhoId IN :leadIds
        ];

        System.assertEquals(
            10,
            taskCount,
            'Ten follow-up Tasks should be created'
        );
    }
}