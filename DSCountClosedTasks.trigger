/**********************************

 * 3/12/2020 Anthony Kelly
 * Trigger to count the number of completed tasks on opportunity 
 * 
 * ********************************/
trigger DSCountClosedTasks on Task (after insert, after update, after delete) {

    //After Triggers
    if(trigger.isAfter) 
    {
        //Pass in Trigger.New for Update and Insert triggers
        if(trigger.isUpdate || trigger.isInsert) 
        {
            DSCountClosedTasksHandler.DSCountClosedTasks(trigger.new);
        }
        //Pass in Trigger.Old for Delete triggers
        if(trigger.isDelete)
        {
            DSCountClosedTasksHandler.DSCountClosedTasks(trigger.old);
        }
    }
}