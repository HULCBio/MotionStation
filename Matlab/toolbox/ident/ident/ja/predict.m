% PREDICT は、k ステップ先の予測を計算します。
%   YP = PREDICT(MODEL,DATA,K)
%   
%   DATA : IDDATA オブジェクトの型で表された出力 - 入力データで、予測計
%          算に使います。 
%      
%   MODEL: 任意の IDMODEL オブジェクトで、IDPOLY, IDSS, IDARX, IDGREY  
%          を使ったモデル
%
%   K    : 予測平面。時刻 t-K までの過去の出力が、時刻t での出力を予測す
%          るのに使われます。すべての関連した入力が使われます。K = inf 
%          とすると、システムの純粋な意味のシミュレーションを実行します
%          (デフォルト K = 1)。
%   YP   : IDDATA オブジェクトで表した、計算結果の予測出力。DATA が複数
%          の実験を含んでいる場合、YP も同じく、複数の実験を含みます。
%
% YP = PREDICT(MODEL,DATA,K,INIT) は、初期ベクトルの選択を行うことができ
% ます。
%   INIT : 初期化の方法：
% 	    'e': 予測誤差のノルムが最小化されるように初期状態を推定
%	         この状態は、X0 として出力(下記参照）
%                複数の実験のDATAに対して、X0は、各実験の初期状態を
%                含む列をもつ行列です 
%	    'z': 初期状態をゼロにする
%	    'm': モデルの内部初期状態を使用
%    X0  : 適切な長さの列ベクトルで、初期値として使用
%          複数の実験を含むDATAに対して、X0は、各実験に対する初期状態
%          を与える列をもつ行列です
% INIT が設定されていない場合、Model.InitialState が使われ、'Estimate', 
% 'Backcast', 'Auto' は推定された初期状態を与え、一方、'Zero' は 'z' を
% 'Fixed' は 'm' を与えます。
%
% [YP,X0,MPRED] = PREDICT(MODEL,DATA,M) は、初期状態 X0 と予測子 MPRED
% を出力します。MPRED は、IDPOLYオブジェクトのセル配列になります。ここで、
% MPRED{ky} は、ky番目の出力に対する予測子です。
%
% 参考: COMPARE, IDMODEL/SIM

%   L. Ljung 10-1-89,9-9-94


%   Copyright 1986-2001 The MathWorks, Inc.
