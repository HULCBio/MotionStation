% SFD   有限勾配差分によるスパースHessian
%
% H = sfd(x,grad,H,group,fdata,fun) は、カレント点 x で、関数 'fun' の 
% Hessian 行列のスパース有限差分を使った近似値を出力します。ベクトル
% グループは、スパース有限差分法を指定します。group(i) = j は、列 i が
% グループ(または カラー) j に属することを意味します。各グループ(または
% カラー)は、有限勾配差分に対応します。
% fdata は、関数 'fun' で必要とされる(可能性のある)データ配列です。
%
% H = sfd(x,grad,H,group,fdata,fun,alpha) は、有限差分のステップサイズを
% 設定します。


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 12:59:58 $
