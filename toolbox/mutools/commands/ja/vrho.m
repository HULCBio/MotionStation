% function out = vrho(matin)
%
% 正方なVARYING/CONSTANT行列のスペクトル半径を求めます。スペクトル半径は、
% CONSTANT行列に対しては、MAX(ABS(EIG(MATIN)))のように定義され、VARYING
% 行列MATINの各々の独立変数に対しては、MAX(ABS(EIG(XTRACTI(MATIN,I))))の
% ように定義されます。
%
% 参考: EIG, VEIG.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
