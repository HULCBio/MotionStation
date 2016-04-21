% Serial Port関数とプロパティ
%
% serial portオブジェクト構成
%   serial        - serial portオブジェクトの作成
%
% パラメータの取得と設定
%   get           - serial port オブジェクトプロパティの値の取得
%   set           - serial port オブジェクトプロパティの値の設定
%
% 状態の変更
%   fopen         - オブジェクトをデバイスに接続
%   fclose        - デバイスからオブジェクトの切断 
%   record        - serial port session からデータを記録
%
% 読み込み関数と書き込み関数
%   fprintf       - デバイスにテキストを書き込む
%   fgetl         - 終端子を無視してデバイスからテキストを1行ずつ読み込む
%   fgets         - 終端子を無視しないてデバイスからテキストを1行ずつ読み込む
%   fread         - デバイスからからバイナリデータの読み込み
%   fscanf        - デバイスからからフォーマット付きデータの読み込み
%   fwrite        - デバイスにバイナリデータを書き込む
%   readasync     - デバイスから非同期でデータを読み込む
%
% serial port 関数
%   serialbreak   - ブレークをデバイスに送る
%
% 一般的な事柄
%   delete        - メモリから serial port オブジェクトを削除
%   inspect       - インスペクタをオープンして instrument オブジェクトの
%                   プロパティを調べる
%   instrcallback - イベントに対するイベント情報の表示
%   instrfind     - 指定したプロパティ値をもつ serial port オブジェクトの検索
%   instrfindall  - ObjectVisibilityに依らずに、すべての instrument 
%                   オブジェクトの検索
%   isvalid       - serial port オブジェクトがデバイスに接続できるかを判定
%   stopasync     - 非同期の読み込みと書き込み操作の停止
%
% serial port プロパティ
%   BaudRate                  - データビットが転送される割合の指定
%   BreakInterruptFcn         - インタラプトが生じたときに、実行する
%                               コールバック関数
%   ByteOrder                 - デバイスのバイト順
%   BytesAvailable            - 読み込みに利用するバイト数の指定
%   BytesAvailableFcn         - バイト数が指定されたときに実行される
%                               コールバック関数
%   BytesAvailableFcnCount    - BytesAvailableAction を実行する前に利用
%
%   BytesAvailableFcnMode     - BytesAvailableAction が、バイト数をベース
%
%   BytesToOutput             - 現在転送されるウエイテング状態のバイト数
%   DataBits                  - 転送されるデータビット数
%   DataTerminalReady         - DataTerminalReady ピンの状態
%   ErrorFcn                  - エラーが生じた場合に実行される
%                               コールバック関数
%   FlowControl               - 使用のためのデータフローコントロール
%                               メソッドの指定
%   InputBufferSize           - 入力バッファのトータルサイズ
%   Name                      - serial port オブジェクトの記述名
%   ObjectVisibility          - コマンドラインや GUI による、オブジェクトへの
%　　　　　　　　　　　　　　　 アクセスをコントロール
%   OutputBufferSize          - 出力バッファのトータルサイズ
%   OutputEmptyFcn            - 出力バッファが空のときに、実行する
%                               コールバック関数
%   Parity                    - エラー検出メカニズム
%   PinStatus                 - ハードウェアピンの状態
%   PinStatusFcn              - PinStatus 構造体内のピンが値を変更した
%                               ときに実行されるコールバック関数
%   Port                      - ハードウェア端子の記述
%   ReadAsyncMode             - 非同期の読み込み操作が連続かマニュアルの
%                               どちらかを指定
%   RecordDetail              - ディスクに記録する情報量
%   RecordMode                - データを一つのディスクファイルにセーブ
%                               するか、複数のディスクファイルにセーブ
%                               するかを指定
%   RecordName                - データの送信と受信を記録するディスク
%                               ファイルの名前
%   RecordStatus              - データがディスクに書き込まれたかを判定
%   RequestToSend             - RequestToSend ピンの状態
%   Status                    - serial port オブジェクトが serial port に
%                               接続しているかを判定
%   StopBits                  - データ転送の終了を示すために転送された
%                               ビット数
%   Tag                       - オブジェクト用ラベル
%   Terminator                - Serial port に送るコマンドを終了させる

%   Timeout                   - データを受信するための待ち時間
%   TimerFcn                  - timer イベントが発生したときに実行される
%                               コールバック関数
%   TimerPeriod               - timer イベント間の秒単位で表わした時間
%   TransferStatus            - 非同期の読み込み、または書き込み操作の
%                               進行を示す
%   Type                      - オブジェクトタイプ
%   UserData                  - オブジェクト用ユーザデータ
%   ValuesReceived            - デバイスから読み込む値の数
%   ValuesSent                - デバイスに書き込む値の数
%
% 参考 : SERIAL.
%


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
