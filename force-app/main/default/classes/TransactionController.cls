public class TransactionController {
   @AuraEnabled
   public static List<String> fetchTransactions(String accountNumber){
    try {
        return makeCallout(accountNumber);
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    } 
   }

   public static List<String> makeCallout(String accountNumber) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.example.com/transactions?accountNumber=' + accountNumber);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Process the response
            return (List<String>) responseMap.get('transactions');
            // Parse and return the transactions
        } else {
            throw new AuraHandledException('Error fetching transactions: ' + response.getStatus());
        }
    }
}