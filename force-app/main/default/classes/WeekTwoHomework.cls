public with sharing class WeekTwoHomework {

    // Requirement 1:
    // Query Contacts with Account Name and Industry.
    // Print each Contact's Account Name.
    public static void getContactsWithAccounts() {

        List<Contact> contacts = [
            SELECT Id, FirstName, LastName,
                   Account.Name, Account.Industry
            FROM Contact
            WHERE AccountId != null
            LIMIT 100
        ];

        for (Contact con : contacts) {
            System.debug(
                'Contact: ' + con.FirstName + ' ' +
                con.LastName +
                ' | Account Name: ' + con.Account.Name +
                ' | Industry: ' + con.Account.Industry
            );
        }
    }

    // Requirement 2:
    // Query Accounts with Closed Won Opportunities.
    // Print each Account's Opportunity Names.
    public static void getAccountsWithWonOpportunities() {

        List<Account> accounts = [
            SELECT Id, Name,
                (SELECT Id, Name, StageName, Amount
                 FROM Opportunities
                 WHERE IsWon = true AND IsClosed = true)
            FROM Account
            LIMIT 100
        ];

        for (Account acc : accounts) {
            for (Opportunity opp : acc.Opportunities) {
                System.debug(
                    'Account: ' + acc.Name +
                    ' | Opportunity: ' + opp.Name
                );
            }
        }
    }

    // Requirement 3:
    // Query Opportunities and return results as a Map.
    public static Map<Id, Opportunity> getOpportunityMap() {

        Map<Id, Opportunity> opportunityMap =
            new Map<Id, Opportunity>([
                SELECT Id, Name, StageName,
                       Amount, CloseDate
                FROM Opportunity
                LIMIT 100
            ]);

        for (Id oppId : opportunityMap.keySet()) {
            System.debug(
                'Opportunity Id: ' + oppId +
                ' | Opportunity Name: ' +
                opportunityMap.get(oppId).Name
            );
        }

        return opportunityMap;
    }

    // Requirement 4:
    // Count all Open Opportunities using AggregateResult.
    public static Integer getOpenOpportunityCount() {

        AggregateResult[] results = [
            SELECT COUNT(Id) totalOpen
            FROM Opportunity
            WHERE IsClosed = false
        ];

        Integer totalOpen =
            (Integer) results[0].get('totalOpen');

        System.debug(
            'Total Open Opportunities: ' + totalOpen
        );

        return totalOpen;
    }
}