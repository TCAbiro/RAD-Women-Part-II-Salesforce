
function RecipeTrigger(Trigger) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            RecipeTriggerHandler.checkDraft(Trigger.new);
            RecipeTriggerHandler.setComplexity(Trigger.new);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            RecipeTriggerHandler.afterInsert(Trigger.new);
        }

        if (Trigger.isUpdate) {
            RecipeTriggerHandler.createReviewTasks(Trigger.new);
        }
    }
}
