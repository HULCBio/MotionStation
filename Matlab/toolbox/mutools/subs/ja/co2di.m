%  function dsys = co2di(csys,alpha)
%
% つぎのように定義された双一次変換を使って、連続時間SYSTEM行列を離散時間
% SYSTEM行列に変換します。
%
%          1     z-1
%   s = ------- -----
%        alpha   z+1
%
%                    j
% 点 z = jは、s = -------へのマッピングを得ます。
%                  alpha
%
% ALPHA>0の場合、右半平面(sについて)が単位円(zについて)の外側にマッピン
% グされ、安定化特性が保存されます。
%----------------------------------------------------------
% 注意:これは、DI2COで使われたものと同じ変換ではありません。DI2COでは、
% つぎの変換
%
%            z-1
% s = alpha -----
%            z+1
%
% が使われます。そのため、SYSTEM行列SYSや任意のALPHAに対して、SYSとCO2DI
% (DI2CO(SYS, 1/ALPHA), ALPHA)が等しくなります。
%

% All Rights Reserved.


%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:29:36 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
