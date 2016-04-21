% MATLAB Timer オブジェクト
%
% Timer 関数とプロパティ
%
% Timer オブジェクトの作成
%   timer         - timer オブジェクトの作成
%
% パラメータの取得と設定
%   get           - timer オブジェクトプロパティ値の取得
%   set           - timer オブジェクトプロパティ値の設定
%
% 一般
%   delete        - メモリから timer オブジェクトの消去
%   display       - timer オブジェクトのためのメソッドの表示
%   inspect       - インスペクターを開き、 timer オブジェクトプロパティの調査
%   isvalid       - 有効な timer オブジェクトの判定
%   length        - timer オブジェクト配列の長さを測定
%   size          - timer オブジェクト配列のサイズを測定
%   timerfind     - 指定されたプロパティ値を使って可視の timer オブジェクト
%                   の検索
%   timerfindall  - 指定されたプロパティ値を使って timer オブジェクトの検索
%
% 実行
%   start         - timer オブジェクトを稼動
%   startat       - 指定された時間で timer オブジェクトを稼動
%   stop          - timer オブジェクトの実行を停止
%   waitfor       - timer オブジェクトに対して実行を停止するための待ち時間
%
% Timer プロパティ
%   AveragePeriod    - TimerFcn 実行間の時間の平均値
%   BusyMode         - TimerFcn を実行の進行中に取得するアクション
%   ErrorFcn         - エラーが発生したときに実行されるコールバック
%   ExecutionMode    - timer イベントのスケジュールに使用されるモード
%   InstantPeriod    - 最後の2つの TimerFcn 実行中の経過時間
%   Name             - timer オブジェクトの記述名
%   Period           - TimerFcn 実行中の時間
%   Running          - timer オブジェクトの実行状態
%   StartDelay       - START と最初に調整された TimerFcn 実行間の遅れ
%   StartFcn         - timer オブジェクトが開始したときに実行される
%                      コールバック
%   StopFcn          - timer オブジェクトが停止した後に実行される関数の
%                      コールバック
%   Tag              - オブジェクトに対するラベル
%   TasksExecuted    - Timer Fcn の実行が発生した数
%   TasksToExecute   - TimerFcn のコールバックを実行する時間数
%   TimerFcn         - timer イベントが発生したときに実行されるコール
%                      バック関数
%   Type             - オブジェクトタイプ
%   UserData         - timer オブジェクトに対するユーザデータ
%
% 参考 TIMER.
%

%    CP 3-01-02
%    Copyright 2001-2002 The MathWorks, Inc. 
