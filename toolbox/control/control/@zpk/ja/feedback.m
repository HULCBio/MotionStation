% FEEDBACK   2つのLTIモデルをフィードバック結合
%
% SYS = FEEDBACK(SYS1,SYS2) は、閉ループフィードバックシステムのLTIモデル
% SYS を求めます。
%
%       u --->O---->[ SYS1 ]----+---> y
%             |                 |           y = SYS * u
%             +-----[ SYS2 ]<---+
%
% 負のフィードバックが仮定され、計算結果のシステム SYS は、u から y への
% 応答を示します。正のフィードバックを適用するためには、つぎの書式を用い
% ます。
% 
%    SYS = FEEDBACK(SYS1,SYS2,+1)
%
% SYS = FEEDBACK(SYS1,SYS2,FEEDIN,FEEDOUT,SIGN) は、より一般的なフィード
% バック結合を作成します。
%                   +--------+
%       v --------->|        |--------> z
%                   |  SYS1  |
%       u --->O---->|        |----+---> y
%             |     +--------+    |
%             |                   |
%             +-----[  SYS2  ]<---+
%
% ベクトル FEEDIN は、SYS1 の入力ベクトルに対するインデックスを含み、
% どの入力 u がフィードバックループに含まれるのかを設定します。同様に 
% FEEDOUT は、SYS1 のどの出力がフィードバックに使用されるのかを設定し
% ます。SIGN = 1 とすると、正のフィードバックが使用されます。SIGN = -1
% とするか、SIGN を省略すると負のフィードバックが、使用されます。すべて
% の場合、計算結果のLTIモデル SYS は、SYS1 と同じ入力と出力をもちます
% (それらの次数を保持します)。
%
% SYS1 と SYS2 が、LTIモデルの配列とすると、FEEDBACK は、同じ次元をもつ
% LTI配列 SYS を出力します。ここで、 
% 
%   SYS(:,:,k) = FEEDBACK(SYS1(:,:,k),SYS2(:,:,k))
% 
% です。
%
% 参考 : LFT, PARALLEL, SERIES, CONNECT, LTIMODELS.


%   P. Gahinet  6-26-96
%   Copyright 1986-2002 The MathWorks, Inc. 
