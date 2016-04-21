function [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x)
%
% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/06/17 12:21:58 $

if((exist('userGftable.mat') == 2))
    load userGftable
else
    load gftable
end

   if isempty(GF_TABLE_STRUCT(x.m).prim_poly)
     ind = [];
   else
     ind = find(GF_TABLE_STRUCT(x.m).prim_poly==x.prim_poly);
   end

   if isempty(ind)
     if x.m>2
       str = sprintf(['Lookup tables not defined for this order 2^%g and\n' ...
                   'primitive polynomial %g.  Arithmetic still works\n' ...
                   'correctly but multiplication, exponentiation, and\n' ...
                   'inversion of elements is faster with lookup tables.\n' ...
                   'Use gftable to create and save the lookup tables.'],...
                     x.m,double(x.prim_poly));
       warning('comm:gftablewarning',str)
     end
     GF_TABLE1 = [];
     GF_TABLE2 = [];
   else
     GF_TABLE1 = GF_TABLE_STRUCT(x.m).table1(:,ind);
     GF_TABLE2 = GF_TABLE_STRUCT(x.m).table2(:,ind);
   end
   GF_TABLE_M = x.m;
   GF_TABLE_PRIM_POLY = x.prim_poly;
   

