# Standard for Powershell
* index
  * codeing rules[#coding-rules]
  * support libraries[#support-libraries]
    - [std]#(std)

## coding rules

## support libraries
### std

> デバッグ, 詳細出力, 開発、商用判断および、ログの出力先は、環境変数で判断
* プロンプトへの出力(トレース, 警告, エラー, デバッグ, 詳細)
  - out-trace
  - out-warn
  - out-error
  - out-debug
  - out-varbose

* ログファイルへの出力
  - outlog


## relative issues
* .envのロード機能をつけてはどうか [#1](https://github.com/taigamorikawa/standards/issues/1#issue-1550299110)
