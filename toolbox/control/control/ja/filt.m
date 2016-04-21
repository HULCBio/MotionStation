% FILT   離散時間伝達関数の DSP で使用される表現法
%
%
% SYS = FILT(NUM,DEN)      サンプリング時間が指定されていないデジタル
%                          フィルタ、H(z^-1)=NUM(z^-1)./DEN(z^-1)
% SYS = FILT(NUM,DEN,Ts)   サンプリング時間が指定されていないデジタル
%                          フィルタ、H(z^-1)=NUM(z^-1)./DEN(z^-1)
% SYS = FILT(M)            ゲイン行列
%
% 上の呼び出しの構文には、プロパティ/値の組が続けられます。
%
% SISO の場合、NUM と DEN は、分子多項式と分母多項式の係数を z^-1 の次数の
% 低い順に並べた行ベクトルです。MIMO の場合、NUM と DEN は、入力 j から
% 出力 i までの伝達関数を表す NUM{i,j} と DEN{i,j} の行ベクトルのセル配列です。
%
% 参考 : TF


% Copyright 1986-2002 The MathWorks, Inc.
