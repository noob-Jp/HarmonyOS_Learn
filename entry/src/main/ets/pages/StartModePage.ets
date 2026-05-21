import { router } from '@kit.ArkUI';

// ============================================================
//  启动模式 & 组件启动规则页
//  知识点：
//  - singleton（单例模式）：全局唯一实例
//  - multiton（多实例模式）：每次启动新实例
//  - specified（指定实例模式）：根据 key 决定复用/新建
//  - 组件启动规则：前台限制、后台启动限制
//  - 应用内 UIAbility 跳转
// ============================================================

interface StartModeCard {
  mode: string;
  icon: string;
  color: string;
  title: string;
  description: string;
  scenario: string;
  config: string;
  pros: string[];
  cons: string[];
}

const START_MODES: StartModeCard[] = [
  {
    mode: 'singleton',
    icon: '1️⃣',
    color: '#6366F1',
    title: 'singleton 单例模式',
    description: '全局只存在一个该 UIAbility 实例。重复启动时，不创建新实例，而是将已有实例切换到前台，并通过 onNewWant 传递新的参数。',
    scenario: '适用场景：主页、全局设置页面等不需要多开的页面',
    config: '"launchType": "singleton"',
    pros: ['节省内存', '状态保持一致', '最常用的默认模式'],
    cons: ['无法同时打开多个实例']
  },
  {
    mode: 'multiton',
    icon: '♾️',
    color: '#8B5CF6',
    title: 'multiton 多实例模式',
    description: '每次启动都会创建一个新的 UIAbility 实例。实例之间相互独立，互不影响。',
    scenario: '适用场景：文档编辑器、浏览器标签页等需要多开的功能',
    config: '"launchType": "multiton"',
    pros: ['支持多实例并行', '实例隔离互不干扰'],
    cons: ['消耗更多内存', '需要管理实例生命周期']
  },
  {
    mode: 'specified',
    icon: '🎯',
    color: '#EC4899',
    title: 'specified 指定实例模式',
    description: '由 AbilityStage 的 onAcceptWant 决定使用哪个实例。传入相同的 key 时复用已有实例，不同 key 则创建新实例。',
    scenario: '适用场景：文档管理（同一文件复用同一实例）',
    config: '"launchType": "specified"',
    pros: ['精确控制实例复用', '灵活的实例管理策略'],
    cons: ['需要 AbilityStage 配合实现']
  }
];

interface StartRule {
  icon: string;
  color: string;
  rule: string;
  detail: string;
}

const START_RULES: StartRule[] = [
  {
    icon: '✅',
    color: '#34D399',
    rule: '前台应用可启动任何 UIAbility',
    detail: '当应用处于前台可见状态时，可以自由启动本应用或其他应用的 UIAbility 组件（目标 UIAbility 需 exported:true 或同应用）'
  },
  {
    icon: '🚫',
    color: '#EF4444',
    rule: '后台应用启动受限',
    detail: 'API 12 起，后台应用默认不允许启动 UIAbility，防止应用在后台弹窗骚扰用户。需要申请 START_ABILITY_FROM_BACKGROUND 权限或使用通知等方式触发'
  },
  {
    icon: '⚠️',
    color: '#FBBF24',
    rule: 'exported 控制可见性',
    detail: '其他应用启动时，目标 UIAbility 必须设置 exported:true，否则拒绝启动并返回错误码'
  },
  {
    icon: '🔒',
    color: '#94A3B8',
    rule: '系统限制启动弹窗',
    detail: 'HarmonyOS 严格限制应用在无用户交互的情况下弹窗，确保用户体验不受干扰'
  }
];

@Entry
@Component
struct StartModePage {
  @State selectedMode: number = 0;
  @State showRules: boolean = false;
  @State codeVisible: boolean = false;

  @Builder
  PageHeader() {
    Column() {
      Row() {
        Text('←')
          .fontSize(20)
          .fontColor('#94A3B8')
          .margin({ right: 12 })
          .onClick(() => router.back())
        Column() {
          Text('启动模式 & 组件启动规则')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
          Text('singleton / multiton / specified')
            .fontSize(11)
            .fontColor('#64748B')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text('🚀').fontSize(24)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13)
      .fontWeight(FontWeight.Bold)
      .fontColor('#8B5CF6')
      .letterSpacing(0.5)
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  ModeSelector() {
    Row() {
      ForEach(START_MODES, (mode: StartModeCard, index: number) => {
        Column() {
          Text(mode.icon)
            .fontSize(20)
          Text(mode.mode)
            .fontSize(10)
            .fontColor(this.selectedMode === index ? '#1E293B' : '#64748B')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .padding({ top: 10, bottom: 10 })
        .backgroundColor(this.selectedMode === index ? `${mode.color}33` : '#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: this.selectedMode === index ? mode.color : 'rgba(0,0,0,0.05)' })
        .margin({ right: index < 2 ? 8 : 0 })
        .onClick(() => { this.selectedMode = index; })
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  ModeDetail() {
    Column() {
      // 头部
      Row() {
        Text(START_MODES[this.selectedMode].icon).fontSize(28).margin({ right: 10 })
        Column() {
          Text(START_MODES[this.selectedMode].title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(START_MODES[this.selectedMode].color)
          Text(START_MODES[this.selectedMode].scenario)
            .fontSize(10)
            .fontColor('#64748B')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .margin({ bottom: 14 })

      // 描述
      Text(START_MODES[this.selectedMode].description)
        .fontSize(12)
        .fontColor('#334155')
        .lineHeight(20)
        .width('100%')
        .margin({ bottom: 14 })

      // 配置
      Row() {
        Text('配置：')
          .fontSize(11)
          .fontColor('#64748B')
        Text(START_MODES[this.selectedMode].config)
          .fontSize(11)
          .fontColor('#0284C7')
          .fontFamily('monospace')
          .layoutWeight(1)
      }
      .width('100%')
      .padding(10)
      .backgroundColor('rgba(0,0,0,0.3)')
      .borderRadius(8)
      .margin({ bottom: 14 })

      // 优缺点
      Row() {
        Column() {
          Text('✅ 优点')
            .fontSize(11)
            .fontColor('#34D399')
            .margin({ bottom: 6 })
          ForEach(START_MODES[this.selectedMode].pros, (pro: string) => {
            Text(`• ${pro}`)
              .fontSize(11)
              .fontColor('#94A3B8')
              .margin({ bottom: 4 })
          }, (pro: string) => pro)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text('⚠️ 限制')
            .fontSize(11)
            .fontColor('#FBBF24')
            .margin({ bottom: 6 })
          ForEach(START_MODES[this.selectedMode].cons, (con: string) => {
            Text(`• ${con}`)
              .fontSize(11)
              .fontColor('#94A3B8')
              .margin({ bottom: 4 })
          }, (con: string) => con)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .border({ width: 1, color: `${START_MODES[this.selectedMode].color}44` })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StartRuleItem(rule: StartRule) {
    Row() {
      Text(rule.icon)
        .fontSize(20)
        .margin({ right: 12 })
      Column() {
        Text(rule.rule)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(rule.color)
          .margin({ bottom: 4 })
        Text(rule.detail)
          .fontSize(11)
          .fontColor('#94A3B8')
          .lineHeight(18)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
    .margin({ bottom: 8 })
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()

        // ── 启动模式选择 ─────────────────────────────────────
        this.SectionTitle('🎛️ 三种启动模式（点击切换）')
        this.ModeSelector()

        // 间距
        Blank().height(12)

        // ── 模式详情 ─────────────────────────────────────────
        this.ModeDetail()

        // ── onNewWant 说明（singleton） ───────────────────────
        this.SectionTitle('📬 onNewWant 回调（singleton 专属）')
        Column() {
          Text('当 singleton 实例已存在时，再次被启动不会触发 onCreate，而是触发 onNewWant 回调，开发者可在此处理新的 Want 参数（如更新页面内容）。')
            .fontSize(12)
            .fontColor('#94A3B8')
            .lineHeight(18)
            .margin({ bottom: 10 })
          Column() {
            Text('// UIAbility.ts\nonNewWant(want: Want, launchParam: LaunchParam): void {\n  // 处理新的启动参数，更新 UI 状态\n  AppStorage.setOrCreate("newWantData", want.parameters);\n}')
              .fontSize(11)
              .fontColor('#0284C7')
              .fontFamily('monospace')
              .lineHeight(18)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F8FAFC')
          .borderRadius(8)
        }
        .width('100%')
        .padding(14)
        .margin({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
        .alignItems(HorizontalAlign.Start)

        // ── 应用内跳转示例 ────────────────────────────────────
        this.SectionTitle('🔗 应用内 UIAbility 跳转')
        Column() {
          Text('同一应用内，使用 context.startAbility(want) 跳转到其他 UIAbility：')
            .fontSize(12)
            .fontColor('#94A3B8')
            .lineHeight(18)
            .margin({ bottom: 10 })
          Column() {
            Text('const want: Want = {\n  bundleName: "com.example.myapp",\n  abilityName: "DetailAbility",\n  parameters: { "articleId": 42 }\n};\nawait context.startAbility(want);')
              .fontSize(11)
              .fontColor('#0284C7')
              .fontFamily('monospace')
              .lineHeight(18)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F8FAFC')
          .borderRadius(8)
        }
        .width('100%')
        .padding(14)
        .margin({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
        .alignItems(HorizontalAlign.Start)

        // ── 组件启动规则 ─────────────────────────────────────
        this.SectionTitle('📋 组件启动规则（Stage 模型）')
        Column() {
          ForEach(START_RULES, (rule: StartRule) => {
            this.StartRuleItem(rule)
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 32 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6F9')
  }
}
