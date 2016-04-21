% DEVAL  微分方程式問題の解を計算します
%
% SXINT = DEVAL(SOL,XINT) は、ベクトルXINTのすべての要素に対する
% 微分方程式問題の解を解きます。SOLは、初期値問題ソルバ(ODE45, 
% ODE23, ODE113, ODE15S, ODE23S, ODE23T, ODE23TB)、境界値問題
% ソルバ(BVP4C)、遅れ微分方程式ソルバ(DDE23)によって出力される構造
% 体です、XINTの要素は、区間 [SOl.x(1) SOL.x(end)] 内になければなりま
% せん。各 I に対して、SXINT(:,I) は、XINT(I) に対応する解です。 
%
% SXINT = DEVAL(SOL,XINT,IDX) は、上記のように実行しますが、IDXにリスト
% されたインデックスをもつ解の要素のみを出力します。   
%
% SXINT = DEVAL(XINT,SOL) と SXINT = DEVAL(XINT,SOL,IDX) も利用できます。
%
% [SXINT,SPXINT] = DEVAL(...) は、上記のように評価しますが、解を補間する
% 多項式の１階導関数の値も出力します。
%
% 多点境界値問題に対して、BVP4C を使用して得られた解は、境界で不連続である
% 可能性があります。境界点 XC に対して、DEVAL は、XC の左と右からの極限の
% 平均を出力します。極限値を得るためには、DEVAL の引数 XINT 
% を XC よりもわずかに小さく、あるいは、わずかに大きく設定してください。
%
% 参考
%    ODE ソルバ:  ODE45, ODE23, ODE113, ODE15S, 
%                 ODE23S, ODE23T, ODE23TB, ODE15I 
%    DDE ソルバ:  DDE23
%    BVP ソルバ:  BVP4C

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
