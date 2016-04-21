% WENTROPY　 エントロピー(ウェーブレットパケット)の算出
%
% E = WENTROPY(X,T,P) は、ベクトルまたは行列 X のエントロピー E を算出
% します。いずれの場合においても、出力 E は1つの実数値です。
%
% T は、エントロピーのタイプを示す文字列です。
%   T = 'shannon'、'threshold'、'norm',
%   'log energy' (または 'logenergy')、'sure'、'user'.
% または、
%   T = FunName (ここで、以前に上にリストされたエントロピータイプ名を
%       除く、任意の他の文字列)。FunName は、ユーザのエントロピー関数
%       のM-ファイル名です。
%
% P は、T の値に依存するオプションパラメータです。
%   T = 'shannon'、または、'log energy' の場合、P は用いられません。
%   T = 'threshold'、または、'sure' の場合、P はスレッシュホールド値に
%   なり、正の数で設定されねばなりません。
%   T = 'norm' の場合、P はべき数で、1 < =  P を満たさなければなりません。
%   T = 'user' の場合、P は単一入力 X をもつ、ユーザ自身のエントロピー
%   関数の M-ファイル名を示す文字列となります。
%   T = FunName の場合、P は、制約のないオプションパラメータになります。
%
% E = WENTROPY(X,T) は、E = WENTROPY(X,T,0) と等価です。

 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
