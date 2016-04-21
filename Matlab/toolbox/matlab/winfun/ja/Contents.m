% Windows オペレーティングシステムインタフェースファイル (DDE/COM)
%
% COM オートメーションクライアント関数
%   actxcontrol         - ActiveXコントロールの作成
%   actxserver          - ActiveXサーバの作成
%   eventlisteners      - 登録されているすべてのイベントのリスト
%   isevent             - オブジェクトのイベントである場合は真
%   registerevent       - 実行時に指定したコントロールに対するイベント
%			      の登録
%   unregisterallevents - 実行時に指定したコントロールに対するすべての
%		             イベントの登録の解除
%   unregisterevent     - 実行時に指定したコントロールに対するイベントの
%			       登録の解除   
%   iscom               - 入力ハンドルがCOM/ActiveXオブジェクトの場合は真
%   isinterface         - 入力ハンドルがCOM Interfaceの場合は真
%   COM/set             - COMオブジェクトのプロパティ値の設定
%   COM/get             - COMオブジェクトプロパティの取得
%   COM/invoke          - オブジェクト、インタフェースについてメソッドを
% 			       呼び込む、またはメソッドを表示
%   COM/events          - COMオブジェクトがトリガ可能なイベントのリストを
%			      出力
%   COM/interfaces      - COMサーバがサポートするカスタムインタフェースの
%			      リスト
%   COM/addproperty     - カスタムプロパティをオブジェクトに追加
%   COM/deleteproperty  - カスタムプロパティをオブジェクトから削除
%   COM/delete          - COMオブジェクトを削除
%   COM/release         - COMインタフェースを解除
%   COM/move            - ActiveXコントロールを親ウィンドウで移動および/
%			      またはリサイズ
%   COM/propedit        - プロパティページを呼び込み
%   COM/save            - COMオブジェクトをファイルにシリアル化
%   COM/load            - COMオブジェクトをファイルから初期化
%
% COM サンプルコード
%   mwsamp   - ActiveXコントロール作成サンプル
%   sampev   - ActiveXサーバのイベントハンドラサンプル
%
% DDEクライアント関数
%   ddeadv   - アドバイザリリンクの設定
%   ddeexec  - 実行用の文字列を転送
%   ddeinit  - DDE通信の初期化
%   ddepoke  - データをアプリケーションに転送
%   ddereq   - データをアプリケーションから要求
%   ddeterm  - DDE通信の終了
%   ddeunadv - アドバイザリリンクの解除
%
% その他
%   winopen     - 適切なWindowsコマンドを用いてファイルを開く
%   winqueryreg - Windowsレジストリから情報を取得

%   Copyright 1984-2002 The MathWorks, Inc. 
