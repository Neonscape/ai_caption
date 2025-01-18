import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { prompt, promptAction, router } from '@kit.ArkUI';
import util from '@ohos.util';
import axios, { AxiosResponse } from '@ohos/axios'
import sendableColorSpaceManager from '@ohos.graphics.sendableColorSpaceManager';
import PreferencesUtils from '../utils/PreferenceUtils';

let base_url = 'http://192.168.3.27:8081'

interface generate {
  user_token: string,
  image: string
};

interface generateRetVal{
  request_token:string,
  error_msg?:string
}

@Entry
@Component
export default struct Picture_confrim_page {
  @State pixel: image.PixelMap | undefined = undefined;
  @State albumPath: string = '';
  @State photoSize: number = 0;
  @State hasChosen: boolean = false;
  @State base64Str: string = '';
  @State request_token : string = '1919810';
  @State user_token: string = '';
  @State currentBreakpoint: string = 'unknown';
  @State paddingSize: number  = 0;
  // @State user_token: string = (router.getParams() as Record<string, string>)['user_token'];

  async getPictureFromAlbum() {
    // 拉起相册，选择图片
    let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(PhotoSelectOptions);
    this.albumPath = photoSelectResult.photoUris[0];

    // 读取图片为buffer
    const file = fs.openSync(this.albumPath, fs.OpenMode.READ_ONLY);
    this.photoSize = fs.statSync(file.fd).size;
    console.info('Photo Size: ' + this.photoSize);
    let buffer = new ArrayBuffer(this.photoSize);
    fs.readSync(file.fd, buffer);
    fs.closeSync(file);

    // 解码成PixelMap
    const imageSource = image.createImageSource(buffer);
    console.log('imageSource: ' + JSON.stringify(imageSource));
    this.pixel = await imageSource.createPixelMap({});
    this.hasChosen=true;

    // 编码成base64
    const imagePackageApi: image.ImagePacker = image.createImagePacker()
    let packOpts: image.PackingOption = {
      format: 'image/jpeg',
      quality: 100,
    }
    const readBuffer = await imagePackageApi.packing(this.pixel, packOpts);
    let base64Helper = new util.Base64Helper();
    let uint8Arr = new Uint8Array(readBuffer);
    let pixelStr = base64Helper.encodeToStringSync(uint8Arr);
    this.base64Str = /*'data:image/jpg;base64,' +*/ pixelStr;
  }

  async generate(){
    if(this.hasChosen){
      promptAction.showToast({
        message: '正在生成...',
        duration: 1000
      });
      let token: string = (await PreferencesUtils.get("user_token")) as string
      console.info("token is " + token)
      this.user_token = token
      console.info(this.user_token + this.base64Str);
      axios.post<string, AxiosResponse, generate>(base_url + '/generate', {
        user_token: this.user_token,
        image: this.base64Str
      })
        .then((response: AxiosResponse) => {
          console.info(JSON.stringify(response));
          if (response.data.error_msg)
          {
            promptAction.showToast({
              message: "生成错误：" + response.data.error_msg
            })
            console.error(`Error occurred: ${response.data.error_msg}`);
          }
          else
          {
            this.request_token = response.data.request_token
            console.log(`Request token received: ${response.data.request_token}`);
          }
          /*
          let rvalue:generateRetVal = JSON.parse(response.data) as generateRetVal
          if (rvalue.error_msg) {
            console.error(`Error occurred: ${rvalue.error_msg}`);
          } else {
            this.request_token=rvalue.request_token;
            console.log(`Request token received: ${rvalue.request_token}`);
          }
          */
        })
        .catch((error:string) => {
          console.info(JSON.stringify(error));
        })
      setTimeout(() => {
        promptAction.showToast({
          message: '任务号:'+this.request_token+',即将返回历史界面',
          duration: 1500
        });
      }, 1000);
      setTimeout(() => {
        // router.back({ url:'pages/history_page',params: { request_token: this.request_token } });
        router.back({
          url: 'pages/home',
          params: {
            finish: true,
            token: this.request_token
          }
        });
      }, 2500);
    }
    else{
      promptAction.showToast({
        message: '请选择一张图片',
        duration: 2000
      });
    }
  }

  build(){
    RelativeContainer() {
      Column(){
        Blank()
          .height('3%')
        Column() {
          Button('返回')
            .onClick(() => {
              router.back({
                url: 'pages/home',
                params: {
                  finish: false,
                  token: this.request_token
                }
              });
            })
        }
        .alignItems(HorizontalAlign.Start)
        // .width('80%')
        .width(this.currentBreakpoint !== 'lg' ? '80%' : '90%')
        Blank()
          .height('5%')
        GridRow({
          columns: {
            sm: 4,
            md: 4,
            lg: 12
          }
        }) {
          GridCol({span: {sm: 4, md: 4, lg: 6}}) {
            Column(){
              Blank()
                .height(this.currentBreakpoint !== 'lg' ? '25%' : '0')
              Image(this.pixel).width('80%').height('80%')
            }
            .width('100%')
            .height('100%')
            .aspectRatio(1)
          }
          .height(this.currentBreakpoint !== 'lg' ? '75%' : '100%')

          GridCol({span: {sm: 4, md: 4, lg: 6}}) {
              Column(){
                Row(){
                  Column(){
                    Button('选择图片')
                      .width('70%')
                      .onClick(() => {
                        this.getPictureFromAlbum();
                      })
                  }
                  .width('50%')
                  Column(){
                    Button('开始生成')
                      .width('70%')
                      .onClick(() => {
                        this.generate();
                      })
                  }
                  .width('50%')
                }
                .width('100%')
                .height(this.currentBreakpoint !== 'lg' ? 'auto' : '60%')
                // Blank()
                // .height('25%')
            }
            .width('100%')
          }
        }
        .onBreakpointChange((currentBreakpoint: string) => {
          this.currentBreakpoint = currentBreakpoint
        })
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .width('100%')
  }
}