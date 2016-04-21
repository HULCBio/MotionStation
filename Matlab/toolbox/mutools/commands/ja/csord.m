% function [v,t,flgout,reig_min,epkgdif] = .....
%                     csord(a,epp,flgord,flgjw,flgeig)
%
% この関数は、順序付けられた複素Schur行列Tを作成します。ここで、
%            v' * a * v  = t = |t11  t12|
%                              | 0   t22|
% であり、V'V = eye()です。
% MATLAB関数SCHURが呼び出されます。これは、順序付けられていないSchur型行
% 列を作成します。サブルーチンCGIVENSにより、複素Givens回転行列を作成し、
% ユーザが定義した方法でT行列を並べます。入力フラグは、つぎのように設定
% します。
%
% EPP           ユーザが設定するゼロの判定基準(デフォルト EPP=1e-9)
% FLGORD = 0    固有値の実数部が増加するように出力(デフォルト)
%        = 1    固有値の実部が負、ゼロ、正の順に出力
% FLGJW  = 0    固有値の位置に関する終了条件はありません(デフォルト)。
%        = 1    jw軸上に固有値が存在すれば終了(JWHAMTSTを参照)
% FLGEIG = 0    半平面上での固有値に関する終了条件はありません
%               (デフォルト)。
%        = 1    length(real(eigenvalue)>0) ~= length(real(eigenvalue)<0)
%               の場合、終了
%
% 出力フラグFLGOUTは、通常0です。固有値がjw軸上にあれば、FLGOUTは1に設定
% されます。正の固有値の数と負の固有値の数が異なる場合、FLGOUTは2に設定
% されます。両方が共に満たされる場合は、FLGOUT は3です。固有値の最小実部
% は、REIG_MINに出力されます。EPKGDIFは、2つの異なるjw軸のテストの比較で
% す。
%
% 参考: RIC_SCHR, SCHUR, RSF2CSF.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
