% SFDNLS   有限差分によるスパースJacobian
%
% J = sfdnls(x,valx,J,group,[],fun) は、カレント点 x で関数 'fun' の 
% Jacobian行列のスパース有限差分近似 J を出力します。ベクトルグループは、
% スパース有限差分手法を指定します。group(i) = j は、列 i がグループ
% (またはカラー) j に属することを意味します。各グループ(またはカラー)は、
% 関数差分に対応します。
% varargin は、関数 'fun' で必要とされる(可能性のある)エクストラパラメータ
% です。
%
% J = sfdnls(x,valx,J,group,fdata,fun,alpha) は、デフォルトの有限差分の
% ステップサイズを書き換えます。
%
% [J, ncol] = sfdnls(...) は、ncol の中で使用される関数の計算回数です。


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 13:00:32 $
