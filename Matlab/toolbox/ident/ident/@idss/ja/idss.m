% IDSS は、IDSS モデルクラスを作成します。
%       
%   M = IDSS(A,B,C,D)
%   M = IDSS(A,B,C,D,K,X0,Ts)
%   M = IDSS(A,B,C,D,K,X0,Ts,'Property',Value,..)
%   M = IDSS(MOD)  
% 
% ここで、MOD は、任意の SS, TF, ZPK モデル、または、任意の IDMODEL オブ
% ジェクトです。
%
%   M : 出力される離散時間モデルを記述するモデル構造体オブジェクト
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
% A,B,C,D,K は、状態空間行列で、X0 は初期条件、必要なら Ts はサンプル時
% 間です。Ts == 0 の場合、連続時間モデルが作成されます。
%
% K, X0, Ts を省略すると、デフォルト値 K = zeros(nx,ny), X0 = zeros(nx,1), 
% Ts = 1 が使われます。ここで、nx と ny は、状態数と出力数です。すなわち、
% size(C) = [nx ny] です。
%
% M = IDSS(MOD) は、MOD の中のモデル情報を出力します。
% MOD が、定義される InputGroup 'Noise' をもたない LTI オブジェクトの場
% 合、ノイズ特性のない(K = 0) IDSSモデルが得られます。デフォルトでは、
% 単位分散ノイズ源が出力に付加されます。ノイズを付加しないためには、入力
% 引数に、
%      ... , 'NoiseVariance' , zeros(ny,ny) , ...
% を追加します。MOD が、InputGroup 'Noise' をもっている場合、これらの入力
% は、単位分散をもつ独立な白色ノイズ源と解釈されます。それで、K と
% NoiseVariance は、このモデルに対するカルマンフィルタから計算されます。
%
% M = IDSS は、空オブジェクトを作成します。
%
% 状態空間ブラックボックスモデルの扱い方は、IDHELP SSBB を参照してくださ
% い。そして、内部構造をもつ状態空間モデルの扱い方は、IDHELP SSSTRUC を
% 参照してください。
% 
% IDSS プロパティの詳細については、IDPROPS IDSS、または、SET(IDSS) とタ
% イプインしてください。
%
% 参考:  SETSTRUC



%   Copyright 1986-2001 The MathWorks, Inc.
