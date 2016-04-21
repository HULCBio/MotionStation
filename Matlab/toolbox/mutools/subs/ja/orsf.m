% function [u,t,k]=orsf(u,a,fl,bord)
%
%  *****  UNTESTED SUBROTUINE  *****
%
% 行列Aを実Schur型で与えると、ORSFは、T = U'*A*Uを求めます。ここで、Uは
% ユニタリ行列です。FL = 'o'の場合、Tの固有値は実数部の昇順に並べられて
% います。または、FL = 's'の場合、Tの固有値は2つのグループに並べられ、最
% 初のグループの固有値の実数部がBORDより小さくなります。BORDのデフォルト
% 値はゼロです。Kは、実数部がBORDよりも小さい極の数です。
%
% 参考: OCSF

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:32:09 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
