import { router } from '@kit.ArkUI';

// ============================================================
//  Want 信息传递载体页
//  知识点：
//  - Want 的作用：组件间通信的消息载体
//  - 显式 Want：明确指定 bundleName + abilityName
//  - 隐式 Want：通过 action/entities/uri/type 匹配
//  - Want 参数传递（parameters）
//  - skills 配置与隐式 Want 匹配规则
//  - 应用间跳转
// ============================================================

interface WantField {
  field: string;
  type: string;
  desc: string;
  example: string;
  required: boolean;
}

const WANT_FIELDS: WantField[] = [
  { field: 'deviceId',     type: 'string',          desc: '目标设备 ID（空字符串=本机）',         example: '""',                         required: false },
  { field: 'bundleName',   type: 'string',          desc: '目标应用的 Bundle 名称',              example: '"com.example.myapp"',         required: false },
  { field: 'moduleName',   type: 'string',          desc: '目标 HAP 模块名称',                  example: '"entry"',                     required: false },
  { field: 'abilityName',  type: 'string',          desc: '目标 UIAbility 类名（显式必填）',      example: '"EntryAbility"',              required: false },
  { field: 'action',       type: 'string',          desc: '意图动作（隐式匹配使用）',             example: '"ohos.want.action.viewData"', required: false },
  { field: 'entities',     type: 'string[]',        desc: '实体类别（隐式匹配使用）',             example: '["entity.system.home"]',      required: false },
  { field: 'uri',          type: 'string',          desc: '资源路径，用于隐式匹配文件/URL',       example: '"file://path/to/doc"',        required: false },
  { field: 'type',         type: 'string',          desc: 'MIME 类型，用于隐式匹配',             example: '"image/jpeg"',                required: false },
  { field: 'parameters',   type: 'Record<string,Object>', desc: '自定义键值对参数',           example: '{"key": "value"}',            required: false },
  { field: 'flags',        type: 'number',          desc: '控制能力（如安装 HAP 包等）',          example: 'wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION', required: false },
];

@Entry
@Component
struct WantPage {
  @State selectedTab: number = 0;
  @State paramKey: string = 'userId';
  @State paramValue: string = '10086';
  @State builtWant: string = '';
  @StorageLink('wantBundleName') wantBundleName: string = '';
  @StorageLink('wantAbilityName') wantAbilityName: string = '';
  @StorageLink('wantParameters') wantParameters: string = '{}';

  aboutToAppear() {
    this.buildWantJson();
  }

  buildWantJson() {
    // 直接拼接字符串，避免 ArkTS 不支持的计算属性名
    this.builtWant = `{
  "bundleName": "com.example.myapp",
  "abilityName": "DetailAbility",
  "parameters": {
    "${this.paramKey}": "${this.paramValue}"
  }
}`;
  }

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('Want 信息传递载体').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('组件间通信的消息包').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('📦').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#EC4899')
      .letterSpacing(0.5).width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  WantTypeCard(isExplicit: boolean) {
    Column() {
      Row() {
        Text(isExplicit ? '🎯' : '🔍').fontSize(24).margin({ right: 10 })
        Column() {
          Text(isExplicit ? '显式 Want' : '隐式 Want')
            .fontSize(15).fontWeight(FontWeight.Bold)
            .fontColor(isExplicit ? '#6366F1' : '#EC4899')
          Text(isExplicit ? '明确指定目标组件' : '通过规则匹配目标组件')
            .fontSize(11).fontColor('#64748B').margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)
      }
      .margin({ bottom: 12 })

      if (isExplicit) {
        Text('必须同时指定 bundleName 和 abilityName，系统直接定位目标。适用于同应用内跳转或已知目标的跨应用调用。')
          .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 12 })
        Column() {
          Text('const want: Want = {\n  bundleName: "com.example.app",\n  abilityName: "DetailAbility",\n  parameters: { "id": 42 }\n};')
            .fontSize(11).fontColor('#0284C7').fontFamily('monospace').lineHeight(16)
        }
        .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      } else {
        Text('不指定 abilityName，通过 action / entities / uri / type 进行模糊匹配，系统找出所有匹配的 UIAbility 供用户选择。适用于分享、打开文件等场景。')
          .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 12 })
        Column() {
          Text('const want: Want = {\n  action: "ohos.want.action.viewData",\n  entities: ["entity.system.browser"],\n  uri: "https://www.example.com",\n  type: "text/html"\n};')
            .fontSize(11).fontColor('#0284C7').fontFamily('monospace').lineHeight(16)
        }
        .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
      }
    }
    .width('100%').padding(14)
    .backgroundColor('#FFFFFF').borderRadius(12)
    .border({ width: 1, color: isExplicit ? 'rgba(99,102,241,0.3)' : 'rgba(236,72,153,0.3)' })
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 16, right: 16, bottom: 10 })
  }

  @Builder
  WantFieldRow(field: WantField) {
    Row() {
      Column() {
        Row() {
          Text(field.field)
            .fontSize(12).fontWeight(FontWeight.Bold)
            .fontColor('#818CF8').fontFamily('monospace')
          if (field.required) {
            Text(' *').fontSize(10).fontColor('#EF4444')
          }
        }
        Text(field.type)
          .fontSize(10).fontColor('#64748B').fontFamily('monospace').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .width(110)

      Column() {
        Text(field.desc)
          .fontSize(11).fontColor('#334155').margin({ bottom: 4 }).maxLines(2)
        Text(field.example)
          .fontSize(10).fontColor('#94A3B8').fontFamily('monospace')
          .backgroundColor('rgba(0,0,0,0.3)').padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10, left: 14, right: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 4 })
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()

        // ── 当前 Want（实际接收） ─────────────────────────────
        this.SectionTitle('📡 当前 Ability 实际接收的 Want')
        Column() {
          Row() {
            Text('bundleName：').fontSize(11).fontColor('#64748B').width(100)
            Text(this.wantBundleName || 'com.example.myapplication2')
              .fontSize(11).fontColor('#34D399').fontFamily('monospace').layoutWeight(1)
          }
          .margin({ bottom: 8 })
          Row() {
            Text('abilityName：').fontSize(11).fontColor('#64748B').width(100)
            Text(this.wantAbilityName || 'EntryAbility')
              .fontSize(11).fontColor('#34D399').fontFamily('monospace').layoutWeight(1)
          }
          .margin({ bottom: 8 })
          Row() {
            Text('parameters：').fontSize(11).fontColor('#64748B').width(100)
            Text(this.wantParameters || '{}')
              .fontSize(11).fontColor('#FBBF24').fontFamily('monospace').layoutWeight(1)
          }
        }
        .width('100%').padding(14)
        .margin({ left: 16, right: 16 })
        .backgroundColor('rgba(52,211,153,0.07)')
        .borderRadius(12).border({ width: 1, color: 'rgba(52,211,153,0.2)' })
        .alignItems(HorizontalAlign.Start)

        // ── 两种 Want 类型 ───────────────────────────────────
        this.SectionTitle('📋 显式 Want vs 隐式 Want')
        this.WantTypeCard(true)
        this.WantTypeCard(false)

        // ── Want 字段速查 ─────────────────────────────────────
        this.SectionTitle('📖 Want 核心字段速查表')
        Column() {
          ForEach(WANT_FIELDS, (field: WantField) => {
            this.WantFieldRow(field)
          })
        }
        .width('100%').padding({ left: 16, right: 16 })

        // ── 应用间跳转 ───────────────────────────────────────
        this.SectionTitle('🌐 应用间跳转')
        Column() {
          Text('跨应用跳转时需注意：\n① 目标应用的 UIAbility 必须设置 exported: true\n② 隐式跳转若找到多个匹配，系统弹出选择器\n③ 可通过 startAbilityForResult 获取返回结果')
            .fontSize(12).fontColor('#94A3B8').lineHeight(20).margin({ bottom: 12 })
          Column() {
            Text('// 应用间跳转示例\nconst want: Want = {\n  action: "ohos.want.action.sendData",\n  type: "text/plain",\n  parameters: {\n    "ohos.extra.EXTRA_TEXT": "Hello from App A"\n  }\n};\nawait context.startAbility(want);\n\n// 获取返回结果\nconst result = await context.startAbilityForResult(want);\nconsole.log("resultCode:", result.resultCode);')
              .fontSize(11).fontColor('#0284C7').fontFamily('monospace').lineHeight(16)
          }
          .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
        }
        .width('100%').padding(14)
        .margin({ left: 16, right: 16, bottom: 32 })
        .backgroundColor('#FFFFFF').borderRadius(12)
        .border({ width: 1, color: 'rgba(0,0,0,0.05)' })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
