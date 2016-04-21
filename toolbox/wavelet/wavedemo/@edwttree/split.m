function tnd = split(t,node,x,varargin)
%SPLIT Split (decompose) the data of a terminal node.
%   TNDATA = SPLIT(T,N,X) decomposes the data X 
%   associated to the terminal node N of the 
%   wavelet tree T.
%
%   TNDATA is a cell array (ORDER x 1) such that
%   TNDATA{k} contains the data associated to
%   the k-th child of N.
%
%   The method uses DWT for one-dimensional data.
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:36:05 $ 

Lo_D  = t.waveInfo.Lo_D;
Hi_D  = t.waveInfo.Hi_D;
mode  = t.dwtMode;
order = treeord(t);
tnd   = cell(order,1);
[tnd{1},tnd{2}] = dwt(x,Lo_D,Hi_D,'mode',mode,'shift',0);
[tnd{4},tnd{3}] = dwt(x,Lo_D,Hi_D,'mode',mode,'shift',1);
