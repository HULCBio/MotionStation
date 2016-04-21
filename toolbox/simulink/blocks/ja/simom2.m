% SIMOM2   行列A,B,C,Dを外部から与える状態空間M-ファイルS-functionの例
%
% このS-functionは、状態空間方程式で記述されるシステムを実現します。
%
% dx/dt = A*x + B*u
% y = C*x + D*u
%
% ここで、xは状態ベクトル、uは入力のベクトル、y
% は出力のベクトルです。
% 行列 A,B,C,Dは、このM-ファイルのパラメータとして外部的に与えられます。
%
% 一般的なS-functionのテンプレートは、sfuntmpl.mを参照してください。
%
% 参考 : SFUNTMPL.


% Copyright 1990-2002 The MathWorks, Inc.
