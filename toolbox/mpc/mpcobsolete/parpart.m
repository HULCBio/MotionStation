function y = parpart(x1,x2,x3);
% PARPART  Parameter partition for nlmpcsim and nlcmpc.
% 	y = parpart(x1,x2)
%	y = parpart(x1,x2,x3)
%  PARPART(x1,x2) = [x1 x2].  If x1 and x2 do not have
%  the same number of rows, PARPART appends extra rows
%  with the last row of x1 or x2.  If x1 is an integer,
%  x1 is the number of outputs from the plant and no output
%  constraints are assumed.  If x2 is an integer, x2 is
%  the number of inputs and no input constraints are assumed.
%  PARPART(x1,x2,x3) = [x1 x2 x3].  If x1, x2, and x3 do not
%  have the same number of rows, PARPART appends extra rows
%  with the last row of x1, x2, or x3.
%
% See also NLMPCSIM, NLCMPC.


%  Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $
if nargin <= 1,
   error('Not enough input arguments')
end
if nargin == 3,
   row1 = size(x1,1);
   row2 = size(x2,1);
   row3 = size(x3,1);
   rowmax = max([row1 row2 row3]);
   if row1 < rowmax,
      for i = row1+1:rowmax,
         x1 = [x1; x1(row1,:)];
      end
   end
   if row2 < rowmax,
      for i = row2+1:rowmax,
         x2 = [x2; x2(row2,:)];
      end
   end
   if row3 < rowmax,
      for i = row3+1:rowmax,
         x3 = [x3; x3(row3,:)];
      end
   end
   y = [x1 x2 x3];
elseif nargin == 2,
   if isempty(x1) | isempty(x2),
      error('ylim and ulim cannot be empty.')
   end
   if max(size(x1)) == 1,
      if ceil(x1) == x1,
         x1 = [-inf*ones(1,x1) inf*ones(1,x1)];
      else
         error('ylim must be either a vector or an integer')
      end
   end
   if max(size(x2)) == 1,
      if ceil(x2) == x2,
         x2 = [-inf*ones(1,x2) inf*ones(1,x2) 1e6*ones(1,x2)];
      else
         error('ulim must be either a vector or an integer')
      end
   end
   row1 = size(x1,1);
   row2 = size(x2,1);
   rowmax = max(row1,row2);
   if row1 < rowmax,
      for i = row1+1:rowmax,
         x1 = [x1; x1(row1,:)];
      end
   end
   if row2 < rowmax,
      for i = row2+1:rowmax,
         x2 = [x2; x2(row2,:)];
      end
   end
   y = [x1 x2];
end
return