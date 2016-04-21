function [Value,ValStr] = pvget(sys,Property)
%PVGET  Get values of public LTI properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   [VALUES,VALSTR] = PVGET(SYS) also returns a cell array 
%   of strings VALSTR containing formatted property value
%   info to be displayed by GET(SYS).  The formatting is done
%   using PVFORMAT. 
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.  The string property
%   must contain the true property name.
%
%   See also GET.

%   Author(s): P. Gahinet, 7-8-97
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/10 06:00:49 $

% RE: PVGET is performing object-specific property value access
%     for the generic LTI/GET method

if nargin==2
   % Value of single property
   try
      switch Property
      case 'a'
         Value = cell2nd(sys.a,0,0);
      case 'b'
         Value = cell2nd(sys.b,0,size(sys.d,2));
      case 'c'
         Value = cell2nd(sys.c,size(sys.d,1),0);
      case 'd'
         Value = sys.d;
      case 'e'
         Value = cell2nd(sys.e,0,0);
      case 'StateName'
         Value = sys.StateName;
      otherwise
         % Must be a parent property
         Value = pvget(sys.lti,Property);
      end
   catch
      % A,B,C,E cannot be represented as ND arrays
      MatName = upper(Property);
      line1 = sprintf('The %s matrices for this set of models have different sizes.  Use',MatName);
      line2 = sprintf(' * [A,B,C,D]=ssdata(sys,''cell'') to access %s matrices of varying size',MatName);
      line3 = sprintf(' * sys(:,:,k).%s=New%s  to modify the %s matrix of the k-th model.',Property,MatName,MatName);
      error(sprintf('%s\n%s\n%s',line1,line2,line3))
   end
   
else
   % Return all public property values (syntax GET(SYS))
   SSPropNames = pnames(sys,'specific');
   SSPropValues = struct2cell(sys);
   Value = [SSPropValues(1:length(SSPropNames)) ; pvget(sys.lti)];
   
   % If state dimension is uniform, turn A,B,C,E into ND arrays
   Nx = size(sys,'order');
   NoE = cellfun('isempty',sys.e);
   if length(Nx)==1,
      Value{1} = cell2nd(Value{1},0,0);
      Value{2} = cell2nd(Value{2},0,size(sys.d,2));
      Value{3} = cell2nd(Value{3},size(sys.d,1),0);
   end
   if length(Nx)==1 | all(NoE(:)),
      Value{5} = cell2nd(Value{5},0,0);
   end
   
   % Property value display
   if nargout==2,
      ValStr = pvformat(Value);  
      if length(Nx)>1,
         MatNames = {'A' 'B' 'C'};
         for i=[1 2 3],
            ValStr{i} = sprintf('%s matrices of varying size',MatNames{min(i,end)});
         end
      end
      if length(Nx)>1 & ~all(NoE(:)),
         ValStr{5} = 'E matrices of varying size';
      end
   end
end
