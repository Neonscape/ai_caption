import router from '@ohos.router';
import profile from './profile'
import picture_confirm from './picture_confrim_page'
import picture_show from './picture_show_page'
// import { http } from '@kit.NetworkKit';
import { JSON } from '@kit.ArkTS';
import  PreferencesUtils from '../utils/PreferenceUtils';
import axios, { AxiosResponse, AxiosError } from '@ohos/axios'
// 获取子页面的引用
let params=router.getParams() as Record<string, string>

let user_token:string = ''
let base_url : string = 'http://192.168.3.27:8081'
//给历史记录打包
export  class history_packet{
  is_finish:boolean = false;
  image:string = ''//图片地址
  title:string = ''//标题
  desc:string = ''//描述
  request_token:string = ''//任务token
  user_token:string = user_token //用户的token，此处默认token为全局变量
  constructor(title: string, desc: string,image:string,task_token:string,finish:boolean) {
    this.title = title;
    this.desc = desc;
    this.image = image;
    this.request_token = task_token;
    this.is_finish = finish
  }
}
interface Item {
  status: boolean;
  index?: number; // 可选字段，因为只有在未完成时才会有值
  image?: string; // 可选字段
  title?: string; // 可选字段
  description?: string;  // 可选字段
  task_token:string
}
interface HistoryResponse {
  items: Item[];
}
interface re_status{
  finish:boolean;
  index?:number;
}
interface confirm{
  finish:boolean;
  token:string;
}

@Entry
@Component
struct tabs {
  @State packet:Array<history_packet> = []
  @State confirm_packet:confirm|null = null
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
  push_packet(title:string,desc:string,image:string,task_token:string,finish:boolean)
  {
    let tmp=new history_packet(title,desc,image,task_token,finish)
    this.packet.push(tmp)
  }
  get_param(t:confirm)
  {
    if(t.finish)
    {
      this.push_packet('正在生成','','',t.token,false)
    }
    console.info('push')

  }
  onPageShow(): void {
    const a = router.getParams() as confirm
    if(a)
    {
      this.get_param(a)
      console.info('onpageshow on')

    }

    //console.log('yes',t.finish);
    //if(t.finish)
    //{
    //  this.push_packet('正在生成','','',t.token,false)
    //}
  }
  build() {
    Row() {
      Tabs({ barPosition: BarPosition.End}) {
        TabContent() {
          history({packet:this.packet})
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

@Component
struct history {
  //packet被修改之后页面会刷新
  @State time:number|undefined = 0
  @State index:number = 0
  @Link packet:Array<history_packet>
  @State message:string = '点击右上角“+”开始生成'
  get_user_token()
  {
    PreferencesUtils.get('user_token').then(token=>{user_token = token as string})
  }
  //将history_packet的包放入packet中
  push_packet(title:string,desc:string,image:string,task_token:string,finish:boolean)
  {
    let tmp=new history_packet(title,desc,image,task_token,finish)
    this.packet.push(tmp)
  }
  //开启计时器，每分钟使用一次refresh函数
  startTimer() {
    this.time = setInterval(this.refresh.bind(this), 5000);

  }
  //关闭计时器
  aboutToDisappear() {
    if (this.time !== undefined) {
      clearInterval(this.time);
    }
  }
  //对后端/history端口返回的json字符串解析
  un_json(data:string)
  {
    //console.debug(data)
    this.packet = []
    let js_data = JSON.parse(data);
    (js_data as HistoryResponse).items.forEach(item=>
    {
      console.info(JSON.stringify(item))
      if(item.title&&item.description&&item.image)
      {
        this.push_packet(item.title,item.description,item.image,item.task_token,item.status)
      }
      else
      {
        this.push_packet('正在生成','','',item.task_token,item.status)
      }
    })
  }
  //遍历packet寻找未完成的，如果存在未完成的，在寻找结束后调用/history接口重新获取
  async refresh()
  {
    let t:boolean = false;
    for (const item of this.packet)
    {
      if (item.is_finish === false)
      {
        let result : boolean = await this.refresh_packet(item)
        if(result === true)
        {
          t = true;
          break;
        }
      }
    }
    /*
    this.packet.forEach(async item => {
      if(item.is_finish===false)
      {

        if(result === true)
        {
          t = true
        }
      }
    })

    */
    if(t)
    {
      this.before_page_show()
    }
  }
  //对未完成的packet查询，如果完成了返回true
  async refresh_packet(item:history_packet): Promise<boolean>
  {
    try{
      let response : AxiosResponse = await axios.post(
        base_url + '/request_status',
        Object({"request_token": item.request_token})
      )
      return response.data.finish;
    } catch (e) {
      console.log(e.message)
    }
    return false;

    /*
    let http_request = http.createHttp()
    http_request.request(
      "POST /history",//url
      {
        method:http.RequestMethod.GET,
        header:{
          'Authorization': 'Bearer '  + item.request_token
        }
      },(err,data)=>{
      if(!err)
      {
        let js_data = JSON.parse(data.result as string);
        if((js_data as re_status).finish === true)
        {
          t = true
        }
      }
      else {
        console.error('请求失败:',err)
      }
    })
    return t;
    */
  }
  //调用/history接口（在渲染前调用和查询发现刚完成的任务时调用
  before_page_show()
  {
    //TODO 与后端交互获取
    axios.post(
      base_url + '/history',
      Object({
        "user_token": user_token
      })
    ).then((res: AxiosResponse) => {
      this.un_json(JSON.stringify(res.data))
    }).catch((e: AxiosError) => {
      console.log("error: " + e.message);
    })

    /*
    let http_request = http.createHttp()
    http_request.request(
      "POST /history",//url
      {
        method:http.RequestMethod.GET,
        header:{
          'Authorization': 'Bearer ' + user_token
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
    */
  }
  //渲染前调用，启动history接口+计时器
  aboutToAppear(): void {
    this.get_user_token()
    this.before_page_show()
    this.startTimer()
  }

  @Builder
  customMenu() {
    Row() {
      Button('+')
        .backgroundColor('white')
        .fontColor('black')
        .fontSize(40)
        .onClick(() => {
          router.pushUrl({url:'pages/picture_confrim_page',params:{user_token:user_token}
          })

          //测试使用，后续可修改为从生成页面返回的request_token信息或其他信息
          console.log('自定义菜单1被点击');
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
