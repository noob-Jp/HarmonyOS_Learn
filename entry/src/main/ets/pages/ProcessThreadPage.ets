import { router } from '@kit.ArkUI';
import { taskpool, ArkTSUtils } from '@kit.ArkTS';

// ============================================================
//  进程模型 & 线程模型 & Native 子进程页
//  知识点：
//  - 进程模型：应用进程结构（main process + extension process）
//  - 主线程：UI 渲染、Ability 生命周期回调
//  - TaskPool：任务池（推荐），自动线程管理
//  - Worker：工作线程，长驻线程，手动管理
//  - 进程间通信（IPC）
//  - Native 子进程（NativeChildProcess）
// ============================================================

@Concurrent
function heavyCompute(n: number): number {
  let sum = 0;
  for (let i = 1; i <= n; i++) {
    sum += i;
  }
  return sum;
}

@Sendable
class SharedData {
  count: number = 0;
  lock: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();

  async safeIncrement() {
    try {
      await this.lock.lockAsync(() => {
        let temp = this.count;
        for(let i=0; i<100; i++){} // 模拟一些耗时操作，增加竞争概率
        this.count = temp + 1;
      });
    } catch (err) {
      console.error('Lock error', err);
    }
  }

  unsafeIncrement() {
    let temp = this.count;
    for(let i=0; i<100; i++){} // 模拟一些耗时操作，增加竞争概率
    this.count = temp + 1;
  }
}

@Concurrent
async function runSafeTasks(data: SharedData, times: number): Promise<void> {
  for (let i = 0; i < times; i++) {
    await data.safeIncrement();
  }
}

@Concurrent
function runUnsafeTasks(data: SharedData, times: number): void {
  for (let i = 0; i < times; i++) {
    data.unsafeIncrement();
  }
}

interface NativeItem {
  title: string;
  color: string;
  code: string;
}

@Entry
@Component
struct ProcessThreadPage {
  @State taskResult: string = '点击按钮运行任务';
  @State taskRunning: boolean = false;
  @State elapsedMs: number = 0;
  @State selectedSection: number = 0;
  @State asyncResult: string = '等待测试...';
  @State isTestingLock: boolean = false;

  private sections: string[] = ['进程模型', 'TaskPool', 'Worker', 'Native子进程', 'AsyncLock'];

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('进程 & 线程模型').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('TaskPool · Worker · IPC · Native子进程').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('🔄').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#10B981')
      .letterSpacing(0.5).width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  TabBar() {
    Scroll() {
      Row() {
        ForEach(this.sections, (section: string, index: number) => {
          Text(section)
            .fontSize(11)
            .fontColor(this.selectedSection === index ? '#10B981' : '#64748B')
            .fontWeight(this.selectedSection === index ? FontWeight.Bold : FontWeight.Normal)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.selectedSection === index ? 'rgba(16,185,129,0.15)' : 'transparent')
            .borderRadius(8)
            .border({ width: this.selectedSection === index ? 1 : 0, color: 'rgba(16,185,129,0.4)' })
            .margin({ right: 8 })
            .onClick(() => { this.selectedSection = index; })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .width('100%')
  }

  @Builder
  ProcessModelSection() {
    Column() {
      Text('HarmonyOS 应用进程结构')
        .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 12 })

      // 进程结构图
      Column() {
        // 主进程
        Column() {
          Text('主进程（Main Process）')
            .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#10B981').margin({ bottom: 8 })
          Row() {
            ForEach(['主线程(UI)\nonForeground\nonBackground', 'Ability生命周期\n回调执行', '渲染线程\n(RenderThread)', '异步IO\n子线程'], (item: string) => {
              Column() {
                Text(item).fontSize(9).fontColor('#94A3B8').textAlign(TextAlign.Center)
              }
              .layoutWeight(1).padding(6)
              .backgroundColor('rgba(16,185,129,0.1)').borderRadius(6)
              .border({ width: 1, color: 'rgba(16,185,129,0.25)' })
              .margin({ right: 4 })
            })
          }
          .width('100%')
        }
        .width('100%').padding(12)
        .backgroundColor('rgba(16,185,129,0.08)').borderRadius(10)
        .border({ width: 1, color: 'rgba(16,185,129,0.3)' })
        .alignItems(HorizontalAlign.Start).margin({ bottom: 8 })

        Text('↕ 独立进程（系统隔离）').fontSize(10).fontColor('#64748B').margin({ bottom: 8 })

        // Extension 进程
        Column() {
          Text('Extension 进程（Extension Process）')
            .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#6366F1').margin({ bottom: 8 })
          Row() {
            ForEach(['ServiceExtensionAbility\n（后台服务）', 'AppServiceExtensionAbility\n（应用服务）'], (item: string) => {
              Column() {
                Text(item).fontSize(9).fontColor('#94A3B8').textAlign(TextAlign.Center)
              }
              .layoutWeight(1).padding(6)
              .backgroundColor('rgba(99,102,241,0.1)').borderRadius(6)
              .border({ width: 1, color: 'rgba(99,102,241,0.25)' })
              .margin({ right: 4 })
            })
          }
          .width('100%')
        }
        .width('100%').padding(12)
        .backgroundColor('rgba(99,102,241,0.08)').borderRadius(10)
        .border({ width: 1, color: 'rgba(99,102,241,0.3)' })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%').padding(14)
      .backgroundColor('#FFFFFF').borderRadius(12)
      .alignItems(HorizontalAlign.Start).margin({ bottom: 14 })

      // 重要规则
      Column() {
        Text('⚠️ 重要规则')
          .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#FBBF24').margin({ bottom: 8 })
        ForEach([
          '主线程禁止执行耗时操作（>5ms），否则导致 UI 卡顿（ANR）',
          '同一 UIAbility 的多个页面运行在同一进程和线程',
          '不同应用的 Extension 在各自独立进程中运行',
          '进程间通过 IPC（Binder）通信，自动序列化'
        ], (rule: string) => {
          Row() {
            Text('•').fontSize(14).fontColor('#FBBF24').margin({ right: 8 })
            Text(rule).fontSize(11).fontColor('#94A3B8').layoutWeight(1).lineHeight(16)
          }
          .margin({ bottom: 6 })
        })
      }
      .width('100%').padding(14)
      .backgroundColor('rgba(251,191,36,0.07)').borderRadius(12)
      .border({ width: 1, color: 'rgba(251,191,36,0.2)' })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  TaskPoolSection() {
    Column() {
      Text('TaskPool 是 HarmonyOS 推荐的多线程方案。系统自动管理线程数量，开发者只需定义并发函数（@Concurrent 装饰器），通过 taskpool.execute 提交任务。')
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 14 })

      // 特性对比
      Row() {
        Column() {
          Text('✅ TaskPool 优势').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#10B981').margin({ bottom: 8 })
          ForEach(['自动线程管理\n（池化复用）', '支持任务优先级', '任务可取消\n（cancel）', '低内存开销', 'API 简洁易用'], (item: string) => {
            Text(`• ${item}`).fontSize(10).fontColor('#94A3B8').margin({ bottom: 4 })
          })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Column() {
          Text('⚠️ 注意事项').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#FBBF24').margin({ bottom: 8 })
          ForEach(['@Concurrent 函数\n不能捕获外部变量', '参数需可序列化\n（无函数/Class）', '不适合长驻任务\n（用 Worker 替代）'], (item: string) => {
            Text(`• ${item}`).fontSize(10).fontColor('#94A3B8').margin({ bottom: 4 })
          })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)
      }
      .margin({ bottom: 14 })

      // 交互演示
      Column() {
        Text('🎮 交互演示：TaskPool 计算 1+2+...+10,000,000')
          .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

        Column() {
          Text('// @Concurrent 装饰的函数在子线程执行\n@Concurrent\nfunction heavyCompute(n: number): number {\n  let sum = 0;\n  for (let i = 1; i <= n; i++) sum += i;\n  return sum;\n}\n\n// 在主线程中提交任务\nconst task = new taskpool.Task(heavyCompute, 10_000_000);\nconst result = await taskpool.execute(task);')
            .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
        }
        .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
        .margin({ bottom: 12 })

        Row() {
          Column() {
            Text('结果：')
              .fontSize(11).fontColor('#64748B')
            Text(this.taskResult)
              .fontSize(13).fontColor(this.taskRunning ? '#FBBF24' : '#34D399')
              .fontWeight(FontWeight.Bold)
            if (this.elapsedMs > 0) {
              Text(`耗时: ${this.elapsedMs}ms`)
                .fontSize(10).fontColor('#64748B')
            }
          }
          .alignItems(HorizontalAlign.Start).layoutWeight(1)

          Button(this.taskRunning ? '⏳ 运行中...' : '▶️ 运行')
            .fontSize(13).height(40)
            .backgroundColor(this.taskRunning ? 'rgba(16,185,129,0.1)' : 'rgba(16,185,129,0.2)')
            .fontColor(this.taskRunning ? '#64748B' : '#10B981')
            .borderRadius(10)
            .border({ width: 1, color: this.taskRunning ? '#64748B' : '#10B981' })
            .enabled(!this.taskRunning)
            .onClick(async () => {
              this.taskRunning = true;
              this.taskResult = '计算中...';
              const start = Date.now();
              try {
                const task = new taskpool.Task(heavyCompute, 10000000);
                const result = await taskpool.execute(task) as number;
                this.elapsedMs = Date.now() - start;
                this.taskResult = `结果: ${result.toLocaleString()}`;
              } catch (e) {
                this.taskResult = `错误: ${e}`;
              } finally {
                this.taskRunning = false;
              }
            })
        }
        .width('100%')
      }
      .width('100%').padding(14)
      .backgroundColor('rgba(16,185,129,0.07)').borderRadius(12)
      .border({ width: 1, color: 'rgba(16,185,129,0.2)' })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  WorkerSection() {
    Column() {
      Text('Worker 适用于需要长驻后台的复杂任务，工作线程独立管理，可双向通信。')
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 14 })

      // TaskPool vs Worker 对比表
      Text('TaskPool vs Worker 对比：')
        .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

      Column() {
        Row() {
          Text('特性').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#64748B').width(100)
          Text('TaskPool').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#10B981').layoutWeight(1)
          Text('Worker').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#6366F1').layoutWeight(1)
        }
        .padding({ bottom: 8 })
        Divider().color('rgba(0,0,0,0.08)')

        ForEach([
          ['任务类型', '短时并发任务', '长驻后台任务'],
          ['线程管理', '系统自动管理', '手动创建销毁'],
          ['任务取消', '支持 cancel', '需手动控制'],
          ['内存开销', '低（共享池）', '高（独立线程）'],
          ['通信方式', '返回 Promise', 'postMessage 双向'],
          ['装饰器', '@Concurrent', '无需装饰'],
          ['最大实例', '系统限制', '64个/应用'],
        ], (row: string[]) => {
          Row() {
            Text(row[0]).fontSize(11).fontColor('#94A3B8').width(100)
            Text(row[1]).fontSize(11).fontColor('#10B981').layoutWeight(1)
            Text(row[2]).fontSize(11).fontColor('#6366F1').layoutWeight(1)
          }
          .padding({ top: 6, bottom: 6 })
          Divider().color('#FFFFFF')
        })
      }
      .width('100%').padding(12)
      .backgroundColor('#FFFFFF').borderRadius(10)
      .margin({ bottom: 14 })

      // Worker 代码示例
      Text('Worker 使用示例：')
        .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 8 })
      Column() {
        Text('// 主线程（创建 Worker）\nconst worker = new worker.ThreadWorker("workers/MyWorker");\n\n// 接收 Worker 消息\nworker.onmessage = (event) => {\n  console.log("Worker 结果:", event.data);\n  worker.terminate(); // 任务完成后销毁\n};\n\n// 向 Worker 发送任务\nworker.postMessage({ taskType: "compress", data: rawData });\n\n// Worker 线程（MyWorker.ets）\nworkerPort.onmessage = (event) => {\n  const result = processData(event.data);\n  workerPort.postMessage(result);\n};')
          .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
      }
      .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
    }
    .width('100%').padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  NativeSection() {
    Column() {
      Text('Native 子进程（NativeChildProcess）允许应用创建独立的 Native 进程来执行 C/C++ 任务，进程间通过 IPC 通信。适用于计算密集型、需要系统级隔离的场景。')
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 14 })

      ForEach([
        { title: '创建子进程', color: '#10B981', code: '// ArkTS 侧\nimport { nativeChildProcess } from "@kit.AbilityKit";\nconst process = await nativeChildProcess.create(\n  "libmynative.so",  // Native 库\n  { timeout: 5000 }\n);' },
        { title: 'IPC 通信', color: '#6366F1', code: '// 通过 IPC 发送数据到子进程\nprocess.send(Uint8Array.from([1, 2, 3]));\n\n// 接收子进程结果\nprocess.on("message", (data: ArrayBuffer) => {\n  const result = new Uint8Array(data);\n  console.log("子进程结果:", result);\n});' },
        { title: '适用场景', color: '#FBBF24', code: '• 图像/视频处理（FFmpeg 等 C 库）\n• 机器学习推理（TFLite 等）\n• 加密计算（OpenSSL 等）\n• 需要独立内存空间的高风险操作' },
      ], (item: NativeItem) => {
        Column() {
          Text(item.title)
            .fontSize(12).fontWeight(FontWeight.Bold).fontColor(item.color).margin({ bottom: 8 })
          Column() {
            Text(item.code)
              .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
          }
          .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
        }
        .width('100%').padding(14)
        .backgroundColor(`${item.color}0D`).borderRadius(12)
        .border({ width: 1, color: `${item.color}30` })
        .alignItems(HorizontalAlign.Start).margin({ bottom: 10 })
      })
    }
    .width('100%').padding({ left: 16, right: 16, bottom: 32 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  AsyncLockSection() {
    Column() {
      Text('ArkTS 异步锁（AsyncLock）支持在并发任务间保护共享资源（如 @Sendable 对象），防止数据竞争并避免死锁。')
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 14 })

      ForEach([
        { title: '实例化与全局请求', color: '#10B981', code: '// 导入 ArkTSUtils\nimport { ArkTSUtils } from "@kit.ArkTS";\n\n// 方式一：实例化局部锁\nlet lock = new ArkTSUtils.locks.AsyncLock();\n\n// 方式二：获取全局共享锁\nlet sharedLock = ArkTSUtils.locks.AsyncLock.request("myLock");' },
        { title: '异步加锁保护', color: '#6366F1', code: '@Sendable\nclass SharedData {\n  count: number = 0;\n  lock: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();\n\n  async increment() {\n    // lockAsync 获取锁，回调执行完自动释放\n    await this.lock.lockAsync(() => {\n      this.count++;\n    });\n  }\n}' },
        { title: '适用场景', color: '#FBBF24', code: '• 多线程（TaskPool/Worker）并发读写 @Sendable 共享对象\n• 必须配合 async/await 使用（非阻塞锁）\n• 自动释放，避免死锁' },
      ], (item: NativeItem) => {
        Column() {
          Text(item.title)
            .fontSize(12).fontWeight(FontWeight.Bold).fontColor(item.color).margin({ bottom: 8 })
          Column() {
            Text(item.code)
              .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
          }
          .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
        }
        .width('100%').padding(14)
        .backgroundColor(`${item.color}0D`).borderRadius(12)
        .border({ width: 1, color: `${item.color}30` })
        .alignItems(HorizontalAlign.Start).margin({ bottom: 10 })
      })

      // 实战测试区域
      Column() {
        Text('🛠️ 交互测试：并发 10 个 Task，每个执行 1000 次加法')
          .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ bottom: 12 })

        Row() {
          Button('无锁并发测试')
            .fontSize(12)
            .backgroundColor('#EF4444')
            .onClick(async () => {
              if (this.isTestingLock) return;
              this.isTestingLock = true;
              this.asyncResult = '无锁测试执行中...';
              let sharedData = new SharedData();
              let promises: Promise<Object>[] = [];
              for (let i = 0; i < 10; i++) {
                let task = new taskpool.Task(runUnsafeTasks, sharedData, 1000);
                promises.push(taskpool.execute(task));
              }
              await Promise.all(promises);
              this.asyncResult = '无锁执行结束：' + sharedData.count + ' (预期: 10000)';
              this.isTestingLock = false;
            })

          Button('带锁并发测试')
            .fontSize(12)
            .backgroundColor('#10B981')
            .onClick(async () => {
              if (this.isTestingLock) return;
              this.isTestingLock = true;
              this.asyncResult = '带锁测试执行中...';
              let sharedData = new SharedData();
              let promises: Promise<Object>[] = [];
              for (let i = 0; i < 10; i++) {
                let task = new taskpool.Task(runSafeTasks, sharedData, 1000);
                promises.push(taskpool.execute(task));
              }
              await Promise.all(promises);
              this.asyncResult = '带锁执行结束：' + sharedData.count + ' (精准防并发)';
              this.isTestingLock = false;
            })
        }
        .width('100%').justifyContent(FlexAlign.SpaceAround).margin({ bottom: 16 })

        Text(this.asyncResult)
          .fontSize(14)
          .fontColor(this.asyncResult.includes('精准') ? '#10B981' : (this.asyncResult.includes('无锁') && this.asyncResult.includes('预期') ? '#EF4444' : '#64748B'))
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(10)
          .backgroundColor('#F8FAFC')
          .borderRadius(8)
      }
      .width('100%').padding(14).backgroundColor('#FFFFFF').borderRadius(12).border({ width: 1, color: 'rgba(0,0,0,0.05)' }).margin({ bottom: 16 })

    }
    .width('100%').padding({ left: 16, right: 16, bottom: 32 }).alignItems(HorizontalAlign.Start)
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()
        this.SectionTitle('📂 选择知识模块')
        this.TabBar()
        Blank().height(4)

        if (this.selectedSection === 0) {
          this.SectionTitle('🏭 进程模型')
          this.ProcessModelSection()
        } else if (this.selectedSection === 1) {
          this.SectionTitle('⚡ TaskPool 任务池')
          this.TaskPoolSection()
        } else if (this.selectedSection === 2) {
          this.SectionTitle('🧵 Worker 工作线程')
          this.WorkerSection()
        } else if (this.selectedSection === 3) {
          this.SectionTitle('⚙️ Native 子进程')
          this.NativeSection()
        } else {
          this.SectionTitle('🔒 并发控制 (AsyncLock)')
          this.AsyncLockSection()
        }
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
