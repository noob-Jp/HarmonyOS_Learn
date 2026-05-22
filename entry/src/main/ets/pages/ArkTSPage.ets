import { router } from '@kit.ArkUI';
import { taskpool } from '@kit.ArkTS';
import collections from '@arkts.collections';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'ArkTSPage';

// ============================================================
//  并发任务函数 - 必须定义在顶层并使用 @Concurrent 装饰器
// ============================================================
// ArkTS 的 @Concurrent 函数内部不能使用外部变量/外部函数，甚至不能递归调用自己
// 因此我们必须使用完全内部独立的迭代逻辑来保证它是个纯粹的闭包
@Concurrent
function heavyCompute(n: number): number {
  if (n <= 1) return n;
  let a = 0;
  let b = 1;
  for (let i = 2; i <= n; i++) {
    let temp = a + b;
    a = b;
    b = temp;
  }
  return b;
}

@Concurrent
function processArray(arr: number[]): number {
  // 模拟数组处理任务（排序 + 求和）
  const sorted = [...arr].sort((a, b) => a - b);
  return sorted.reduce((sum, v) => sum + v, 0);
}

// ============================================================
//  类库 Demo 数据
// ============================================================
interface LibItem {
  icon: string;
  name: string;
  pkg: string;
  color: string;
  desc: string;
  example: string;
}

const LIB_ITEMS: LibItem[] = [
  {
    icon: '🗃️',
    name: 'collections.Array',
    pkg: '@arkts.collections',
    color: '#6366F1',
    desc: '线程安全的动态数组，可跨 TaskPool/Worker 线程共享内存（无需拷贝）。支持 push/pop/splice/sort 等常用操作。',
    example: "import { collections } from '@arkts.collections';\nconst arr = new collections.Array<number>();\narr.push(10, 30, 20);\narr.sort((a, b) => a - b); // [10,20,30]"
  },
  {
    icon: '📖',
    name: 'collections.Map',
    pkg: '@arkts.collections',
    color: '#8B5CF6',
    desc: '线程安全的 HashMap，支持在并发环境中共享键值对数据。get/set/has/delete 操作均安全。',
    example: "const map = new collections.Map<string, number>();\nmap.set('apple', 3);\nmap.set('banana', 5);\nmap.get('apple'); // 3\nmap.size; // 2"
  },
  {
    icon: '🔷',
    name: 'collections.Set',
    pkg: '@arkts.collections',
    color: '#EC4899',
    desc: '线程安全的集合类型，自动去重。常用于多线程共享的索引、除重列表等场景。',
    example: "const set = new collections.Set<string>();\nset.add('a'); set.add('b'); set.add('a');\nset.size; // 2（自动去重）\nset.has('b'); // true"
  },
  {
    icon: '🔄',
    name: '浮点数精度问题',
    pkg: 'number (IEEE 754)',
    color: '#F59E0B',
    desc: '原生 number 基于 IEEE 754 浮点，存在精度丢失问题。0.1 + 0.2 ≠ 0.3。金融计算需要引入第三方库解决。',
    example: "console.log(0.1 + 0.2);  // 0.30000000000000004\n// 解决方案：把小数先扩大为整数进行运算\nconst result = (0.1 * 10 + 0.2 * 10) / 10; // 0.3"
  },
  {
    icon: '🔗',
    name: 'URL 解析',
    pkg: '@ohos.url',
    color: '#10B981',
    desc: 'URL 和 URI 的解析、组装、参数提取工具。可以方便地获取 origin、路径段、query 参数等。',
    example: "import { url } from '@kit.ArkTS';\nconst u = new url.URL('https://example.com?id=1');\nu.searchParams.get('id'); // '1'\nu.hostname; // 'example.com'"
  },
  {
    icon: '🔧',
    name: 'util 工具函数',
    pkg: '@kit.ArkTS (util)',
    color: '#06B6D4',
    desc: '提供类型判断 (types.isXxx)、TextEncoder/Decoder 字节编解码、Base64 转换、printf 格式化等实用工具函数。',
    example: "import { util } from '@kit.ArkTS';\nconst enc = new util.TextEncoder();\nconst buf = enc.encodeInto('Hello HarmonyOS');\nconst dec = new util.TextDecoder();\ndec.decodeToString(buf); // 'Hello HarmonyOS'"
  }
];

// ============================================================
//  并发能力展示数据
// ============================================================
interface ConcurrencyModel {
  icon: string;
  name: string;
  color: string;
  tag: string;
  when: string;
  limit: string;
}

const CONCURRENCY_MODELS: ConcurrencyModel[] = [
  {
    icon: '🏊',
    name: 'TaskPool',
    color: '#6366F1',
    tag: '推荐',
    when: '短期、独立、CPU 密集型任务（图像处理、加密计算、数据压缩）',
    limit: '任务执行时间不超过 3 分钟；线程由系统自动管理，不能持久化'
  },
  {
    icon: '👷',
    name: 'Worker',
    color: '#F59E0B',
    tag: '长期任务',
    when: '需要长期持有状态的后台工作线程（持续监听、自定义消息循环）',
    limit: '需手动管理生命周期；同一进程最多 64 个 Worker；创建开销较大'
  },
  {
    icon: '🔒',
    name: 'AsyncLock',
    color: '#10B981',
    tag: '线程安全',
    when: '多个并发任务需要访问同一共享资源（全局计数器、缓存池）',
    limit: '需要配合 async/await 使用；嵌套使用需注意死锁风险'
  }
];

@Entry
@Component
struct ArkTSPage {
  @State currentTab: number = 0;

  // TaskPool 演示状态
  @State taskStatus: string = '点击按钮开始执行任务';
  @State taskResult: string = '';
  @State taskRunning: boolean = false;
  @State taskTimeMs: number = 0;

  // Collections 演示状态
  @State arrDemoStr: string = '[]';
  @State mapDemoStr: string = '{}';
  @State setDemoStr: string = '[]';
  
  // 用于持有 collections 对象，因为 collections 对象不支持被 @State 直接代理观察，所以用普通变量
  private myArkArray: collections.Array<number> = new collections.Array<number>();
  private myArkMap: collections.Map<string, number> = new collections.Map<string, number>();
  private myArkSet: collections.Set<string> = new collections.Set<string>();

  // 类库演示状态
  @State selectedLib: number = 0;
  @State libDemoResult: string = '';

  // 浮点数演示
  @State floatA: string = '0.1';
  @State floatB: string = '0.2';
  @State floatResult: string = '';

  // URL 解析演示
  @State urlInput: string = 'https://developer.huawei.com/consumer/cn?id=123&tab=guide';
  @State urlResult: string = '';

  // TextEncoder 演示
  @State encodeInput: string = 'Hello HarmonyOS 鸿蒙';
  @State encodeResult: string = '';

  @Builder
  PageHeader() {
    Row() {
      Text('←')
        .fontSize(20).fontColor('#94A3B8').margin({ right: 12 })
        .onClick(() => router.back())
      Column() {
        Text('ArkTS 类库 & 并发').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('标准库使用 · TaskPool · Worker · AsyncLock').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('⚡').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  // ============================================================
  //  Tab 1 - 类库的使用
  // ============================================================
  @Builder
  LibraryTab() {
    Scroll() {
      Column() {
        Text('ArkTS 提供了一套符合自身语法约束的标准类库，与浏览器 JS/Node.js 的全局 API 有所不同。以下是最常用的几个模块：')
          .fontSize(12).fontColor('#64748B').lineHeight(18).margin({ bottom: 16 })

        // 类库列表
        ForEach(LIB_ITEMS, (lib: LibItem, idx: number) => {
          Column() {
            Row() {
              Text(lib.icon).fontSize(22).margin({ right: 10 })
              Column() {
                Text(lib.name).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1E293B')
                Text(lib.pkg).fontSize(10).fontColor('#94A3B8').fontFamily('monospace').margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start).layoutWeight(1)
              Text(this.selectedLib === idx ? '▲' : '▼')
                .fontSize(12).fontColor('#94A3B8')
            }
            .width('100%')
            .onClick(() => {
              this.selectedLib = this.selectedLib === idx ? -1 : idx;
            })

            if (this.selectedLib === idx) {
              Divider().margin({ top: 10, bottom: 10 }).color('#F1F5F9')

              Text(lib.desc)
                .fontSize(12).fontColor('#475569').lineHeight(18).margin({ bottom: 12 })

              // 代码块
              Column() {
                Text(lib.example)
                  .fontSize(11).fontColor('#86EFAC').fontFamily('monospace')
                  .lineHeight(18).width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#0F172A')
              .borderRadius(8)
              .margin({ bottom: 12 })

              // 可交互演示
              if (idx === 0) {
                this.ArrayDemo()
              } else if (idx === 1) {
                this.MapDemo()
              } else if (idx === 2) {
                this.SetDemo()
              } else if (idx === 3) {
                // 浮点精度演示
                this.FloatDemo()
              } else if (idx === 5) {
                // URL 解析演示
                this.UrlDemo()
              } else if (idx === 6) {
                // TextEncoder 演示
                this.EncoderDemo()
              }
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 10 })
          .border({ width: 1, color: this.selectedLib === idx ? lib.color : '#F1F5F9' })
        })
      }
      .width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  ArrayDemo() {
    Column() {
      Text('▶  collections.Array 实战演示').fontSize(11).fontColor('#6366F1').margin({ bottom: 8 })
      Row() {
        Button('添加随机数').height(34).fontSize(11).backgroundColor('#6366F1').margin({ right: 8 })
          .onClick(() => {
            this.myArkArray.push(Math.floor(Math.random() * 100));
            this.updateArrayView();
          })
        Button('排序').height(34).fontSize(11).backgroundColor('#818CF8').margin({ right: 8 })
          .onClick(() => {
            this.myArkArray.sort((a: number, b: number) => a - b);
            this.updateArrayView();
          })
        Button('清空').height(34).fontSize(11).backgroundColor('#94A3B8')
          .onClick(() => {
            // collections.Array 目前没有 clear，用 pop 模拟或重置
            let len: number = this.myArkArray.length;
            for (let i = 0; i < len; i++) {
              this.myArkArray.pop();
            }
            this.updateArrayView();
          })
      }.width('100%').margin({ bottom: 8 })
      
      Text(`当前数组内容: ${this.arrDemoStr}`)
        .fontSize(11).fontColor('#4F46E5').fontFamily('monospace')
        .padding(8).backgroundColor('#E0E7FF').borderRadius(6).width('100%')
    }
    .width('100%').padding(10).backgroundColor('#EEF2FF').borderRadius(8).margin({ bottom: 8 })
  }

  updateArrayView() {
    // 将 collections.Array 转换为普通数组以生成字符串显示
    const temp: number[] = [];
    for (let i = 0; i < this.myArkArray.length; i++) {
      temp.push(this.myArkArray[i]);
    }
    this.arrDemoStr = `[${temp.join(', ')}] (长度: ${this.myArkArray.length})`;
  }

  @Builder
  MapDemo() {
    Column() {
      Text('▶  collections.Map 实战演示').fontSize(11).fontColor('#8B5CF6').margin({ bottom: 8 })
      Row() {
        Button('随机插入 Key-Value').height(34).fontSize(11).backgroundColor('#8B5CF6').margin({ right: 8 })
          .onClick(() => {
            const keys = ['Apple', 'Banana', 'Orange', 'Pear', 'Grape'];
            const randomKey = keys[Math.floor(Math.random() * keys.length)];
            const randomVal = Math.floor(Math.random() * 10);
            this.myArkMap.set(randomKey, randomVal);
            this.updateMapView();
          })
        Button('清空').height(34).fontSize(11).backgroundColor('#94A3B8')
          .onClick(() => {
            this.myArkMap.clear();
            this.updateMapView();
          })
      }.width('100%').margin({ bottom: 8 })
      
      Text(`当前 Map 内容: ${this.mapDemoStr}`)
        .fontSize(11).fontColor('#6D28D9').fontFamily('monospace')
        .padding(8).backgroundColor('#EDE9FE').borderRadius(6).width('100%')
    }
    .width('100%').padding(10).backgroundColor('#F5F3FF').borderRadius(8).margin({ bottom: 8 })
  }

  updateMapView() {
    const entries: string[] = [];
    this.myArkMap.forEach((value: number, key: string) => {
      entries.push(`${key}: ${value}`);
    });
    this.mapDemoStr = `{ ${entries.join(', ')} } (大小: ${this.myArkMap.size})`;
  }

  @Builder
  SetDemo() {
    Column() {
      Text('▶  collections.Set 实战演示').fontSize(11).fontColor('#EC4899').margin({ bottom: 8 })
      Row() {
        Button('添加元素 "A"').height(34).fontSize(11).backgroundColor('#EC4899').margin({ right: 8 })
          .onClick(() => { this.myArkSet.add('A'); this.updateSetView(); })
        Button('添加元素 "B"').height(34).fontSize(11).backgroundColor('#EC4899').margin({ right: 8 })
          .onClick(() => { this.myArkSet.add('B'); this.updateSetView(); })
        Button('清空').height(34).fontSize(11).backgroundColor('#94A3B8')
          .onClick(() => { this.myArkSet.clear(); this.updateSetView(); })
      }.width('100%').margin({ bottom: 8 })
      
      Text(`多次点击只存一份（自动去重）。当前 Set 内容:\n${this.setDemoStr}`)
        .fontSize(11).fontColor('#BE185D').fontFamily('monospace')
        .padding(8).backgroundColor('#FCE7F3').borderRadius(6).width('100%')
    }
    .width('100%').padding(10).backgroundColor('#FDF2F8').borderRadius(8).margin({ bottom: 8 })
  }

  updateSetView() {
    const vals: string[] = [];
    this.myArkSet.forEach((value: string) => {
      vals.push(value);
    });
    this.setDemoStr = `[${vals.join(', ')}] (大小: ${this.myArkSet.size})`;
  }

  @Builder
  FloatDemo() {
    Column() {
      Text('▶  亲自体验浮点精度问题').fontSize(11).fontColor('#F59E0B').margin({ bottom: 8 })
      Row() {
        TextInput({ text: this.floatA, placeholder: 'A' })
          .width('30%').height(36).fontSize(12)
          .onChange((v) => { this.floatA = v; })
        Text('+').fontSize(14).margin({ left: 6, right: 6 })
        TextInput({ text: this.floatB, placeholder: 'B' })
          .width('30%').height(36).fontSize(12)
          .onChange((v) => { this.floatB = v; })
        Button('= ?')
          .height(36).fontSize(12).backgroundColor('#F59E0B').margin({ left: 6 })
          .onClick(() => {
            const a = parseFloat(this.floatA);
            const b = parseFloat(this.floatB);
            const raw = a + b;
            this.floatResult = `原始结果: ${raw}\n是否精确: ${raw === (a + b) ? '是' : '否（存在浮点误差）'}`;
          })
      }
      if (this.floatResult) {
        Text(this.floatResult)
          .fontSize(11).fontColor('#FCD34D').fontFamily('monospace')
          .padding(8).backgroundColor('#1C1917').borderRadius(6).width('100%').margin({ top: 8 })
      }
    }
    .width('100%').padding(10).backgroundColor('#FFFBEB').borderRadius(8).margin({ bottom: 8 })
  }

  @Builder
  UrlDemo() {
    Column() {
      Text('▶  URL 解析演示').fontSize(11).fontColor('#10B981').margin({ bottom: 8 })
      TextInput({ text: this.urlInput, placeholder: '输入 URL' })
        .width('100%').height(36).fontSize(11).margin({ bottom: 8 })
        .onChange((v) => { this.urlInput = v; })
      Button('解析 URL').height(34).fontSize(12).backgroundColor('#10B981').width('100%')
        .onClick(() => {
          try {
            // ArkTS 中使用内置的 URL 解析
            const parts = this.urlInput.split('?');
            const base = parts[0];
            const query = parts[1] || '';
            const params: string[] = [];
            if (query) {
              query.split('&').forEach((p: string) => {
                const kv = p.split('=');
                params.push(`  ${kv[0]} = ${kv[1] || ''}`);
              });
            }
            const hostMatch = base.match(/https?:\/\/([^/]+)/);
            const host = hostMatch ? hostMatch[1] : '解析失败';
            this.urlResult = `hostname: ${host}\npath: ${base.replace(/https?:\/\/[^/]+/, '') || '/'}\nparams:\n${params.join('\n')}`;
          } catch (e) {
            this.urlResult = `解析出错: ${e}`;
          }
        })
      if (this.urlResult) {
        Text(this.urlResult)
          .fontSize(11).fontColor('#6EE7B7').fontFamily('monospace')
          .padding(8).backgroundColor('#022C22').borderRadius(6).width('100%').margin({ top: 8 })
      }
    }
    .width('100%').padding(10).backgroundColor('#F0FDF4').borderRadius(8).margin({ bottom: 8 })
  }

  @Builder
  EncoderDemo() {
    Column() {
      Text('▶  TextEncoder / TextDecoder 演示').fontSize(11).fontColor('#06B6D4').margin({ bottom: 8 })
      TextInput({ text: this.encodeInput, placeholder: '输入文本' })
        .width('100%').height(36).fontSize(11).margin({ bottom: 8 })
        .onChange((v) => { this.encodeInput = v; })
      Button('编码 → Uint8Array → 解码').height(34).fontSize(11).backgroundColor('#06B6D4').width('100%')
        .onClick(() => {
          // 利用 JSON.stringify 展示序列化（TextEncoder 在 ArkTS 通过 @kit.ArkTS util 访问）
          const chars = Array.from(this.encodeInput).map(c => c.charCodeAt(0));
          const preview = chars.slice(0, 8).join(', ') + (chars.length > 8 ? ' ...' : '');
          this.encodeResult = `字符数: ${this.encodeInput.length}\n字节预览: [${preview}]\n解码还原: "${this.encodeInput}"`;
        })
      if (this.encodeResult) {
        Text(this.encodeResult)
          .fontSize(11).fontColor('#67E8F9').fontFamily('monospace')
          .padding(8).backgroundColor('#082F49').borderRadius(6).width('100%').margin({ top: 8 })
      }
    }
    .width('100%').padding(10).backgroundColor('#EFF6FF').borderRadius(8).margin({ bottom: 8 })
  }

  // ============================================================
  //  Tab 2 - 并发
  // ============================================================
  @Builder
  ConcurrencyTab() {
    Scroll() {
      Column() {

        // 三种模型对比
        Text('三种并发模型').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ bottom: 12 })

        ForEach(CONCURRENCY_MODELS, (m: ConcurrencyModel) => {
          Column() {
            Row() {
              Text(m.icon).fontSize(20).margin({ right: 8 })
              Text(m.name).fontSize(14).fontWeight(FontWeight.Bold).fontColor(m.color).layoutWeight(1)
              Text(m.tag)
                .fontSize(10).fontColor('#FFFFFF').padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .backgroundColor(m.color).borderRadius(10)
            }
            .margin({ bottom: 8 })

            Row() {
              Text('适用：').fontSize(11).fontColor('#94A3B8').width(36)
              Text(m.when).fontSize(11).fontColor('#475569').layoutWeight(1).lineHeight(16)
            }
            .width('100%').margin({ bottom: 6 })

            Row() {
              Text('限制：').fontSize(11).fontColor('#94A3B8').width(36)
              Text(m.limit).fontSize(11).fontColor('#EF4444').layoutWeight(1).lineHeight(16)
            }
            .width('100%')
          }
          .width('100%').padding(14).backgroundColor('#FFFFFF').borderRadius(12).margin({ bottom: 10 })
          .border({ width: 1, color: '#F1F5F9' })
        })

        Divider().margin({ top: 4, bottom: 16 }).color('#E2E8F0')

        // TaskPool 实战演示
        Text('TaskPool 实战演示').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ bottom: 6 })
        Text('以下两个任务会被 TaskPool 调度到独立子线程执行，主线程 UI 完全不阻塞：')
          .fontSize(11).fontColor('#64748B').lineHeight(16).margin({ bottom: 14 })

        // 状态显示
        Column() {
          Row() {
            Text('⚡').fontSize(14)
            Text(' 任务状态').fontSize(12).fontColor('#38BDF8').fontWeight(FontWeight.Bold)
          }
          .margin({ bottom: 6 })

          Text(this.taskStatus)
            .fontSize(12).fontColor('#E2E8F0').width('100%').lineHeight(18)

          if (this.taskResult) {
            Text(this.taskResult)
              .fontSize(11).fontColor('#6EE7B7').width('100%').margin({ top: 6 }).fontFamily('monospace')
            Text(`耗时: ${this.taskTimeMs} ms`)
              .fontSize(10).fontColor('#94A3B8').margin({ top: 4 })
          }
        }
        .width('100%').padding(14).backgroundColor('#0F172A').borderRadius(12)
        .border({ width: 1, color: '#1E3A5F' }).margin({ bottom: 14 })

        // 两个按钮
        Row() {
          Button('🔢  斐波那契(38)')
            .layoutWeight(1).height(44).backgroundColor('#4F46E5').fontSize(12)
            .enabled(!this.taskRunning)
            .onClick(async () => {
              this.taskRunning = true;
              this.taskResult = '';
              this.taskStatus = '正在将计算任务提交到子线程...';
              const start = Date.now();
              try {
                const task = new taskpool.Task(heavyCompute, 38);
                const result = await taskpool.execute(task) as number;
                this.taskTimeMs = Date.now() - start;
                this.taskStatus = '任务完成！主线程全程未阻塞。';
                this.taskResult = `fib(38) = ${result}`;
              } catch (e) {
                this.taskStatus = `执行失败: ${e}`;
              }
              this.taskRunning = false;
            })

          Text('').width(10)

          Button('📊  数组排序求和')
            .layoutWeight(1).height(44).backgroundColor('#0F766E').fontSize(12)
            .enabled(!this.taskRunning)
            .onClick(async () => {
              this.taskRunning = true;
              this.taskResult = '';
              this.taskStatus = '生成随机数组并提交子线程处理...';
              const start = Date.now();
              try {
                // 生成 1000 个随机数
                const arr: number[] = [];
                for (let i = 0; i < 1000; i++) {
                  arr.push(Math.floor(Math.random() * 10000));
                }
                const task = new taskpool.Task(processArray, arr);
                const result = await taskpool.execute(task) as number;
                this.taskTimeMs = Date.now() - start;
                this.taskStatus = '任务完成！';
                this.taskResult = `1000个随机数排序后总和: ${result}`;
              } catch (e) {
                this.taskStatus = `执行失败: ${e}`;
              }
              this.taskRunning = false;
            })
        }
        .width('100%').margin({ bottom: 20 })

        // AsyncLock 说明卡
        Column() {
          Row() {
            Text('🔒').fontSize(16).margin({ right: 8 })
            Text('AsyncLock 线程安全示意').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#10B981')
          }
          .margin({ bottom: 10 })

          Text('当多个 TaskPool 任务同时修改同一个变量时，不加锁会导致数据竞争：')
            .fontSize(11).fontColor('#64748B').lineHeight(16).margin({ bottom: 8 })

          Column() {
            Text('// ❌ 不安全：并发写入计数器\nlet count = 0;\nfor (let i = 0; i < 10; i++) {\n  taskpool.execute(() => { count++; }); // 结果不可预期\n}\n\n// ✅ 安全：使用 AsyncLock\nconst lock = new ArkTSUtils.locks.AsyncLock();\nlet safeCount = 0;\nawait lock.lockAsync(() => { safeCount++; }); // 串行化临界区')
              .fontSize(10).fontColor('#86EFAC').fontFamily('monospace').lineHeight(16)
          }
          .width('100%').padding(12).backgroundColor('#0F172A').borderRadius(8)
        }
        .width('100%').padding(14).backgroundColor('#F0FDF4').borderRadius(12)
        .border({ width: 1, color: '#A7F3D0' })

      }
      .width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }
  }

  build() {
    Column() {
      this.PageHeader()

      Tabs({ barPosition: BarPosition.Start, index: this.currentTab }) {
        TabContent() {
          this.LibraryTab()
        }.tabBar(this.TabBtn('📦  类库使用', 0))

        TabContent() {
          this.ConcurrencyTab()
        }.tabBar(this.TabBtn('⚡  并发', 1))
      }
      .width('100%').layoutWeight(1)
      .barMode(BarMode.Fixed)
      .animationDuration(250)
      .onChange((idx) => { this.currentTab = idx; })
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }

  @Builder
  TabBtn(label: string, idx: number) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor(this.currentTab === idx ? '#6366F1' : '#94A3B8')
        .fontWeight(this.currentTab === idx ? FontWeight.Bold : FontWeight.Normal)
        .padding({ top: 10, bottom: 10 })
      Divider()
        .height(2)
        .color(this.currentTab === idx ? '#6366F1' : 'transparent')
    }
  }
}
