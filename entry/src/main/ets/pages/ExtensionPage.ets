import { router } from '@kit.ArkUI';

// ============================================================
//  ExtensionAbility 页
//  知识点：
//  - ExtensionAbility 各类型（Service/AppService/Agent/EmbeddedUI/Backup等）
//  - Call 调用实现 UIAbility 多端协同
//  - UIAbility 备份恢复（BackupExtensionAbility）
//  - EmbeddedUIExtensionAbility（跨进程嵌入 UI）
// ============================================================

interface ExtensionType {
  icon: string;
  name: string;
  type: string;
  color: string;
  desc: string;
  process: string;
  useCase: string;
}

interface BackupFlowItem {
  step: string;
  title: string;
  desc: string;
  color: string;
}

const EXTENSION_TYPES: ExtensionType[] = [
  {
    icon: '⚙️',
    name: 'ServiceExtensionAbility',
    type: 'service',
    color: '#EF4444',
    desc: '系统级后台服务，需要系统权限。可在后台常驻运行，提供进程间服务能力。',
    process: '独立进程（Extension 进程）',
    useCase: '系统服务、输入法、无障碍服务等'
  },
  {
    icon: '🛠️',
    name: 'AppServiceExtensionAbility',
    type: 'appService',
    color: '#F97316',
    desc: '应用级后台服务（API 12+），无需系统权限。用于实现应用自身的后台常驻能力。',
    process: '应用专属 Extension 进程',
    useCase: '音乐后台播放、文件同步、定时任务'
  },
  {
    icon: '🤖',
    name: 'AgentExtensionAbility',
    type: 'agent',
    color: '#D946EF',
    desc: '智能体服务扩展（API 15+），用于实现基于大模型的智能助手能力，可被意图框架调度。',
    process: '应用 Extension 进程',
    useCase: '应用内智能助手、AI 功能扩展'
  },
  {
    icon: '🪟',
    name: 'EmbeddedUIExtensionAbility',
    type: 'embeddedUI',
    color: '#06B6D4',
    desc: '跨进程 UI 嵌入能力。允许一个应用将自己的 UI 界面嵌入到另一个应用的 UI 中，通过 <EmbeddedComponent> 实现。',
    process: 'Provider 应用进程',
    useCase: '第三方组件嵌入、跨应用 Widget'
  },
  {
    icon: '💾',
    name: 'BackupExtensionAbility',
    type: 'backup',
    color: '#10B981',
    desc: '应用数据备份与恢复扩展。在系统执行备份时调用，将应用数据序列化；在恢复时反序列化还原。',
    process: '主进程',
    useCase: '云备份、设备迁移、数据恢复'
  },
  {
    icon: '🔔',
    name: 'StaticSubscriberExtensionAbility',
    type: 'staticSubscriber',
    color: '#FBBF24',
    desc: '静态公共事件订阅，应用未启动时也能接收系统广播事件（如开机、安装等）。',
    process: '应用进程（被唤醒）',
    useCase: '开机自启、系统事件监听'
  },
  {
    icon: '📋',
    name: 'FormExtensionAbility',
    type: 'form',
    color: '#818CF8',
    desc: '服务卡片扩展，用于实现桌面/锁屏上的小组件（ArkTS 卡片）。',
    process: '应用 Extension 进程',
    useCase: '桌面卡片、锁屏信息卡片'
  },
  {
    icon: '🖼️',
    name: 'PhotoEditorExtensionAbility',
    type: 'photoEditor',
    color: '#94A3B8',
    desc: '图片编辑扩展（API 12+），允许第三方应用接入系统相册的编辑流程。',
    process: '应用 Extension 进程',
    useCase: '滤镜、图片处理应用'
  }
];

@Entry
@Component
struct ExtensionPage {
  @State selectedExtension: number = 0;
  @State showCallDemo: boolean = false;

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('ExtensionAbility').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('特殊场景扩展 · Call调用 · 备份恢复').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('🧩').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#EF4444')
      .letterSpacing(0.5).width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  ExtensionCard(ext: ExtensionType, index: number) {
    Column() {
      Row() {
        Text(ext.icon).fontSize(24).margin({ right: 10 })
        Column() {
          Text(ext.name)
            .fontSize(12).fontWeight(FontWeight.Bold).fontColor(ext.color)
          Text(`type: "${ext.type}"`)
            .fontSize(10).fontColor('#64748B').fontFamily('monospace').margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)
        Text(this.selectedExtension === index ? '▲' : '▼')
          .fontSize(12).fontColor('#64748B')
      }
      .width('100%')

      if (this.selectedExtension === index) {
        Column() {
          Text(ext.desc)
            .fontSize(11).fontColor('#94A3B8').lineHeight(18).margin({ top: 10, bottom: 8 })
          Row() {
            Text('进程：').fontSize(10).fontColor('#64748B').width(50)
            Text(ext.process).fontSize(10).fontColor('#334155').layoutWeight(1)
          }
          .margin({ bottom: 4 })
          Row() {
            Text('场景：').fontSize(10).fontColor('#64748B').width(50)
            Text(ext.useCase).fontSize(10).fontColor(ext.color).layoutWeight(1)
          }
        }
        .animation({ duration: 300, curve: Curve.EaseOut })
      }
    }
    .width('100%').padding(14)
    .backgroundColor(this.selectedExtension === index ? `${ext.color}12` : '#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: this.selectedExtension === index ? `${ext.color}44` : 'rgba(0,0,0,0.05)' })
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 8 })
    .onClick(() => {
      this.selectedExtension = this.selectedExtension === index ? -1 : index;
    })
  }

  @Builder
  CallSection() {
    Column() {
      Text('Call 调用允许调用方通过 IPC 与指定 UIAbility 实例进行通信，无需拉起该 UIAbility 的 UI 界面（常驻后台实例）。适用于多端协同、跨 Ability 数据共享。')
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 14 })

      // 被调用方配置
      Column() {
        Text('① 被调用方（UIAbility）实现 Callee')
          .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#FBBF24').margin({ bottom: 8 })
        Column() {
          Text('// UIAbility.ts\nimport { rpc } from "@kit.IPCKit";\n\nexport default class MyAbility extends UIAbility {\n  onCreate() {\n    // 注册 callee 处理函数\n    this.callee.on("MyMethod", this.callHandler);\n  }\n\n  callHandler(data: rpc.MessageSequence) {\n    // 读取调用方传来的数据\n    const msg = data.readString();\n    console.log("收到 Call 调用:", msg);\n    \n    // 返回结果\n    const result = new rpc.MessageSequence();\n    result.writeString("处理完成");\n    return result;\n  }\n}')
            .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
        }
        .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      }
      .width('100%').padding(14)
      .backgroundColor('rgba(251,191,36,0.07)').borderRadius(12)
      .border({ width: 1, color: 'rgba(251,191,36,0.2)' })
      .alignItems(HorizontalAlign.Start).margin({ bottom: 10 })

      // 调用方
      Column() {
        Text('② 调用方（发起 Call）')
          .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#6366F1').margin({ bottom: 8 })
        Column() {
          Text('// 调用方 Page.ets\nconst want: Want = {\n  bundleName: "com.example.app",\n  abilityName: "MyAbility"\n};\n\n// 发起 Call 调用（不拉起UI）\nconst caller = await context.startAbilityByCall(want);\n\n// 发送数据\nconst data = new rpc.MessageSequence();\ndata.writeString("Hello from Caller");\nconst result = await caller.call("MyMethod", data);\n\n// 断开连接\ncaller.release();')
            .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
        }
        .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      }
      .width('100%').padding(14)
      .backgroundColor('rgba(99,102,241,0.07)').borderRadius(12)
      .border({ width: 1, color: 'rgba(99,102,241,0.2)' })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  BackupSection() {
    Column() {
      Text('BackupExtensionAbility 使应用能够参与系统级数据备份流程，保证应用数据在设备迁移、重置、恢复出厂设置时的完整性。')
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 14 })

      // 流程图
      Column() {
        Text('备份/恢复流程')
          .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

        ForEach([
          { step: '1', title: '系统触发备份', desc: '云端同步 / 设备迁移 / 手动备份', color: '#10B981' },
          { step: '2', title: '调用 onBackup()', desc: '将应用数据写入备份目录（el2/backup）', color: '#6366F1' },
          { step: '3', title: '系统压缩上传', desc: '备份数据加密上传至华为云', color: '#F59E0B' },
          { step: '4', title: '恢复时调用 onRestore()', desc: '从备份目录读取数据，还原应用状态', color: '#EC4899' },
        ], (item: BackupFlowItem) => {
          Row() {
            Column() {
              Text(item.step)
                .fontSize(14).fontWeight(FontWeight.Bold).fontColor('#F4F6F9')
            }
            .width(28).height(28).borderRadius(14)
            .backgroundColor(item.color)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            .margin({ right: 12 })

            Column() {
              Text(item.title).fontSize(12).fontWeight(FontWeight.Bold).fontColor(item.color)
              Text(item.desc).fontSize(10).fontColor('#64748B').margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .margin({ bottom: 10 })
        })
      }
      .width('100%').padding(14)
      .backgroundColor('#FFFFFF').borderRadius(12)
      .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
      .alignItems(HorizontalAlign.Start).margin({ bottom: 14 })

      Column() {
        Text('export default class MyBackupAbility extends BackupExtensionAbility {\n  async onBackup() {\n    // 将数据复制到备份目录\n    const srcPath = this.context.filesDir + "/user_data.db";\n    const dstPath = this.context.backupDir + "/user_data.db";\n    await fs.copyFile(srcPath, dstPath);\n  }\n\n  async onRestore(bundleVersion: BundleVersion) {\n    // 从备份目录恢复数据\n    const srcPath = this.context.backupDir + "/user_data.db";\n    const dstPath = this.context.filesDir + "/user_data.db";\n    await fs.copyFile(srcPath, dstPath);\n  }\n}')
          .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
      }
      .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
    }
    .width('100%').padding({ left: 16, right: 16, bottom: 32 }).alignItems(HorizontalAlign.Start)
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()

        // ── ExtensionAbility 类型 ─────────────────────────────
        this.SectionTitle('🧩 ExtensionAbility 全类型（点击展开）')
        Column() {
          ForEach(EXTENSION_TYPES, (ext: ExtensionType, index: number) => {
            this.ExtensionCard(ext, index)
          })
        }
        .width('100%').padding({ left: 16, right: 16 })

        // ── Call 调用 ────────────────────────────────────────
        this.SectionTitle('📞 Call 调用实现多端协同')
        this.CallSection()

        // ── 备份恢复 ─────────────────────────────────────────
        this.SectionTitle('💾 UIAbility 备份恢复（BackupExtensionAbility）')
        this.BackupSection()
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
