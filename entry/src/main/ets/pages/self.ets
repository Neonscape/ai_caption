@Entry
@Component
struct Place {
  @State place: string[] = ['南京大学苏州校区', '智能软件与工程学院']

  build() {
    Column() {
      // Navigation Bar
      Navigation()
        .title('个人信息')
        .height(60)
        .titleMode(NavigationTitleMode.Mini)
        .backgroundColor('#4CAF50')
          // .titleColor('#fff')
        .margin({ top: 30, bottom: 20 })

      // Address list display section
      Column() {
        ForEach(this.place, (item: string, index: number) => {
          Row() {
            // Icon & Text
            Column() {
              Image('icon-location') // Replace with your own location icon
                .width(30)
                .height(30)
                .padding({ right: 10 })
              Text(item)
                .fontSize(20)
                .fontWeight('bold')
                .fontColor('#333')
            }
            // .alignment('center')

            // Card styling for the address
          }
          .backgroundColor('#fff')
          .borderRadius(12)
          .margin({ top: 15 })
          .width('90%')
          .padding({ top: 10, bottom: 10, left: 15, right: 15 })
          // .boxShadow('0 4px 8px rgba(0, 0, 0, 0.1)')
        })

        // Add New Address Button
        Row() {
          Button('添加新地址')
            .fontSize(18)
            .fontColor('#fff')
            .backgroundColor('#4CAF50')
            .height(50)
            .borderRadius(25)
            .width('90%')
            .margin({ top: 30 })
            .onClick(() => {
              this.place.push('南京大学苏州校区') // Replace with dynamic input if needed
            })
        }
      }

      // Container styling
    }
    .width('100%')
    .height('100%')
    .padding({ top: 30, bottom: 30 })
    .backgroundColor('#f9f9f9') // Light background for the page
  }
}
