import { router } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';


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

        Text('AppServiceExtensionAbility')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#F97316').margin({ bottom: 10 })

        // 限制说明
        Row() {
          Text('🚫  ').fontSize(12)
          Text('需要系统级签名，普通三方应用不可使用（报错 801 Capability not supported）')
            .fontSize(11).fontColor('#D97706').layoutWeight(1).lineHeight(16)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 12, right: 12 })
        .backgroundColor('#FFFBEB').borderRadius(8)
        .border({ width: 1, color: '#FDE68A' })
        .margin({ bottom: 20 })

        // vs 对比卡片
        Text('与 长时任务 (ContinuousTask) 的对比')
          .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

        Row() {
          // AppService 列
          Column() {
            Text('AppService\nExtensionAbility').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#F97316').textAlign(TextAlign.Center).margin({ bottom: 8 })
            Column() {
              this.CompareRow('权限', '系统级签名')
              this.CompareRow('进程', '独立服务进程')
              this.CompareRow('绑定', 'IPC 远程调用')
              this.CompareRow('适用', '系统应用')
            }
          }
          .layoutWeight(1).padding(12)
          .backgroundColor('#FFF7ED').borderRadius(10)
          .border({ width: 1.5, color: '#FB923C' })
          .margin({ right: 8 })

          // ContinuousTask 列
          Column() {
            Text('ContinuousTask\n长时任务').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#10B981').textAlign(TextAlign.Center).margin({ bottom: 8 })
            Column() {
              this.CompareRow('权限', '普通应用权限')
              this.CompareRow('进程', '主进程后台')
              this.CompareRow('绑定', 'API 直接调用')
              this.CompareRow('适用', '普通应用 ✅')
            }
          }
          .layoutWeight(1).padding(12)
          .backgroundColor('#F0FDF4').borderRadius(10)
          .border({ width: 1.5, color: '#34D399' })
        }
        .width('100%').margin({ bottom: 20 })

        // 工作原理图
        Text('AppServiceExtensionAbility 工作原理')
          .fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

        Column() {
          Row() {
            Column() {
              Text('📱').fontSize(20)
              Text('客户端 App').fontSize(9).fontColor('#94A3B8').margin({ top: 2 })
            }
            .width('28%').padding(10).backgroundColor('#1E293B').borderRadius(8)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text('connectAppService\nExtensionAbility()').fontSize(7).fontColor('#38BDF8').textAlign(TextAlign.Center)
              Text('→  IPC 远程调用  →').fontSize(8).fontColor('#94A3B8').margin({ top: 4 })
            }
            .layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text('⚙️').fontSize(20)
              Text('服务进程').fontSize(9).fontColor('#94A3B8').margin({ top: 2 })
            }
            .width('28%').padding(10).backgroundColor('#1C1917').borderRadius(8)
            .border({ width: 1, color: '#F97316' })
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          }
          .width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%').padding(12).backgroundColor('#0F172A').borderRadius(12).margin({ bottom: 20 })

        // 场景卡片
        Text('应用场景').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })
        Column() {
          this.FeatureRow('🔊', '音乐播放服务', '系统级音乐 App 的后台播放控制。')
          this.FeatureRow('📱', '设备管理', 'MDM 企业设备管理、安全监控。')
          this.FeatureRow('🧪', '应用内测试替代', '普通应用推荐用长时任务 (ContinuousTask)实现同样的后台能力。')
        }
        .backgroundColor('#FFFFFF').borderRadius(12).padding(4)
        .border({ width: 1, color: '#E2E8F0' })

      }
      .width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  CompareRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(10).fontColor('#94A3B8').width(36)
      Text(value).fontSize(10).fontColor('#1E293B').layoutWeight(1)
    }
    .width('100%').margin({ bottom: 6 })
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

        Text('ShareExtensionAbility')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#10B981').margin({ bottom: 10 })

        // 注意说明
        Row() {
          Text('ℹ️  ').fontSize(12)
          Text('系统分享面板已弹出（✅ 成功），但需在真机安装后才能在列表中看到本 App。')
            .fontSize(11).fontColor('#0369A1').layoutWeight(1).lineHeight(16)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 12, right: 12 })
        .backgroundColor('#EFF6FF').borderRadius(8)
        .border({ width: 1, color: '#BFDBFE' })
        .margin({ bottom: 20 })

        // 工作原理图
        Text('工作流程').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

        // 发送方
        Column() {
          Text('① 发送方 (任意 App)').fontSize(10).fontColor('#94A3B8').margin({ bottom: 6 })
          Row() {
            Column() {
              Text('📤').fontSize(20)
              Text('ShareController\n.show()').fontSize(8).fontColor('#6EE7B7').textAlign(TextAlign.Center).margin({ top: 4 })
            }
            .width('45%').height(64).backgroundColor('#064E3B').borderRadius(8)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text('→  系统 Share 服务  →').fontSize(9).fontColor('#94A3B8')
              Text('UTD 类型匹配').fontSize(8).fontColor('#6EE7B7').margin({ top: 4 })
            }
            .layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text('📋').fontSize(20)
              Text('系统分享\n选择器').fontSize(8).fontColor('#94A3B8').textAlign(TextAlign.Center).margin({ top: 4 })
            }
            .width('35%').height(64).backgroundColor('#1E293B').borderRadius(8)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          }
          .width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%').padding(12).backgroundColor('#052E16').borderRadius(12).margin({ bottom: 6 })

        Text('↓  用户从列表选择我们的 App').fontSize(9).fontColor('#94A3B8').textAlign(TextAlign.Center).width('100%').margin({ bottom: 6 })

        // 接收方
        Column() {
          Text('② 接收方 (我们的 App)').fontSize(10).fontColor('#94A3B8').margin({ bottom: 6 })
          Row() {
            Column() {
              Text('📥').fontSize(20)
              Text('ShareExtension\nAbility').fontSize(8).fontColor('#6EE7B7').textAlign(TextAlign.Center).margin({ top: 4 })
              Text('onSessionCreate').fontSize(7).fontColor('#94A3B8').margin({ top: 3 })
            }
            .width('45%').height(64).backgroundColor('#064E3B').borderRadius(8)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text('→  加载专属 UI  →').fontSize(9).fontColor('#94A3B8')
            }
            .layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text('🗂️').fontSize(20)
              Text('SharePage.ets').fontSize(8).fontColor('#6EE7B7').textAlign(TextAlign.Center).margin({ top: 4 })
            }
            .width('35%').height(64).backgroundColor('#052E16').borderRadius(8)
            .border({ width: 1, color: '#10B981' })
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          }
          .width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%').padding(12).backgroundColor('#F0FDF4').borderRadius(12)
        .border({ width: 1, color: '#A7F3D0' }).margin({ bottom: 20 })

        // 演示按钮区
        Text('实战演示').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

        Button('🗂️  直接查看分享接收界面')
          .width('100%').height(46).backgroundColor('#0F766E').fontColor('#FFFFFF').fontSize(14)
          .margin({ bottom: 10 })
          .onClick(() => {
            // 直接导航到 SharePage 展示接收界面长什么样
            router.pushUrl({ url: 'pages/SharePage' });
          })

        Button('🌐  唤起系统分享面板')
          .width('100%').height(46).backgroundColor('#10B981').fontColor('#FFFFFF').fontSize(14)
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

        Text('⬆  系统分享面板成功弹出即代表 ShareKit API 调用成功。在完整真机环境下，本 App 会出现在选择器中，选择后会拉起 SharePage.ets 显示接收到的内容。')
          .fontSize(11).fontColor('#6B7280').lineHeight(17).margin({ top: 12 })
          .padding(12).backgroundColor('#F9FAFB').borderRadius(8)
          .border({ width: 1, color: '#E5E7EB' })

        // 关键 API 卡片
        Divider().margin({ top: 20, bottom: 14 }).color('#E2E8F0')
        Text('关键配置要点').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })
        Column() {
          this.FeatureRow('🏷️', 'module.json5 注册', 'type: "share" + skills.actions: "ohos.want.action.sendData"')
          this.FeatureRow('📐', 'UTD 类型匹配', '发送方 SharedData.utd 必须与接收方 skills.uris 中的类型对应')
          this.FeatureRow('🖼️', '专属接收 UI', 'onSessionCreate 中加载 SharePage，显示接收内容')
          this.FeatureRow('↩️', '结果回传', 'session.terminateSelfWithResult() 将结果传回发送方')
        }
        .backgroundColor('#FFFFFF').borderRadius(12).padding(4)
        .border({ width: 1, color: '#E2E8F0' })

      }
      .width('100%').padding(16).alignItems(HorizontalAlign.Start)
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
          this.EmbeddedUISection()
        }.tabBar('嵌入式 UI')

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
  EmbeddedUISection() {
    Scroll() {
      Column() {
        Text('EmbeddedUIExtensionAbility')
          .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#06B6D4').margin({ bottom: 10 })

        // 设备支持提示
        Row() {
          Text('⚠️  ').fontSize(12)
          Text('仅支持折叠屏 / 平板 / 2-in-1 设备，手机及模拟器不可用')
            .fontSize(11).fontColor('#D97706').layoutWeight(1).lineHeight(16)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 12, right: 12 })
        .backgroundColor('#FFFBEB').borderRadius(8)
        .border({ width: 1, color: '#FDE68A' })
        .margin({ bottom: 20 })

        // 原理图：宿主进程
        Text('工作原理').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })

        Column() {
          Text('宿主进程 (Host App UIAbility)').fontSize(9).fontColor('#94A3B8').margin({ bottom: 8 })
          Row() {
            Column() {
              Text('普通 UI').fontSize(10).fontColor('#E2E8F0')
              Text('正常渲染').fontSize(8).fontColor('#94A3B8').margin({ top: 2 })
            }
            .width('45%').height(60).backgroundColor('#334155').borderRadius(8)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text('🔲').fontSize(20)
              Text('<EmbeddedComponent>').fontSize(7).fontColor('#38BDF8').margin({ top: 2 })
            }
            .width('45%').height(60)
            .border({ width: 2, color: '#38BDF8', style: BorderStyle.Dashed })
            .borderRadius(8).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            .backgroundColor('#0F172A')
          }
          .width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%').padding(12).backgroundColor('#1E293B').borderRadius(12).margin({ bottom: 6 })

        Text('↕  跨进程图形缓冲区合成  /  terminateSelfWithResult() 传回结果')
          .fontSize(9).fontColor('#94A3B8').textAlign(TextAlign.Center).width('100%').margin({ bottom: 6 })

        // 原理图：提供方进程
        Column() {
          Text('提供方独立沙箱进程 (EmbeddedUIExtensionAbility)').fontSize(9).fontColor('#94A3B8').margin({ bottom: 8 })
          Column() {
            Text('🔒').fontSize(26)
            Text('安全控件（如支付键盘）').fontSize(10).fontColor('#67E8F9').margin({ top: 4 })
            Text('崩溃 → 不影响宿主').fontSize(9).fontColor('#94A3B8').margin({ top: 3 })
          }
          .width('100%').height(80).backgroundColor('#042424').borderRadius(10)
          .border({ width: 1, color: '#06B6D4' })
          .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        .width('100%').padding(12).backgroundColor('#F0FDFF').borderRadius(12)
        .border({ width: 1, color: '#A5F3FC' }).margin({ bottom: 20 })

        // 特性卡片
        Text('核心价值').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#334155').margin({ bottom: 10 })
        Column() {
          this.FeatureRow('🛡️', '进程安全隔离', '密码/数据对宿主完全不可见，防止恶意窃取。')
          this.FeatureRow('💥', '崩溃隔离', '嵌入组件崩溃不会导致主 App 闪退。')
          this.FeatureRow('🎨', '视觉无缝融合', '用户感知不到两个进程的边界。')
          this.FeatureRow('📍', '典型场景', '第三方支付面板、高德地图、文档编辑器插件。')
        }
        .backgroundColor('#FFFFFF').borderRadius(12).padding(4)
        .border({ width: 1, color: '#E2E8F0' })

      }
      .width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  FeatureRow(icon: string, title: string, desc: string) {
    Row() {
      Text(icon).fontSize(16).margin({ right: 10 })
      Column() {
        Text(title).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text(desc).fontSize(11).fontColor('#64748B').lineHeight(16).margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)
    }
    .width('100%').padding({ top: 10, bottom: 10, left: 12, right: 12 })
    .border({ width: 0.5, color: '#F1F5F9' })
    .alignItems(VerticalAlign.Top)
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
