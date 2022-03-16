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
  
- Googleカレンダーアプリと同期、iOS標準カレンダーアプリと同期    
    
となっております。  
  
苦労した点：これまで利用していたSQLite、Firebaseと比べてRealmはRealmSwiftの設計思想や使い方を理解して使わなければトラブルがよく発生する点。  
  
現状での課題：UXの考え方や既存アプリとの差別化をするためにはどうすればいいか模索中です。  
  
このアプリはAppStoreに公開済みです。  
[https://apps.apple.com/jp/app/re-%E3%82%B9%E3%82%B1/id1607735456](https://apps.apple.com/jp/app/re-%E3%82%B9%E3%82%B1/id1607735456)
  
## 使用ライブラリ  
- [FSCalendar](https://github.com/WenchaoD/FSCalendar)  
カレンダーの実装  

- [RealmSwift](https://github.com/realm/realm-cocoa)  
日付ごとのイベント管理  
  
- [CalculateCalendarLogic](https://github.com/fumiyasac/handMadeCalendarAdvance)  
祝日判定  
  
- [TextFieldEffects](https://github.com/raulriera/TextFieldEffects)  
TextFieldのUI  
  
- [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)  
キーボード表示時の画面のスライド  
  
- [PKHUD](https://github.com/pkluz/PKHUD)  
通信時のローディングインジケーター  
  
- [SwiftLint](https://github.com/realm/SwiftLint)  
ソースコードの品質管理  
  
- [AppAuth](https://github.com/openid/AppAuth-iOS)  
OAuth2.0およびOpenIDConnectプロバイダーと通信するためのクライアントSDK  
  
- [GTMAppAuth](https://github.com/google/GTMAppAuth)  
AppAuthでリクエストを認証するためGTMFetcherAuthorizationProtocolの実装を提供する  
  
- [GoogleAPIClientForREST/Calendar](https://github.com/google/google-api-objectivec-client-for-rest)  
Googleの様々なAPI へのアクセス・データの取得などを簡単にできるようにしてくれるもの(今回はGoogleカレンダー)  
  
- [Google-Mobile-Ads-SDK](https://github.com/googleads/googleads-mobile-ios-examples)  
Googleモバイル広告の最新世代で、洗練された広告フォーマットと、モバイル広告ネットワークや広告ソリューションにアクセスするため  
  
- [LicensePlist](https://github.com/mono0926/LicensePlist#installation)  
CocoaPods、SwiftPMなどで管理しているライブラリのライセンス表示を自動的に生成するツール 
    
- [Firebase](https://github.com/firebase/firebase-ios-sdk)  
Firebaseのアナリティクスでユーザー解析をするため     
   
## 開発環境  
- Swift5.5.2  
- Xcode13.2.1  
  
## スクリーンショット(iPhone12mini)  
<img src="https://user-images.githubusercontent.com/65600700/155959998-cb8f5742-6dd8-47cd-99ef-c3d858133868.PNG" width="250px">  <img src="https://user-images.githubusercontent.com/65600700/155960155-17014964-0171-4228-8427-b5d9166f5a73.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155960296-b86baedc-4b5d-4390-9e10-e352c27a6610.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155960394-f2c44a71-c035-43ab-b5b2-b79066f237e1.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155960489-9b5abcbc-9330-4b78-a6c5-8f75ca3dd238.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155960723-5d12f34b-5fde-4c68-abeb-0f3becdc27a6.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155960865-f3b61923-748e-4d8a-9f74-01f9cbb5b374.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155960956-9ce75a08-ba0e-4cd1-a2d4-ef8d3e9e1d22.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155961021-41ca3e8e-8ec7-445b-aa9b-b3bd070ba8a6.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155961136-585193a5-5dc0-4c07-bf94-807013cb2425.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155961386-1c43ba5c-1d7a-4cca-a126-8c5e40d71791.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/155961452-83b053da-fd45-4abc-a0f7-e1cd6c407130.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735986-ac748815-f7be-46ef-b8f1-44c490789dc1.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/148356028-b716538b-e1d0-4c5d-a0f6-7ef4a8a28c2f.jpg" width="250px" height="530px">  
  
  




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
