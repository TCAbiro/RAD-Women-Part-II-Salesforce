trigger LeadProductInterestTrigger on Lead (after insert, after update) {

    if (Trigger.isAfter) {

        if (Trigger.isInsert) {
            LeadProductInterestHandler.createFollowUpTasks(
                Trigger.new,
                null
            );
        }

        if (Trigger.isUpdate) {
            LeadProductInterestHandler.createFollowUpTasks(
                Trigger.new,
                Trigger.oldMap
            );
        }
    }
}