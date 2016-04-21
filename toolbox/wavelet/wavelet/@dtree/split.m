function tnd = split(t,node,x,varargin)
%SPLIT Split (decompose) the data of a terminal node.
%   TNDATA = SPLIT(T,N,X) decomposes the data X 
%   associated to the terminal node N of the 
%   data tree T.
%   TNDATA is a cell array (ORDER x 1) such that
%   TNDATA{k} contains the data associated to
%   the kth child of N.
%
%   Caution: 
%   This method has to be overloaded for a
%   concrete class of objects.
%   ----------
%   For the Class DTREE the SPLIT method assign
%   the data of N to the most left child.
%   ----------

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:37:37 $

order  = treeord(t);
tnd    = cell(order,1);
tnd{1} = x;
