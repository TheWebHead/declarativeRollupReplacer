/***************************************

Anthony Kelly, Developer, DialSource 2020

Logic for counting the number of certain types of closed tasks for
San Francisco Giants (Salesforce). Replaces Declarative Rollup Lookup Helper.

***************************************/

public class DSCountClosedTasksHandler {

    public static void DSCountClosedTasks (List<Task> tasks) {

        //Get Ids of Opportunities to Process
        Set<Id> oppIds = getOppIds(tasks);
        system.debug('Opp Ids: '+oppIds);

        //Determine size of Opp list and send to the appropriate method context for processing
        if(oppIds.size() > 1)
        {
            //Future
            processOppsFuture(oppIds);
        }
        else if(oppIds.size() == 1) 
        {
            //Synchronous
            processOpps(oppIds);
        }
    }
        
    /** Future invocation for processOpps() */
    @future(callout=true)
    private static void processOppsFuture(Set<Id> oppIds){
        processOpps(oppIds);
    }
    
    /** Queries Opps and their associated Tasks to update Task-related info on each Opp */
    private static void processOpps(Set<Id> oppIds){

        List<Opportunity> opps = [Select    Id, 
                                            DS_Open_Activities__c,
                                            DS_Completed_Activities__c,
                                            DS_Conversation_Activities__c,
                                            DS_Voicemail_Activities__c,
                                            DS_Email_Activities__c,
                                            DS_Text_Activities__c,
                                            DS_Other_Activities__c,
                                            DS_Last_Activity_Completed_Date__c,
                                            DS_Last_Completed_Activity_Result__c,
                                            DS_Days_Since_Last_Completed_Activity__c,
                                            DS_Next_Activity_Due_Date__c,
                                            DS_Get_Next_Open_Activity_Type__c,
                                            DS_Days_Until_Next_Activity_Due__c,
                                            DS_Last_Conversation_Activity_Date__c,
                                            DS_Last_Voicemail_Activity_Date__c,
                                            DS_Date_of_Last_No_Voicemail_Activity__c,
                                            DS_Last_Email_Activity_Date__c,
                                            DS_Last_Text_Activity_Date__c,
                                            DS_Last_Other_Activity_Date__c,
                                            Bypass_Validation__c,
                                            (Select Id, isClosed, ActivityDate, Activity_Result__c, Type From Tasks) 
                                From Opportunity 
                                Where Id IN: oppIds];
        system.debug('Opp List: '+opps);

        //Iterate through Opps and related Tasks
        for(Opportunity o: opps) 
        {
            /** Declare variables to collect info from related Tasks that will be updated on the Opp 
             * 
            */
            //Conversation
            integer inc=0;
            Date lastDueConvDate;

            //Voicemail
            integer inv=0;
            Date lastDueVmDate;

            //No Voicemail
            integer in_nv=0;
            Date lastDueNoVmDate;

            //Email
            integer ine=0;
            Date lastDueEmailDate;

            //Text
            integer intx=0;
            Date lastDueTxtDate;

            //Other
            integer ino = 0;
            Date lastDueOtherDate;

            //Last Completed Activity
            integer inr=0;
            Date lastDueDate;
            String lastActivityResult;
            Decimal numDaysLastDue;

            //Next Due Activity
            integer inp=0;
            Date nextDueDate;
            String nextOpenType;
            Decimal numDaysNextDue;
    
            //Iterate through related Tasks to extract info
            for(Task t: o.Tasks) 
            {
                //Open Tasks
                if(!t.isClosed) 
                {
                    //Count Open Activities
                    inp ++;

                    //Next Open Activity
                    if(nextDueDate == null || (nextDueDate > t.ActivityDate) ) 
                    {
                        nextDueDate = t.ActivityDate;
                        nextOpenType = t.Type;
                        numDaysNextDue = (system.today()).daysBetween(Date.valueOf(nextDueDate));
                    }

                }

                //Completed Tasks
                if(t.isClosed) 
                {
                    //Count Completed Activities
                    inr ++;

                    //Last Completed Activity
                    if(lastDueDate == null || (lastDueDate < t.ActivityDate) ) 
                    {
                        lastDueDate = t.ActivityDate;
                        lastActivityResult = t.Activity_Result__c;
                        numDaysLastDue = (system.today()).daysBetween(Date.valueOf(lastDueDate));
                    }

                    //Activity Result conditions
                    if(t.Activity_Result__c == 'Conversation') 
                    {
                        //Verify Last Conversation Task Date
                        if(lastDueConvDate == null || lastDueConvDate < t.ActivityDate) {
                            lastDueConvDate = t.ActivityDate;
                        }
                        //Voicemail Activity
                        inc ++;
                    }
                    else if(t.Activity_Result__c == 'Voicemail') 
                    {
                        //Verify Last Voicemail Task Date
                        if(lastDueVmDate == null || lastDueVmDate < t.ActivityDate) {
                            lastDueVmDate = t.ActivityDate;
                        }
                        //Voicemail Activity
                        inv ++;
                    }
                    else if(t.Activity_Result__c == 'No Voicemail') 
                    {
                        //Verify Last No Voicemail Task Date
                        if(lastDueNoVmDate == null || lastDueNoVmDate < t.ActivityDate) {
                            lastDueNoVmDate = t.ActivityDate;
                        }
                        //No Voicemail Activity
                        in_nv ++;
                    }
                    else if(t.Activity_Result__c == 'Email') 
                    {
                        //Verify Last Email Task Date
                        if(lastDueEmailDate == null || lastDueEmailDate < t.ActivityDate) {
                            lastDueEmailDate = t.ActivityDate;
                        }
                        //Email Activity
                        ine ++;
                    }
                    else if(t.Activity_Result__c == 'Text') 
                    {
                        //Verify Last Text Task Date
                        if(lastDueTxtDate == null || lastDueTxtDate < t.ActivityDate) {
                            lastDueTxtDate = t.ActivityDate;
                        }
                        //Text Activity
                        intx ++;
                    }
                    else if(t.Activity_Result__c == 'Other') 
                    {
                        //Verify Last Other Task Date
                        if(lastDueOtherDate == null || lastDueOtherDate < t.ActivityDate) {
                            lastDueOtherDate = t.ActivityDate;
                        }
                        //Other Activity
                        ino ++;
                    }
                }
            }

            //Map vars back to Opp fields
            o.DS_Open_Activities__c=inp;
            o.DS_Completed_Activities__c=inr;
            o.DS_Conversation_Activities__c=inc;
            o.DS_Voicemail_Activities__c=inv;
            o.DS_No_Voicemail_Activities__c=in_nv;
            o.DS_Email_Activities__c=ine;
            o.DS_Text_Activities__c=intx;
            o.DS_Other_Activities__c=ino;
            
            o.DS_Last_Activity_Completed_Date__c=lastDueDate;
            o.DS_Last_Completed_Activity_Result__c=lastActivityResult;
            o.DS_Days_Since_Last_Completed_Activity__c=numDaysLastDue;

            o.DS_Next_Activity_Due_Date__c=nextDueDate;
            o.DS_Get_Next_Open_Activity_Type__c=nextOpenType;
            o.DS_Days_Until_Next_Activity_Due__c=numDaysNextDue;
            
            o.DS_Last_Conversation_Activity_Date__c=lastDueConvDate;
            o.DS_Last_Voicemail_Activity_Date__c=lastDueVmDate;
            o.DS_Date_of_Last_No_Voicemail_Activity__c=lastDueNoVmDate;
            o.DS_Last_Email_Activity_Date__c=lastDueEmailDate;
            o.DS_Last_Text_Activity_Date__c=lastDueTxtDate;
            o.DS_Last_Other_Activity_Date__c=lastDueOtherDate;
            o.Bypass_Validation__c=true;

            
        }

        update opps;
    }

    /** Checks for Tasks that were recently added or removed from an Opp and returns the assoicated Opp Ids */
    private static Set<Id> getOppIds(List<Task> tasks){

        Set<Id> oppsWithTasks = new Set<Id>();

        //After triggers
        if(trigger.isAfter)
        {
            //Identify Opps that need processing
            for(Task t: tasks) 
            {
                /** Insert & delete conditions
                 * NOTE: "tasks" contains trigger.old records from the delete context and trigger.new records from insert context. This is why both contexts can be processed
                 * based on identical conditions within this "tasks" list.
                 */
                if(trigger.isInsert || trigger.isDelete)
                {
                    //New Task added on an Opp or old Task deleted from it
                    if(t.WhatId <> null && t.WhatId.getSObjectType() == Opportunity.SObjectType) {
                        oppsWithTasks.add(t.whatId);
                    }
                }
                //Update conditions
                if(trigger.isUpdate)
                {
                    //Get pre-update Task
                    Task oldTask = (Task) trigger.oldMap.get(t.Id);
                    
                    //Check conditions related to the whatId changing
                    if(t.whatId <> oldTask.whatId) 
                    {
                        //Reparented to an Opp
                        if(t.whatId <> null && t.WhatId.getSObjectType() == Opportunity.SObjectType) {
                            oppsWithTasks.add(t.whatId);
                        }

                        //Reparented from an Opp
                        if(oldTask.whatId <> null && oldTask.whatId.getSObjectType() == Opportunity.SObjectType) {
                            oppsWithTasks.add(oldTask.whatId);
                        }
                    }
                    //Recently closed Tasks
                    if(t.isClosed == true && oldTask.isClosed == False)
                    {
                        if(t.whatId <> null && t.whatId.getSObjectType() == Opportunity.SObjectType) {
                            oppsWithTasks.add(t.whatId);
                        }
                    }
                    //Tasks with a changed Due Date
                    if(t.ActivityDate <> oldTask.ActivityDate)
                    {
                        if(t.whatId <> null && t.whatId.getSObjectType() == Opportunity.SObjectType) {
                            oppsWithTasks.add(t.whatId);
                        }
                    }
                }
            }
        }

        return oppsWithTasks;
    }
    
}