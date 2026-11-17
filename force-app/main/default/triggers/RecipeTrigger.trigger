trigger RecipeTrigger on Recipe__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        RecipeTriggerHandler.checkDraft(Trigger.new);
        RecipeTriggerHandler.setComplexity(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        RecipeTriggerHandler.afterInsert(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        RecipeTriggerHandler.createReviewTasks(Trigger.new);
    }
}
