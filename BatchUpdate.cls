public class BatchUpdate implements Database.batchable<Sobject>,Database.Stateful,Schedulable{
    public integer count = 0;
    public Database.QueryLocator start(Database.BatchableContext bc){
        String str ='select id,Name,Mark_for_Delete__c from Trainee__c WHERE Is_Registration_Completed__c =False AND createddate !=LAST_N_DAYS:2';
        return Database.getQueryLocator (str);
    }
    
    public void execute(Database.BatchableContext bc, List<Trainee__c> traineeList){
        for(Trainee__c trainee :traineeList){
            trainee.Mark_for_Delete__c= 'YES';
        }
        try{
            
            Database.SaveResult[] saveResult=Database.update(traineeList,false);
            for(Database.SaveResult sr : saveResult){
                if(sr.issuccess()){
                    count++;
                }
            }  
        }
        
        catch(exception e){
            system.debug('update failed');
        }
        
    }
    
    public void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(new BatchUpdate());       
    }
    
    public void finish(Database.BatchableContext bc){
        system.debug('count'+ count);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'ranjananoop4@gmail.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job is done');
        mail.setPlainTextBody('Total ' + count +' students are marked to be deleted');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}