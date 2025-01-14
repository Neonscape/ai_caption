import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { buffer } from '@kit.ArkTS';
import util from '@ohos.util';

@Entry
@Component
export default struct Picture_confrim_page {
  @State pixel: image.PixelMap | undefined = undefined;
  @State albumPath: string = '';
  @State photoSize: number = 0;
  @State hasChosen: boolean = false;
  @State base64Str: string = '';

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
    // this.array = new Uint8Array(buffer);

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
        duration: 2000
      });
      console.info(this.base64Str);
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
        Row(){
          Button('返回')
            .onClick(() => {
              // router.back();
            })
        }
        Blank()
          .height('5%')
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
      }
      .width('100%')
    }
    .height('100%')
  }
}