function gftable(m,prim_poly)
%GFTABLE Generate a MAT-file to accelerate Galois field computations.
%   GFTABLE(M,PRIM_POLY) generates two tables which will significantly
%   speed up computations over a Galois field. Use this function 
%   if you plan to do many calculations with nondefault primitive polynomials.
%   Tables already exist for every default primitive polynomial. 
%
%   The tables are stored in the MAT-file userGftable.mat in the working directory.
%   Once this file is created it needs to be on the MATLAB path, or in the working
%   directory. See the ADDPATH command for instructions on adding a directory to 
%   the MATLAB path.
%
%   See also GF.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.5 $  $Date: 2002/06/17 12:22:20 $ 

global GF_TABLE_STRUCT GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

% check to see if the m and prim_poly already exist in 
% either userGftable or gftable
if((exist('userGftable.mat') == 2))
    clear GF_TABLE_M GF_TABLE_PRIM_POLY
    load userGftable.mat
    if ~isempty(find(GF_TABLE_STRUCT(m).prim_poly==prim_poly))
        fprintf(1,'This m and prim_poly are already in the MAT-file.')
        return
    end   
else
    load gftable
    clear GF_TABLE_M GF_TABLE_PRIM_POLY
    if ~isempty(find(GF_TABLE_STRUCT(m).prim_poly==prim_poly))
        fprintf(1,'This m and prim_poly are already in the MAT-file.')
        return
    end
end

  x=gf(0:2^m-1,m, prim_poly)';
  x1 = gf(zeros(1,2^m),m,prim_poly);
  warning('off','comm:gftablewarning'); ;
  x1=x(3).^(0:2^m-1);
  warning('on','comm:gftablewarning');
  ind=x1.x;
  %ind =
  %     1     2     4     3     6     7     5     1
  ind=double(ind);
  ind(end)=[];
  x=0*ind; 
  i=0:2^m-2;
  x(ind)=i;
  %x =
  %     0     1     3     2     6     4     5
  table = [[ind'; 1] [-1; x']];
  if isempty(GF_TABLE_STRUCT(m).prim_poly)
    GF_TABLE_STRUCT(m).prim_poly = uint32(prim_poly);
    GF_TABLE_STRUCT(m).table1 = uint16(table(2:end,1));
    GF_TABLE_STRUCT(m).table2 = uint16(table(2:end,2));
else
    GF_TABLE_STRUCT(m).prim_poly(end+1) = uint32(prim_poly);
    GF_TABLE_STRUCT(m).table1(:,end+1) = uint16(table(2:end,1));
    GF_TABLE_STRUCT(m).table2(:,end+1) = uint16(table(2:end,2));
end

%assign tables to the global workspace
GF_TABLE1 = GF_TABLE_STRUCT(m).table1;
GF_TABLE2 = GF_TABLE_STRUCT(m).table2;


save userGftable GF_TABLE_STRUCT
fprintf(1,['Tables have been saved for m=%g and prim_poly=%g in gfUsertable.mat.\n'...
        'In order to use these tables, userGftable.mat must be on the MATLAB path\n'...
        'or in the working directory'],m, prim_poly);  
