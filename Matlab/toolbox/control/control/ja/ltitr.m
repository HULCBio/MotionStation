% LTITR は、線形時不変時間応答の計算カーネルです。
%
% X = LTITR(A,B,U) は、システム x[n+1] = Ax[n] + Bu[n] の入力列 U の時間
% 応答を計算します。行列 U は、存在している入力群 u と同じ列数をもって
% います。U の各行は、新しい時間点に対応しています。LTITR は、状態 x の
% 数と同じ列数で、LENGTH(U) の行数をもつ行列 X を出力します。
%
%	for i = 1:n
%       x(:,i) = x0;
%       x0 = a * x0 + b * u(i,:).';
%	end
%	x = x.';


%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:26 $
