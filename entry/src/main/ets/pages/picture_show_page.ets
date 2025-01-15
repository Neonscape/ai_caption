import util from '@ohos.util';
import { image } from '@kit.ImageKit';
import CommonConstants from '../common/CommonConstants';
import { router } from '@kit.ArkUI';

let tmpImage:string=CommonConstants.base64_ins;

@Entry
@Component
export default struct Picture_show_page {
  @State pixel: image.PixelMap | undefined = undefined;
  @State image: string = (router.getParams() as Record<string, string>)['image'];
  @State title: string = (router.getParams() as Record<string, string>)['title'];
  @State desc: string = (router.getParams() as Record<string, string>)['desc'];

  async show(){
    // decode
    let helper = new util.Base64Helper();
    let buffer: ArrayBuffer = helper.decodeSync(tmpImage.split('image/jpeg;base64,')[1], util.Type.MIME).buffer as ArrayBuffer;
    // let buffer: ArrayBuffer = helper.decodeSync(this.image.split('image/jpeg;base64,')[1], util.Type.MIME).buffer as ArrayBuffer;
    let imageSource = image.createImageSource(buffer);
    let opts: image.DecodingOptions = { editable: true };
    this.pixel = await imageSource.createPixelMap(opts);
  }

  aboutToAppear(): void {
    this.show();
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
                router.back()
              })
          }
          .width('35%')
          Column(){}
          .width('65%')
        }
        .height('10%')
        Blank()
          .height('4%')
        Image(this.pixel)
          .width('80%')
          .aspectRatio(1)
        Blank()
          .height('5%')
        Text(this.title)
          .textAlign(TextAlign.Start)
          .width('80%')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Blank('3%')
        Text(this.desc)
          .textAlign(TextAlign.Start)
          .width('80%')
          .fontSize(20)
        Blank()
          .height('25%')

      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}