% FEEDBACK   2つの LTI モデルをフィードバック結合
%
%
% SYS = FEEDBACK(SYS1,SYS2) は、閉ループフィードバックシステムの LTIモデル
% SYS を求めます。
%
%           u --->O---->[ SYS1 ]----+---> y
%                 |                 |           y = SYS * u
%                 +-----[ SYS2 ]<---+
%
% 負のフィードバックが仮定され、計算結果のシステム SYS は、u からy への応答を
% 示します。正のフィードバックを適用するためには、つぎの書式を用います。 
%   SYS = FEEDBACK(SYS1,SYS2,+1)
%
% SYS = FEEDBACK(SYS1,SYS2,FEEDIN,FEEDOUT,SIGN) は、より一般的なフィードバッ
% ク結合を作成します。 
%                       +--------+
%           v --------->|        |--------> z
%                       |  SYS1  |
%           u --->O---->|        |----+---> y
%                 |     +--------+    |
%                 |                   |
%                 +-----[  SYS2  ]<---+
%
% ベクトル FEEDIN は、SYS1 の入力ベクトルに対するインデックスを含み、どの入力
% u がフィードバックループに含まれるのかを設定します。同様にFEEDOUT は、SYS1
% のどの出力がフィードバックに使用されるのかを設定します。SIGN = 1 とすると、
% 正のフィードバックが使用されます。SIGN = -1とするか、SIGN を省略すると負の
% フィードバックが、使用されます。すべての場合、計算結果の LTI モデル SYS は、
% SYS1 と同じ入力と出力をもちます(それらの次数を保持します)。
%
% SYS1 と SYS2 が、LTI モデルの配列とすると、FEEDBACK は、同じ次元をもつLTI
% 配列 SYS を出力します。 ここで、 
%   SYS(:,:,k) = FEEDBACK(SYS1(:,:,k),SYS2(:,:,k)) 
% です。
%
% 参考 : LFT, PARALLEL, SERIES, CONNECT, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
