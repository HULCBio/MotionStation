% EVALC   キャプチャを使ったMATLAB表現の評価
% 
% T = EVALC(S) は、コマンドウィンドウに通常書き出されるものがキャプチャ
% されて、キャラクタ配列Tに出力されること以外は、EVAL(S) と同じです(T の
% ラインは、'\n' キャラクタで区切られます)。  
%
% T = EVALC(s1,s2) は、出力が T にキャプチャされること以外は、EVAL(s1,s2) 
% と同じです。
%
% [T,X,Y,Z,...] = EVALC(S) は、出力が T にキャプチャされること以外は、
% [X,Y,Z,...] = EVAL(S) と同じです。
%
% 注意: evalc の中で、DIARY、MORE、INPUTは使用できません。
%
% 参考： EVAL, EVALIN, DIARY, MORE, INPUT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:56 $
