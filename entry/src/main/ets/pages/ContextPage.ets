import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

// ============================================================
//  应用上下文 Context 页
//  知识点：
//  - Context 层级：ApplicationContext > AbilityStageContext > UIAbilityContext
//  - UIAbilityContext 常用 API：startAbility / terminateSelf / 文件路径
//  - ApplicationContext：全局信息获取、监听注册
//  - 获取/设置环境变量（systemLanguage / colorMode 等）
// ============================================================

interface ContextLevel {
  icon: string;
  name: string;
  color: string;
  parentOf: string;
  desc: string;
  apis: string[];
  code: string;
}

const CONTEXT_LEVELS: ContextLevel[] = [
  {
    icon: '🏢',
    name: 'ApplicationContext',
    color: '#6366F1',
    parentOf: '最顶层',
    desc: '应用级上下文，一个应用只有一个实例。可以获取应用级别的信息（包名、版本等），注册全局监听器（内存/配置/Ability生命周期），设置颜色模式。',
    apis: [
      'getApplicationContext()',
      'setColorMode(ColorMode)',
      'registerAbilityLifecycleCallback()',
      'registerEnvironmentCallback()',
      'registerMemoryLevel()',
      'kill() - 终止整个应用进程',
      'getRunningProcessInformation()'
    ],
    code: '// 获取 ApplicationContext\nconst appCtx = this.context.getApplicationContext();\n\n// 设置深色模式\nappCtx.setColorMode(ColorMode.COLOR_MODE_DARK);\n\n// 注册配置变更监听\nappCtx.registerEnvironmentCallback({\n  onConfigurationUpdated(config) {\n    console.log("语言变更:", config.language);\n  }\n});'
  },
  {
    icon: '🏗️',
    name: 'AbilityStageContext',
    color: '#8B5CF6',
    parentOf: 'Module 级别',
    desc: '模块级上下文，对应 AbilityStage。可获取模块级别的信息（HAP 包信息、模块路径等）。',
    apis: [
      'currentHapModuleInfo - 当前 HAP 信息',
      'config - 当前配置（语言/颜色模式）',
      'filesDir / cacheDir / tempDir',
      'getGroupDir(groupId) - 数据组目录',
    ],
    code: '// 在 AbilityStage 中\nconst stageCtx = this.context;\nconst hapInfo = stageCtx.currentHapModuleInfo;\nconsole.log("模块名:", hapInfo.name);\n\n// 获取文件路径\nconsole.log("文件目录:", stageCtx.filesDir);'
  },
  {
    icon: '⚡',
    name: 'UIAbilityContext',
    color: '#EC4899',
    parentOf: 'UIAbility 级别',
    desc: '最常用的上下文，在 UIAbility 内通过 this.context 获取。提供启动/停止 Ability、拉起 UI 选择器、获取文件沙箱路径等能力。',
    apis: [
      'startAbility(want) - 启动其他 Ability',
      'startAbilityForResult(want) - 启动并等待结果',
      'terminateSelf() - 关闭当前 Ability',
      'terminateSelfWithResult(result) - 关闭并返回',
      'requestPermissionsFromUser() - 申请权限',
      'filesDir / cacheDir / databaseDir',
      'getExternalFilesDir() - 外部存储路径',
      'setMissionLabel(label) - 设置任务标签'
    ],
    code: '// 在 UIAbility 或 Page 中\nconst ctx = getContext(this) as common.UIAbilityContext;\n\n// 启动其他 Ability\nawait ctx.startAbility({\n  bundleName: "com.example.app",\n  abilityName: "DetailAbility"\n});\n\n// 获取沙箱路径\nconst filesPath = ctx.filesDir; // /data/storage/el2/base/files\nconst cacheDir  = ctx.cacheDir;'
  }
];

interface EnvVar {
  key: string;
  type: string;
  desc: string;
  values: string;
  api: string;
}

const ENV_VARS: EnvVar[] = [
  {
    key: 'systemLanguage',
    type: 'string',
    desc: '系统当前语言',
    values: '"zh-Hans" / "en" / "fr" ...',
    api: 'getConfiguration().language'
  },
  {
    key: 'colorMode',
    type: 'ColorMode',
    desc: '深色/浅色/跟随系统',
    values: 'COLOR_MODE_LIGHT / DARK / NOT_SET',
    api: 'setColorMode() / getColorMode()'
  },
  {
    key: 'direction',
    type: 'Direction',
    desc: '屏幕方向',
    values: 'DIRECTION_HORIZONTAL / VERTICAL',
    api: 'getConfiguration().direction'
  },
  {
    key: 'densityDpi',
    type: 'number',
    desc: '屏幕像素密度 (DPI)',
    values: '120 / 160 / 240 / 320 / 480 / 640',
    api: 'getConfiguration().densityDpi'
  },
  {
    key: 'fontSizeScale',
    type: 'number',
    desc: '字体大小比例系数',
    values: '0.85 / 1.0 / 1.15 / 1.3',
    api: 'getConfiguration().fontSizeScale'
  }
];

@Entry
@Component
struct ContextPage {
  @State selectedLevel: number = 2;
  @State currentFilesDir: string = '/data/storage/el2/base/files';
  @State currentCacheDir: string = '/data/storage/el2/base/cache';
  @State memoryLevel: string = '正常';

  aboutToAppear() {
    try {
      const ctx = getContext(this) as common.UIAbilityContext;
      this.currentFilesDir = ctx.filesDir ?? '/data/storage/el2/base/files';
      this.currentCacheDir = ctx.cacheDir ?? '/data/storage/el2/base/cache';
    } catch (e) {
      console.error('获取 context 失败', e);
    }
    this.memoryLevel = AppStorage.get<string>('memoryLevel') ?? '正常';
  }

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('应用上下文 Context').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('获取运行环境信息与能力').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('🌐').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#06B6D4')
      .letterSpacing(0.5).width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  ContextHierarchy() {
    Column() {
      Text('Context 继承层级关系')
        .fontSize(12).fontColor('#64748B').margin({ bottom: 12 })

      ForEach(CONTEXT_LEVELS, (level: ContextLevel, index: number) => {
        Column() {
          Row() {
            Text(level.icon).fontSize(18).margin({ right: 10 })
            Text(level.name)
              .fontSize(13).fontWeight(FontWeight.Bold)
              .fontColor(this.selectedLevel === index ? level.color : '#94A3B8')
              .layoutWeight(1)
            Text(level.parentOf)
              .fontSize(10).fontColor(level.color)
              .backgroundColor(`${level.color}22`)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 14, right: 14, top: 12, bottom: 12 })
        .backgroundColor(this.selectedLevel === index ? `${level.color}1A` : '#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: this.selectedLevel === index ? `${level.color}66` : 'rgba(0,0,0,0.05)' })
        .margin({ bottom: 4 })
        .onClick(() => { this.selectedLevel = index; })

        if (index < 2) {
          Row() {
            Text('  ↓ extends')
              .fontSize(10).fontColor('#94A3B8')
          }
          .margin({ bottom: 4 })
        }
      })
    }
    .width('100%').padding(14)
    .margin({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12).border({ width: 1, color: 'rgba(0,0,0,0.05)' })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ContextDetail(level: ContextLevel) {
    Column() {
      Row() {
        Text(level.icon).fontSize(24).margin({ right: 10 })
        Text(level.name)
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor(level.color)
      }
      .margin({ bottom: 10 })

      Text(level.desc)
        .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 12 })

      Text('常用 API：')
        .fontSize(12).fontWeight(FontWeight.Medium).fontColor('#334155').margin({ bottom: 8 })

      ForEach(level.apis, (api: string) => {
        Row() {
          Text('▸').fontSize(12).fontColor(level.color).margin({ right: 8 })
          Text(api).fontSize(11).fontColor('#94A3B8').fontFamily('monospace').layoutWeight(1)
        }
        .margin({ bottom: 4 })
      })

      Text('代码示例：')
        .fontSize(12).fontWeight(FontWeight.Medium).fontColor('#334155').margin({ top: 12, bottom: 8 })

      Column() {
        Text(level.code)
          .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(16)
      }
      .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
    }
    .width('100%').padding(14)
    .margin({ left: 16, right: 16 })
    .backgroundColor(`${level.color}10`)
    .borderRadius(12).border({ width: 1, color: `${level.color}33` })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  EnvVarRow(env: EnvVar) {
    Column() {
      Row() {
        Text(env.key)
          .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#818CF8').fontFamily('monospace')
          .layoutWeight(1)
        Text(env.type)
          .fontSize(10).fontColor('#64748B').fontFamily('monospace')
          .backgroundColor('#FFFFFF').padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
      }
      .margin({ bottom: 4 })
      Text(env.desc).fontSize(11).fontColor('#334155').margin({ bottom: 4 })
      Text(env.values).fontSize(10).fontColor('#64748B').fontFamily('monospace')
      Text(env.api).fontSize(10).fontColor('#06B6D4').fontFamily('monospace').margin({ top: 4 })
    }
    .width('100%').padding(12)
    .backgroundColor('#FFFFFF').borderRadius(8)
    .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
    .alignItems(HorizontalAlign.Start).margin({ bottom: 6 })
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()

        // ── 层级图 ───────────────────────────────────────────
        this.SectionTitle('🏛️ Context 三层继承体系（点击查看详情）')
        this.ContextHierarchy()

        // ── 选中层详情 ─────────────────────────────────────────
        Blank().height(10)
        this.ContextDetail(CONTEXT_LEVELS[this.selectedLevel])

        // ── 实际路径展示 ─────────────────────────────────────
        this.SectionTitle('📁 当前应用沙箱路径（真实值）')
        Column() {
          Row() {
            Text('filesDir：').fontSize(11).fontColor('#64748B').width(90)
            Text(this.currentFilesDir)
              .fontSize(10).fontColor('#34D399').fontFamily('monospace').layoutWeight(1).maxLines(2)
          }
          .margin({ bottom: 8 })
          Row() {
            Text('cacheDir：').fontSize(11).fontColor('#64748B').width(90)
            Text(this.currentCacheDir)
              .fontSize(10).fontColor('#FBBF24').fontFamily('monospace').layoutWeight(1).maxLines(2)
          }
        }
        .width('100%').padding(14)
        .margin({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF').borderRadius(12)
        .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
        .alignItems(HorizontalAlign.Start)

        // ── 环境变量 ─────────────────────────────────────────
        this.SectionTitle('🌍 获取/设置环境变量')
        Column() {
          ForEach(ENV_VARS, (env: EnvVar) => {
            this.EnvVarRow(env)
          })
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 32 })
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
