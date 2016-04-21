% STOP   タイマーの停止
%
% STOP(OBJ) は、timer オブジェクト OBJ で表されるタイマーを停止します。
% OBJ が timer オブジェクトの配列である場合、STOP は、すべてのタイマーを
% 停止します。TIMER 関数は、timer オブジェクトを生成するために使われます。
%
% STOP は、timer オブジェクト OBJ の Running プロパティを 'Off' に設定し、
% TimerFcn コールバックを停止し StopFcn コールバックを実行します。
%
% 参考 : TIMER, TIMER/START.  


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:48 $
