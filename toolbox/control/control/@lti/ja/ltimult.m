% LTIMULT   LTIモデルの乗算に対するLTIプロパティを管理
% 
% [SYS.LTI,SYS1,SYS2] = LTIMULT(SYS1.LTI,SYS2.LTI,SYS1,SYS2,SCALARMULT) 
% は、モデル SYS = SYS1 * SYS2 のLTIプロパティを設定します。離散時間の
% 場合、相反する遅れを DELAY2Z を用いて取り除きます(SYS1 と SYS2 は、
% このとき、これに従って更新されます)。
%
% 参考 : TF/MTIMES.


%   Author(s):  P. Gahinet, 5-23-96
%   Copyright 1986-2002 The MathWorks, Inc. 
