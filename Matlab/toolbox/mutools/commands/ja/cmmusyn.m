%function [qopt,bound] = cmmusyn(r,u,v,blk,opt,Qinit)
%
% CONSTANT行列の上界のμシンセシス。BLKで定義されたブロック構造を使って、
% mu(R+UQV)の上界を(CONSTANT行列Qについて)最小化します。



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
