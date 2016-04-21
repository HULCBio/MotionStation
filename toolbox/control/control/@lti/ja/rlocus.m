% RLOCUS   Evans根軌跡法
%
% RLOCUS(SYS) は、1入力1出力のLTIモデル SYS の根軌跡を求めてプロットし
% ます。根軌跡プロットは、つぎのような負のフィードバックループを解析する
% ために利用されます。
%
%                  +-----+
%      ---->O----->| SYS |----+---->
%          -|      +-----+    |
%           |                 |
%           |       +---+     |
%           +-------| K |<----+
%                   +---+
%
% 根軌跡は、フィードバックゲイン K が、0から Inf (無限大)へ変化する場合
% の閉ループ極の軌跡を示します。RLOCUS は、滑らかなプロットを作成する
% ように自動的に正のゲインの集合を計算します。  
%
% RLOCUS(SYS,K) は、ユーザが設定したゲインベクトル K を利用します。
%
% RLOCUS(SYS1,SYS2,...) は、複数のLTIモデル SYS1,SYS2,...の根軌跡を
% 一つのプロット図に表示します。各モデルに対して、カラー、ラインスタイル、
% マーカをつぎのように設定することができます。
% 
%   rlocus(sys1,'r',sys2,'y:',sys3,'gx')
% 
% [R,K] = RLOCUS(SYS)、または、R = RLOCUS(SYS,K) は、ゲイン K に対応する
% 複素根の位置を行列 R に出力します。R は、LENGTH(K) の列をもち、j番目
% の列は、ゲイン K(j) に対する閉ループ根になります。  
%
% 参考 : RLTOOL, RLOCFIND, POLE, ISSISO, LTIMODELS.


%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 7-8-89, 6-21-92 
%   Revised P. Gahinet 7-96
%   Revised A. DiVergilio 6-00
%   Copyright 1986-2002 The MathWorks, Inc. 
