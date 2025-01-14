import router from '@ohos.router';
import profile from './profile'
import picture_confirm from './picture_confrim_page'
import picture_show from './picture_show_page'
import history from "./history_page"
let params=router.getParams() as Record<string, string>
@Entry
@Component
struct tabs {
  @State currentIndex: number = 0;
  @Builder TabBarBuilder(index: number, title: string, icon: Resource, iconSelected: Resource) {
    Column() {
      Image(this.currentIndex === index ? iconSelected : icon)
        .width(24)
        .height(24)
        .margin(5)
        .objectFit(ImageFit.Contain)
      // .borderRadius(50)
      Text(title)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#182431')
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .backgroundColor('#f7f7f7')
    .border({ width: { top: 0.5 }, color: '#bbbbbb' })
  }
  // aboutToAppear(){
  //   if(!this.user){
  //     router.replaceUrl({
  //       url:'pages/user/login'
  //     })
  //   }
  // }

  build() {
    Row() {
      Tabs({ barPosition: BarPosition.End}) {
        TabContent() {
          picture_confirm()
        }
        .tabBar(this.TabBarBuilder(0, '展示？', $r('app.media.avatar'), $r('app.media.avatar')))

        TabContent() {
          history()
        }
        .tabBar(this.TabBarBuilder(1, '历史记录？', $r('app.media.avatar'), $r('app.media.avatar')))
        TabContent() {
          profile()
        }
        .tabBar(this.TabBarBuilder(2, '主页', $r('app.media.avatar'), $r('app.media.avatar')))

      }
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
  }
}