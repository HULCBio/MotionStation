% LTIPLUS   LTIモデルの加算に対するLTIプロパティを管理
% 
% [SYS.LTI,SYS1,SYS2] = LTIPLUS(SYS1.LTI,SYS2.LTI,SYS1,SYS2) は、モデル 
% SYS = SYS1 + SYS2 の LTI プロパティを設定します。離散時間では、相反
% する遅れは、DELAY2Z を用いて取り除かれます(SYS1 と SYS2 は、このとき
% これに従って更新されます)。
%
% 参考 : TF/PLUS.


%   Author(s):  P. Gahinet, 5-23-96
%   Copyright 1986-2002 The MathWorks, Inc. 
