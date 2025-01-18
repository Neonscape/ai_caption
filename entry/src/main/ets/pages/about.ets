@Entry
@Component
struct About {
  build() {
    Column() {
      // Navigation Bar
      Navigation()
        .title('关于我们')
        .height(90)
        .backgroundColor('#4CAF50')
        .titleMode(NavigationTitleMode.Mini)
        //.margin({ top: 30 })

      // Application Info Section
      Column() {
        Row() {
          Column() {
            Image($r('app.media.icon_alt')) // Replace with actual logo
              .width(120)
              .height(120)
              .borderRadius(15)
            // .alignment('center')
            Text($r('app.string.EntryAbility_label'))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
            // .alignment('center')
            Text('用AI描绘你的生活！')
              .fontSize(18)
              .fontColor('#666')
            // .alignment('center')
          }
        }
        .margin({ top: 20 })
        .padding({ bottom: 20 })
      }

      // Developer and Project Information Section
      Column() {
        Row() {
          Text('开发者：')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .padding(10)
        .alignSelf(ItemAlign.Start)

        Row() {
          Text(`寇冠权 黄家豪 何昊宇 顾晓宇 周沫 王智鹏`)
            .fontSize(16)
            .fontColor('#555')
            .padding({ bottom: 5 })
        }
        .width('100%')
        .padding({ left: 10 })
        .alignSelf(ItemAlign.Start)
        .borderWidth({ bottom: 1 })
        .borderColor('#e3e4e5')

        // Project Description
        Row() {
          Text('项目简介：')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .padding(10)
        .alignSelf(ItemAlign.Start)

        Row() {
          Text(`用AI描述你的生活，为生活增添乐趣`)
            .fontSize(14)
            .fontColor('#555')
            .padding({ bottom: 5 })
        }
        .width('100%')
        .padding({ left: 10 })
        .alignSelf(ItemAlign.Start)

        // Contact and Social Links
        Row() {
          Text('联系方式：')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .padding(10)
        .alignSelf(ItemAlign.Start)

        Row() {
          Text(`邮箱: neonscapemail@gmail.com`) // Replace with real email
            .fontSize(14)
            .fontColor('#555')
            .padding({ bottom: 5 })
        }
        .width('100%')
        .padding({ left: 10 })
        .alignSelf(ItemAlign.Start)
        .borderWidth({ bottom: 1 })
        .borderColor('#e3e4e5')

        Row() {
          Text('项目地址：')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .padding(10)
        .alignSelf(ItemAlign.Start)

        Row() {
          Text(`https://git.nju.edu.cn/Neonscape/ai_caption_frontend`)
            .fontSize(14)
            .fontColor('#0066cc')
            .padding({ bottom: 5 })
            .onClick(() => {
              // Open the GitHub project link when clicked
              // openUrl('https://git.nju.edu.cn/Neonscape/ai_caption_frontend');
            })
        }
        .width('100%')
        .padding({ left: 10 })
        .alignSelf(ItemAlign.Start)
        .borderWidth({ bottom: 1 })
        .borderColor('#e3e4e5')

        // Check for Updates Section
        Row() {
          Text('检查更新')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .padding(10)
        .alignSelf(ItemAlign.Start)

        Row() {
          Text(`已是最新版本`)
            .fontSize(14)
            .fontColor('#666')
            .padding({ bottom: 5 })
        }
        .width('100%')
        .padding({ left: 10 })
        .alignSelf(ItemAlign.Start)
      }
      .width('90%')
      .margin({ top: 30 })
      .backgroundColor('#fff')
      .borderRadius(20)
      .padding({ top: 20, bottom: 20, left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f7f7f7')
  }
}
