public with sharing class TwilioOpportunityTriggerHandler {
    public static void handleOpportunityInsert(List<Opportunity> newOpportunities) {
        handleClosedWonOpportunities(newOpportunities, null);
    }

    public static void handleOpportunityUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMap) {
        handleClosedWonOpportunities(newOpportunities, oldMap);
    }

    public static void handleClosedWonOpportunities(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMap) {
       Set<id> accountIds = new Set<id>();
        // Logic to handle closed won opportunities
        for (Opportunity opp : newOpportunities) {
            if (opp.StageName == 'Closed Won' && opp.AccountId != null && (oldMap == null || oldMap.get(opp.Id).StageName != 'Closed Won')) {
                accountIds.add(opp.AccountId);
            }
        }

        updateAccountAsHot(accountIds);
    }

    public static void updateAccountAsHot(Set<Id> accountIds) {
        List<Account> accountsToUpdate = new List<Account>();
        List<AggregateResult> aggregateResults = [SELECT COUNT(Id), AccountId  FROM Opportunity WHERE AccountId IN :accountIds AND StageName='Closed Won' GROUP BY AccountId Having COUNT(Id) > 2];
        
        for(AggregateResult result : aggregateResults) {
            Id accountId = (Id) result.get('AccountId');
            accountsToUpdate.add(new Account(Id = accountId, Rating = 'Hot'));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}