% PE は、予測誤差を計算します。
% 
%   E = PE(Model,DATA)
%   E = PE(Model,DATA,INIT)
%
%   E    : 計算した予測誤差。誤差を E.OutputData に含んだ IDDATA オブジ
%          ェクトです。
%   DATA : IDDATA オブジェクトの型で表した出力 - 入力データ(HELP IDDATA 
%          を参照)
%   Model: 任意の IDMODEL オブジェクト、IDPOLY, IDSS, IDARX, IDGREY で
%          与えたモデル
%   INIT : 初期化の方法：
% 	    'e': E のノルムが最小化されるように初期状態を推定
%	         この状態は、X0 として出力
%	    'z': 初期状態をゼロにする
%	    'm': モデルの内部初期状態を使用
%       X0: 適切な長さの列ベクトルで、初期値として使用
%           複数の実験を含むDATAに対して、X0は、各実験に対する初期状態
%           を与える列をもつ行列です
% INIT が設定されていない場合、Model.InitialState が使われ、'Estimate',
% 'Backcast', 'Auto'は推定された初期状態を与え、一方、'Zero' は 'z' を、
% 'Fixed' は 'm' を与えます。
%
% [E,X0] = PE(Model,DATA) は、使用する初期状態 X0 を出力します。DATA が
% 複数の実験を含む場合、X0 は、各実験に対する初期状態を含む列をもつ行列
% になります。

%	L. Ljung 10-1-86,2-11-91


%	Copyright 1986-2001 The MathWorks, Inc.
