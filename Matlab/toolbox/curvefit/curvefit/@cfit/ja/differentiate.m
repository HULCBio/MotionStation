% DIFFERENTIATE  Fit result オブジェクトを微分
% DERIV1 = DIFFERENTIATE(FITOBJ,X) は、X で指定した点で、モデル FITOBJ を
% 微分し、結果を DERIV1 に出力します。
% 
% FITOBJ は、FIT、または、CFIT 関数で作成される FIT オブジェクトです。
% X は、ベクトルです。DERIV1 は、X と同じサイズのベクトルです。
% 数学的に表現すると、つぎのようになります。
% 
%   DERIV1 = D(FITOBJ)/D(X)
%
% [DERIV1,DERIV2] = DIFFERENTIATE(FITOBJ, X) は、モデル FITOBJ の1階微分 
% DERIV1 と2階微分 DERIV2 を出力します。
%
% 参考   INTEGRATE, FIT, CFIT.

% $Revision: 1.2.4.1 $


%   Copyright 2001-2004 The MathWorks, Inc.
