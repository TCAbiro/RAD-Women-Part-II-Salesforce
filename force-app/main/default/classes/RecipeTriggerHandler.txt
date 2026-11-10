
public with sharing class RecipeTriggerHandler {

    // 1. Check required values and mark incomplete recipes
    public static void checkDraft(List<Recipe__c> recipes) {

        for (Recipe__c recipe : recipes) {

            if (
                String.isBlank(recipe.Name) ||
                recipe.Active_Time__c == null ||
                String.isBlank(recipe.Description__c) ||
                String.isBlank(recipe.Active_Time_Units__c) ||
                recipe.Servings__c == null
            ) {
                recipe.Draft__c = true;
            }
        }
    }

    // 2. Calculate recipe complexity
    public static void setComplexity(List<Recipe__c> recipes) {

        for (Recipe__c recipe : recipes) {

            // Assumes the existing helper accepts a Recipe__c
            // and returns an Integer.
            Integer rating =
                HelperFunctions.rateRecipeComplexity(recipe);

            if (rating == 3) {
                recipe.Complexity__c = 'Difficult';
            } else if (rating == 2) {
                recipe.Complexity__c = 'Moderate';
            } else if (rating == 1) {
                recipe.Complexity__c = 'Simple';
            }
        }
    }

    // 3. After Insert handler
    public static void afterInsert(List<Recipe__c> recipes) {
        // No After Insert business logic required yet.
    }

    // 4. Create review tasks for cookbook owners
    public static void createReviewTasks(List<Recipe__c> recipes) {

        Set<Id> recipeIds = new Set<Id>();

        // Collect non-draft recipe IDs
        for (Recipe__c recipe : recipes) {
            if (recipe.Draft__c == false) {
                recipeIds.add(recipe.Id);
            }
        }

        if (recipeIds.isEmpty()) {
            return;
        }

        // Find cookbooks using the updated recipes
        List<Recipe_Usage__c> usages = [
            SELECT Id,
                   Recipe__c,
                   Cookbook__c,
                   Cookbook__r.OwnerId
            FROM Recipe_Usage__c
            WHERE Recipe__c IN :recipeIds
            AND Cookbook__c != null
        ];

        List<Task> tasksToInsert = new List<Task>();

        // Create one review task per recipe usage
        for (Recipe_Usage__c usage : usages) {

            Task reviewTask = new Task();

            reviewTask.Subject = 'Review Recipe';
            reviewTask.WhatId = usage.Cookbook__c;
            reviewTask.OwnerId = usage.Cookbook__r.OwnerId;
            reviewTask.ActivityDate = System.today().addDays(7);
            reviewTask.Status = 'Not Started';

            tasksToInsert.add(reviewTask);
        }

        // Perform one bulk DML operation
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}
