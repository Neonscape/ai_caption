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
  @State currentBreakpoint: string = 'unknown';
  @State paddingSize: number  = 0;

  async show(){
    // decode
    let helper = new util.Base64Helper();
    // let buffer: ArrayBuffer = helper.decodeSync(tmpImage.split('data:image/jpeg;base64,')[1], util.Type.MIME).buffer as ArrayBuffer;
    let buffer: ArrayBuffer = helper.decodeSync(this.image, util.Type.MIME).buffer as ArrayBuffer;
    let imageSource = image.createImageSource(buffer);
    let opts: image.DecodingOptions = { editable: true };
    this.pixel = await imageSource.createPixelMap(opts);
  }

  aboutToAppear(): void {
    this.show();
  }

  build(){
    RelativeContainer() {
      Column(){
        Blank()
          .height('3%')
        Column() {
          Button('< 返回', {
            type: ButtonType.Normal,
          })
            .fontColor("#000000")
            .backgroundColor("#00000000")
            .onClick(() => {
              router.back()
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
              Image(this.pixel).width('80%').height('80%')
            }
            .width('100%')
            .height('100%')
            .aspectRatio(1)
          }
          .height(this.currentBreakpoint !== 'lg' ? '43%' : '100%')

          GridCol({span: {sm: 4, md: 4, lg: 6}}) {
            Column(){
              Text(this.title)
                .textAlign(TextAlign.Start)
                .width('80%')
                .fontSize(50)
                .fontWeight(FontWeight.Bold)
                .padding({top: 15, left: 20, bottom: 10})
              Text(this.desc)
                .textAlign(TextAlign.Start)
                .width('80%')
                .fontSize(20)
                .padding({top: 10, left: 20, bottom: 20})
              Blank()
                .height('20%')
            }
            .width('100%')
            .height('auto')
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