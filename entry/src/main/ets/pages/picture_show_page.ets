import util from '@ohos.util';
import { image } from '@kit.ImageKit';


class Item {
  // 字段定义
  image: string;
  title: string;
  desc: string;

  // 构造函数
  constructor(image: string, title: string, desc: string) {
    this.image = image;
    this.title = title;
    this.desc = desc;
  }
}

// 示例：创建一个 Item 实例
const tmp = new Item(
  'data:image/jpeg;base64,TWFuaXNkaXN0aW5ndWlzaGVkbm90b25seWJ5aGlzcmVhc29uYnV0Ynl0aGlzc2luZ3VsYXJwYXNz\n' +
    'aW9uZnJvbW90aGVyYW5pbWFsc3doaWNoaXNhbHVzdG9mdGhlbWluZGV4Y2VlZHN0aGVzaG9ydHZl\n' +
    'aGVtZW5jZW9mYW55Y2FybmFscGxlYXN1cmU=',
  '丘成桐（国内）',
  '天命 主宰 欺诈'
);

@Entry
@Component
export default struct Picture_show_page {
  // @State params: routerParams = router.getParams() as routerParams
  @State item : Item = tmp;
  @State pixel: image.PixelMap | undefined = undefined;

  async show(){
    // decode
    let helper = new util.Base64Helper();
    let buffer: ArrayBuffer = helper.decodeSync(this.item.image, util.Type.MIME).buffer as ArrayBuffer;
    let imageSource = image.createImageSource(buffer);
    let opts: image.DecodingOptions = { editable: true };
    this.pixel = await imageSource.createPixelMap(opts);
    console.info('123456789')
  }

  build() {
    Row() {
      Column() {
        Blank()
          .height('5%')
        Button('渲染')
          .onClick(() => {
            // router.back();
            console.info('try to show')
            this.show();
            console.info('end show')
          })
          .height('5%')
        Blank()
          .height('5%')
        Image(this.pixel)
          .width('80%')
          .aspectRatio(1)
        Text('Title:')
          .height('10%')
        Blank()
          .height('5%')
        Text('Desc:')
          .height('10%')

      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}