import dataPreferences from '@ohos.data.preferences'
import GlobalContext from '../common/GlobalContext';


const TAG = "PreferencesUtils"
// 默认文件名，可以在构造函数进行修改
const PREFERENCES_NAME = 'yiPreferences'
const KEY_PREFERENCES = "preferences"
type ValueType = number | string | boolean | Array<number> | Array<string> | Array<boolean> | bigint | object;

export class PreferencesUtils{
  // preferences的文件名
  private preferencesName: string = PREFERENCES_NAME
  // 用于获取preferences实例的key值，保存到单例中
  private keyPreferences: string = KEY_PREFERENCES

  constructor(name: string = PREFERENCES_NAME, keyP: string = KEY_PREFERENCES) {
    this.preferencesName = name
    this.keyPreferences = keyP
  }

  public createPreferences(context: Context) {
    let preferences = dataPreferences.getPreferences(context, this.preferencesName)
    GlobalContext.getContext().setObject(this.keyPreferences, preferences)
    return preferences
  }

  public getPreferences(): Promise<dataPreferences.Preferences> {
    return GlobalContext.getContext().getObject(KEY_PREFERENCES) as Promise<dataPreferences.Preferences>
  }

  async get(key: string, def?: ValueType): Promise<ValueType> {
    return (await this.getPreferences()).get(key, def)
  }

  async getAll(): Promise<Object> {
    let  preferences = await this.getPreferences()
    return preferences.getAll()
  }

  async put(key: string, value: ValueType): Promise<void> {
    let promise = await this.getPreferences().then(async (p) => {
      await p.put(key, value)
      await p.flush();
    }).catch((error:string)=>{
      console.log(TAG, error)
    })
    return promise
  }



  async delete(key: string): Promise<void> {
    return (await this.getPreferences()).delete(key).finally(async () => {
      (await this.getPreferences()).flush()
    })
  }

  async clear(): Promise<void> {
    return (await this.getPreferences()).clear().finally(async () => {
      (await this.getPreferences()).flush()
    })
  }

}

export default new PreferencesUtils()
