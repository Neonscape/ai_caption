import { router } from '@kit.ArkUI';


//给历史记录打包
class history_packet{
  image:string = ''//图片地址
  title:string = ''//标题
  desc:string = ''//描述
  request_token:string = ''//每个任务的token
  user_token:string = 'user_token'//用户的token，此处默认token为全局变量
  constructor(title: string, desc: string,image:string) {
    this.title = title;
    this.desc = desc;
    this.image = image;
  }
}




@Entry
@Component

export default struct history {
  //packet被修改之后页面会刷新
  @State packet:Array<history_packet> = []
  @State message:string = '点击右上角“+”开始生成'
  before_page_show()
  {
    //TODO 与后端交互获取
    let tmp=new history_packet('name1','desc','image')
    this.packet.push(tmp)
  }
  aboutToAppear(): void {
    this.before_page_show()
  }
  @Builder
  customMenu() {
    Row() {
      Button('+')
        .backgroundColor('white')
        .fontColor('black')
        .fontSize(40)
        .onClick(() => {
          router.pushUrl({url:'pages/picture_confrim_page'})

          //测试使用，后续可修改为从生成页面返回的request_token信息或其他信息
          let tmp=new history_packet('name','desc','image')
          this.packet.push(tmp)
        console.log('自定义菜单1被点击');//TODO 跳转到上传图片的页面
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
                router.pushUrl({
                  url:'pages/picture_show_page',
                  params:{
                    image:item.image,
                    title:item.title,
                    desc:item.desc
                  }})

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
