import { worker, ThreadWorkerGlobalScope, MessageEvents, ErrorEvent } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (e: MessageEvents) => {
  let data = e.data as Record<string, Object>;
  hilog.info(0x0000, 'MyWorker', 'Worker received message: %{public}s', JSON.stringify(data));
  
  if (data && data.type === 'compute') {
    // 模拟耗时任务
    let sum = 0;
    let limit = data.value as number;
    for (let i = 1; i <= limit; i++) {
      sum += i;
    }
    hilog.info(0x0000, 'MyWorker', 'Worker computation complete. Result: %{public}d', sum);
    
    // 发送结果回主线程
    let resultData: Record<string, Object> = { 'type': 'result', 'value': sum };
    workerPort.postMessage(resultData);
  } else {
    let replyData: Record<string, Object> = { 'type': 'reply', 'value': 'Hello from worker' };
    workerPort.postMessage(replyData);
  }
}

workerPort.onerror = (e: ErrorEvent) => {
  hilog.error(0x0000, 'MyWorker', 'Worker error: %{public}s', e.message);
}
