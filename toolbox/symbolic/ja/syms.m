% SYMS   シンボリックオブジェクト作成のショートカット
% 
%      SYMS arg1 arg2 ...
% 
% は、つぎのステートメントの短縮形です。
% 
%      arg1 = sym('arg1');
%      arg2 = sym('arg2'); ...
%
%      SYMS arg1 arg2 ... real
%  
% は、つぎのステートメントの短縮形です。
% 
%      arg1 = sym('arg1','real');
%      arg2 = sym('arg2','real'); ...
%
%      SYMS arg1 arg2 ... positive
%   
% は、つぎのステートメントの短縮形です。
% 
%      arg1 = sym('arg1','positive');
%      arg2 = sym('arg2','positive'); ...
%
%     SYMS arg1 arg2 ... unreal
%   
% は、つぎのステートメントの短縮形です。
% 
%      arg1 = sym('arg1','unreal');
%      arg2 = sym('arg2','unreal'); ...
%
% 各入力引数は、文字で始まり、英数字のみを含まなければなりません。
%
% SYMS だけでは、ワークスペース内のシンボリックオブジェクトをリストしま
% す。
%
% 例題:
% 
%      syms x beta real
% 
% は、つぎのステートメントと等価です。
% 
%      x = sym('x','real');
%      beta = sym('beta','real');
%
% 'real' 状態のシンボリックオブジェクト x と beta を消去するためには、つ
% ぎのようにタイプしてください。
% 
%      syms x beta unreal
%
% 参考   SYM.



%   Copyright 1993-2002 The MathWorks, Inc.
