
trigger RecipeTrigger on Recipe__c (
    before insert,
    after insert,
    before update,
    after update
) {

    // BEFORE INSERT
    if (Trigger.isBefore && Trigger.isInsert) {

        // Check if required recipe fields are missing
        RecipeTriggerHandler.checkDraft(Trigger.new);

        // Calculate recipe complexity
        RecipeTriggerHandler.setComplexity(Trigger.new);
    }

    // AFTER INSERT
    if (Trigger.isAfter && Trigger.isInsert) {

        RecipeTriggerHandler.afterInsert(Trigger.new);
    }

    // BEFORE UPDATE
    if (Trigger.isBefore && Trigger.isUpdate) {

        // Check if required recipe fields are missing
        RecipeTriggerHandler.checkDraft(Trigger.new);

        // Recalculate recipe complexity
        RecipeTriggerHandler.setComplexity(Trigger.new);
    }

    // AFTER UPDATE
    if (Trigger.isAfter && Trigger.isUpdate) {

        // Create review tasks for recipes used in cookbooks
        RecipeTriggerHandler.createReviewTasks(Trigger.new);
    }
}
