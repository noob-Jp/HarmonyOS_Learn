import { router } from '@kit.ArkUI';

// ============================================================
//  应用配置文件详解页
//  知识点：
//  - app.json5 结构（应用级配置）
//  - module.json5 结构（模块级配置）
//  - abilities 配置项详解
//  - extensionAbilities 配置
//  - 应用/组件级配置（图标、标签、权限等）
// ============================================================

interface ConfigField {
  field: string;
  type: string;
  required: boolean;
  desc: string;
  example: string;
}

const APP_JSON5_FIELDS: ConfigField[] = [
  { field: 'bundleName',    type: 'string',   required: true,  desc: '应用包名，全局唯一标识（反向域名格式）',  example: '"com.example.myapp"' },
  { field: 'vendor',        type: 'string',   required: true,  desc: '开发商名称',                             example: '"MyCompany"' },
  { field: 'versionCode',   type: 'number',   required: true,  desc: '版本号（整数，每次发版递增）',           example: '1000000' },
  { field: 'versionName',   type: 'string',   required: true,  desc: '版本名称（展示给用户）',                 example: '"1.0.0"' },
  { field: 'icon',          type: 'resource', required: true,  desc: '应用图标资源引用',                       example: '"$media:app_icon"' },
  { field: 'label',         type: 'resource', required: true,  desc: '应用名称资源引用',                       example: '"$string:app_name"' },
  { field: 'minAPIVersion', type: 'number',   required: false, desc: '支持的最低 API 版本',                   example: '12' },
  { field: 'targetAPIVersion', type: 'number', required: false, desc: '目标 API 版本',                       example: '15' },
  { field: 'appPreloadingEnabled', type: 'boolean', required: false, desc: '开启应用预加载加速启动',          example: 'true' },
  { field: 'multiProjects', type: 'boolean',  required: false, desc: '是否多 HAP 共享数据沙箱',              example: 'false' },
];

const MODULE_JSON5_FIELDS: ConfigField[] = [
  { field: 'name',          type: 'string',   required: true,  desc: 'HAP 模块名称（工程内唯一）',             example: '"entry"' },
  { field: 'type',          type: 'string',   required: true,  desc: '模块类型：entry/feature/shared',          example: '"entry"' },
  { field: 'mainElement',   type: 'string',   required: true,  desc: '主 UIAbility 名称（作为应用入口）',       example: '"EntryAbility"' },
  { field: 'srcEntry',      type: 'string',   required: false, desc: 'AbilityStage 入口文件路径',              example: '"./ets/abilitystage/MyAbilityStage.ets"' },
  { field: 'deviceTypes',   type: 'string[]', required: true,  desc: '支持的设备类型列表',                     example: '["phone", "tablet"]' },
  { field: 'pages',         type: 'string',   required: false, desc: '页面路由配置文件引用',                   example: '"$profile:main_pages"' },
  { field: 'abilities',     type: 'object[]', required: false, desc: 'UIAbility 组件配置列表',                 example: '[{...}]' },
  { field: 'extensionAbilities', type: 'object[]', required: false, desc: 'ExtensionAbility 组件配置列表',    example: '[{...}]' },
  { field: 'requestPermissions', type: 'object[]', required: false, desc: '运行时权限申请列表',               example: '[{"name":"ohos.permission.CAMERA"}]' },
  { field: 'definePermissions', type: 'object[]', required: false, desc: '自定义权限声明（跨应用访问控制）',  example: '[{"name":"com.example.MY_PERMISSION"}]' },
];

const ABILITY_FIELDS: ConfigField[] = [
  { field: 'name',          type: 'string',   required: true,  desc: 'UIAbility 类名（同代码文件中的类名）',   example: '"EntryAbility"' },
  { field: 'srcEntry',      type: 'string',   required: true,  desc: 'UIAbility 源文件路径',                   example: '"./ets/entryability/EntryAbility.ets"' },
  { field: 'launchType',    type: 'string',   required: false, desc: '启动模式：singleton/multiton/specified', example: '"singleton"' },
  { field: 'exported',      type: 'boolean',  required: false, desc: '是否允许其他应用启动（默认false）',      example: 'true' },
  { field: 'icon',          type: 'resource', required: false, desc: '该 Ability 的图标（用于任务管理器）',    example: '"$media:icon"' },
  { field: 'label',         type: 'resource', required: false, desc: '该 Ability 的标签',                     example: '"$string:ability_name"' },
  { field: 'description',   type: 'resource', required: false, desc: '该 Ability 描述',                       example: '"$string:ability_desc"' },
  { field: 'skills',        type: 'object[]', required: false, desc: '隐式 Want 匹配规则（actions/entities/uris）', example: '[{"entities":[...],"actions":[...]}]' },
  { field: 'startWindowIcon', type: 'resource', required: false, desc: '启动窗口（闪屏）图标',               example: '"$media:startIcon"' },
  { field: 'startWindowBackground', type: 'resource', required: false, desc: '启动窗口背景色',               example: '"$color:start_window_background"' },
];

@Entry
@Component
struct ConfigPage {
  @State selectedTab: number = 0;
  @State expandedField: string = '';

  private tabs: string[] = ['app.json5', 'module.json5', 'abilities配置'];

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('应用配置文件详解').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('app.json5 · module.json5 · abilities').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('⚙️').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  SectionTitle(text: string) {
    Text(text)
      .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#64748B')
      .letterSpacing(0.5).width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }

  @Builder
  TabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Text(tab)
          .fontSize(11)
          .fontColor(this.selectedTab === index ? '#818CF8' : '#64748B')
          .fontFamily('monospace')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.selectedTab === index ? 'rgba(129,140,248,0.15)' : 'transparent')
          .borderRadius(8)
          .border({ width: this.selectedTab === index ? 1 : 0, color: 'rgba(129,140,248,0.4)' })
          .onClick(() => { this.selectedTab = index; this.expandedField = ''; })
      })
    }
    .width('100%').padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  FieldRow(field: ConfigField) {
    Column() {
      Row() {
        Column() {
          Row() {
            Text(field.field)
              .fontSize(12).fontWeight(FontWeight.Bold).fontColor('#818CF8').fontFamily('monospace')
            if (field.required) {
              Text(' *').fontSize(10).fontColor('#EF4444')
            }
          }
          Text(field.type)
            .fontSize(9).fontColor('#64748B').fontFamily('monospace').margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start).width(160)

        Text(field.desc)
          .fontSize(11).fontColor('#94A3B8').layoutWeight(1).maxLines(2)

        Text(this.expandedField === field.field ? '▲' : '▼')
          .fontSize(10).fontColor('#64748B')
      }
      .width('100%')

      if (this.expandedField === field.field) {
        Column() {
          Text('示例值：')
            .fontSize(10).fontColor('#64748B').margin({ top: 8, bottom: 4 })
          Text(field.example)
            .fontSize(11).fontColor('#0284C7').fontFamily('monospace')
            .backgroundColor('#F8FAFC').padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .borderRadius(6).width('100%')
        }
        .animation({ duration: 200, curve: Curve.EaseOut })
      }
    }
    .width('100%').padding(12)
    .backgroundColor(this.expandedField === field.field ? 'rgba(129,140,248,0.08)' : '#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: this.expandedField === field.field ? 'rgba(129,140,248,0.3)' : 'rgba(0,0,0,0.05)' })
    .alignItems(HorizontalAlign.Start).margin({ bottom: 4 })
    .onClick(() => {
      this.expandedField = this.expandedField === field.field ? '' : field.field;
    })
  }

  @Builder
  FullExample(title: string, code: string, color: string) {
    Column() {
      Text(title)
        .fontSize(12).fontWeight(FontWeight.Bold).fontColor(color).margin({ bottom: 8 })
      Column() {
        Text(code)
          .fontSize(10).fontColor('#0284C7').fontFamily('monospace').lineHeight(14)
      }
      .width('100%').padding(12).backgroundColor('#F8FAFC').borderRadius(8)
    }
    .width('100%').padding(14)
    .margin({ left: 16, right: 16 })
    .backgroundColor(`${color}0A`).borderRadius(12)
    .border({ width: 1, color: `${color}30` })
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Scroll() {
      Column() {
        this.PageHeader()

        this.SectionTitle('📂 配置文件类型')
        this.TabBar()

        if (this.selectedTab === 0) {
          this.SectionTitle('📋 app.json5 字段说明（点击展开示例）')
          Column() {
            Text('app.json5 位于 AppScope/ 目录，全局只有一份，配置整个应用的元数据。')
              .fontSize(11).fontColor('#64748B').lineHeight(16).margin({ bottom: 10 })
            ForEach(APP_JSON5_FIELDS, (field: ConfigField) => {
              this.FieldRow(field)
            })
          }
          .width('100%').padding({ left: 16, right: 16 })

          this.SectionTitle('📄 完整示例')
          this.FullExample('app.json5 完整示例', '{\n  "app": {\n    "bundleName": "com.example.myapp",\n    "vendor": "MyCompany",\n    "versionCode": 1000000,\n    "versionName": "1.0.0",\n    "icon": "$media:app_icon",\n    "label": "$string:app_name",\n    "minAPIVersion": 12,\n    "targetAPIVersion": 15,\n    "appPreloadingEnabled": true\n  }\n}', '#6366F1')

        } else if (this.selectedTab === 1) {
          this.SectionTitle('📋 module.json5 字段说明（点击展开示例）')
          Column() {
            Text('module.json5 位于各 HAP 模块的 src/main/ 目录，配置该模块的组件和权限。')
              .fontSize(11).fontColor('#64748B').lineHeight(16).margin({ bottom: 10 })
            ForEach(MODULE_JSON5_FIELDS, (field: ConfigField) => {
              this.FieldRow(field)
            })
          }
          .width('100%').padding({ left: 16, right: 16 })

          this.SectionTitle('📄 完整示例')
          this.FullExample('module.json5 完整示例', '{\n  "module": {\n    "name": "entry",\n    "type": "entry",\n    "mainElement": "EntryAbility",\n    "srcEntry": "./ets/abilitystage/MyAbilityStage.ets",\n    "deviceTypes": ["phone", "tablet"],\n    "pages": "$profile:main_pages",\n    "abilities": [{ ... }],\n    "extensionAbilities": [{ ... }],\n    "requestPermissions": [\n      { "name": "ohos.permission.CAMERA" }\n    ]\n  }\n}', '#8B5CF6')

        } else {
          this.SectionTitle('📋 abilities 配置字段（点击展开示例）')
          Column() {
            Text('abilities 数组中每一项配置一个 UIAbility 组件，至少需要配置一个 entryAbility 作为应用入口。')
              .fontSize(11).fontColor('#64748B').lineHeight(16).margin({ bottom: 10 })
            ForEach(ABILITY_FIELDS, (field: ConfigField) => {
              this.FieldRow(field)
            })
          }
          .width('100%').padding({ left: 16, right: 16 })

          this.SectionTitle('📄 abilities 完整示例')
          this.FullExample('单个 ability 配置示例', '"abilities": [{\n  "name": "EntryAbility",\n  "srcEntry": "./ets/entryability/EntryAbility.ets",\n  "icon": "$media:layered_image",\n  "label": "$string:EntryAbility_label",\n  "description": "$string:EntryAbility_desc",\n  "startWindowIcon": "$media:startIcon",\n  "startWindowBackground": "$color:start_window_background",\n  "exported": true,\n  "launchType": "singleton",\n  "skills": [{\n    "entities": ["entity.system.home"],\n    "actions": ["ohos.want.action.home"]\n  }]\n}]', '#EC4899')
        }

        Blank().height(32)
      }
      .width('100%')
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }
}
