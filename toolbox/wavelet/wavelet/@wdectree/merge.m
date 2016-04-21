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
 
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:38:52 $ 

order = treeord(t);
s = read(t,'sizes',node);
typeWT = t.WT_Settings.typeWT;
switch typeWT
    case {'dwt','wpt'}
        shift   = t.WT_Settings.shift;
        extMode = t.WT_Settings.extMode;
        Lo_R = t.WT_Settings.Filters.Lo_R;
        Hi_R = t.WT_Settings.Filters.Hi_R;
        switch order
            case 2 , 
                x = idwt(tnd{1},tnd{2},...
                    Lo_R,Hi_R,max(s),'mode',extMode,'shift',shift);
            case 4 ,
                x = idwt2(tnd{1},tnd{2},tnd{3},tnd{4},...
                    Lo_R,Hi_R,s,'mode',extMode,'shift',shift);
        end
 
    case {'lwt','lwpt'}
        typeDEC = typeWT(2:3);
        LS = t.WT_Settings.LS;
        switch order
            case 2 ,
                x = ilwt(tnd{1},tnd{2},LS,1,'typeDEC',typeDEC);
            case 4 ,
                x = ilwt2(tnd{1},tnd{2},tnd{3},tnd{4},LS,1,'typeDEC',typeDEC);
        end        
end