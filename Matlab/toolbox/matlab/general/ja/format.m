% FORMAT   出力書式の設定
% FORMAT は、MATLAB での計算方法に影響を与えません。たとえば、浮動小数点
% (単精度および倍精度)変数の計算は、変数の表示方法に依らず、適切な浮動
% 小数点精度(単精度または倍精度)で行われます。
% FORMATは、つぎに示すような、異なる表示書式間の切り替えを行います。
% 
% MATLABは、すべての計算を倍精度で実行します。
% FORMATは、つぎに示すような、異なる表示書式間の切り替えを行います。
%   FORMAT          デフォルト。SHORTと同じです。
%   FORMAT SHORT    5桁のスケーリングされた固定小数点。
%   FORMAT LONG     15桁のスケーリングされた固定小数点。
%   FORMAT SHORT E  5桁の浮動小数点。
%   FORMAT LONG E   15桁の浮動小数点。
%   FORMAT SHORT G  5桁の固定小数点または浮動小数点の最良表示。
%   FORMAT LONG G   15桁の固定小数点または浮動小数点の最良表示。
%   FORMAT HEX      16進数。
%   FORMAT +        正の数、負の数、ゼロに対する+、-、ブランク。虚数
%                   部分は無視されます。
%   FORMAT BANK     ドルとセントの固定書式。
%   FORMAT RAT      有理数書式
%
% スペース:
%   FORMAT COMPACT 余分なラインフィードを省略
%   FORMAT LOOSE   ラインフィードの追加


%   Copyright 1984-2002 The MathWorks, Inc. 
