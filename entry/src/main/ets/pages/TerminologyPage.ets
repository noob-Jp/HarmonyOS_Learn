import { router } from '@kit.ArkUI';

// ============================================================
//  Ability Kit 术语表页
//  知识点：所有核心术语的定义、关系与对比
// ============================================================

interface Term {
  term: string;
  english: string;
  category: string;
  color: string;
  definition: string;
  related: string[];
  note: string;
}

const TERMS: Term[] = [
  {
    term: 'UIAbility',
    english: 'UIAbility',
    category: '组件',
    color: '#6366F1',
    definition: '包含 UI 界面的应用组件，是应用与用户交互的基本单元，由系统统一调度。每个 UIAbility 实例对应一个任务管理器条目。',
    related: ['AbilityStage', 'WindowStage', 'Want'],
    note: 'Stage 模型核心组件，替代了 FA 模型的 PageAbility'
  },
  {
    term: 'ExtensionAbility',
    english: 'ExtensionAbility',
    category: '组件',
    color: '#EF4444',
    definition: '没有 UI 界面的应用组件，用于特定场景扩展（后台服务、卡片、输入法等）。根据场景有多种子类型。',
    related: ['ServiceExtensionAbility', 'FormExtensionAbility', 'BackupExtensionAbility'],
    note: '替代了 FA 模型的 ServiceAbility 和 DataAbility'
  },
  {
    term: 'AbilityStage',
    english: 'AbilityStage',
    category: '容器',
    color: '#F59E0B',
    definition: '每个 HAP 模块级别的应用组件容器，与 HAP 包一一对应。负责模块级初始化，生命周期早于模块内任何 UIAbility。',
    related: ['UIAbility', 'HAP', 'srcEntry'],
    note: '需手动在 module.json5 中通过 srcEntry 注册'
  },
  {
    term: 'WindowStage',
    english: 'WindowStage',
    category: '窗口',
    color: '#06B6D4',
    definition: 'UIAbility 与窗口系统之间的管理器。每个 UIAbility 实例绑定一个 WindowStage，通过 loadContent 加载页面内容。',
    related: ['UIAbility', 'window.Window', 'loadContent'],
    note: '只在 UIAbility 的 onWindowStageCreate 生命周期中可用'
  },
  {
    term: 'Want',
    english: 'Want',
    category: '通信',
    color: '#EC4899',
    definition: '组件间传递信息的载体对象，包含目标组件的身份信息（bundleName/abilityName）和参数（parameters）。分显式和隐式两种。',
    related: ['UIAbility', 'startAbility', 'skills'],
    note: '类似 Android 的 Intent，是跨组件通信的标准方式'
  },
  {
    term: 'Context',
    english: 'Context',
    category: '运行时',
    color: '#8B5CF6',
    definition: '应用运行时的上下文对象，提供访问应用资源、文件系统、启动组件等能力。分三层：Application / AbilityStage / UIAbility 级别。',
    related: ['ApplicationContext', 'UIAbilityContext', 'AbilityStageContext'],
    note: '层级越低，能力越具体，通常在 UIAbility 中使用 this.context'
  },
  {
    term: 'HAP',
    english: 'HarmonyOS Ability Package',
    category: '包',
    color: '#10B981',
    definition: '应用安装和运行的基本单元，分为 entry（入口）和 feature（功能）两种类型。一个应用可以包含多个 HAP。',
    related: ['HAR', 'HSP', 'module.json5'],
    note: 'HAP 是真正安装到设备上的可执行包'
  },
  {
    term: 'HAR',
    english: 'HarmonyOS Ability Resources',
    category: '包',
    color: '#34D399',
    definition: '静态共享包，可在同一应用的不同 HAP 间或跨应用共享代码和资源。编译时静态链接到 HAP 中。',
    related: ['HAP', 'HSP'],
    note: 'HAR 不能单独安装，其代码被打包进引用方的 HAP'
  },
  {
    term: 'HSP',
    english: 'HarmonyOS Shared Package',
    category: '包',
    color: '#FBBF24',
    definition: '动态共享包，运行时共享。同一设备上的多个 HAP 可以共用同一份 HSP，减少安装包体积。',
    related: ['HAP', 'HAR'],
    note: 'HSP 需要单独安装，适合多个应用共享同一基础库'
  },
  {
    term: 'AppStorage',
    english: 'AppStorage',
    category: '数据',
    color: '#818CF8',
    definition: '进程级的全局状态存储，同一进程内的所有页面和组件都可以通过 @StorageLink/@StorageProp 访问，数据不跨进程。',
    related: ['LocalStorage', 'PersistentStorage', '@StorageLink'],
    note: '进程内全局共享，应用退出后数据消失'
  },
  {
    term: 'PersistentStorage',
    english: 'PersistentStorage',
    category: '数据',
    color: '#A78BFA',
    definition: '持久化存储，数据会写入设备本地文件，应用重启后仍然保留。基于 AppStorage 提供持久化能力。',
    related: ['AppStorage', 'LocalStorage'],
    note: '只能存储简单类型（string/number/boolean），不支持复杂对象'
  },
  {
    term: 'TaskPool',
    english: 'TaskPool',
    category: '并发',
    color: '#2DD4BF',
    definition: '系统级任务池，用于执行并发的短时任务。开发者通过 @Concurrent 装饰器标注函数，系统自动管理线程创建与销毁。',
    related: ['Worker', '@Concurrent', 'taskpool.Task'],
    note: '推荐方案，无需管理线程生命周期，系统自动调度'
  },
  {
    term: 'InsightIntent',
    english: 'InsightIntent',
    category: '意图',
    color: '#D946EF',
    definition: '意图框架，将应用功能拆解为可被系统/助手直接调用的"意图"。通过 @InsightIntentPage 或 @InsightIntentEntry 声明。',
    related: ['AgentExtensionAbility', '@InsightIntentPage', 'intentProfile.json'],
    note: 'HarmonyOS 原子化服务的核心机制，实现无需打开 App 即可调用功能'
  },
  {
    term: 'Bundle',
    english: 'Bundle',
    category: '应用',
    color: '#64748B',
    definition: '应用的唯一标识单元，由 bundleName 标识。一个 Bundle 包含应用的所有 HAP 包和资源，对应一个已安装的应用。',
    related: ['HAP', 'bundleName', 'BundleManager'],
    note: 'bundleName 是应用的"身份证"，一旦上架不可更改'
  },
];

interface Category {
  name: string;
  color: string;
}

const CATEGORIES: Category[] = [
  { name: '全部', color: '#6366F1' },
  { name: '组件', color: '#EF4444' },
  { name: '包', color: '#10B981' },
  { name: '数据', color: '#818CF8' },
  { name: '并发', color: '#2DD4BF' },
  { name: '意图', color: '#D946EF' },
];

@Entry
@Component
struct TerminologyPage {
  @State selectedCategory: string = '全部';
  @State expandedTerm: string = '';
  @State searchText: string = '';
  @State filteredTerms: Term[] = TERMS.slice();

  // ArkTS struct 不支持 get 访问器，改为普通方法
  updateFilter(): void {
    this.filteredTerms = TERMS.filter((t: Term) => {
      const matchCategory: boolean =
        this.selectedCategory === '全部' || t.category === this.selectedCategory;
      const searchLower: string = this.searchText.toLowerCase();
      const matchSearch: boolean =
        this.searchText === '' ||
        t.term.toLowerCase().includes(searchLower) ||
        t.definition.includes(this.searchText);
      return matchCategory && matchSearch;
    });
  }

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('Ability Kit 术语表').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('核心概念 · 定义 · 关系对比').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('📚').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 8 })
  }

  @Builder
  SearchBar() {
    Row() {
      Text('🔍').fontSize(16).margin({ right: 8 })
      TextInput({ text: this.searchText, placeholder: '搜索术语...' })
        .fontSize(13)
        .fontColor('#1E293B')
        .placeholderColor('#94A3B8')
        .backgroundColor('transparent')
        .layoutWeight(1)
        .onChange((value: string) => {
          this.searchText = value;
          this.updateFilter();
        })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .margin({ left: 16, right: 16 })
    .backgroundColor('rgba(0,0,0,0.05)')
    .borderRadius(12)
    .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
  }

  @Builder
  CategoryFilter() {
    Scroll() {
      Row() {
        ForEach(CATEGORIES, (cat: Category) => {
          Text(cat.name)
            .fontSize(11)
            .fontColor(this.selectedCategory === cat.name ? '#F4F6F9' : '#64748B')
            .backgroundColor(this.selectedCategory === cat.name ? cat.color : 'rgba(0,0,0,0.05)')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(20)
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedCategory = cat.name;
              this.updateFilter();
            })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .width('100%')
  }

  @Builder
  TermCard(term: Term) {
    Column() {
      Row() {
        Column() {
          Row() {
            Text(term.term)
              .fontSize(15).fontWeight(FontWeight.Bold).fontColor(term.color)
            Text(` · ${term.category}`)
              .fontSize(10).fontColor('#64748B')
          }
          Text(term.english)
            .fontSize(10).fontColor('#94A3B8').fontFamily('monospace').margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)

        Text(this.expandedTerm === term.term ? '▲' : '▼')
          .fontSize(12).fontColor('#64748B')
      }
      .width('100%')

      if (this.expandedTerm === term.term) {
        Column() {
          Text(term.definition)
            .fontSize(12).fontColor('#334155').lineHeight(18).margin({ top: 10, bottom: 10 })

          Row() {
            Text('相关：').fontSize(10).fontColor('#64748B').margin({ right: 6 })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(term.related, (r: string) => {
                Text(r)
                  .fontSize(10).fontColor(term.color)
                  .backgroundColor(`${term.color}18`)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .borderRadius(10)
                  .margin({ right: 6, bottom: 4 })
              })
            }
            .layoutWeight(1)
          }
          .width('100%').margin({ bottom: 8 })

          Row() {
            Text('💡 ').fontSize(12)
            Text(term.note)
              .fontSize(11).fontColor('#94A3B8').layoutWeight(1).lineHeight(16)
          }
          .width('100%')
          .padding(10)
          .backgroundColor(`${term.color}0F`)
          .borderRadius(8)
        }
        .animation({ duration: 250, curve: Curve.EaseOut })
      }
    }
    .width('100%').padding(14)
    .backgroundColor(this.expandedTerm === term.term ? `${term.color}0F` : '#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: this.expandedTerm === term.term ? `${term.color}44` : 'rgba(0,0,0,0.05)' })
    .alignItems(HorizontalAlign.Start).margin({ bottom: 8 })
    .onClick(() => {
      this.expandedTerm = this.expandedTerm === term.term ? '' : term.term;
    })
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()

        // 搜索栏
        this.SearchBar()
        Blank().height(12)

        // 分类筛选
        this.CategoryFilter()
        Blank().height(12)

        // 统计
        Row() {
          Text(`共 ${this.filteredTerms.length} 个术语`)
            .fontSize(11).fontColor('#64748B')
        }
        .width('100%').padding({ left: 16, right: 16 })

        Blank().height(8)

        // 术语列表
        Column() {
          ForEach(this.filteredTerms, (term: Term) => {
            this.TermCard(term)
          }, (term: Term) => term.term)
          if (this.filteredTerms.length === 0) {
            Column() {
              Text('🔍').fontSize(48).margin({ bottom: 12 })
              Text('没有找到匹配的术语').fontSize(14).fontColor('#94A3B8')
            }
            .width('100%').padding(60).alignItems(HorizontalAlign.Center)
          }
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 32 })
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
