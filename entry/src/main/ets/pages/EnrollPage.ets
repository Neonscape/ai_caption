import promptAction from '@ohos.promptAction'
import router from '@ohos.router'
@Entry
@Component
struct EnrollPage {
  // 创建用户的账号密码
  @State username:string = 'admin'
  @State password: string = '123456'

  build() {
    Column() {
      //用户头像(导入所需图片)
      Image($r('app.media.startIcon'))
        .width(80)
        .height(80)
        .margin({top:100})
      //TextInput来完成用户名注册
      TextInput({placeholder:'请输入用户名',text:this.username })
        .margin({top:20})
        .onChange((value) => {
          this.username = value
        })
      // TextInput来完成密码注册
      TextInput({placeholder:'请输入密码',text:this.password})
        .type(InputType.Password)
        .margin({top:20})
        .onChange((value) => {
          this.password = value
        })
      // 账号密码输入成功后我们需要在点击登录按钮的情况下进行判断判断账号密码是否正确
      Button('注册')
        .width('80%')
        .margin({top: 30})
          // 点击登录按钮触发某些条件完成路径跳转
        .onClick(() => {
          if(this.username === 'admin' &&  this.password === '123456') {
            router.pushUrl({
              // 需要跳转的路径
              url: 'pages/enroll'
            })
          }
          else {
            // 账号密码不符弹出警告
            promptAction.showToast({
              message:'账号或密码格式不正确'
            })
          }
        })
      Text('返回登陆').fontColor('#0078fd')
        .margin({top: 10})
        .onClick(()=>{
          router.pushUrl({
            // 需要跳转的路径
            url: 'pages/Index'
          })
        })
    }.width('100%').height('100%').padding(20)
  }
}