% Optimization Toolbox
% Version 3.0 (R14) 05-May-2004 
%
% 非線形関数の最小化
%   fminbnd     - 範囲による制約付きスカラ非線形関数の最小化
%   fmincon     - 制約付き多変数非線形関数の最小化
%   fminsearch  - Nelder-Mead直接検索法による制約なし多変数非線形関数の
%                 最小化
%   fminunc     - 制約なし多変数非線形関数の最小化
%   fseminf     - 半無限制約付き多変数非線形関数の最小化
%
% 非線形多目的関数の最小化
%   fgoalattain - 多変数ゴール到達最適化
%   fminimax    - 多変数ミニマックス最適化
%        
% (行列問題の)線形最小二乗法
%   lsqlin      - 線形制約付き線形最小二乗法
%   lsqnonneg   - 非負制約付き線形最小二乗法
%
% (関数の)非線形最小二乗法
%   lsqcurvefit - (範囲による)制約付き非線形最小二乗カーブフィッティング
%   lsqnonlin   - 範囲による制約付き非線形最小二乗法
%
% 非線形零点検出(方程式の解法)
%   fzero       - スカラ非線形方程式の零点
%   fsolve      - 非線形方程式の解法 (関数の解)
%
% 行列問題の最小化
%   linprog    - 線形計画法
%   quadprog   - 二次計画法
% 
% デフォルト値とoptionsのコントロール
%   optimset - 最適化パラメータのOPTIONS構造体の作成と変更 
%   optimget - OPTIONS構造体からの最適化パラメータの取得  
%
% 大規模法を使ったデモンストレーション
%   circustent - サーカスのテントの型を検出する二次計画法
%   molecule   - 制約なし非線形最小化を使った分子構造の決定
%   optdeblur  - 範囲による制約付き線形最小二乗法を使ったイメージの明瞭化
%
% 中規模法を使ったデモンストレーション
%   optdemo    - デモンストレーションメニュー
%   tutdemo    - チュートリアルの説明
%   bandemo    - banana関数の最小化
%   goaldemo   - ゴール到達法
%   dfildemo   - 有限精度でのフィルタ設計(Signal Processing Toolboxが必要)
%   datdemo    - データのカーブフィッティング
% 
% User's Guideからの中規模法の例題
%   objfun     - 非線形目的関数
%   confun     - 非線形制約
%   objfungrad - 勾配が与えられた非線形目的関数
%   confungrad - 勾配が与えられた非線形制約
%   confuneq   - 非線形等式制約
%   optsim.mdl - 非線形プラントプロセスのsimulinkモデル
%   optsiminit - optisim.mdlのinitファイル
%   tracklsq   - lsqnonlin 多目的目的関数
%   trackmmobj - fminimax多目的目的関数
%   trackmmcon - fminimax多目的制約
%
% User's Guideからの大規模法の例題
%   nlsf1        - Jacobianが与えられた非線形等式の目的関数
%   nlsf1a       - 非線形等式の目的関数
%   nlsdat1      - JacobianスパースパターンのMAT-ファイル(nlsf1a参照)
%   brownfgh     - 勾配およびHessianが与えられた非線形最小化目的関数
%   brownfg      - 勾配が与えられた非線形最小化目的関数
%   brownhstr    - HessianスパースパターンのMAT-ファイル(brownfg参照)
%   tbroyfg      - 勾配が与えられた非線形最小化目的関数
%   tbroyhstr    - HessianスパースパターンのMAT-ファイル(tbroyfg参照)
%   browneq      - Aeq および beq スパース線形等式制約のMAT-ファイル
%   runfleq1     - 等式をもつFMINCON の 'HessMult' オプションについての記述
%   brownvv      - スパースでない構造をもつHessianが与えられた非線形最小化
%   hmfleq1      - brownvv 目的関数のHessian 行列積
%   fleq1        - brownvv, hmfleq1 および Aeq,beqのV 行列のMAT-ファイル
%   qpbox1       - 二次目的関数のHessianスパース行列のMAT-ファイル
%   runqpbox4    - 範囲の制約付き QUADPROG の'HessMult' オプション
%   qpbox4       - 二次計画問題の行列のMAT-ファイル
%   runnls3      - LSQNONLIN の 'JacobMult' オプションについての記述
%   nlsmm3       - runnls3/nlsf3a 目的関数のJacobian乗算関数
%   nlsdat1      - runnls3/nlsf3a目的関数に対する問題の行列のMAT-ファイル
%   runqpeq5     - 等式をもつ QUADPROG の 'HessMult' オプションについての記述
%   qpeq5        - runqpeq5の2次計画行列のMAT-ファイル
%   particle     - 線形最小二乗 C およびd スパース行列のMAT-ファイル
%   sc50b        - 線形計画の例題のMAT-ファイル
%   densecolumns - 線形計画の例題のMAT-ファイル


%   Copyright 1990-2004 The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.10  $Date: 2003/05/01 13:00:33 $
