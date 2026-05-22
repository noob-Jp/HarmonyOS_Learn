import { router } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import { rpc } from '@kit.IPCKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';

class ServiceActionItem {
  name: string;
  code: number;
  color: string;
  constructor(name: string, code: number, color: string) {
    this.name = name;
    this.code = code;
    this.color = color;
  }
}

interface ExtensionType {
  icon: string;
  name: string;
  type: string;
  color: string;
  desc: string;
}

const EXTENSION_TYPES: ExtensionType[] = [
  { icon: '⚙️', name: 'ServiceExtensionAbility', type: 'service', color: '#EF4444', desc: '系统级后台服务，需要系统权限。可在后台常驻运行，提供进程间服务能力。' },
  { icon: '🤖', name: 'AgentExtensionAbility', type: 'agent', color: '#D946EF', desc: '智能体服务扩展（API 15+），用于实现基于大模型的智能助手能力，可被意图框架调度。' },
  { icon: '🪟', name: 'EmbeddedUIExtensionAbility', type: 'embeddedUI', color: '#06B6D4', desc: '跨进程 UI 嵌入能力。允许一个应用将自己的 UI 界面嵌入到另一个应用的 UI 中。' },
  { icon: '💾', name: 'BackupExtensionAbility', type: 'backup', color: '#10B981', desc: '应用数据备份与恢复扩展。在系统执行备份时调用，将应用数据序列化；在恢复时反序列化还原。' },
  { icon: '🔔', name: 'StaticSubscriberExtensionAbility', type: 'staticSubscriber', color: '#FBBF24', desc: '静态公共事件订阅，应用未启动时也能接收系统广播事件（如开机、安装等）。' },
  { icon: '🖼️', name: 'PhotoEditorExtensionAbility', type: 'photoEditor', color: '#94A3B8', desc: '图片编辑扩展（API 12+），允许第三方应用接入系统相册的编辑流程。' }
];

@Entry
@Component
struct ExtensionPage {
  @State isConnected: boolean = false;
  @State serviceResponse: string = '等待操作...';
  
  private connectionId: number = -1;
  private serviceProxy: rpc.IRemoteObject | null = null;

  @Builder
  PageHeader() {
    Row() {
      Text('←').fontSize(20).fontColor('#94A3B8').margin({ right: 12 }).onClick(() => router.back())
      Column() {
        Text('ExtensionAbility 示例').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('实战：后台服务 · 桌面卡片 · 分享接收').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
      Text('🧩').fontSize(24)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 56, bottom: 16 })
  }

  @Builder
  AppServiceSection() {
    Scroll() {
      Column() {
        Text('AppServiceExtensionAbility 提供了独立于 UI 的应用级后台服务进程。')
          .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ bottom: 8 })

        Text('⚠️ 注意：标准真机/模拟器可能因缺乏特权而报错 801 (Capability not supported)。普通第三方应用推荐使用“长时任务(Continuous Task)”。')
          .fontSize(11).fontColor('#EF4444').lineHeight(16).margin({ bottom: 14 })
          .backgroundColor('#FEF2F2').padding(8).borderRadius(6)

        Text('服务反馈: ' + this.serviceResponse)
          .fontSize(12)
          .fontColor(this.isConnected ? '#10B981' : '#FBBF24')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 12 })
          
        Row() {
          Button(this.isConnected ? '断开后台服务' : '绑定后台服务 (Connect)')
            .fontSize(12)
            .backgroundColor(this.isConnected ? '#EF4444' : '#10B981')
            .onClick(() => {
              const context = getContext(this) as common.UIAbilityContext;
              if (this.isConnected) {
                hilog.info(0x0000, 'ExtensionPage', 'Disconnecting service...');
                context.disconnectAppServiceExtensionAbility(this.connectionId).then(() => {
                  this.isConnected = false;
                  this.serviceProxy = null;
                  this.serviceResponse = '已断开服务';
                });
              } else {
                this.serviceResponse = '正在连接...';
                const want: Want = {
                  bundleName: 'com.example.myapplication2',
                  moduleName: 'entry',
                  abilityName: 'MyAppServiceExtAbility'
                };
                const options: common.ConnectOptions = {
                  onConnect: (elementName, remote) => {
                    this.isConnected = true;
                    this.serviceProxy = remote;
                    this.serviceResponse = '服务连接成功!';
                  },
                  onDisconnect: () => {
                    this.isConnected = false;
                    this.serviceResponse = '服务已自动断开';
                  },
                  onFailed: (code) => {
                    this.serviceResponse = '连接失败，错误码: ' + code;
                  }
                };
                this.connectionId = context.connectAppServiceExtensionAbility(want, options);
              }
            })
        }
        .width('100%').margin({ bottom: 14 })
        
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach([
            new ServiceActionItem('🎵 播放音乐', 1, '#8B5CF6'),
            new ServiceActionItem('⬇️ 后台下载', 2, '#3B82F6'),
            new ServiceActionItem('🔄 数据同步', 3, '#10B981'),
            new ServiceActionItem('📊 获取全局状态', 4, '#F59E0B')
          ], (item: ServiceActionItem) => {
            Button(item.name)
              .fontSize(11).width('48%').margin({ bottom: 8 })
              .backgroundColor(item.color)
              .enabled(this.isConnected)
              .onClick(async () => {
                if (!this.serviceProxy) return;
                try {
                  this.serviceResponse = '请求中...';
                  let data = new rpc.MessageSequence();
                  let reply = new rpc.MessageSequence();
                  let option = new rpc.MessageOption();
                  await this.serviceProxy.sendMessageRequest(item.code, data, reply, option);
                  this.serviceResponse = reply.readString();
                } catch (e) {
                  this.serviceResponse = '请求失败: ' + String(e);
                }
              })
          })
        }
        .width('100%')
      }
      .width('100%').padding(20)
    }
  }

  @Builder
  FormSection() {
    Scroll() {
      Column() {
        Text('FormExtensionAbility (服务卡片)')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#818CF8').margin({ bottom: 12 })

        Text('服务卡片允许应用将重要信息（如天气、待办）直接展示在系统桌面或锁屏上，属于高度独立的 Extension 进程。')
          .fontSize(13).fontColor('#64748B').lineHeight(20).margin({ bottom: 20 })

        Image($r('sys.media.ohos_app_icon')) // 占位图
          .width(80).height(80).borderRadius(16).margin({ bottom: 16 })

        Text('如何体验我们刚刚添加的卡片？')
          .fontSize(14).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 12 })

        Column() {
          Text('1. 编译并安装本应用到模拟器/真机。')
            .fontSize(12).fontColor('#475569').margin({ bottom: 8 })
          Text('2. 回到系统桌面 (Home键)。')
            .fontSize(12).fontColor('#475569').margin({ bottom: 8 })
          Text('3. 找到本应用的图标，长按图标。')
            .fontSize(12).fontColor('#475569').margin({ bottom: 8 })
          Text('4. 在弹出的菜单中选择「服务卡片」')
            .fontSize(12).fontColor('#475569').margin({ bottom: 8 })
          Text('5. 点击「添加到桌面」，即可看到我们在代码里写的 WidgetCard 界面啦！')
            .fontSize(12).fontColor('#475569').margin({ bottom: 8 })
        }
        .width('100%').alignItems(HorizontalAlign.Start)
        .padding(16).backgroundColor('#F8FAFC').borderRadius(12)
        
      }
      .width('100%').padding(20).alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  ShareSection() {
    Scroll() {
      Column() {
        Text('ShareExtensionAbility (分享接收)')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#10B981').margin({ bottom: 12 })

        Text('通过配置 type="share" 和对应的 intents，我们的应用可以出现在系统相册或浏览器的分享面板中，接收别的应用发来的文本或图片。')
          .fontSize(13).fontColor('#64748B').lineHeight(20).margin({ bottom: 20 })

        Button('模拟别的应用分享文本给我们')
          .width('100%').backgroundColor('#10B981').height(44)
          .onClick(() => {
            const context = getContext(this) as common.UIAbilityContext;
            let sharedData = new systemShare.SharedData({
              utd: utd.UniformDataType.IMAGE,
              uri: 'file://docs/storage/Users/currentUser/mock_image.jpg',
              content: '这是一个模拟分享的图片文件'
            });
            let controller = new systemShare.ShareController(sharedData);
            controller.show(context, {
              previewMode: systemShare.SharePreviewMode.DETAIL,
              selectionMode: systemShare.SelectionMode.SINGLE
            }).catch((err: Error) => {
              hilog.error(0x0000, 'ExtensionPage', `Share failed: ${err.message}`);
            });
          })

        Text('点击上方按钮，系统会弹出分享应用选择器，请在里面选择我们的应用，就能看到被拉起的专属分享界面 (SharePage.ets)！')
          .fontSize(12).fontColor('#94A3B8').lineHeight(18).margin({ top: 16 })
          .padding(12).backgroundColor('#F0FDF4').borderRadius(8)
      }
      .width('100%').padding(20).alignItems(HorizontalAlign.Start)
    }
  }

  build() {
    Column() {
      this.PageHeader()

      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          this.AppServiceSection()
        }.tabBar('后台服务')

        TabContent() {
          this.FormSection()
        }.tabBar('桌面卡片')

        TabContent() {
          this.ShareSection()
        }.tabBar('分享接收')

        TabContent() {
          this.OthersSection()
        }.tabBar('其他扩展')
      }
      .width('100%').layoutWeight(1)
      .barMode(BarMode.Scrollable)
      .animationDuration(300)
    }
    .width('100%').height('100%').backgroundColor('#F4F6F9')
  }

  @Builder
  OthersSection() {
    Scroll() {
      Column() {
        Text('除了我们前面演示的 AppService、Form、Share 之外，HarmonyOS 还提供了以下几种场景化的扩展：')
          .fontSize(12).fontColor('#64748B').lineHeight(18).margin({ bottom: 16 })

        ForEach(EXTENSION_TYPES, (ext: ExtensionType) => {
          Row() {
            Text(ext.icon).fontSize(24).margin({ right: 12 })
            Column() {
              Text(ext.name)
                .fontSize(13).fontWeight(FontWeight.Bold).fontColor(ext.color)
              Text(`type: "${ext.type}"`)
                .fontSize(10).fontColor('#94A3B8').fontFamily('monospace').margin({ top: 2, bottom: 4 })
              Text(ext.desc)
                .fontSize(11).fontColor('#64748B').lineHeight(16)
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .width('100%').padding(14).backgroundColor('#FFFFFF').borderRadius(12).margin({ bottom: 10 })
        })
      }
      .width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }
  }
}
