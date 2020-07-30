/***************************************

Anthony Kelly, Developer, DialSource 2020

Test class for DSCountClosedTasks trigger
and trigger handler

***************************************/

@isTest
public class DSClosedTasks_Test {
   static testMethod void createRecords(){
    Account a = new Account();
    a.Name = 'New Test Account';
    insert a;
    
	Opportunity o = new Opportunity();
    o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Season Ticket Sale').getRecordTypeId();
    o.AccountId = a.Id;
    o.Name = 'New test opportunity';
    o.Season__c = '2020';
    o.Type = 'Season';
    o.CloseDate = system.Today() + 1;
    o.StageName = 'Open';
    insert o;
    
    Task tVm = new Task();
    tVm.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('New Task').getRecordTypeId();
    tVm.WhatId = o.Id;
    tVm.Subject = 'Great conversation';
    tVm.ActivityDate = system.today();
    tVm.Type = 'Other';
    tVm.OwnerId = userinfo.getUserId();
    tVm.Priority = 'Normal';
    tVm.Status = 'Completed';
    tVm.Description = 'Hi';
    tVm.Activity_Result__c = 'Voicemail';
    insert tVm;
    
    Task tnVm = new Task();
    tnVm.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('New Task').getRecordTypeId();
    tnVm.WhatId = o.Id;
    tnVm.Subject = 'Great conversation';
    tnVm.ActivityDate = system.today();
    tnVm.Type = 'Outbound Call';
    tnVm.OwnerId = userinfo.getUserId();
    tnVm.Priority = 'Normal';
    tnVm.Status = 'Completed';
    tnVm.Description = 'Hi';
    tnVm.Activity_Result__c = 'No Voicemail';
    insert tnVm;
    
       
    Task tc = new Task();
    tc.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('New Task').getRecordTypeId();
    tc.WhatId = o.Id;
    tc.Subject = 'Great conversation';
    tc.ActivityDate = system.today();
    tc.Type = 'Outbound Call';
    tc.OwnerId = userinfo.getUserId();
    tc.Priority = 'Normal';
    tc.Status = 'Completed';
    tc.Description = 'Hi';
    tc.Activity_Result__c = 'Conversation';
    insert tc;
       
    Task te = new Task();
    te.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('New Task').getRecordTypeId();
    te.WhatId = o.Id;
    te.Subject = 'Great conversation';
    te.ActivityDate = system.today();
    te.Type = 'Email';
    te.OwnerId = userinfo.getUserId();
    te.Priority = 'Normal';
    te.Status = 'Completed';
    te.Description = 'Hi';
    te.Activity_Result__c = 'Email';
    insert te;
    
    Task te1 = new Task();
    te1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('New Task').getRecordTypeId();
    te1.WhatId = a.Id;
    te1.Subject = 'Great conversation';
    te1.ActivityDate = system.today();
    te1.Type = 'Email';
    te1.OwnerId = userinfo.getUserId();
    te1.Priority = 'Normal';
    te1.Status = 'Completed';
    te1.Description = 'Hi';
    te1.Activity_Result__c = 'Email';
    insert te1;   
       
    Task tOpen = new Task();
    tOpen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('New Task').getRecordTypeId();
    tOpen.WhatId = o.Id;
    tOpen.Subject = 'Great conversation';
    tOpen.ActivityDate = system.today();
    tOpen.Type='Outbound Call';
    tOpen.OwnerId=userinfo.getUserId();
    tOpen.Priority='Normal';
    tOpen.Status = 'Not Started';
    tOpen.Description = 'Hi';
    insert tOpen;
       
       
    delete tOpen;
    }
}