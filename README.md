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
  
## スクリーンショット(現時点)  
<img src="https://user-images.githubusercontent.com/65600700/149734705-82815666-31cc-4cbe-bb55-698ad97d44f9.PNG" width="250px">  <img src="https://user-images.githubusercontent.com/65600700/149734822-4ca4253b-4362-4ccc-bbfb-3f015875d32a.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149734966-ed7f34bd-1ba1-4965-b1d8-afb879df609d.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735087-886919a0-b91a-44b0-b546-a3793c4cab83.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735203-87cebd7e-ca52-4cbb-937f-a65166ce372a.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735506-337a5498-8952-466f-8b04-f484b0bd66b1.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735657-8e6f79a1-82bd-40f7-a3dc-d57a2bb368e4.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735911-560f3061-ab86-4643-9582-ccf56b9ab476.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735986-ac748815-f7be-46ef-b8f1-44c490789dc1.PNG" width="250px"> 　<img src="https://user-images.githubusercontent.com/65600700/148356028-b716538b-e1d0-4c5d-a0f6-7ef4a8a28c2f.jpg" width="250px" height="530px">  
  
  




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
