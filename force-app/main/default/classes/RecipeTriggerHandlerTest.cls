
@isTest
private class RecipeTriggerHandlerTest {

    // Create a complete recipe for testing.
    private static Recipe__c createRecipe(String name) {
        return new Recipe__c(
            Name = name,
            Active_Time__c = 30,
            Active_Time_Units__c = 'Minutes',
            Description__c = 'A delicious homemade recipe',
            Servings__c = 4,
            Draft__c = false
        );
    }

    // TEST 1: Missing required fields should mark draft
    @isTest
    static void testIncompleteRecipeIsDraft() {

        Recipe__c recipe = new Recipe__c(
            Name = 'Incomplete Recipe',
            Description__c = 'Test recipe'
        );

        Test.startTest();
        insert recipe;
        Test.stopTest();

        Recipe__c savedRecipe = [
            SELECT Id, Draft__c
            FROM Recipe__c
            WHERE Id = :recipe.Id
        ];

        Assert.isTrue(
            savedRecipe.Draft__c,
            'Incomplete recipe should be marked as draft.'
        );
    }

    // TEST 2: Complete recipe should not be draft
    @isTest
    static void testCompleteRecipe() {

        Recipe__c recipe = createRecipe('Chicken Curry');

        Test.startTest();
        insert recipe;
        Test.stopTest();

        Recipe__c savedRecipe = [
            SELECT Id, Draft__c, Complexity__c
            FROM Recipe__c
            WHERE Id = :recipe.Id
        ];

        Assert.isFalse(
            savedRecipe.Draft__c,
            'Complete recipe should not be a draft.'
        );

        Assert.isNotNull(
            savedRecipe.Complexity__c,
            'Complexity should be calculated.'
        );
    }

    // TEST 3: Validate draft status on update
    @isTest
    static void testRecipeUpdateToDraft() {

        Recipe__c recipe = createRecipe('Vegetable Soup');
        insert recipe;

        Test.startTest();

        recipe.Description__c = null;
        update recipe;

        Test.stopTest();

        Recipe__c updatedRecipe = [
            SELECT Draft__c
            FROM Recipe__c
            WHERE Id = :recipe.Id
        ];

        Assert.isTrue(
            updatedRecipe.Draft__c,
            'Missing description should mark recipe as draft.'
        );
    }

    // TEST 4: Validate complexity on update
    @isTest
    static void testComplexityOnUpdate() {

        Recipe__c recipe = createRecipe('Beef Stew');
        insert recipe;

        Test.startTest();

        recipe.Active_Time__c = 90;
        update recipe;

        Test.stopTest();

        Recipe__c updatedRecipe = [
            SELECT Complexity__c
            FROM Recipe__c
            WHERE Id = :recipe.Id
        ];

        Assert.isTrue(
            new Set<String>{
                'Simple',
                'Moderate',
                'Difficult'
            }.contains(updatedRecipe.Complexity__c),
            'Recipe should have a valid complexity.'
        );
    }

    // TEST 5: Create a review task for a cookbook
    @isTest
    static void testCookbookReviewTask() {

        Recipe__c recipe = createRecipe('Rice Pilau');
        insert recipe;

        Cookbook__c cookbook = new Cookbook__c(
            Name = 'African Cookbook'
        );
        insert cookbook;

        Recipe_Usage__c usage = new Recipe_Usage__c(
            Recipe__c = recipe.Id,
            Cookbook__c = cookbook.Id
        );
        insert usage;

        Test.startTest();

        recipe.Description__c = 'Updated recipe instructions';
        update recipe;

        Test.stopTest();

        List<Task> reviewTasks = [
            SELECT Id, Subject, WhatId,
                   OwnerId, ActivityDate
            FROM Task
            WHERE WhatId = :cookbook.Id
        ];

        Assert.areEqual(
            1,
            reviewTasks.size(),
            'One review task should be created.'
        );

        Assert.areEqual(
            cookbook.Id,
            reviewTasks[0].WhatId,
            'Task should be linked to cookbook.'
        );

        Assert.areEqual(
            cookbook.OwnerId,
            reviewTasks[0].OwnerId,
            'Task should belong to cookbook owner.'
        );

        Assert.areEqual(
            Date.today().addDays(7),
            reviewTasks[0].ActivityDate,
            'Task should be due in seven days.'
        );
    }

    // TEST 6: Verify bulk insert processing
    @isTest
    static void testBulkRecipeInsert() {

        List<Recipe__c> recipes = new List<Recipe__c>();

        for (Integer i = 0; i < 20; i++) {
            recipes.add(
                createRecipe('Test Recipe ' + i)
            );
        }

        Test.startTest();
        insert recipes;
        Test.stopTest();

        Set<Id> recipeIds = new Map<Id, Recipe__c>(
            recipes
        ).keySet();

        List<Recipe__c> savedRecipes = [
            SELECT Id, Draft__c, Complexity__c
            FROM Recipe__c
            WHERE Id IN :recipeIds
        ];

        Assert.areEqual(
            20,
            savedRecipes.size(),
            'All 20 recipes should be inserted.'
        );

        for (Recipe__c recipe : savedRecipes) {
            Assert.isFalse(
                recipe.Draft__c,
                'Complete recipes should not be drafts.'
            );

            Assert.isNotNull(
                recipe.Complexity__c,
                'Each recipe should have a complexity.'
            );
        }
    }
}
