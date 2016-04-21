% HPRECON   H-前提条件のスパースCholesky分解
%
% [R,PVEC] = HPRECON(H,UPPERBANDW,DM,DG) は、スパースCholesky分解を計算
% します。(正方行列 M の(通常の)範囲付きの前提条件の転置を行います。)
%                M = DM*H*DM + DG
% ここで、DM と DG は、非負のスパース対角行列です。
% R'*R は、M(pvec,pvec) を近似します。すなわち、
%          R'*R = M(pvec,pvec)
% です。
%
% H は、真のHessianではありません。H が真のHessianと同じ大きさの場合、H は、
% 前提条件 R の計算に使われます。
% それ以外の場合、以下の式に対する対角前提条件を計算します。
%               M = DM*DM + DG
%
% 0 < UPPERBANDW <  n の場合、R の高帯域幅は、UPPERBANDW になります。
% UPPERBANDW >= n の場合、R の構造は、symmmdの順序付けを用いた H のスパース
% Cholesky因子分解に対応します。(順序付けは、PVEC に出力されます。)


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 13:01:57 $
