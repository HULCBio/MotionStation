function this = subsasgn(this,Struct,rhs)
% Subscripted assignment for data set objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:28 $

% RE: Needed for D.x(2,2)=1 when D.x is empty (need to 
%     initialize array)
StructL = length(Struct);

% Peel off first layer of subassignment
warning('1')
switch Struct(1).type
   case '.'
      % Assignment of the form sys.fieldname(...)=rhs
      FieldName = Struct(1).subs;
      try
         if StructL==1
            % Direct assignment
            this.(FieldName) = rhs;
         else
            % Get current value
            FieldValue = this.(FieldName);
            if isempty(FieldValue)
               % Need to initialize LHS
               GridSize = getGridSize(this);
               if StructL>2 || ~strcmp(Struct(2).type,'()') || any(GridSize==0)
                  error('Invalid assignment into uninitialized variable %s',FieldName);
               end
               % D.var(ind) = rhs assignment
               FieldValue = hdsNewArray(rhs,GridSize);
            end
            % Perform assignment on field value and write back
            this.(FieldName) = subsasgn(FieldValue,Struct(2:end),rhs);
         end
      catch
         rethrow(lasterror)
      end
   case {'()','{}'}
      error('Invalid assignment syntax into data set object.')
end
