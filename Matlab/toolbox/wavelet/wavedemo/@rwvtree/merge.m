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
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:36:06 $ 

[order,dwtMode,Lo_R,Hi_R] = getwtbo(t,'order','dwtMode','Lo_R','Hi_R');
s = nodesize(t,node);
switch order
  case 2 , x = idwt(tnd{2},tnd{1},Lo_R,Hi_R,max(s),'mode',dwtMode,'shift',0);
  case 4
    x = idwt2(tnd{4},tnd{1},tnd{2},tnd{3},...
              Lo_R,Hi_R,s,'mode',dwtMode,'shift',[0 0]);
end
