% COUNTHARDERRORS   コンポーネントの実行中のハードエラーの数を追跡
% NUMERR=COUNTHARDERRORS(RPTCP,INCREMENT)は、INCREMENTがゼロ以上の数値の
% とき、既に記録されているエラーの数にincrementを追加します。
%
% COUNTHARDERRORS(RPTCP,-1)は、ハードエラーカウンタをリセットします。
%
% ハードエラーは、RPTCP/RUNCOMPONENT中にexecute(c)がtry/catchで失敗した
% 場合に起こります。





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:21:42 $
%   Copyright 1997-2002 The MathWorks, Inc.
