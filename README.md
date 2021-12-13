# 2021年度 櫻井ゼミ カレンダーアプリ

## 概要
このアプリはカレンダーでスケジュール管理ができるアプリです。   
データベースはRealmを利用しています。  
  
主な機能としては  
・日付ごとのイベント管理機能(CRUD)  

・リマインダープッシュ通知  

・カスタマイズ可能なカレンダー表示(スライド方向の切り替え設定)  
  
・六曜の表示  

・土日祝のみの表示機能(現在実装中)    
となっており、現在制作中です。  
  
苦労している点：これまで利用していたSQLite、Firebaseと比べてRealmはRealmSwiftの設計思想や使い方を理解して使わなければトラブルがよく発生する点。  
  
現状での課題：UXの考え方や既存アプリとの差別化をするためにはどうすればいいか模索中です。  
  
## 使用ライブラリ  
[FSCalendar](https://github.com/WenchaoD/FSCalendar)  
[RealmSwift](https://github.com/realm/realm-cocoa)  
[CalculateCalendarLogic](https://github.com/fumiyasac/handMadeCalendarAdvance)  
[TextFieldEffects](https://github.com/raulriera/TextFieldEffects)  
[IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)  

  
## 開発環境  
Swift5.5.1  
Xcode13.1  
  
# スクリーンショット(現時点)  
<img src="https://user-images.githubusercontent.com/65600700/145767949-91060b21-84bb-435e-95f9-c523868e2474.PNG" width="250px">  <img src="https://user-images.githubusercontent.com/65600700/145768113-f4ef144f-c57b-40e1-b4aa-94420e3efa80.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/145768408-984f460d-e5c2-42d1-98c5-83e938b83fef.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/145768122-10364383-055f-42d6-b882-87455aa5add6.PNG" width="250px"> <img src="https://user-images.githubusercontent.com/65600700/145768595-1564663f-d567-4a3a-9a24-2aa2cf390f7e.PNG" width="250px">  
  
  




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
