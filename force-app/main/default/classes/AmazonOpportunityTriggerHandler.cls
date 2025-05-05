public with sharing class AmazonOpportunityTriggerHandler {
    public static void handleOpportunityUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> opportunitiesToProcess = new List<Opportunity>();
       for(Opportunity opp : newOpportunities) {
            if (opp.StageName == 'Closed Won' && opp.AccountId != null &&  oldMap.get(opp.Id).StageName != 'Closed Won') {
                // Logic to handle closed won opportunities
                accountIds.add(opp.AccountId);
                opportunitiesToProcess.add(opp);
            }
        }

        List<Opportunity> recentOpportunities = [Select id, Bonus_Discount__c, AccountId, CloseDate FROM Opportunity WHERE accountID IN : accountIds AND StageName = 'Closed Won' AND ID NOT IN :opportunitiesToProcess ];
        Map<Id, List<Opportunity>> accountToOpportunitiesMap = new Map<Id, List<Opportunity>>();
        
        for(Opportunity opp : recentOpportunities) {
            if(accountToOpportunitiesMap.containsKey(opp.AccountId)) {
                accountToOpportunitiesMap.get(opp.AccountId).add(opp);
            } else {
                accountToOpportunitiesMap.put(opp.AccountId, new List<Opportunity>{opp});
            }
        }

        updateDiscountedWeight(opportunitiesToProcess, accountToOpportunitiesMap);
    }

    public static void updateDiscountedWeight(List<Opportunity> opportunitiesToProcess, Map<Id, List<Opportunity>> accountToOpportunitiesMap) {
    
       
       for(Opportunity opp : opportunitiesToProcess) {
            List<Opportunity> recentOpportunities = accountToOpportunitiesMap.get(opp.AccountId);
            Decimal discountedWeight = calculateDiscountedWeight(opp, recentOpportunities);
            opp.Bonus_Discount__c = discountedWeight;
        }

    }

    public static Decimal calculateDiscountedWeight(Opportunity currentOpportunity, List<Opportunity> recentOpportunities) {
        
        if(recentOpportunities == null || recentOpportunities.isEmpty()) {
            return currentOpportunity.Bonus_Discount__c == null ? 0 : currentOpportunity.Bonus_Discount__c; 
        }
         
        Date currentOpportunityCloseDate = currentOpportunity.CloseDate;
        Decimal weightSum = 0;
        Decimal weightedDiscount = 0;
        for(Opportunity opp : recentOpportunities) {
            Date recentOpportunityCloseDate = opp.CloseDate;
            Integer daysDifference = Math.abs(currentOpportunityCloseDate.daysBetween(recentOpportunityCloseDate));
            Decimal weight = 1/(1+daysDifference);
            weightSum += weight;
            weightedDiscount += weight * opp.Bonus_Discount__c;
        }

        return weightSum > 0 ? weightedDiscount / weightSum : 0;
    }
    

    
}