% ARX   ARX モデルを最小二乗法を使って計算します。
% 
%   M = ARX(DATA,ORDERS)
%
%   M: つぎの型で表される ARX モデル
% 
%   A(q) y(t) = B(q) u(t-nk) + e(t)
% 
% の推定パラメータで、共分散や構造情報を含んでいます。
% 単出力システムに対して、M は IDPOLY モデルオブジェクトになり、多出力シ
% ステムに対して、IDARX オブジェクトになります。
% 
% 詳細は、IDPROPS, IDPROPS IDPOLY, IDPROPS IDARX のいずれかを入力してく
% ださい。
%
%   DATA: IDDATA オブジェクトの型をした推定に使用するデータで、詳細は HE
%         LP IDDATA を参照してください。
%   
%   ORDERS = [na nb nk] は、上のモデルの次数と遅れです。
%   
% 多出力システムの場合、ORDERS は出力数と同数の行をもち、na は ny|ny 行
% 列で、その i 行 j 列の要素は i 番目の入力と j 番目の出力を関連付ける多
% 項式(遅れ演算子を含んで)の次数を表しています。同様に、nb と nk も ny-
% |nu 行列になります(ny:# は出力を、nu:# は入力)。時系列の場合、ORDER = 
% na のみになります。
% 
% 別の表現として、m = ARX(DATA,'na',na,'nb',nb,'nk',nk) を使うことができ
% ます。
%
% 多出力の場合、ARX は E'*inv(LAMBDA)*E のノルムを最小化します。ここで、
% E は予測誤差で、LAMBDAはイニシャルモデル(デフォルトは単位行列)のノイズ
% 分散です。
%
% アルゴリズムに関連したいくつかのパラメータとオプションは、任意の順番の
% プロパティとプロパティ値の組合わせとなります。省略したプロパティは、デ
% フォルトの値に設定されます。利用される典型的なオプションとして、つぎの
% ものがあります。
%   
%   FOCUS ('Prediction', 'simulation', 'stability' または、プリフィルタ)
%   INPUTDELAY
%   FIXEDPARAMETER (ノミナルモデルの固定したいパラメータ)
%   NOISEVARIANCE (多出力での出力ノルムの指定)
%   MAXSIZE  (構成される行列の最大サイズの指定)
%
% 参考: 詳細は、IDPROPS ALGORITHM、または、IDPROPS IDMODEL
%       パラメータ次数の推定法に関しては、ARXSTRUC, SELSTRUC
%       他の推定ルーチンに関しては、AR, ARMAX, BJ, IV4, N4SID, OE, PEM

%   L. Ljung 10-1-86,12-8-91


%   Copyright 1986-2001 The MathWorks, Inc.
