/*
Problem Statement:- 
When an Opportunities with StageName "Closed Won" inserted or updated to "Closed Won", 
Mark their related Account Rating as "Hot" only if they have 3+ Opportunities with StageName "Closed Won".
*/

trigger TwilioOpportunityTrigger on Opportunity (after insert, after update) {

    if(Trigger.isAfter && Trigger.isInsert) {
        TwilioOpportunityTriggerHandler.handleOpportunityInsert(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
        TwilioOpportunityTriggerHandler.handleOpportunityUpdate(Trigger.new, Trigger.oldMap);
    }
}