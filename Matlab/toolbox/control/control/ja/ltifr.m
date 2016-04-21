% LTIFR   線形時不変周波数応答計算カーネル
%
% G = LTIFR(A,b,S) は、システム G(s) = (sI - A)\b に対して、ベクトル S 
% で設定した複素数周波数での周波数応答を計算します。列ベクトル b は、
% 行列 A の行数と同じです。行列 G は、SIZE(A) 行 LENGTH(S) 列の大きさです。
% これは、高速実行コードです。
%
%		function g = ltifr(a,b,s)
%		ns = length(s); na = length(a);
%		e = eye(na); g = sqrt(-1) * ones(na,ns);
%		for i = 1:ns
%		    g(:,i) = (s(i)*e-a)\b;
%		end


%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:22 $
