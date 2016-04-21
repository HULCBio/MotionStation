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
%   The method uses DWT (respectively DWT2) for
%   one-dimensional (respectively two-dimensional) data.
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:38:56 $ 
 
order = treeord(t);
tnd   = cell(order,1);
typeWT = t.WT_Settings.typeWT;
switch typeWT
    case {'dwt','wpt'}
        shift   = t.WT_Settings.shift;
        extMode = t.WT_Settings.extMode;
        Lo_D = t.WT_Settings.Filters.Lo_D;
        Hi_D = t.WT_Settings.Filters.Hi_D;
        switch order
            case 2 , 
                [tnd{1},tnd{2}] = ...
                    dwt(x,Lo_D,Hi_D,'mode',extMode,'shift',shift);
            case 4 ,
                [tnd{1},tnd{2},tnd{3},tnd{4}] = ...
                    dwt2(x,Lo_D,Hi_D,'mode',extMode,'shift',shift);
        end
    case {'lwt','lwpt'}
        typeDEC = typeWT(2:3);
        LS = t.WT_Settings.LS;
        switch order
            case 2 ,
                [tnd{1},tnd{2}] = lwt(x,LS,1,'typeDEC',typeDEC);
            case 4 ,
                [tnd{1},tnd{2},tnd{3},tnd{4}] = lwt2(x,LS,1,'typeDEC',typeDEC);
        end        
end