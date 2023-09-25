public class EmailSendUtility {
    public static final string LIMITSENDPOINT='/services/data/v58.0/limits';
    public static final string ORGURL = URL.getSalesforceBaseUrl().toExternalForm();
    
    public static void SendToAddress(String targetAddress) {
        final Messaging.SingleEmailMessage mail = composeTestMessage();
        
        mail.setToAddresses(new String[] {targetAddress});
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
        System.Debug('Email Invocations:' + Limits.getEmailInvocations() + ' of ' + Limits.getLimitEmailInvocations());

    }
    
    public static void SendToId(Id targetId) {
        final Messaging.SingleEmailMessage mail = composeTestMessage();
        
        mail.setTargetObjectId(targetId);
        mail.setTreatTargetObjectAsRecipient(true);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
        System.Debug('Email Invocations:' + Limits.getEmailInvocations() + ' of ' + Limits.getLimitEmailInvocations());
    }  
    private static Messaging.SingleEmailMessage composeTestMessage() {
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Required when sending to internal users, for simplicity we're always going to leave this off
        mail.setSaveAsActivity(false); 
        mail.setSubject('Test Email Limits');
        final string msgBody = 'Test email limits body';
        mail.setHtmlBody('<html><body>'+msgBody+'</body></html>');
        mail.setPlainTextBody(msgBody);
        return mail;
    }
    
    public static LimitsResponse getDailyLimits() {
        string msg = '';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ORGURL + LIMITSENDPOINT);
        req.setMethod('GET');
        // Shortcut to authenticate with the current running user's identity
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        HTTPResponse res = http.send(req);

        
        LimitsResponse parsedResponse = (LimitsResponse) System.JSON.deserialize(res.getBody(), LimitsResponse.class);        
        return parsedResponse;
    }
    
    // Model the JSON response - we only care about a subset of fields that are in turn nested
    public class LimitsResponse {
        public QuotaWrapper SingleEmail {get;set;}
        public QuotaWrapper MassEmail {get;set;}
        public override String toString() 
        {
            return 'Single Email Max: ' + this.SingleEmail.Max + ' Remaining: ' + this.SingleEmail.Remaining +  ' Mass Email Max:' + this.MassEmail.Max + ' Remaining ' + this.MassEmail.Remaining;
        }                                       
    }
    
    public class QuotaWrapper {
        public integer Max {get; set;}
        public integer Remaining {get; set;}
    }
    
    /**
{
  "ActiveScratchOrgs" : {
    "Max" : 3,
    "Remaining" : 3
  },
  "AnalyticsExternalDataSizeMB" : {
    "Max" : 40960,
    "Remaining" : 40960
  },
  "ConcurrentAsyncGetReportInstances" : {
    "Max" : 200,
    "Remaining" : 200
  },
  "ConcurrentEinsteinDataInsightsStoryCreation" : {
    "Max" : 5,
    "Remaining" : 5
  },
  "ConcurrentEinsteinDiscoveryStoryCreation" : {
    "Max" : 2,
    "Remaining" : 2
  },
  "ConcurrentSyncReportRuns" : {
    "Max" : 20,
    "Remaining" : 20
  },
  "DailyAnalyticsDataflowJobExecutions" : {
    "Max" : 60,
    "Remaining" : 60
  },
  "DailyAnalyticsUploadedFilesSizeMB" : {
    "Max" : 51200,
    "Remaining" : 51200
  },
  "DailyApiRequests" : {
    "Max" : 15000,
    "Remaining" : 14861
  },
  "DailyAsyncApexExecutions" : {
    "Max" : 250000,
    "Remaining" : 250000
  },
  "DailyAsyncApexTests" : {
    "Max" : 500,
    "Remaining" : 500
  },
  "DailyBulkApiBatches" : {
    "Max" : 15000,
    "Remaining" : 15000
  },
  "DailyBulkV2QueryFileStorageMB" : {
    "Max" : 976562,
    "Remaining" : 976562
  },
  "DailyBulkV2QueryJobs" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyDeliveredPlatformEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyDurableGenericStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyDurableStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyEinsteinDataInsightsStoryCreation" : {
    "Max" : 1000,
    "Remaining" : 1000
  },
  "DailyEinsteinDiscoveryOptimizationJobRuns" : {
    "Max" : 25,
    "Remaining" : 25
  },
  "DailyEinsteinDiscoveryPredictAPICalls" : {
    "Max" : 50000,
    "Remaining" : 50000
  },
  "DailyEinsteinDiscoveryPredictionsByCDC" : {
    "Max" : 500000,
    "Remaining" : 500000
  },
  "DailyEinsteinDiscoveryStoryCreation" : {
    "Max" : 100,
    "Remaining" : 100
  },
  "DailyFunctionsApiCallLimit" : {
    "Max" : 50000,
    "Remaining" : 50000
  },
  "DailyGenericStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyScratchOrgs" : {
    "Max" : 6,
    "Remaining" : 6
  },
  "DailyStandardVolumePlatformEvents" : {
    "Max" : 10000,
    "Remaining" : 10000
  },
  "DailyStreamingApiEvents" : {
    "Max" : 10000,
    "Remaining" : 9986
  },
  "DailyWorkflowEmails" : {
    "Max" : 1905,
    "Remaining" : 1905
  },
  "DataStorageMB" : {
    "Max" : 5,
    "Remaining" : 5
  },
  "DurableStreamingApiConcurrentClients" : {
    "Max" : 20,
    "Remaining" : 20
  },
  "FileStorageMB" : {
    "Max" : 20,
    "Remaining" : 20
  },
  "HourlyAsyncReportRuns" : {
    "Max" : 1200,
    "Remaining" : 1200
  },
  "HourlyDashboardRefreshes" : {
    "Max" : 200,
    "Remaining" : 200
  },
  "HourlyDashboardResults" : {
    "Max" : 5000,
    "Remaining" : 5000
  },
  "HourlyDashboardStatuses" : {
    "Max" : 999999999,
    "Remaining" : 999999999
  },
  "HourlyLongTermIdMapping" : {
    "Max" : 100000,
    "Remaining" : 99999
  },
  "HourlyManagedContentPublicRequests" : {
    "Max" : 50000,
    "Remaining" : 50000
  },
  "HourlyODataCallout" : {
    "Max" : 1000,
    "Remaining" : 996
  },
  "HourlyPublishedPlatformEvents" : {
    "Max" : 50000,
    "Remaining" : 50000
  },
  "HourlyPublishedStandardVolumePlatformEvents" : {
    "Max" : 1000,
    "Remaining" : 1000
  },
  "HourlyShortTermIdMapping" : {
    "Max" : 100000,
    "Remaining" : 100000
  },
  "HourlySyncReportRuns" : {
    "Max" : 500,
    "Remaining" : 500
  },
  "HourlyTimeBasedWorkflow" : {
    "Max" : 1000,
    "Remaining" : 1000
  },
  "MassEmail" : {
    "Max" : 10,
    "Remaining" : 10
  },
  "MonthlyEinsteinDiscoveryStoryCreation" : {
    "Max" : 500,
    "Remaining" : 500
  },
  "MonthlyPlatformEventsUsageEntitlement" : {
    "Max" : 0,
    "Remaining" : 0
  },
  "Package2VersionCreates" : {
    "Max" : 6,
    "Remaining" : 6
  },
  "Package2VersionCreatesWithoutValidation" : {
    "Max" : 500,
    "Remaining" : 500
  },
  "PermissionSets" : {
    "Max" : 1500,
    "Remaining" : 1499,
    "CreateCustom" : {
      "Max" : 1000,
      "Remaining" : 999
    }
  },
  "PrivateConnectOutboundCalloutHourlyLimitMB" : {
    "Max" : 0,
    "Remaining" : 0
  },
  "PublishCallbackUsageInApex" : {
    "Max" : 5242880,
    "Remaining" : 5242880
  },
  "SingleEmail" : {
    "Max" : 15,
    "Remaining" : 12
  },
  "StreamingApiConcurrentClients" : {
    "Max" : 20,
    "Remaining" : 20
  }
}    **/
}