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
    
となっており、現在制作中です。  
  
苦労している点：これまで利用していたSQLite、Firebaseと比べてRealmはRealmSwiftの設計思想や使い方を理解して使わなければトラブルがよく発生する点。  
  
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
   
## 開発環境  
- Swift5.5.2  
- Xcode13.2.1  
  
## スクリーンショット(iPhone12mini)  
<img src="https://user-images.githubusercontent.com/65600700/152096481-9bc06538-d097-4e5b-86af-cf6401c8490a.PNG" width="250px">  <img src="https://user-images.githubusercontent.com/65600700/152096520-dc17ad4a-5ae0-4b85-bb33-189e48ce6c38.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/152096607-277945bf-433a-4971-873d-aff12204725b.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/152096655-a107ef83-2b4e-40a3-86bf-da56c79abde5.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/152096715-bb049bf3-60be-4bbe-b94f-d46af27d12b2.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/152096731-289c460c-6258-4eac-86af-75619b7f0b1d.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/152096907-589e5e52-db1c-44d6-ad19-6d95482024ba.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150466745-65fcb571-ffae-41ea-a8f5-dcc49f32843a.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/150107750-4414d6dd-671b-4859-bdf9-a1cdfd704106.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/152097069-81b16a46-9f7c-40f9-9009-27a26fcfbe50.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/149735986-ac748815-f7be-46ef-b8f1-44c490789dc1.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/148356028-b716538b-e1d0-4c5d-a0f6-7ef4a8a28c2f.jpg" width="250px" height="530px">  
  
  




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
