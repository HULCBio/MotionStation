% EVALFIS  ファジィ推論計算の実行
%
% 表示
%    output =  evalfis(input,fismat)
%    output =  evalfis(input,fismat,numPts)
%    [output,IRR,ORR,ARR] =  evalfis(input,fismat)
%    [output,IRR,ORR,ARR] =  evalfis(input,fismat,numPts)
% 
% 詳細
% evalfis は、つぎの引数をもちます。
% 
% input   : 入力値を設定する数、または、行列。入力が M 行 N 列(ここでは、
%           N は入力変数の数)の行列の場合、evalfis は、入力の各行を入力
%           ベクトルとして受け取って、変数 output に M 行 L 列の行列を出
%           力します。このとき、各行は出力ベクトルで、L は出力変数の数で
%           す。
% 
% fismat  : 計算の対象となる FIS 構造体
% 
% numPts  :その入力範囲、または、出力範囲上で、メンバシップ関数を計算す
%          るサンプル点数を表すオプションの引数。この引数を使用しない場
%          合、デフォルト値の101点を使用します。
% 
% evalfis の範囲ラベルは、つぎのとおりです。
% 
% output  :大きさが、M 行 L 列の出力行列。このとき、M は上で設定した入力
%          値の数、L は FIS に対する出力変数の数です。
% 
% 　　　　　入力引数が行ベクトル(入力の集合を1つのみ適用)の場合のみ、ev-
%           alfis に対するオプションの範囲変数を計算します。オプションの
%           範囲の変数は、つぎのとおりです。
% 
% IRR     :メンバシップ関数を使った入力値の計算結果。大きさは、numRules 
%          行 N 列の行列になります。このとき、numRules はルールの数、N 
%          は入力変数の数です。
% 
% ORR     :メンバシップ関数による出力値の計算結果。大きさは、numPts 行 
%          numRules*L 列の行列になります。ここで、numRules はルールの数
%          L は出力数です。
%          この行列の最初の numRules 列は、最初の出力に対応し、つぎの 
%          numRules 列は、2番目の出力に対応します。そして、以下同様に対
%          応します。
% 
% ARR     :各出力の出力範囲に沿った numPts でサンプルされた集積値を要素
%          とする numPts 行 L 列の行列です。
% 
% 1つの範囲の変数のみで起動すると、この関数は、数値、または、行列 input 
% で設定される入力値に対して、行列 fismat により設定されているファジィ推
% 論システムの出力ベクトル output を計算します。この計算はオプションの引
% 数です。
% 
% 例題
%    fismat = readfis('tipper');
%    out = evalfis([2 1; 4 9],fismat)
% 
% 結果は、つぎのようになります。
% 
%    out  = 
%        7.0169
%        19.6810
% 
% 参考    ruleview, gensurf



%   Copyright 1994-2002 The MathWorks, Inc. 
