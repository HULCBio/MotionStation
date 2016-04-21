% PDENTRP は、PDEPE 用の内挿に関する補助関数
% [U,UX] = PDENTRP(M,XL,UL,XR,UR,XOUT) は、連続的なメッシュ点 XL < XR を満たす点 、
% XL での解 UL と XR での解 UR を使って、XL < =  XOUT(i) < =  XR での XOUT(i) で
% の解 U と x に関する偏微分係数 UX を内挿により求めます。UL と UR は列ベクトル
% です。出力引数 U,UX の列 i は、XOUT(i) に対応します。
%
% 参考：PDEPE, PDEVAL, PDEODES.

% $Revision: 1.6 $ $Date: 2002/06/17 13:35:17 $
%   Copyright 1984-2002 The MathWorks, Inc. 
