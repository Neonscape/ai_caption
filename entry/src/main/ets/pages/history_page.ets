class history_packet{
  image:string = ''
  title:string = ''
  desc:string = ''
  user_token:string = 'user_token'
  constructor(name: string, icon: string,image:string) {
    this.title = name;
    this.desc = icon;
    this.image = image;
  }
}
let global_packet:Array<history_packet> = []
@Entry
@Component
@Preview
struct history {
  @State packet:Array<history_packet> = global_packet
  @State message:string = '点击右上角“+”开始生成'
  @Builder
  customMenu() {
    Row() {
      Button('+')
        .backgroundColor('white')
        .fontColor('black')
        .fontSize(40)
        .onClick(() => {
        console.log('自定义菜单1被点击');//TODO
      })
    }
  }
  build() {
    Column() {
      Navigation() {
        if(this.packet.length==0)
        {
          Column(){
            Text(this.message).align(Alignment.Center)
          }

        }
        else {
          List({space:10})
          {

            ForEach(this.packet, (item: history_packet) => {
              ListItem() {
                Column() {
                  Text(item.title).fontSize(30).fontWeight(FontWeight.Normal)
                  Text(item.desc).fontSize(20).fontWeight(FontWeight.Regular)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }.backgroundColor(0xDCDCDC)
              .onClick(()=>{
                //TODO 跳转到显示页面
              })
            })
          }
          .height("100%")
          .width('100%')
        }
      }
      .mode(NavigationMode.Stack)
      .title("历史记录")
      .menus(this.customMenu())

    }
  }
}
