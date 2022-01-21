# 2021年度 櫻井ゼミ カレンダーアプリ

## 概要
このアプリはカレンダーでスケジュール管理ができるアプリです。   
データベースはRealmを利用しています。  
  
主な機能としては  
- 日付ごとのイベント管理機能(CRUD)  

- リマインダープッシュ通知  

- カスタマイズ可能なカレンダー表示(スライド方向の切り替え設定、曜日順)  
  
- 六曜の表示  

- 土日祝のみと平日のみの表示機能  
  
- Widgetを追加 
  
- Googleカレンダーアプリと同期  
    
となっており、現在制作中です。  
  
苦労している点：これまで利用していたSQLite、Firebaseと比べてRealmはRealmSwiftの設計思想や使い方を理解して使わなければトラブルがよく発生する点。  
  
現状での課題：UXの考え方や既存アプリとの差別化をするためにはどうすればいいか模索中です。  
このアプリはAppStoreに公開予定です。
  
## 使用ライブラリ  
- [FSCalendar](https://github.com/WenchaoD/FSCalendar)  
- [RealmSwift](https://github.com/realm/realm-cocoa)  
- [CalculateCalendarLogic](https://github.com/fumiyasac/handMadeCalendarAdvance)  
- [TextFieldEffects](https://github.com/raulriera/TextFieldEffects)  
- [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)  
- [PKHUD](https://github.com/pkluz/PKHUD)  
- [SwiftLint](https://github.com/realm/SwiftLint)
- [AppAuth](https://github.com/openid/AppAuth-iOS)  
- [GTMAppAuth](https://github.com/google/GTMAppAuth)  
- [GoogleAPIClientForREST/Calendar](https://github.com/google/google-api-objectivec-client-for-rest)  

  
## 開発環境  
- Swift5.5.2  
- Xcode13.2.1  
  
## スクリーンショット(iPhone12mini)  
<img src="https://user-images.githubusercontent.com/65600700/150466218-0b30e3b9-b481-4865-989e-af03e0bc0425.PNG" width="250px">  <img src="https://user-images.githubusercontent.com/65600700/150466355-fc8a48e5-95c4-40d8-8c60-3717a2381ea1.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150466443-5d4b8bbc-2036-4f93-b035-0f8c2af023b8.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150466491-5a29f00c-980b-44d9-9c22-4b503f3332ab.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150466522-972b7acc-bf40-4fbc-8fd8-98cb67be5a94.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150466562-e5d523fa-d036-46be-a8d3-e79bcb6485af.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150466745-65fcb571-ffae-41ea-a8f5-dcc49f32843a.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150107750-4414d6dd-671b-4859-bdf9-a1cdfd704106.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735986-ac748815-f7be-46ef-b8f1-44c490789dc1.PNG" width="250px"> 　<img src="https://user-images.githubusercontent.com/65600700/148356028-b716538b-e1d0-4c5d-a0f6-7ef4a8a28c2f.jpg" width="250px" height="530px">  
  
  




## セットアップ

### CocoaPods導入

ターミナルで以下を入力

```
sudo gem install cocoapods
```

下記のエラーが出る場合は、

https://github.com/orta/cocoapods-keys/issues/198#issuecomment-510909030

を参考にRubyのバージョン2.6.3を入れる

```
ERROR:  Error installing cocoapods:
        ERROR: Failed to build gem native extension.

    current directory: /Library/Ruby/Gems/2.6.0/gems/ffi-1.12.2/ext/ffi_c
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/bin/ruby -I /Library/Ruby/Site/2.6.0 -r ./siteconf20211113-24669-declh0.rb extconf.rb
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/mkmf.rb:467:in `try_do': The compiler failed to generate an executable file. (RuntimeError)
You have to install development tools first.
        from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/mkmf.rb:546:in `block in try_link0'
        from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/tmpdir.rb:93:in `mktmpdir'
        from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/mkmf.rb:543:in `try_link0'
        from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/mkmf.rb:570:in `try_link'
        from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/mkmf.rb:672:in `try_ldflags'
        from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/mkmf.rb:1832:in `pkg_config'
        from extconf.rb:9:in `system_libffi_usable?'
        from extconf.rb:34:in `<main>'

To see why this extension failed to compile, please check the mkmf.log which can be found here:

  /Library/Ruby/Gems/2.6.0/extensions/universal-darwin-20/2.6.0/ffi-1.12.2/mkmf.log

extconf failed, exit code 1
```

gitでcloneしたディレクトリをターミナルで開き、ディレクトリに移動後以下を実行

```
pod setup
pod install
```

### プロジェクトを開く

[Xcode](https://developer.apple.com/jp/xcode/)でgitでcloneしたディレクトリを開く。

`./CarendarApp.xcworkspace`ディレクトリが生成される。

Xcodeが入っていない場合はAppleのアプリストアでインストールする。
