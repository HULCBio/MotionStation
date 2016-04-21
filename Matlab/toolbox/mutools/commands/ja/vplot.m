% function vplot([plot_type],vmat1,vmat2,vmat3, ...)
% function vplot([plot_type],vmat1,'linetype1',vmat2,'linetype2',...)
% function vplot('bode_l',toplimits,bottomlimits,vmat1,vmat2,vmat3, ...)
%
% 1つまたは複数のVARYING行列をプロットします。シンタックスは、すべてのデ
% ータがVMATiに含まれ、軸がPLOT_TYPEによって指定されることを除けば、MA-
% TLABのplotコマンドと同じです。
%
% (オプションの)plot_type引数は、つぎのうちのいずれかです。
%
%    'iv,d'       行列と独立変数(デフォルト)
%    'iv,m'       ゲインと独立変数
%    'iv,lm'      ゲイン(対数)と独立変数
%    'iv,p'       位相と独立変数
%    'liv,d'      行列と独立変数(対数)
%    'liv,m'      ゲインと独立変数(対数)
%    'liv,lm'     ゲイン(対数)と独立変数(対数)
%    'liv,p'      位相と独立変数(対数)
%    'ri'         実数と虚数(独立変数によりパラメータ化)
%    'nyq'        実数と虚数(独立変数によりパラメータ化)
%    'nic'        ニコルス線図
%    'bode'       ボード線図
%    'bode_g'     グリッド付きボード線図
%    'bode_l'     軸の制限付きボード製図
%    'bode_gl'    軸の制限とグリッド付きボード線図
%
% プロットタイプ'bode_l'および'bode_gl'では、2番目と3番目の引数が、それ
% ぞれ、上段と下段の軸の範囲を示すベクトルです。たとえば、つぎのようにな
% ります。
%
%     vplot('bode_gl',[-1,1,-3,1],[-1,1,-180,0],...
%
%  参考: PLOT



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
