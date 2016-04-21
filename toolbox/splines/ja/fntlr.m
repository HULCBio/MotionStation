% FNTLR   テイラー(Taylor)係数あるいは多項式
%
% FNTLR(F,DORDER,X) は、X における次数 DORDER の F のテイラー(Taylor)
% 係数を出力します。DORDER は、テイラー(Taylor)のベクトルです。
%
%      T(F,DORDER,X) := [F(X); DF(X); ...; D^(DORDER-1)F(X)]
%
% この場合 F は一変数で、X はスカラです。
%
% より一般的に、X が行列の場合、テイラー(Taylor)のベクトルに対応するもので
% 各入力を置き換えることによって、X から得られた行列が出力されます。
%
% より一般的に、F が d>1、または length(d)>1 であるd個の値をもち、
% さらに/あるいは、いくらかの m>1 に対してm変数関数である場合、DORDER 
% は、正の整数のm個のベクトルであることが要求され、また X は、m行の行列で
% あることが要求されます。そしてその場合、
%
%     T(F,DORDER,X(:,j))(i1,...,im) = D_1^{i1-1}...D_m^{im-1}F(X(:,j))
%
%                                       i1=1:DORDER(1), ..., im=1:DORDER(m).
%
% をj番目の列として含む、大きさ [prod(d)*prod(DORDER),size(x,2)] の出力
% となります。
%
% FNTLR(F,DORDER,X,INTERV) は、X が [m,1] の大きさで、INTERV が [m,2] 
% の大きさで与えられ、F によって記述されたm変数関数に対して、与えられた
% 基本区間をもつ次数 DORDER の X におけるテイラー(Taylor)多項式のpp-型を
% 出力します。
%
% 例えば、fntlr(f,3,x) は、
%
%   df = fnder(f); [fnval(f,x); fnval(df,x); fnval(fnder(df),x)]
%
% と同じ出力を生成します。
%
% これは、f によって記述された関数が有理スプラインの場合で、fnder(f) が
% エラーメッセージのみ生成する場合に特に役立ちます。
% 例えば、以下は、有名なRunge関数のプロットと一次微分を与えます。:
%      runge = rpmak([-5 5],[0 0 1; 1 -10 26],1);  x = -5:.1:5;
%      tlr = fntlr(runge,2,x);
%      plot(x,tlr)
%   
% 例えば、f が区分的なbicubic関数を記述している場合、
%
%   tp = fntlr(f,[4 4],[0;0],[-1 1;-1 1]);
%
% は、原点 (0,0) を含む壊れた四角(break-rectangle)上の関数に一致する
% 多項式を記述します。
%
% 参考 : FNDER, FNDIR, FNVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
