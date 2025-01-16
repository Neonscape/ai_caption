import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { promptAction, router } from '@kit.ArkUI';
import util from '@ohos.util';
import axios, { AxiosResponse } from '@ohos/axios'
import sendableColorSpaceManager from '@ohos.graphics.sendableColorSpaceManager';

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
    this.base64Str = 'data:image/jpg;base64,' + pixelStr;
  }

  generate(){
    if(this.hasChosen){
      promptAction.showToast({
        message: '正在生成...',
        duration: 1000
      });
      console.info(this.base64Str);
      axios.post<string, AxiosResponse<string>, generate>('/generate', {
        user_token: this.user_token,
        image: this.base64Str
      })
        .then((response: AxiosResponse<string>) => {
          console.info(JSON.stringify(response));
          let rvalue:generateRetVal = JSON.parse(response.data) as generateRetVal
          if (rvalue.error_msg) {
            console.error(`Error occurred: ${rvalue.error_msg}`);
          } else {
            this.request_token=rvalue.request_token;
            console.log(`Request token received: ${rvalue.request_token}`);
          }
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
          url: 'pages/history_page',
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

  build() {
    Row() {
      Column() {
        Blank()
          .height('3%')
        Row(){
          Column(){
            Button('返回')
              .onClick(() => {
                router.back({
                  url: 'pages/history_page',
                  params: {
                    finish: false,
                    token: this.request_token
                  }
                });
              })
          }
          .width('35%')
          Column(){}
          .width('65%')
        }
          .height('10%')
        Blank()
          .height('10%')
        Image(this.pixel)
          .width('80%')
          .aspectRatio(1)
        Blank()
          .height('5%')
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
          .height('10%')
        Blank()
          .height('20%')
      }
      .width('100%')
    }
    .height('100%')
  }
}