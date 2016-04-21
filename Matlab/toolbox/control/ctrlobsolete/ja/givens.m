% GIVENS   Givens 回転行列
%
% G = GIVENS(x,y) は、複素数 Givens 回転行列を出力します。
%
%     | c       s |                  | x |     | r | 
% G = |           |   such that  G * |   |  =  |   |
%     |-conj(s) c |                  | y |     | 0 |
%                                
% ここで、c は実数、s は複素数、また、c^2 + |s|^2 = 1 です。 


%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:03 $
