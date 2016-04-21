% FEM1ODE   時変質量行列 M(t)*y' = f(t,y) をもつスティッフな問題
% 
% パラメータNは離散化を制御し、結果のシステムは、N個の方程式で構成されま
% す。デフォルトでは、Nは19です。  
%
% この例題で、サブ関数 f(Y,Y,N) は、偏微分方程式の有限要素の離散化用の微
% 係数ベクトルを出力します。サブ関数 mass(T,N) は、時刻 T で評価する時変
% の質量行列 M を出力します。デフォルトでは、ODE Suite のソルバは、y' = 
% f(t,y) の型のシステムを解きます。システム M(t)y' = f(t,y) を解くために、
% ODESET を使って、プロパティ 'Mass' を関数に設定し、M(t) を計算するため
% に、'MStateDepencence'に'none'を設定します。
%   
% この問題で、Jacobian df/dy は定数で、三重対角行列になります。'Jacobian' 
% プロパティは、df/dy をソルバに与えます。
%
% 参考：ODE15S, ODE23T, ODE23TB, ODESET, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 11-11-94.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:48:32 $
