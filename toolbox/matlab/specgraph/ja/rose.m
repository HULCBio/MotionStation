% ROSE   角度ヒストグラム
% 
% ROSE(THETA) は、THETA の各々の角度に対して、角度ヒストグラムをプロット
% します。ベクトル THETA の角度は、ラジアン単位で指定しなければなりません。
%
% ROSE(THETA,N) は、N がスカラのとき、0から2*PIまでの N 個の等間隔のbinを
% 使用します。N のデフォルト値は、20です。
%
% ROSE(THETA,X) は、X がベクトルのとき、X で指定したbinを使って、ヒスト
% グラムを描画します。
%
% ROSE(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = ROSE(...) は、lineオブジェクトのハンドル番号からなるベクトルを
% 出力します。
%
% [T,R] = ROSE(...) は、POLAR(T,R) がヒストグラムとなるような、ベクトル T 
% と R を出力します。プロットは行われません。
%
% 参考：HIST, POLAR, COMPASS.


%   Clay M. Thompson 7-9-91
%   Copyright 1984-2002 The MathWorks, Inc. 
