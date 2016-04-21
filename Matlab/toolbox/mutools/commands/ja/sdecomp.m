% function [sysst,sysun] = sdecomp(sys,bord,fl)
%
% システムを2つのシステムの和に分解します。
%    SYS = MADD(SYSST,SYSUN)
% SYSSTは、極の実数部がBORDよりも小さいものを含み、SYSUNは、極の実数部が、
% BORD以上のものを含みます。BORDは、デフォルトは0です。
%
% SYSUNに対するD行列は、FL = 'd'でない限りゼロで、このときは、SYSSTもゼ
% ロになります。
%
% 参考: HANKMR, SFRWTBAL, SFRWTBLD, SNCFBAL, SREALBAL, SYSBAL.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
