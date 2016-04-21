% function csys = di2co(dsys,alpha)
%
% つぎのように定義された双一次変換を使って、離散時間SYSTEM行列を連続時間
% SYSTEM行列に変換します。
%
%         s + alpha
% z =  -  -----------
%         s - alpha
%
% 点s = j alphaで、z = jへのマッピングを得ます。
% ALPHA>0の場合、右半平面(sについて)が単位円(zについて)の外側にマッピン
% グされ、安定化特性が保存されます。
%----------------------------------------------------------
% 注意:これは、CO2DIで使われたものと同じ変換ではありません。CO2DIでは、
% つぎの変換
%
%          s + (1/alpha)
% z =  -  --------------
%          s - (1/alpha)
%
% が使われます。そのため、SYSTEM行列SYSと任意のALPHAに対して、SYSとCO2DI
% (DI2CO(SYS, 1/ALPHA), ALPHA)が等しくなります。
%

% All Rights Reserved.


%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:49 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
