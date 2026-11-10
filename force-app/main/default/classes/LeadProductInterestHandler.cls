public with sharing class LeadProductInterestHandler {

    public static void createFollowUpTasks(
        List<Lead> newLeads,
        Map<Id, Lead> oldLeadMap
    ) {

        List<Task> tasksToInsert = new List<Task>();

        for (Lead ld : newLeads) {

            // Skip Leads without Product Interest
            if (String.isBlank(ld.ProductInterest__c)) {
                continue;
            }

            // On update, only process changed Product Interest
            if (oldLeadMap != null) {

                Lead oldLead = oldLeadMap.get(ld.Id);

                if (oldLead.ProductInterest__c ==
                    ld.ProductInterest__c) {
                    continue;
                }
            }

            // Create follow-up Task
            Task followUpTask = new Task(
                WhoId = ld.Id,
                Subject = 'Follow up on ' +
                          ld.ProductInterest__c,
                Description = 'Contact the Lead regarding ' +
                              'their interest in ' +
                              ld.ProductInterest__c,
                Status = 'Not Started',
                Priority = 'Normal',
                ActivityDate = Date.today().addDays(2),
                OwnerId = ld.OwnerId
            );

            tasksToInsert.add(followUpTask);
        }

        // Bulk insert outside the loop
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}