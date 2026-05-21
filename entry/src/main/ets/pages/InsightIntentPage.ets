import { router } from '@kit.ArkUI';

// ============================================================
//  意图框架 (Insight Intent) & 智能体 (Agent) 开发指导页
//  知识点：
//  - InsightIntent 意图框架概述
//  - 意图声明（@InsightIntentPage / @InsightIntentEntry）
//  - 意图执行模式（前台/后台/服务扩展）
//  - AgentExtensionAbility 智能体服务
//  - 配置 intentProfile.json
// ============================================================

interface IntentExecuteMode {
  icon: string;
  mode: string;
  color: string;
  desc: string;
  abilityType: string;
  lifecycle: string;
}

interface CallChainItem {
  label: string;
  color: string;
}

const EXECUTE_MODES: IntentExecuteMode[] = [
  {
    icon: '🖥️',
    mode: 'UI 页面执行',
    color: '#6366F1',
    desc: '调用意图时，拉起 UIAbility 并跳转到指定页面，用户可以看到界面。适用于需要展示 UI 的意图。',
    abilityType: 'UIAbility',
    lifecycle: '前台可见 → 页面跳转 → 用户交互'
  },
  {
    icon: '⬛',
    mode: '后台执行',
    color: '#EC4899',
    desc: '调用意图时，UIAbility 在后台执行，不展示任何界面。适用于静默完成任务的场景（如发送消息）。',
    abilityType: 'UIAbility (后台)',
    lifecycle: '在后台创建实例 → 执行任务 → 自动销毁'
  },
  {
    icon: '🔧',
    mode: 'Service 执行',
    color: '#10B981',
    desc: '通过 IntentServiceExtensionAbility 在独立进程中执行，更稳定，适合耗时任务。',
    abilityType: 'IntentServiceExtensionAbility',
    lifecycle: 'Extension 进程 → 执行意图 → 回调结果'
  }
];

interface IntentExample {
  title: string;
  desc: string;
  code: string;
}

const INTENT_EXAMPLES: IntentExample[] = [
  {
    title: '① 声明意图（@InsightIntentPage）',
    desc: '在 Page 组件上标注 @InsightIntentPage，声明该页面可被意图框架直接打开',
    code: '// 在 ArkTS 页面中声明意图\n@InsightIntentPage({\n  intentName: "OpenMusicPlayer",\n  domain: "music",\n  parameters: [\n    { name: "songId", type: "string", desc: "歌曲ID" }\n  ]\n})\n@Entry\n@Component\nstruct MusicPlayerPage {\n  @InsightIntentParam() songId: string = "";\n  \n  build() {\n    // 页面内容...\n  }\n}'
  },
  {
    title: '② 声明意图（@InsightIntentEntry）',
    desc: '在 UIAbility 中通过 @InsightIntentEntry 装饰器声明，处理更复杂的意图执行逻辑',
    code: '// 在 UIAbility 中\n@InsightIntentEntry({\n  intentName: "PlayMusic",\n  executeMode: [ExecuteMode.UI_ABILITY_FOREGROUND]\n})\nexport default class MusicAbility extends UIAbility {\n  onExecuteInUIAbilityForegroundMode(\n    name: string,\n    param: Record<string,Object>,\n    pageLoader: window.WindowStage\n  ): insightIntent.ExecuteResult {\n    pageLoader.loadContent("pages/Player");\n    return { code: 0, result: {} };\n  }\n}'
  },
  {
    title: '③ 配置 intentProfile.json',
    desc: '在 module.json5 的 metadata 中引用 intentProfile，声明应用支持的所有意图',
    code: '// module.json5 中引用\n"metadata": [\n  {\n    "name": "ohos.insightIntent.profile",\n    "resource": "$profile:insight_intent"\n  }\n]\n\n// insight_intent.json\n{\n  "insightIntents": [\n    {\n      "intentName": "PlayMusic",\n      "domain": "MUSIC",\n      "intentVersion": "1.0.1",\n      "srcEntry": "./ets/entryability/EntryAbility.ets"\n    }\n  ]\n}'
  }
];

@Entry
@Component
struct InsightIntentPage {
  @State selectedMode: number = 0;
  @State expandedExample: number = -1;
  @State showAgentSection: boolean = false;

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('意图框架 & 智能体').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('InsightIntent · AgentExtensionAbility').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('🤖').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#D946EF')
      .letterSpacing(0.5).width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()

        // ── 意图框架概述 ─────────────────────────────────────
        this.SectionTitle('🧠 InsightIntent 意图框架概述')
        Column() {
          Text('InsightIntent（意图框架）是 HarmonyOS 实现"应用原子化服务"的核心机制。它将应用能力拆解为一个个"意图"，供系统、助手、快捷指令调用，无需用户打开完整应用。')
            .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 12 })

          // 调用链示意
          Column() {
            Text('意图调用链')
              .fontSize(11).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })
            Row() {
              ForEach([
                { label: '小艺/助手\n语音指令', color: '#D946EF' },
                { label: '意图框架\n路由匹配', color: '#8B5CF6' },
                { label: '应用\nAbility执行', color: '#6366F1' },
                { label: '返回结果\n给调用方', color: '#06B6D4' }
              ], (item: CallChainItem, index: number) => {
                Row() {
                  Column() {
                    Text(item.label)
                      .fontSize(10).fontColor(item.color).textAlign(TextAlign.Center).lineHeight(14)
                  }
                  .layoutWeight(1).padding(8)
                  .backgroundColor(`${item.color}18`).borderRadius(8)
                  .border({ width: 1, color: `${item.color}44` })

                  if (index < 3) {
                    Text('→').fontSize(14).fontColor('#94A3B8').margin({ left: 4, right: 4 })
                  }
                }
              })
            }
            .width('100%')
          }
          .width('100%').padding(12).backgroundColor('#FFFFFF').borderRadius(10)
        }
        .width('100%').padding(14)
        .margin({ left: 16, right: 16 })
        .backgroundColor('rgba(217,70,239,0.07)').borderRadius(12)
        .border({ width: 1, color: 'rgba(217,70,239,0.2)' })
        .alignItems(HorizontalAlign.Start)

        // ── 执行模式 ─────────────────────────────────────────
        this.SectionTitle('⚡ 三种执行模式（点击切换）')
        Column() {
          ForEach(EXECUTE_MODES, (mode: IntentExecuteMode, index: number) => {
            Column() {
              Row() {
                Text(mode.icon).fontSize(22).margin({ right: 10 })
                Column() {
                  Text(mode.mode)
                    .fontSize(13).fontWeight(FontWeight.Bold)
                    .fontColor(this.selectedMode === index ? mode.color : '#94A3B8')
                  Text(mode.abilityType)
                    .fontSize(10).fontColor('#64748B').fontFamily('monospace').margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start).layoutWeight(1)
                Text(this.selectedMode === index ? '▲' : '▼')
                  .fontSize(10).fontColor('#64748B')
              }
              if (this.selectedMode === index) {
                Column() {
                  Text(mode.desc)
                    .fontSize(11).fontColor('#94A3B8').lineHeight(18).margin({ top: 10, bottom: 8 })
                  Text('执行时序：')
                    .fontSize(10).fontColor('#64748B').margin({ bottom: 4 })
                  Text(mode.lifecycle)
                    .fontSize(11).fontColor(mode.color).fontFamily('monospace')
                    .backgroundColor(`${mode.color}11`).padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .borderRadius(6).width('100%')
                }
              }
            }
            .width('100%').padding(14)
            .backgroundColor(this.selectedMode === index ? `${mode.color}12` : '#FFFFFF')
            .borderRadius(12).border({ width: 1, color: this.selectedMode === index ? `${mode.color}44` : 'rgba(0,0,0,0.05)' })
            .alignItems(HorizontalAlign.Start).margin({ bottom: 8 })
            .onClick(() => { this.selectedMode = index; })
          })
        }
        .width('100%').padding({ left: 16, right: 16 })

        // ── 开发步骤 ─────────────────────────────────────────
        this.SectionTitle('📝 意图开发三步骤（点击展开代码）')
        Column() {
          ForEach(INTENT_EXAMPLES, (example: IntentExample, index: number) => {
            Column() {
              Row() {
                Text(example.title)
                  .fontSize(12).fontWeight(FontWeight.Bold)
                  .fontColor(this.expandedExample === index ? '#D946EF' : '#334155')
                  .layoutWeight(1)
                Text(this.expandedExample === index ? '▲' : '▼')
                  .fontSize(10).fontColor('#64748B')
              }
              .margin({ bottom: this.expandedExample === index ? 8 : 0 })

              if (this.expandedExample === index) {
                Text(example.desc)
                  .fontSize(11).fontColor('#94A3B8').lineHeight(16).margin({ bottom: 8 })
                Column() {
                  Text(example.code)
                    .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
                }
                .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
              }
            }
            .width('100%').padding(14)
            .backgroundColor(this.expandedExample === index ? 'rgba(217,70,239,0.08)' : '#FFFFFF')
            .borderRadius(12).border({ width: 1, color: this.expandedExample === index ? 'rgba(217,70,239,0.35)' : 'rgba(0,0,0,0.05)' })
            .alignItems(HorizontalAlign.Start).margin({ bottom: 8 })
            .onClick(() => { this.expandedExample = this.expandedExample === index ? -1 : index; })
          })
        }
        .width('100%').padding({ left: 16, right: 16 })

        // ── AgentExtensionAbility ─────────────────────────────
        this.SectionTitle('🤖 AgentExtensionAbility 智能体服务')
        Column() {
          Text('AgentExtensionAbility（API 15+）用于实现应用内的 AI 智能体服务，可被小艺等系统助手调用，使用大语言模型完成复杂自然语言任务。')
            .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 12 })

          Row() {
            Text('🧩 与 InsightIntent 的关系：')
              .fontSize(11).fontWeight(FontWeight.Bold).fontColor('#D946EF')
          }
          .margin({ bottom: 8 })

          Text('• InsightIntent：结构化指令，精确触发特定功能\n• AgentExtensionAbility：自然语言交互，由 LLM 理解用户意图并规划多步骤执行\n• 两者配合：Agent 可调用多个 InsightIntent 实现复杂任务链')
            .fontSize(11).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 12 })

          Column() {
            Text('// AgentExtensionAbility 基本结构\nexport default class MyAgent extends AgentExtensionAbility {\n  onCreate() {\n    // 初始化 AI 模型、工具注册\n  }\n\n  onQuery(query: AgentQuery): AgentResponse {\n    // 接收自然语言问题\n    const userInput = query.userInput;\n    \n    // 调用 LLM 分析意图\n    const intent = this.llm.analyze(userInput);\n    \n    // 调用相应 InsightIntent\n    if (intent === "play_music") {\n      return this.executeMusicIntent(query);\n    }\n    \n    return { text: "已为您处理完成" };\n  }\n}')
              .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
          }
          .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
        }
        .width('100%').padding(14)
        .margin({ left: 16, right: 16, bottom: 32 })
        .backgroundColor('rgba(217,70,239,0.07)').borderRadius(12)
        .border({ width: 1, color: 'rgba(217,70,239,0.2)' })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
