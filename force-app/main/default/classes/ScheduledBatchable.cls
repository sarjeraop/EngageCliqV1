/**
 * @classname				ScheduledBatchable
 * @author				Rati Kulkarni
 * @description			This class is used to schedule a batch as per Schedule Communcation object
 * @createddate			30-August-2023
 * * @modificationlog
 * 						1.0 Ganesh Bhakare : Added Batch size to constructor.
 */
global with sharing class ScheduledBatchable implements Schedulable {
    global Schedule_Communication__c objScheduleCommunication;
    global void execute(SchedulableContext sc) {
        SendBulkMessagesBatch s = new SendBulkMessagesBatch(this.objScheduleCommunication);
        Database.executeBatch(s,50);
     }
    public ScheduledBatchable(Schedule_Communication__c objScheduleCommunication) {
        this.objScheduleCommunication = objScheduleCommunication;
    }
}