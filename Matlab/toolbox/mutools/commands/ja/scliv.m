% function [vout] = scliv(vin,fac,offset)
%
% FACを使ってVARYING行列の独立変数要素をスケーリングし、各々にOFFSET(オ
% プション)を付加します。
%
%    newiv = fac*oldiv + offset
%
% これは、CONSTANT行列に対しては何も行いません。SYSTEM行列に対してはエラ
% ーを出力します。
%
% 参考: *, MMULT, MSCL, SCLIN, SCLOUT, SEEIV.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
