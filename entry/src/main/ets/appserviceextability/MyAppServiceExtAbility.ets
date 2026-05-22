import { AppServiceExtensionAbility, Want } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'MyAppServiceExtAbility';

class GlobalState {
  status: string = 'idle';
  lastSyncTime: string = 'never';
  downloadProgress: string = '0%';
}

// 自定义一个 RemoteObject，处理来自主 UI 进程的 IPC 通信请求
class ServiceRemoteObject extends rpc.RemoteObject {
  // 模拟的全局核心状态
  private globalState: GlobalState = new GlobalState();

  private timerId: number = -1;

  constructor(descriptor: string) {
    super(descriptor);
  }

  // 当主 UI 发来 rpc.MessageSequence 时，会触发此方法
  onRemoteMessageRequest(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence, option: rpc.MessageOption): boolean | Promise<boolean> {
    hilog.info(0x0000, TAG, `Received request code: %{public}d`, code);

    // 根据自定义的操作码 (code) 执行对应的后台任务
    switch (code) {
      case 1: // 1: 音乐播放
        this.globalState.status = 'playing_music';
        hilog.info(0x0000, TAG, '后台任务启动: 正在缓冲和播放音乐...');
        // 此处应调用 @ohos.multimedia.media 等 API，为了示例仅使用日志和状态模拟
        reply.writeString('后台服务反馈：音乐播放已启动 (状态更新为 playing_music)');
        return true;

      case 2: // 2: 大文件下载
        this.globalState.status = 'downloading';
        hilog.info(0x0000, TAG, '后台任务启动: 开始大文件下载...');
        // 模拟后台下载进度
        let progress = 0;
        this.timerId = setInterval(() => {
          progress += 20;
          this.globalState.downloadProgress = `${progress}%`;
          hilog.info(0x0000, TAG, `后台下载中... 进度: ${progress}%`);
          if (progress >= 100) {
            clearInterval(this.timerId);
            this.globalState.status = 'idle';
            hilog.info(0x0000, TAG, '后台下载完成！');
          }
        }, 2000);
        reply.writeString('后台服务反馈：大文件下载已开启，即使杀掉 UI 进程，日志中仍可见下载进度');
        return true;

      case 3: // 3: 定时数据同步
        this.globalState.status = 'syncing';
        hilog.info(0x0000, TAG, '后台任务启动: 开始与服务器同步数据...');
        setTimeout(() => {
          this.globalState.lastSyncTime = new Date().toLocaleTimeString();
          this.globalState.status = 'idle';
          hilog.info(0x0000, TAG, '后台同步完成，最后同步时间: ' + this.globalState.lastSyncTime);
        }, 3000);
        reply.writeString('后台服务反馈：已触发数据同步任务，预计 3 秒后完成');
        return true;

      case 4: // 4: 获取全局状态
        const stateStr = JSON.stringify(this.globalState);
        hilog.info(0x0000, TAG, 'UI 获取全局状态: %{public}s', stateStr);
        reply.writeString(stateStr);
        return true;

      default:
        return super.onRemoteMessageRequest(code, data, reply, option);
    }
  }
}

export default class MyAppServiceExtAbility extends AppServiceExtensionAbility {
  onCreate(want: Want): void {
    hilog.info(0x0000, TAG, 'onCreate: AppServiceExtensionAbility created.');
  }

  onRequest(want: Want, startId: number): void {
    hilog.info(0x0000, TAG, `onRequest: startId = ${startId}`);
  }

  onConnect(want: Want): rpc.RemoteObject {
    hilog.info(0x0000, TAG, 'onConnect: UI is binding to the service.');
    // 返回我们的自定义 IPC 对象给调用方
    return new ServiceRemoteObject('MyServiceExtAbility');
  }

  onDisconnect(want: Want): void {
    hilog.info(0x0000, TAG, 'onDisconnect: UI has disconnected from the service.');
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'onDestroy: AppServiceExtensionAbility destroyed.');
  }
}
