% DDEINIT DDE通信の初期化
% 
% DDEINITは、サービスまたはアプリケーションの名前と、サービスのトピックを
% 表す2つの引数を必要とします。他のMATLAB DDE関数で使用するためのチャン
% ネルハンドルを出力します。
%
%    channel = DDEINIT(service,topic)
%
% channel 通信に割り当てられたチャンネル
% service 通信のためのサービスまたはアプリケーション名を指定する文字列
% topic   通信のためのトピックスを指定する文字列
%
% たとえば、Microsoft Excelのスプレッドシート'forecast,xls'との通信を
% 初期化します。
% 
%      channel = ddeinit('excel','forecast.xls');
%
% 参考：DDETERM, DDEEXEC, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:09:43 $
%   Built-in function.

