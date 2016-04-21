% EVALIN   ワークスペース内の式の評価
% 
% EVALIN(WS,'expression') は、ワークスペース WS の環境下で 'expression' 
% を実行します。WS は、'caller' または 'base' のいずれかです。これは、
% 式をどのワークスペースで実行するかを制御できるということを除けば、EVAL 
% と同じです。
%
% [X,Y,Z,...] = EVALIN(WS,'expression') は、式から出力引数を出力します。
%
% EVALIN(WS,'try','catch') は、式 'try' を評価しようとし、それに失敗すると
% (カレントのワークスペース内で)式 'catch' を評価します。
%
% 参考：EVAL, ASSIGNIN.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:57 $

%   Built-in function
