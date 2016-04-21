% STCOL   点在する変換選点行列
%
% COLMAT = STCOL(CENTERS, X, TYPE) は、psi_j と n が、STMAK で記述されて
% いるように、CENTERS と文字列 TYPE に依存する、(i,j) の要素が
%
%      psi_j( X(:,i) ),   i=1:size(X,2),  j=1:n ,
%
% となる行列を出力します。
%
% CENTERS と X は、同じ行数をもつ行列でなければなりません。
%
% TYPE のデフォルトは 'tp' で、このデフォルトに対して、n は size(CENTERS,2) 
% で、関数 psi_j は、つぎのように与えられています。
%
%      psi_j(x) := psi( x - CENTERS(:,j) ),   j=1:n,
%
% ここで、psi は、thin-plateスプライン基底関数であり、
%
%      psi(x) := |x|^2 log |x|^2 
%
% です。ただし、|x| は、ベクトル x のユークリッド(Euclidean)ノルムを
% 示しています。
%
% COLMAT = STCOL(..., 'tr') は、STCOL(...) の転置を出力します。
%
% 行列 COLMAT は、線形システム
%
%      sum_j a_j psi_j(X(:,i))  =  y_i,    i=1:size(X,2)
% 
% の係数行列です。関数 f := sum_j a_j psi_j が、すべての i について
% サイト X(:,i) で値 _i を補間するには、f の係数 a_j がこの式を満足して
% いなければなりません。
%
% 例題
%      a = [0,2/3*pi,4/3*pi]; centers = [cos(a), 0; sin(a), 0];
%      [x1,x2] = ndgrid(linspace(-2,2,45)); 
%      xx = [x1(:) x2(:)].';
%      coefs = [1 1 1 -3.5];
%      y = reshape( coefs*stcol(centers,xx,'tr'), size(x1));
%      surf(x1,x2,y), view([240,15]), axis off
%   は、thin-plateスプライン基底関数の4つの点在する変換 
%   psi(x-centers(:,j))，j=1:4, の重み付きの和を評価し、プロットします。
%
% 参考 : STMAK, STBRK, STVAL, SPCOL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
