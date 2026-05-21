import { router } from '@kit.ArkUI';

// ============================================================
//  主页 - HarmonyOS Ability Kit 知识大全导航中心
//  知识点：应用模型概述、Stage 模型架构、各能力导航入口
// ============================================================

interface NavCard {
  id: string;
  icon: string;
  title: string;
  subtitle: string;
  tag: string;
  color: string;
  route: string;
  topics: string[];
}

const NAV_CARDS: NavCard[] = [
  {
    id: 'lifecycle',
    icon: '⚡',
    title: 'UIAbility 生命周期',
    subtitle: '应用组件的完整生命旅程',
    tag: '核心',
    color: '#6366F1',
    route: 'pages/LifecyclePage',
    topics: ['onCreate', 'onForeground', 'onBackground', 'onDestroy', 'WindowStage', '数据同步', '跨端迁移']
  },
  {
    id: 'startmode',
    icon: '🚀',
    title: '启动模式 & 启动规则',
    subtitle: 'singleton / multiton / specified',
    tag: '重要',
    color: '#8B5CF6',
    route: 'pages/StartModePage',
    topics: ['singleton', 'multiton', 'specified', '前台启动规则', '后台启动规则', '应用内跳转']
  },
  {
    id: 'want',
    icon: '📦',
    title: 'Want 信息传递载体',
    subtitle: '应用间通信的消息包',
    tag: '核心',
    color: '#EC4899',
    route: 'pages/WantPage',
    topics: ['显式 Want', '隐式 Want', 'Want 参数', '应用间跳转', 'skills 匹配']
  },
  {
    id: 'context',
    icon: '🌐',
    title: '应用上下文 Context',
    subtitle: '获取应用运行环境信息',
    tag: '核心',
    color: '#06B6D4',
    route: 'pages/ContextPage',
    topics: ['ApplicationContext', 'UIAbilityContext', 'AbilityStageContext', '文件路径', '环境变量']
  },
  {
    id: 'abilitystage',
    icon: '🏗️',
    title: 'AbilityStage & AppStartup',
    subtitle: '模块级管理 + 启动框架',
    tag: '高级',
    color: '#F59E0B',
    route: 'pages/AbilityStagePage',
    topics: ['AbilityStage', 'AppStartup', '应用预加载', '应用重启', '异常退出原因']
  },
  {
    id: 'process',
    icon: '🔄',
    title: '进程 & 线程模型',
    subtitle: 'TaskPool / Worker / AsyncLock',
    tag: '高级',
    color: '#10B981',
    route: 'pages/ProcessThreadPage',
    topics: ['进程模型', '主线程', 'TaskPool', 'Worker', 'AsyncLock', 'Native子进程', 'IPC通信']
  },
  {
    id: 'extension',
    icon: '🧩',
    title: 'ExtensionAbility',
    subtitle: '后台服务与特殊场景扩展',
    tag: '扩展',
    color: '#EF4444',
    route: 'pages/ExtensionPage',
    topics: ['ServiceExtensionAbility', 'AppServiceExtensionAbility', 'AgentExtensionAbility', 'EmbeddedUI', 'Call调用', 'UIAbility备份恢复']
  },
  {
    id: 'config',
    icon: '⚙️',
    title: '配置文件详解',
    subtitle: 'app.json5 / module.json5',
    tag: '基础',
    color: '#64748B',
    route: 'pages/ConfigPage',
    topics: ['app.json5', 'module.json5', 'abilities配置', 'extensionAbilities', '应用/组件级配置']
  },
  {
    id: 'insight',
    icon: '🤖',
    title: '意图框架 & 智能体',
    subtitle: 'Insight Intent + Agent',
    tag: '新特性',
    color: '#D946EF',
    route: 'pages/InsightIntentPage',
    topics: ['InsightIntent', '意图声明', '意图执行', 'AgentExtensionAbility', '智能体服务']
  },
  {
    id: 'terminology',
    icon: '📚',
    title: 'Ability Kit 术语表',
    subtitle: '核心概念一览与对比',
    tag: '参考',
    color: '#0EA5E9',
    route: 'pages/TerminologyPage',
    topics: ['Ability', 'UIAbility', 'ExtensionAbility', 'HAP', 'HAR', 'HSP', 'Bundle', 'Want']
  }
];

@Entry
@Component
struct Index {
  @State selectedCard: string = '';
  @State headerOpacity: number = 0;
  @State cardsVisible: boolean = false;
  @StorageLink('lifecycleState') lifecycleState: string = '';

  aboutToAppear(): void {
    // 入场动画
    animateTo({ duration: 600, curve: Curve.EaseOut }, () => {
      this.headerOpacity = 1;
    });
    setTimeout(() => {
      animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
        this.cardsVisible = true;
      });
    }, 300);
  }

  @Builder
  ArchitectureLayer(label: string, desc: string, color: string, icon: string) {
    Row() {
      Text(icon)
        .fontSize(18)
        .margin({ right: 8 })
      Column() {
        Text(label)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
        Text(desc)
          .fontSize(10)
          .fontColor('#94A3B8')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor(color)
    .borderRadius(8)
    .margin({ bottom: 4 })
  }

  @Builder
  NavCardItem(card: NavCard, index: number) {
    Column() {
      // 卡片头部
      Row() {
        Text(card.icon)
          .fontSize(28)
        Blank()
        Text(card.tag)
          .fontSize(10)
          .fontColor(card.color)
          .backgroundColor(`${card.color}22`)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(10)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 标题
      Text(card.title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E293B')
        .maxLines(2)
        .margin({ bottom: 4 })
        .alignSelf(ItemAlign.Start)

      // 副标题
      Text(card.subtitle)
        .fontSize(11)
        .fontColor('#94A3B8')
        .margin({ bottom: 10 })
        .alignSelf(ItemAlign.Start)

      // Topics chips
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(card.topics.slice(0, 3), (topic: string) => {
          Text(topic)
            .fontSize(9)
            .fontColor('#334155')
            .backgroundColor('rgba(0,0,0,0.05)')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ right: 4, bottom: 4 })
        })
        if (card.topics.length > 3) {
          Text(`+${card.topics.length - 3}`)
            .fontSize(9)
            .fontColor('#64748B')
            .backgroundColor('#FFFFFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
        }
      }
      .width('100%')

      Blank()

      // 进入按钮
      Row() {
        Text('查看详情')
          .fontSize(11)
          .fontColor(card.color)
        Text(' →')
          .fontSize(11)
          .fontColor(card.color)
      }
      .margin({ top: 8 })
      .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .height(190)
    .padding(14)
    .backgroundColor(this.selectedCard === card.id ? `${card.color}33` : 'rgba(0,0,0,0.05)')
    .borderRadius(16)
    .border({
      width: 1,
      color: this.selectedCard === card.id ? card.color : 'rgba(0,0,0,0.08)'
    })
    .shadow({
      radius: this.selectedCard === card.id ? 20 : 0,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 4
    })
    .scale({ x: this.selectedCard === card.id ? 0.97 : 1, y: this.selectedCard === card.id ? 0.97 : 1 })
    .opacity(this.cardsVisible ? 1 : 0)
    .translate({ y: this.cardsVisible ? 0 : 30 })
    .animation({
      duration: 300 + index * 50,
      curve: Curve.EaseOut,
      delay: index * 30
    })
    .onClick(() => {
      this.selectedCard = card.id;
      router.pushUrl({ url: card.route }).catch((err: Error) => {
        console.error('Navigation failed:', err.message);
      });
    })
  }

  build() {
    Scroll() {
      Column() {
        // ── Header ──────────────────────────────────────────
        Column() {
          // 徽标行
          Row() {
            Column() {
              Text('HarmonyOS')
                .fontSize(11)
                .fontColor('#6366F1')
                .fontWeight(FontWeight.Medium)
                .letterSpacing(2)
              Text('Ability Kit')
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E293B')
                .lineHeight(32)
              Text('知识全景探索')
                .fontSize(13)
                .fontColor('#94A3B8')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 状态指示器
            Column() {
              Text('⚡')
                .fontSize(32)
                .margin({ bottom: 4 })
              Text(this.lifecycleState || 'onForeground')
                .fontSize(9)
                .fontColor('#34D399')
                .backgroundColor('rgba(52,211,153,0.15)')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(8)
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .margin({ bottom: 16 })

          // Stage 模型架构层级图
          Column() {
            Row() {
              Text('📐 Stage 模型架构')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#334155')
              Blank()
              Text('当前激活')
                .fontSize(10)
                .fontColor('#6366F1')
            }
            .width('100%')
            .margin({ bottom: 8 })

            this.ArchitectureLayer('Application', 'App全局配置 · ApplicationContext', 'rgba(99,102,241,0.25)', '🏢')
            this.ArchitectureLayer('AbilityStage', '模块容器 · 模块级初始化入口', 'rgba(139,92,246,0.20)', '🏗️')
            this.ArchitectureLayer('UIAbility', '交互核心 · 完整生命周期管理', 'rgba(236,72,153,0.20)', '⚡')
            this.ArchitectureLayer('WindowStage → Page → Component', '窗口管理 · 页面路由 · UI组件树', 'rgba(6,182,212,0.20)', '🪟')
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
          .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 60, bottom: 20 })
        .opacity(this.headerOpacity)
        .animation({ duration: 600, curve: Curve.EaseOut })

        // ── 统计栏 ──────────────────────────────────────────
        Row() {
          Column() {
            Text('10')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#6366F1')
            Text('知识模块')
              .fontSize(10)
              .fontColor('#64748B')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Divider().vertical(true).height(30).color('rgba(0,0,0,0.08)')

          Column() {
            Text('40+')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8B5CF6')
            Text('核心知识点')
              .fontSize(10)
              .fontColor('#64748B')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Divider().vertical(true).height(30).color('rgba(0,0,0,0.08)')

          Column() {
            Text('100%')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#10B981')
            Text('文档覆盖率')
              .fontSize(10)
              .fontColor('#64748B')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 16 })
        .backgroundColor('#FFFFFF')

        // ── 知识卡片网格 ─────────────────────────────────────
        Text('知识模块')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#64748B')
          .letterSpacing(1)
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 10 })

        Grid() {
          ForEach(NAV_CARDS, (card: NavCard, index: number) => {
            GridItem() {
              this.NavCardItem(card, index)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .padding({ left: 16, right: 16, bottom: 16 })
        .width('100%')

        // ── FA 模型说明 ──────────────────────────────────────
        Column() {
          Row() {
            Text('⚠️')
              .fontSize(16)
              .margin({ right: 8 })
            Text('FA 模型（已废弃）')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FBBF24')
          }
          .width('100%')
          .margin({ bottom: 8 })

          Text('HarmonyOS 早期采用 Feature Ability (FA) 模型，现已全面迁移至 Stage 模型。新应用开发请统一使用 Stage 模型。FA 模型中的 PageAbility、ServiceAbility、DataAbility 已分别被 UIAbility 和 ExtensionAbility 取代。')
            .fontSize(11)
            .fontColor('#94A3B8')
            .lineHeight(18)
        }
        .width('100%')
        .padding(14)
        .margin({ left: 16, right: 16, bottom: 32 })
        .backgroundColor('rgba(251,191,36,0.08)')
        .borderRadius(12)
        .border({ width: 1, color: 'rgba(251,191,36,0.25)' })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6F9')
  }
}