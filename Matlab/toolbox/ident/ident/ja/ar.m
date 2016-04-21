% AR は、種々のアプローチを使って、信号の AR モデルを計算します。
%   Model = AR(Y,N)    
%   TH = AR(Y,N,Approach)  
%   TH = AR(Y,N,Approach,Win)
%
%   Model: AR モデルの推定したパラメータを使って、IDPOLY モデルとして出
%          力されます。詳細は、HELP IDPOLY を参照。
%
%   Y    : モデル化に使用する時系列で、IDDATA オブジェクトです(HELP ID-
%           DATAを参照)。
%   N    : AR-モデルの次数
%   Approach: 使用する手法で、つぎのいずれかを選択してください。
%      'fb' : 前方、後方アプローチ(デフォルト)
%      'ls' : 最小二乗法
%      'yw' : Yule-Walker 法
%      'burg': Burg 法
%      'gl' : 幾何学的格子法
%    後半2つは、反射係数と損失関数を、[Model ,REFL] = AR(y,n,approach) 
%    の型で、引数 REFL に出力されます。上の引数の最後に0を付加する(たと
%    えば、'burg0')と、共分散の計算が省略されます。
%   Win    : 使用するウインドウで、つぎのいずれかを選択してください。
%      'now' : ウインドウを使用しない(approach='yw' のとき以外は、デフォ
%              ルト)
%      'prw' : 処理の前にウインドウを適用
%      'pow' : 処理の後にウインドウを適用
%      'ppw' : 処理の前と後にウインドウを適用
%
% プロパティ/値の組としての、'MaxSize'/maxsize と 'Ts'/Ts は、プロパティ
% MaxSizeを設定し(IDPROPS ALGを参照)、データのサンプリング間隔を上書きする
% ために、追加可能です。
% 例：Model = AR(Y,N,Approach,'MaxSize',500)。
%
% 参考： IVAR 
%        多出力の場合は、ARX と N4SID



%   Copyright 1986-2001 The MathWorks, Inc.
