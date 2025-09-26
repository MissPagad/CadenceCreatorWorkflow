//this class helps us to create Tasks depending on user input from Record Level LWC Component
public  class customCadenceController { 
    @AuraEnabled
    //get all the parameters from LWC Component
    public static void getData(String recId,String objectName, String type,Date sDate,Integer nCad,Integer intervalCad,Id cadOwner,Boolean cboxVal,Boolean cboxRem,String remSet ) {
        
        system.debug('recordId=='+recId);
        system.debug('currenObjectName=='+objectName);
        system.debug('value=='+type);
        system.debug('startD=='+sDate);
        system.debug('noCad=='+nCad);
        system.debug('intCad=='+intervalCad);
        system.debug('cadOwner=='+cadOwner);
        system.debug('cboxVal=='+cboxVal);
        system.debug('cboxRem=='+cboxRem);
        system.debug('remSet=='+remSet);
        
        List<Date> targetedDays = new List<Date>();
        //get the defaut Business Hours Id
        Id businessHourId = [SELECT Id FROM BusinessHours WHERE IsDefault = true].Id;
        
        //check condition whether Business Hours to be included or not
        if(cboxVal == false){
            for(integer i=0;i<nCad;i++){
                Date targetDate = sDate.addDays(intervalCad*i);
                targetedDays.add(targetDate);
            }
            system.debug('targetedDays=='+targetedDays); 
        }
        else{
            for(integer i=0;i<nCad;i++){
                Datetime sD1 = sDate;
                targetedDays.add(checkBusinessDays(sD1, intervalCad*i, businessHourId).date());
            }
            system.debug('targetedDays=='+targetedDays);
        }
        
        List<Task> taskList = new List<Task>();
        
        //creating a list of tasks
        for(integer i=0; i<targetedDays.size(); i++){
            
            Task tsk = new Task();
            //tsk.Subject = 'You have a follow up' + ' ' +type;
            tsk.Subject = 'Cadence ' + (i+1) + ' of ' + nCad + ' - ' + type;
			tsk.Description = 'This is cadence step ' + (i+1) + ' out of ' + nCad + 
                  '. Task type: ' + type + 
                  '. Scheduled for: ' + String.valueOf(targetedDays[i]) + 
                  '. Created automatically by Cadence Creator.';            
            tsk.OwnerId = cadOwner;
            tsk.ActivityDate = targetedDays[i]; 
            tsk.Type = type;
            tsk.TaskSubtype = 'Task';
            tsk.Priority = 'Normal';
            tsk.Status = 'Not Started';
            
            //get the object name to check to assign recordId to whatId or  whoId
            if(objectName == 'Contact' || objectName == 'Lead'){
                tsk.WhoId = recId;
            }
            else{
                tsk.WhatId = recId;
            }
            if(cboxRem == true){
                if(remSet == 'previousDay'){
                    tsk.IsReminderSet = true;
                    Date myDate = tsk.ActivityDate.addDays(-1);
                    Time myTime = Time.newInstance( 9, 0, 0, 0 );
                    tsk.ReminderDateTime = DateTime.newInstanceGmt( myDate, myTime );
                    system.debug('tsk.ReminderDateTime=='+tsk.ReminderDateTime);
                }
                else{
                    tsk.IsReminderSet = true;
                    Date myDate = tsk.ActivityDate;
                    Time myTime = Time.newInstance( 9, 0, 0, 0 );
                    tsk.ReminderDateTime = DateTime.newInstanceGmt( myDate, myTime );
                    system.debug('tsk.ReminderDateTime=='+tsk.ReminderDateTime);
                }
            }
            
            taskList.add(tsk);
        }
        if(taskList != null && !taskList.isEmpty()){
            try{
                insert taskList; 
                system.debug('taskList=='+taskList);
            }catch(Exception e){
                system.debug(' Error :'+e.getMessage());
            }
        }
    } 
    
    //this class is to calculate if the Start date falls under business hours or not, else get the next business day
    public static Datetime checkBusinessDays(Datetime startDate, Integer interval, Id businessHourId){
        
        //If startdate is not within working days, take next working day
        startDate = BusinessHours.nextStartDate(businessHourId, startDate);
        try{
            for (Integer i = 0; i < interval; i++)
            {
                //Add 1 day
                startDate = startDate.addDays(1);
                
                //Check if new date is within working days
                if (!BusinessHours.isWithin(businessHourId, startDate))
                { 
                    //If new date is not within working days, get new working day
                    startDate = BusinessHours.nextStartDate(businessHourId, startDate);
                } 
            }
        }Catch(Exception e){
            system.debug(' Error :'+e.getMessage());
        }
        
        return startDate;
    } 
}