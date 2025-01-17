import router from '@ohos.router'
import promptAction from '@ohos.promptAction';
import axios, {AxiosResponse, AxiosError} from '@ohos/axios'
import PreferenceUtils from '../utils/PreferenceUtils'

let base_url = "http://192.168.3.27:8081"
interface list{
  text: string;
  image: Resource;
  url: string;
  id: number;
}
interface info{
  menu: string;
  url: string;
}

@Entry
@Component
export default struct Home {
  @State name: string = '用户名'
  @State ID: string = '123123'
  @State menu: info[] = [
    { menu: '个人信息', url: 'pages/self' },
    { menu: '更改用户名', url: 'pages/changeName'},
    // { menu: '个性设置', url: '' },
    { menu: '关于应用', url: 'pages/about' },

  ]
  @State sign:string='签到'
  async aboutToAppear(): Promise<void> {
    this.ID = (await PreferenceUtils.get("user_token")) as string
    let resp: AxiosResponse = await axios.get(
      base_url + '/get_username',
      {
        params:{
          "user_token": this.ID
        }
      }
    )
    console.info("get_username called, " + `data is ${resp}`)
    if (resp.data.success === false)
      promptAction.showToast({
        message: resp.data.error_msg
      })
    else {
      promptAction.showToast({
        message: "信息获取成功"
      })
      this.name=resp.data.name
    }

  }
  build() {
    Column() {
      Scroll() {
        Column() {
          //用户信息
          Row() {
            Image($r('app.media.person'))
              .width(100)
              .height(100)
              .margin({ top: 30 })
              .borderRadius(100)


            Column() {
              Text(this.name)
                .fontSize(30)
                .margin({ left: 0, top: 30 })
              /*Text('ID:' + this.ID)*/
            }
            .height(100)
            .margin({ top: 30, left: 20 })
            //修改
            Button(this.sign)
              .margin({ left: 30, top: 30 })
              .onClick(() => {
                promptAction.showToast({ message: this.sign==='签到'?'签到成功':'请勿重复签到' })
                this.sign='已签到'
                console.log(this.sign);
              })
          }

          ForEach(this.menu, (item: info) => {
            Row() {
              Text(item.menu)
                .fontSize(25)
                .width('50%')
                .padding({ left: '10%' })
              Text('>')
                .fontSize(30)
                .width('55%')
                .textAlign(TextAlign.End)
                .padding({right:'10%',top:5,bottom:5})
              // .padding({ left: '45%' })
            }
            .borderRadius(10)
            .width('90%')
            .margin({ top: 20 })
            .backgroundColor('#e3e4e5')
            .padding({ top: 5, bottom: 5 })
            .onClick(() => {
              router.pushUrl({
                url: item.url
              })
            })
          })

          //退出登录
          Button('退出登录')
            .margin({ top: 100 })
            .backgroundColor('#eeeeee')
            .fontColor('#000000')
            .fontSize(20)
            .onClick(() => {
              router.replaceUrl({
                url: 'pages/Index'
              })
              router.clear()
            })
        }
      }
    }
  }
}
