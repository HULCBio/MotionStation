% NORMSPEC   設定した範囲内での正規密度のプロット
%
% NORMSPEC(SPECS,MU,SIGMA) は、SPECS で設定される下限と上限の間の正規
% 密度をプロットします。MU と SIGMA は、プロットされる分布のパラメータ
% です。
% 
% [P, H] = NORMSPEC(SPECS,MU,SIGMA) は、下限と上限の間に入る標本の確率 P 
% を出力します。H は、lineオブジェクトのハンドル番号です。
% 
% SPECS(1) が -Inf の場合、下限の範囲の制限はありません。また、同様に、
% SPECS(2) = Inf の場合、上限の制限はありません。デフォルトでは、MU は0、
% SIGMA は1です。
% 


%   B.A. Jones 2-7-95
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:14:31 $
