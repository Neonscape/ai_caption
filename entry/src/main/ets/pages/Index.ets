import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
import axios, { AxiosResponse } from '@ohos/axios'
import  PreferencesUtils  from '../utils/PreferenceUtils'

let base_url = "http://192.168.3.27:8081"

interface user {
  username: string,
  password: string
};

interface returnValue{
  success:boolean,
  user_token:string,
  error_msg:string
}

@Entry
@Component

struct Login {
  // 创建用户的账号密码
  @State username:string = ''
  @State password: string = ''

  build() {
    Column() {
      //用户头像(导入所需图片)
      Image($r('app.media.icon_alt'))
        .width(80)
        .height(80)
        .margin({top:100})
        .border({radius: 15})
      //登录界面
      Text('登录').fontColor('#ff011221')
        .margin({top: 10})
        .fontSize(17)
      //TextInput来完成用户名认证
      TextInput({placeholder:'请输入用户名',text:this.username })
        .margin({top:20})
        .onChange((value) => {
          this.username = value
        })
      // TextInput来完成密码名认证
      TextInput({placeholder:'请输入密码',text:this.password})
        .type(InputType.Password)
        .margin({top:20})
        .onChange((value) => {
          this.password = value
        })
      // 账号密码输入成功后我们需要在点击登录按钮的情况下进行判断判断账号密码是否正确
      Button('登录')
        .width('80%')
        .margin({top: 30})
          // 点击登录按钮触发某些条件完成路径跳转
        .onClick(() => {
          axios.post<string, AxiosResponse, user>(base_url + '/login', {
            username: this.username,
            password: this.password
          })
            .then((response: AxiosResponse) => {
              console.info(JSON.stringify(response));
              if(response.data.success === true)
              {
                console.info("user info updated")
                PreferencesUtils.put("username", this.username)
                PreferencesUtils.put("user_token", response.data.user_token)
                promptAction.showToast({
                  message: "登录成功"
                })
                router.pushUrl({
                  url: 'pages/home'
                })
              }
              else
              {
                promptAction.showToast({
                  message: '登录失败：' + response.data.error_msg
                })
              }


              /*
              let rvalue:returnValue = JSON.parse(response.data) as returnValue
              if(rvalue.success === true)
              {
                PreferencesUtils.put("user_name", this.username)
                PreferencesUtils.put("user_token", rvalue.user_token)
                promptAction.showToast({
                  message:'登录成功'
                })
                router.pushUrl({
                  // 需要跳转的路径
                  url: 'pages/home'
                })
              }else {
                promptAction.showToast({
                  message:rvalue.error_msg
                })
              }
              */
            })
            .catch((error:string) => {
              console.info(JSON.stringify(error));
            })
        })
      Text('注册账号').fontColor('#0078fd')
        .margin({top: 10})
        .onClick(()=>{
          router.pushUrl({
            // 需要跳转的路径
            url: 'pages/EnrollPage'
          })
        })
    }.width('100%').height('100%').padding(20)
  }
}

