import { router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { JSON } from '@kit.ArkTS';




//给历史记录打包
export  class history_packet{
  image:string = ''//图片地址
  title:string = ''//标题
  desc:string = ''//描述
  request_token:string = ''//任务token
  //user_token:string = 'user_token'//用户的token，此处默认token为全局变量
  constructor(title: string, desc: string,image:string) {
    this.title = title;
    this.desc = desc;
    this.image = image;
  }
}
/*const jsonString = `{
  "items": [
    {
      "status": true,
      "index": 0,
      "image": "base64_encoded_image_string_1",
      "title": "Example Title 1",
      "desc": "Example Description 1"
    },
    {
      "status": false,
      "index": 2,
      "image": "",
      "title": "",
      "desc": ""
    },
    {
      "status": true,
      "index": 0,
      "image": "base64_encoded_image_string_2",
      "title": "Example Title 2",
      "desc": "Example Description 2"
    }
  ]
}`;*/

interface Item {
  status: boolean;
  index?: number; // 可选字段，因为只有在未完成时才会有值
  image?: string; // 可选字段
  title?: string; // 可选字段
  desc?: string;  // 可选字段
}
interface HistoryResponse {
  items: Item[];
}



@Entry
@Component

export default struct history {
  //packet被修改之后页面会刷新

  @State index:number = 0
  @State packet:Array<history_packet> = []
  @State message:string = '点击右上角“+”开始生成'
  push_packet(title:string,desc:string,image:string)
  {
    let tmp=new history_packet(title,desc,image)
    this.packet.push(tmp)
  }
  un_json(data:string)
  {
    //console.debug(data)
    let js_data = JSON.parse(data);
    (js_data as HistoryResponse).items.forEach(item=>
    {
      if(item.title&&item.desc&&item.image)
      {
        this.push_packet(item.title,item.desc,item.image)
      }
      else
      {
        this.push_packet('正在生成','','')
      }
    })
  }

  before_page_show()
  {
    //TODO 与后端交互获取
    let http_request = http.createHttp()
    http_request.request(
      "POST /history",//url
      {
        method:http.RequestMethod.GET,
        header:{
          'Authorization': 'Bearer ' // + user_token
        }
    },(err,data)=>{
        if(!err)
        {
          this.un_json(data.result as string)
        }
        else {
          console.error('请求失败:',err)
        }
    })
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

        console.log('自定义菜单1被点击');//TODO 跳转到上传图片的页面
      })
    }
  }
  build() {

    Column() {
      Navigation() {
        Text()
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
