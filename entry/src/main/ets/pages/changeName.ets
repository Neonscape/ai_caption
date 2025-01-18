import axios, {AxiosResponse, AxiosError} from '@ohos/axios'
import PreferenceUtils from '../utils/PreferenceUtils'
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
let base_url = "http://192.168.3.27:8081"

@Entry
@Component
struct ModifyUsername {
  @State username: string = ''; // 存储用户名
  build() {

    Column() {
      // Navigation Bar
      Navigation()
        .title('修改用户名')
        .height(60)
        .backgroundColor('#4CAF50')
        .titleMode(NavigationTitleMode.Mini)
        .margin({ top: 30 })

      // Modify Username Section
      Column() {
        // Title
        Row() {
          Text('请输入新的用户名')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .padding({ top: 20, bottom: 10 })
        .alignSelf(ItemAlign.Start)

        // // Username Input Field
        Row() {
          TextInput({placeholder:"新的用户名", text: this.username})
            .fontSize(16)
            .borderColor('#e3e4e5')
            .borderWidth(1)
            .padding({ left: 10 })
            .width('100%')
            .height(40)
            .backgroundColor('#fff')
            .borderRadius(8)
            .margin({ bottom: 20 })
            .onChange((value) => {
              this.username = value
            })
        }

        // Check for Invalid Input
        Row() {
          Text('用户名不能为空')
            .fontSize(14)
            .fontColor('#e74c3c')
            .id('error-message')
        }
        .padding({ bottom: 20 })

        // Save Button
        Row() {
          Button('保存并返回')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .height(45)
            .backgroundColor('#4CAF50')
            .fontColor('#fff')
            .onClick(async () => {
              const newUsername = this.username
              console.info(`new name: ${newUsername}`)
              let resp: AxiosResponse = await axios.post(
                base_url + '/change_username',
                Object({
                  "user_token": await PreferenceUtils.get("user_token") as string,
                  "new_username": newUsername
                })
              )
              console.info(resp.data)
              if (resp.data.success === false)
                promptAction.showToast({
                  message: resp.data.error_msg
                })
              else
              {
                promptAction.showToast({
                  message: "Username updated."
                })
                PreferenceUtils.put("username", newUsername)
                console.info("username changed.")
                router.replaceUrl({
                  url: 'pages/home'
                }
                )
              }
              // 调用接口修改
            })
        }
        .padding({ top: 20 })
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
