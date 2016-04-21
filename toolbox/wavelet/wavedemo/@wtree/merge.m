function x = merge(t,node,tnd)
%MERGE Merge (recompose) the data of a node.
%   X = MERGE(T,N,TNDATA) recomposes the data X 
%   associated to the node N of the data tree T,
%   using the data associated to the children of N.
%
%   TNDATA is a cell array (ORDER x 1) or (1 x ORDER)
%   such that TNDATA{k} contains the data associated to
%   the k-th child of N.
%
%   The method uses IDWT (respectively IDWT2) for
%   one-dimensional (respectively two-dimensional) data.
%
%   This method overloads the DTREE method.
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:36:10 $ 

order = treeord(t);
mode  = t.dwtMode;
Lo_R = t.waveInfo.Lo_R;
Hi_R = t.waveInfo.Hi_R;
s = nodesize(t,node);
switch order
  case 2 , x = idwt(tnd{1},tnd{2},Lo_R,Hi_R,max(s),'mode',mode,'shift',0);
  case 4
    x = idwt2(tnd{1},tnd{2},tnd{3},tnd{4},...
              Lo_R,Hi_R,s,'mode',mode,'shift',[0 0]);
end
