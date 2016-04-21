% function y = vinterp(u,stepsize,finaliv,order)
% または
% function y = vinterp(u,varymat,order)
%
% 出力ベクトルY(VARYING)は、入力Uを内挿したものです。
%
% 2番目の引数が正のスカラの場合、つぎのようになります。Yの独立変数はMIN
% (GETIV(U))から始まり、FINALIV(または、引数が2個のみの場合、MAX(GETIV
% (U)))で終了します。増分はSTEPSIZEです。従って、これにより出力IVが定間
% 隔になります。2番目の引数がVARYING行列の場合、つぎのようになります。Y
% の独立変数は、GETIV(VARYMAT)と等しくなります。この場合、3番目の引数は
% 内挿の次数です。
%
% orderは、つぎの内から選択されます。
%     0	ゼロ次ホールド(引数が3個の場合、デフォルト)
%     1	線形補間
%
% 参考: DTRSP, TRSP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
