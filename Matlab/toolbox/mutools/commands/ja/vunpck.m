% function [data,rowpoint,indv,err] = vunpck(mat)
%
% VARYING行列を分解します。MATの値は、変数DATAに順に出力されます。ROWP-
% OINT(i)の値は、MATのi番目の値の最初の行に対応するDATAの行を示します。
% INDVは、独立変数値をもつ列ベクトルです。ERRは、通常0ですが、matがSYS-
% TEM行列の場合、1です。
%
% 参考: GETIV, MINFO, PCK, UNPCK, VPCK, XTRACT, XTRACTI.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
