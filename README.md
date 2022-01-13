# 2021年度 櫻井ゼミ カレンダーアプリ

## 概要
このアプリはカレンダーでスケジュール管理ができるアプリです。   
データベースはRealmを利用しています。  
  
主な機能としては  
- 日付ごとのイベント管理機能(CRUD)  

- リマインダープッシュ通知  

- カスタマイズ可能なカレンダー表示(スライド方向の切り替え設定)  
  
- 六曜の表示  

- 土日祝のみと平日のみの表示機能  
  
- Widgetを追加 
  
- Googleカレンダーアプリと同期  
    
となっており、現在制作中です。  
  
苦労している点：これまで利用していたSQLite、Firebaseと比べてRealmはRealmSwiftの設計思想や使い方を理解して使わなければトラブルがよく発生する点。  
  
現状での課題：UXの考え方や既存アプリとの差別化をするためにはどうすればいいか模索中です。  
  
## 使用ライブラリ  
- [FSCalendar](https://github.com/WenchaoD/FSCalendar)  
- [RealmSwift](https://github.com/realm/realm-cocoa)  
- [CalculateCalendarLogic](https://github.com/fumiyasac/handMadeCalendarAdvance)  
- [TextFieldEffects](https://github.com/raulriera/TextFieldEffects)  
- [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)  

  
## 開発環境  
- Swift5.5.2  
- Xcode13.2.1  
  
## スクリーンショット(現時点)  
<img src="https://user-images.githubusercontent.com/65600700/148766905-ed8818d8-e32a-4362-8886-94546dde3f6b.PNG" width="250px">  <img src="https://user-images.githubusercontent.com/65600700/148766975-f831f0f0-02d8-448e-ab51-f1ccd76f9a05.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/148767121-3986cf51-e352-434f-b947-66819bf534f4.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/148767117-f70cf182-0cdf-4a5f-813d-3596cd39c10f.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/148767094-bef32219-1f2f-4949-9093-84d88df16854.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/148193891-f1aa8ee6-9171-4a3e-b0d7-2adf57942fdd.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/148193988-e2a3341f-4c7a-4ecb-9b39-a3a2f20c13ea.PNG" width="250px">　<img src="https://user-images.githubusercontent.com/65600700/148356028-b716538b-e1d0-4c5d-a0f6-7ef4a8a28c2f.jpg" width="250px" height="530px">  
  
  




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
