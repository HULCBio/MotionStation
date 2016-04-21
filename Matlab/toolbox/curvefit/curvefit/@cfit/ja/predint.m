% PREDINT  fit result オブジェクト、または、新しい観測に関する予測区間
% 
% CI = PREDINT(FITRESULT,X,LEVEL) は、指定した X の値で、新しい Y の値に
% 対する予測区間を出力します。LEVEL は、信頼レベルで、デフォルト値は、
% 0.95 です。
%
% CI = PREDINT(FITRESULT,X,LEVEL,'INTOPT','SIMOPT') は、計算する区間のタ
% イプを指定します。'INTOPT' は、'observation'、または、'functional'のい
% ずれかを設定することができます。'observation' は、デフォルトで、新しい
% 観測に対する範囲を計算し、'functional' は、X で計算されたカーブに対する
% 範囲を計算します。'SIMOPT' は、'on'の場合、同期を取って信頼区間を計算し、
% 'off'の場合、非同期で計算します
%
% 'INTOPT' が、'functional' の場合、カーブの計算で、不確かさの測定になる
% 範囲です。また、'observation' の場合、範囲は、新しい Y 値(カーブ値にラ
% ンダムノイズを付加)を予測する中で、付加的な不確かさを表わすためにより広
% くなります｡
%
% 信頼レベルが 95% で、'INTOPT' を 'functional' と仮定します。
% 'SIMOPT' が、'off' (デフォルト)の場合、95% の信頼をもつ前もって定めた 
% X 値を与えると、真のカーブは、信頼区間の間に入ります。'SIMOPT' が 'on' 
% になる場合、(すべての X 値での)すべてのカーブが、範囲の中に入っている 
% 95% の信頼区間をもちます。

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
