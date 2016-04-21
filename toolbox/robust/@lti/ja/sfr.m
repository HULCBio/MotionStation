% SFR 右スペクトル分解
%
% [SS_M] = SFR(SS_)、または、[AM,BM,CM,DM] = SFR(A,B,C,D) は、つぎのよう
% なSFLと双対な右スペクトル分解を実行します。
%
%                 M(s)M'(-s) = I - G(s)G'(-s)
%
%                入力データ: G(s):= SS_ = MKSYS(A,B,C,D);
%                出力データ: M(s):= SS_M = MKSYS(AM,BM,CM,DM);
%
%  "branch"を使って、一般的な状態空間表現に展開できます。



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
