import { router } from '@kit.ArkUI';

// ============================================================
//  AbilityStage & AppStartup & 应用预加载 & 重启 & 异常退出页
//  知识点：
//  - AbilityStage：模块级管理器，生命周期
//  - AppStartup：启动任务框架，加速启动速度
//  - 应用预加载（appPreloadingEnabled）
//  - 应用重启（context.restartApp）
//  - 获取应用异常退出原因（ErrorManager）
// ============================================================

interface StartupTask {
  name: string;
  dependency: string[];
  thread: string;
  desc: string;
}

interface LifecycleCbItem {
  cb: string;
  desc: string;
}

const STARTUP_TASKS: StartupTask[] = [
  { name: 'DatabaseInitTask', dependency: [],                  thread: '主线程', desc: '初始化 Room 数据库连接' },
  { name: 'NetworkConfigTask', dependency: [],                 thread: '子线程', desc: '配置网络参数和证书' },
  { name: 'UserSessionTask',   dependency: ['DatabaseInitTask'], thread: '主线程', desc: '读取用户登录状态' },
  { name: 'ThemeConfigTask',   dependency: ['UserSessionTask'], thread: '主线程', desc: '根据用户偏好加载主题' },
];

interface ExitReason {
  code: string;
  name: string;
  color: string;
  desc: string;
}

const EXIT_REASONS: ExitReason[] = [
  { code: '0',  name: 'NORMAL',           color: '#34D399', desc: '正常退出' },
  { code: '1',  name: 'CPP_CRASH',        color: '#EF4444', desc: 'Native 层崩溃（Segfault 等）' },
  { code: '2',  name: 'JS_ERROR',         color: '#F97316', desc: 'ArkTS/JS 未捕获异常' },
  { code: '3',  name: 'APP_FREEZE',       color: '#FBBF24', desc: '应用卡死（ANR）' },
  { code: '4',  name: 'PERFORMANCE_CONTROL', color: '#818CF8', desc: '系统性能管控（内存过高）' },
  { code: '5',  name: 'RESOURCE_CONTROL', color: '#64748B', desc: '资源管控（CPU/GPU 过高）' },
  { code: '6',  name: 'UPGRADE',          color: '#06B6D4', desc: '应用升级触发退出' },
  { code: '7',  name: 'USER_REQUEST',     color: '#94A3B8', desc: '用户主动关闭应用' },
];

@Entry
@Component
struct AbilityStagePage {
  @State selectedSection: number = 0;
  @StorageLink('stageLoadTime') stageLoadTime: number = 0;
  @StorageLink('stageOnCreateCalled') stageCreated: boolean = false;
  @StorageLink('moduleName') moduleName: string = 'entry';
  @StorageLink('lastAcceptWantKey') lastWantKey: string = '';

  private sections: string[] = ['AbilityStage', 'AppStartup', '预加载&重启', '异常退出'];

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('AbilityStage & 启动框架').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('模块管理 · AppStartup · 预加载 · 重启 · 异常退出').fontSize(10).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('🏗️').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#F59E0B')
      .letterSpacing(0.5).width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  TabBar() {
    Row() {
      ForEach(this.sections, (section: string, index: number) => {
        Text(section)
          .fontSize(11)
          .fontColor(this.selectedSection === index ? '#F59E0B' : '#64748B')
          .fontWeight(this.selectedSection === index ? FontWeight.Bold : FontWeight.Normal)
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor(this.selectedSection === index ? 'rgba(245,158,11,0.15)' : 'transparent')
          .borderRadius(8)
          .border({ width: this.selectedSection === index ? 1 : 0, color: 'rgba(245,158,11,0.4)' })
          .onClick(() => { this.selectedSection = index; })
      })
    }
    .width('100%').padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  AbilityStageSection() {
    Column() {
      // 实时状态
      Column() {
        Text('✅ MyAbilityStage 实时状态')
          .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#34D399').margin({ bottom: 10 })
        Row() {
          Text('onCreate 已触发：').fontSize(11).fontColor('#64748B').width(120)
          Text(this.stageCreated ? '✅ 是' : '❌ 否')
            .fontSize(12).fontColor(this.stageCreated ? '#34D399' : '#EF4444')
        }
        .margin({ bottom: 8 })
        Row() {
          Text('模块名：').fontSize(11).fontColor('#64748B').width(120)
          Text(this.moduleName || 'entry').fontSize(12).fontColor('#818CF8')
        }
        .margin({ bottom: 8 })
        Row() {
          Text('加载时间：').fontSize(11).fontColor('#64748B').width(120)
          Text(this.stageLoadTime > 0 ? new Date(this.stageLoadTime).toLocaleTimeString() : '--')
            .fontSize(12).fontColor('#FBBF24')
        }
        .margin({ bottom: 8 })
        Row() {
          Text('onAcceptWant Key：').fontSize(11).fontColor('#64748B').width(120)
          Text(this.lastWantKey || '（未触发）').fontSize(12).fontColor('#06B6D4')
        }
      }
      .width('100%').padding(14).backgroundColor('rgba(52,211,153,0.07)').borderRadius(12)
      .border({ width: 1, color: 'rgba(52,211,153,0.2)' }).alignItems(HorizontalAlign.Start)
      .margin({ bottom: 14 })

      // 生命周期说明
      Text('AbilityStage 生命周期')
        .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

      Column() {
        ForEach([
          { cb: 'onCreate()', desc: 'HAP 模块首次加载时调用，做模块级初始化，时机早于 UIAbility.onCreate' },
          { cb: 'onAcceptWant(want)', desc: 'specified 启动模式专用，返回 key 决定使用哪个 UIAbility 实例' },
          { cb: 'onConfigurationUpdate(config)', desc: '系统配置变更（语言/深色模式/屏幕方向）时回调' },
          { cb: 'onMemoryLevel(level)', desc: '系统内存压力事件（MODERATE=0 / LOW=1 / CRITICAL=2）' },
        ], (item: LifecycleCbItem) => {
          Row() {
            Text(item.cb)
              .fontSize(11).fontColor('#F59E0B').fontFamily('monospace').width(180)
            Text(item.desc)
              .fontSize(11).fontColor('#94A3B8').layoutWeight(1).maxLines(3)
          }
          .padding({ top: 8, bottom: 8 })
          Divider().color('#FFFFFF')
        })
      }
      .width('100%').padding(12).backgroundColor('#FFFFFF').borderRadius(10)
    }
    .width('100%').padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  AppStartupSection() {
    Column() {
      Text('AppStartup 是 HarmonyOS 提供的启动任务编排框架，将分散的初始化逻辑统一管理，支持：\n• 并行任务：无依赖的任务同时在子线程执行\n• 串行依赖：有依赖关系的任务按顺序执行\n• 精确时机：控制任务在主线程/子线程运行')
        .fontSize(12).fontColor('#94A3B8').lineHeight(20).margin({ bottom: 14 })

      Text('启动任务依赖关系图：')
        .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

      // 可视化任务图
      Column() {
        // 第一层（并行）
        Row() {
          Column() {
            Text('DatabaseInitTask').fontSize(10).fontColor('#F59E0B').fontFamily('monospace')
            Text('主线程').fontSize(9).fontColor('#64748B')
          }
          .padding(8).backgroundColor('rgba(245,158,11,0.15)').borderRadius(8)
          .border({ width: 1, color: 'rgba(245,158,11,0.4)' })
          .margin({ right: 8 })

          Column() {
            Text('NetworkConfigTask').fontSize(10).fontColor('#06B6D4').fontFamily('monospace')
            Text('子线程').fontSize(9).fontColor('#64748B')
          }
          .padding(8).backgroundColor('rgba(6,182,212,0.15)').borderRadius(8)
          .border({ width: 1, color: 'rgba(6,182,212,0.4)' })
        }
        .margin({ bottom: 6 })

        Text('↓ depends on DatabaseInitTask').fontSize(9).fontColor('#64748B').margin({ bottom: 6 })

        // 第二层
        Column() {
          Text('UserSessionTask').fontSize(10).fontColor('#8B5CF6').fontFamily('monospace')
          Text('主线程 · 依赖 DatabaseInitTask').fontSize(9).fontColor('#64748B')
        }
        .padding(8).backgroundColor('rgba(139,92,246,0.15)').borderRadius(8)
        .border({ width: 1, color: 'rgba(139,92,246,0.4)' })
        .margin({ bottom: 6 })

        Text('↓ depends on UserSessionTask').fontSize(9).fontColor('#64748B').margin({ bottom: 6 })

        // 第三层
        Column() {
          Text('ThemeConfigTask').fontSize(10).fontColor('#EC4899').fontFamily('monospace')
          Text('主线程 · 依赖 UserSessionTask').fontSize(9).fontColor('#64748B')
        }
        .padding(8).backgroundColor('rgba(236,72,153,0.15)').borderRadius(8)
        .border({ width: 1, color: 'rgba(236,72,153,0.4)' })
      }
      .width('100%').padding(14).backgroundColor('rgba(0,0,0,0.3)').borderRadius(10)
      .margin({ bottom: 14 })

      Text('配置示例（startup_config.json）：')
        .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 8 })
      Column() {
        Text('{\n  "startupTasks": [\n    {\n      "name": "DatabaseInitTask",\n      "srcEntry": "./ets/startup/DatabaseInitTask.ets",\n      "runOnThread": "mainThread"\n    },\n    {\n      "name": "UserSessionTask",\n      "srcEntry": "./ets/startup/UserSessionTask.ets",\n      "dependencies": ["DatabaseInitTask"]\n    }\n  ],\n  "configEntry": "./ets/startup/StartupConfig.ets"\n}')
          .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
      }
      .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
    }
    .width('100%').padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  PreloadRestartSection() {
    Column() {
      // 应用预加载
      Column() {
        Text('⚡ 应用预加载（appPreloadingEnabled）')
          .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#34D399').margin({ bottom: 8 })
        Text('在用户可能启动应用之前，系统提前创建进程并初始化资源，减少冷启动时间。')
          .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 10 })
        Column() {
          Text('// app.json5\n{\n  "app": {\n    "appPreloadingEnabled": true\n  }\n}')
            .fontSize(11).fontColor('#0284C7').fontFamily('monospace').lineHeight(16)
        }
        .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      }
      .width('100%').padding(14).backgroundColor('rgba(52,211,153,0.07)').borderRadius(12)
      .border({ width: 1, color: 'rgba(52,211,153,0.2)' }).alignItems(HorizontalAlign.Start)
      .margin({ bottom: 10 })

      // 应用重启
      Column() {
        Text('🔄 应用重启（restartApp）')
          .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#6366F1').margin({ bottom: 8 })
        Text('应用可以在满足条件时主动请求系统重启自身（如更新后应用语言环境重置等）。')
          .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 10 })
        Column() {
          Text('const want: Want = {\n  bundleName: context.abilityInfo.bundleName,\n  abilityName: "EntryAbility"\n};\n// 重启应用\ncontext.restartApp(want);')
            .fontSize(11).fontColor('#0284C7').fontFamily('monospace').lineHeight(16)
        }
        .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      }
      .width('100%').padding(14).backgroundColor('rgba(99,102,241,0.07)').borderRadius(12)
      .border({ width: 1, color: 'rgba(99,102,241,0.2)' }).alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  ExitReasonSection() {
    Column() {
      Text('通过 ErrorManager 注册错误监听器，在应用异常退出后的下次启动时，可以从 AbilityStage.onCreate 中读取上次退出原因，以便做差异化处理（如弹窗提示或自动修复）。')
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 14 })

      Column() {
        Text('// 注册异常监听（在 AbilityStage.onCreate 中）\nconst errorManager = errorManager.on("error", {\n  onUnhandledException(errMsg) {\n    console.error("未捕获异常:", errMsg);\n  },\n  onException(errorObj) {\n    console.error("JS 异常:", errorObj.message);\n  }\n});\n\n// 获取上次退出原因\nconst reasons = await appRecovery.getLastExitReasons();\nif (reasons[0].exitReason === ExitReason.JS_ERROR) {\n  // 上次崩溃，展示恢复提示\n}')
          .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
      }
      .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      .margin({ bottom: 14 })

      Text('退出原因枚举（ExitReason）：')
        .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

      Grid() {
        ForEach(EXIT_REASONS, (reason: ExitReason) => {
          GridItem() {
            Column() {
              Row() {
                Text(reason.code)
                  .fontSize(14).fontWeight(FontWeight.Bold).fontColor(reason.color)
                  .width(24)
                Text(reason.name)
                  .fontSize(10).fontColor(reason.color).fontFamily('monospace').layoutWeight(1)
              }
              .margin({ bottom: 4 })
              Text(reason.desc)
                .fontSize(10).fontColor('#64748B')
            }
            .padding(10).backgroundColor(`${reason.color}10`)
            .borderRadius(8).border({ width: 1, color: `${reason.color}30` })
            .alignItems(HorizontalAlign.Start)
          }
        })
      }
      .columnsTemplate('1fr 1fr').columnsGap(8).rowsGap(8).width('100%')
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
          this.SectionTitle('🏗️ AbilityStage 模块级管理器')
          this.AbilityStageSection()
        } else if (this.selectedSection === 1) {
          this.SectionTitle('🚀 AppStartup 启动任务框架')
          this.AppStartupSection()
        } else if (this.selectedSection === 2) {
          this.SectionTitle('⚡ 应用预加载 & 重启')
          this.PreloadRestartSection()
        } else {
          this.SectionTitle('💥 获取应用异常退出原因')
          this.ExitReasonSection()
        }
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
