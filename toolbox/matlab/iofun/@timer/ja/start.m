% START   タイマーを稼動
%
% START(OBJ) は、timer オブジェクト OBJ で表されるタイマーを稼動します。
% OBJ が timer オブジェクトの配列である場合、START は、すべてのタイマーを
% 稼動します。TIMER 関数は、timer オブジェクトを作成するために使われます。
%
% START は、timer オブジェクト OBJ の Running プロパティを 'On' に設定し、
% TimerFcn コールバックを初期化し、StartFcn コールバックを実行します。
%
% 以下の条件の一つが適用された場合、タイマーを停止します。:
%  - 実行された TimerFcn コールバックの数が、TasksToExecute プロパティ
%    で指定された数に等しくなった場合
%  - STOP(OBJ) コマンドが発行された場合
%  - TimerFcn コールバックの実行中にエラーが発生した場合
%   
% 参考 : TIMER, TIMER/STOP.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:46 $
