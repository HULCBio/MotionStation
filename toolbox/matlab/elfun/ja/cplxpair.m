% CPLXPAIR   複素数を複素共役の組に並べ替え
% 
% Y = CPLXPAIR(X) は、複素共役の組と実数を要素とするベクトルにします。
% CPLXPAIRは、複素数が対応する複素共役の組になるように、Xの要素を再配列
% します。複素共役の組は、実部の大きさの昇順に並べられます。虚数部をもた
% ない純粋な実数値は、すべての複素数の組の後に出力されます。
% Y = CPLXPAIR(X,TOL)は、比較のために相対誤差TOLを使います。デフォルト
% のTOLは、100*EPSです。
%
% XがN次元配列の場合、CPLXPAIR(X) および CPLXPAIR(X,TOL) は、Xの最初に
% 1でない次元の要素を並べ替えます。CPLXPAIR(X,[],DIM)、および、
% CPLXPAIR(X,TOL,DIM) は、次元DIMについてXを並べ替えます。

%   L. Shure 1-27-88
%   Revised 4-30-96 D. Orofino
%   Copyright 1984-2003 The MathWorks, Inc. 