% IDPOLY/PEM は、一般的な線形モデルの予測誤差推定を計算します。
% 
%   M = PEM(Z,Mi)   
%
%   M : IDPOLY オブジェクト書式で、推定される共分散と構造の情報を含んだ
%       推定モデルを出力します。M の厳密な書式に関しては、help IDPOLY を
%       参照してください。
%
%   Z : IDDATA オブジェクトフォーマットで記述した推定に使用するデータ。
%       help IDDATA を参照してください。
%
%   Mi: モデル構造を定義する IDPOLY モデルオブジェクト。最小化は、Mi の
%       中に与えられるパラメータで初期化されます。
%
% M = pem(Z,Mi,Property_1,Value_1, ...., Property_n,Value_n) により、モ
% デル構造とアルゴリズムに関連したすべてのプロパティを使用できます。プロ
% パティ名/値に関する一覧は、IDSS や IDPOLY と入力してください。
% 



%	Copyright 1986-2001 The MathWorks, Inc.
