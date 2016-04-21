% FIT   データを fit type オブジェクトに近似します。
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE) は、FITTYPE が、その値に従って、
% データ XDATA と YDATA に近似する文字列の場合、近似されたモデル FIT-
% TEDMODEL を、戻します。
% 
% FITTYPE は、つぎの値を取ることができます。
%                FITTYPE                詳細       
%   スプライン：     
%                'smoothingspline'      平滑化スプライン
%                'cubicspline'          キュービック(内挿)スプライン
%   Interpolants:
%                'linearinterp'         線形内挿
%                'nearestinterp'        最近傍内挿
%                'splineinterp'         キュービックスプライン内挿
%                'pchipinterp'          型を保存したまま(pchip)での内挿
%
% または、CFLIBHELP の中に記述されるライブラリモデルの名前のいずれか
% (type CFLIBHELP により、ライブラリモデルの名前と詳細を見ることがで
% きます)。XDATA と YDATA は、列ベクトルです。注意：'cubicspline' と 
% 'splineinterp' は、同じ FITTYPE です。
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE) は、FITTYPE が、それ自身に含まれ
% る情報に従って、データ XDATA と YDATA を近似する FITTYPE オブジェクト
% の場合、近似されたモデル FITTEDMODEL を戻します。カスタムモデルは、
% FITTYPE 関数を使って、作成されます。
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,...,PROP1,VAL1,PROP2,VAL2,...) は、
% プロパティ名と値、PROP1, VAL1 等々で指定したアルゴリズムのオプションと
% 問題のオプションを使って、データ XDATA と YDATA を近似します。FITOP-
% TIONS プロパティとデフォルト値については、FITOPTIONS(FITTYPE) と入力
% してください。 
% 
%      fitoptions('cubicspline')
%      fitoptions('exp2')
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,OPTIONS) は、FITOPTIONS オブジェク
% ト OPTIONS に指定した問題とアルゴリズムのオプションを使って、データ 
% XDATA と YDATA を近似します。これは、プロパティの名前と値を組で設定する
% 別の表示方法です。OPTIONS オブジェクトの作成に関するヘルプは、FITOP-
% TIONS を参照してください。
%
% FITTEDMODEL=FIT(XDATA,YDATA,FITTYPE,...,'problem',VALUES) は、problem 
% に依存した定数を VALUES に割り当てます。VALUES は、problem に依存した
% 定数に付き一つの要素をもつセル配列です。problem に依存した定数に関する
% 情報は、FITTYPE を参照してください。
%
% [FITTEDMODEL,GOODNESS] = FIT(XDATA,YDATA,...) は、与えた入力に対して、
% 適合度合いを構造体 GOODNESS に出力します。GOODNESS は、つぎのフィール
% ドを含んでいます：SSE (誤差による二乗和)、R2(決定係数、または、R^2)、
% adjustedR2 (adjustedR^2 の自由度)と、stdError (近似標準誤差、または、
% RMS誤差)。
%
% [FITTEDMODEL,GOODNESS,OUTPUT] = FIT(XDATA,YDATA,...) は、与えられた入力
% に対して、適切な出力値をもつ OUTPUT 構造体を戻します。たとえば、非線形
% 近似問題に対して、繰り返し回数、モデルの計算回数、収束を示す exitflag 、
% 残差、Jacobian を、構造体 OUTPUT に戻します。
%
% 例題：
%      [curve, goodness] = fit(xdata,ydata,'pchipinterp');
% は、xdata と ydata を通して、キュービック内挿スプラインを使って、近似
% します。
% 
%      curve = fit(x,y,'exp1','Startpoint',p0)
% 
% は、初期値を p0 で書き換えた有理型関数のカーブフィッテングライブラリの
% 中の3番目の方程式に近似します。
%
% 参考： CFLIBHELP, FITTYPE, FITOPTIONS.

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
