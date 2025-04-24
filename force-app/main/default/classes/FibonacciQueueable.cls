public with sharing class FibonacciQueueable implements Queueable {
   private static Integer param1;
   private static Integer param2;
   FibonacciQueueable(Integer a, Integer b){
    param1 = a;
    param2 = b;
   }

    public static void calculateFibonacciTo(Integer depth){
        AsyncOptions asyncOptions = new AsyncOptions();

        asyncOptions.MaximumQueueableStackDepth = depth;
        System.enqueueJob(new FibonacciQueueable(null,null),asyncOptions);
    }

    public static void execute(QueueableContext context) {
        Integer newParam;
        Integer currentDepth = AsyncInfo.getCurrentQueueableStackDepth();
        if(currentDepth < 3) {

        } else {
            newParam = param1 + param2;
        }

        if(currentDepth == AsyncInfo.getMaximumQueueableStackDepth()) {
            System.debug('Fibonacci Queueable(' + newParam + ')');
        } else {
            System.enqueueJob(new FibonacciQueueable(newParam,param2));
        }
    }
}