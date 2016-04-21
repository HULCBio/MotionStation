% STRNCMP   文字列の最初のN個のキャラクタの比較
% 
% STRNCMP(S1,S2,N) は、文字列 S1 と S2 の最初の N 個のキャラクタが同じ
% 場合は1、他の場合は0を出力します。
%
% TF = STRNCMP(S,T,N) は、S と T のうちのいずれかが文字列のセル配列のとき、
% S や T と同じサイズで、S と T の同じ要素(最大Nキャラクタ)の場合は1、他の
% 場合は0を要素とする配列を出力します。S と T は、同じサイズ(またはスカラの
% セル)でなければなりません。いずれかが、正しい行数をもつキャラクタ配列
% でも構いません。
%
% STRNCMP は、国際キャラクタセットをサポートします。
%
% 参考：STRCMP, STRNCMPI, FINDSTR, STRMATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:07:14 $
%   Built-in function.

