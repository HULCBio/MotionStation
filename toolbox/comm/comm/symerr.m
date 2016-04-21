function [num, rat, loc] = symerr(varargin)
%SYMERR Compute number of symbol errors and symbol error rate.
%   [NUMBER,RATIO] = SYMERR(X,Y) compares the elements in the two matrices
%   X and Y. The number of the differences is output in NUMBER. The ratio of
%   NUMBER to the number of elements is output in RATIO. When one of the inputs
%   is a matrix and the other is a vector the function performs either a
%   column-wise or row-wise comparison based on the orientation of the vector.
%
%   Column : When one of the inputs is a matrix and the other is a column
%   Wise     vector with as many elements as there are rows in the input
%            matrix, a column-wise comparison is performed.  In this mode the
%            column vector is compared with each column of the input matrix. By
%            default the results of each column comparison are output and both
%            NUMBER and RATIO are row vectors.  To override this default and
%            output the overall results, use the 'overall' flag(see below).
%
%   Row    : When one of the inputs is a matrix and the other is a row vector
%   Wise     with as many elements as there are columns in the input matrix, a
%            row-wise comparison is performed.  In this mode the row vector is
%            compared with each row of the input matrix.  By default the
%            results of each row comparison are output and both NUMBER and
%            RATIO are column vectors.  To override this default and output the
%            overall NUMBER and RATIO, use the 'overall' flag(see below).
%
%   In addition to the two matrices, one optional parameter can be given:
%
%   [NUMBER,RATIO] = SYMERR(...,FLAG) uses FLAG to specify how to perform and
%   report the comparison.  FLAG has three possible values: 'column-wise',
%   'row-wise' and 'overall'.  If FLAG is 'column-wise' then SYMERR compares
%   each individual column and outputs the results as row vectors. If FLAG is
%   'row-wise' then SYMERR compares each individual row and outputs the results
%   as column vectors.  Lastly, if FLAG is 'overall' then SYMERR compares all
%   elements together and outputs the results as scalars.
%
%   [NUMBER,RATIO,INDIVIDUAL] = SYMERR(...) outputs a matrix representing the
%   results of each individual symbol comparison in INDIVIDUAL.  INDIVIDUAL is
%   a matrix containing zeros for all locations where the elements of the two
%   matrices are equal, and ones where the two elements differ.  INDIVIDUAL is
%   always a matrix, regardless of which mode the comparison is performed in.
%
%   Examples:
%   » A = [1 2 3; 1 2 2];
%   » B = [1 2 0; 3 2 2];
%
%   » [Num,Rat] = symerr(A,B)
%   Num =
%        2
%   Rat =
%       0.3333
%
%   » [Num,Rat,Ind] = symerr(A,B,'column-wise')
%   Num =
%        1      0      1
%   Rat =
%       0.5000  0     0.5000
%   Ind =
%        0      0      1
%        1      0      0
%
%   See also BITERR.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $  $Date: 2004/04/12 23:01:26 $

% Typical error checking.
error(nargchk(2,3,nargin));

% --- Placeholder for the signature string.
sigStr = '';
flag = '';

% --- Identify string and numeric arguments
for n=1:nargin
   if(n>1)
      sigStr(size(sigStr,2)+1) = '/';
   end;
   % --- Assign the string and numeric flags
   if(ischar(varargin{n}))
      sigStr(size(sigStr,2)+1) = 's';
   elseif(isnumeric(varargin{n}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error('Only string and numeric arguments are accepted.');
   end;
end;

% --- Identify parameter signitures and assign values to variables
switch sigStr
   % --- symerr(a, b)
   case 'n/n'
      a		= varargin{1};
      b		= varargin{2};

   % --- symerr(a, b, flag)
   case 'n/n/s'
      a		= varargin{1};
      b		= varargin{2};
      flag	= varargin{3};

   % --- If the parameter list does not match one of these signatures.
   otherwise
      error('Syntax error.');
end;

if (isempty(a)) | (isempty(b))
   error('Required parameter empty.');
end

if ~(min(min(isfinite(a))) & min(min(isfinite(b))))
   warning('comm:symerr:InfOrNaN', ...
           'Inputs contain an "Inf" or "NaN", results may not be reliable.');
end

% Determine the sizes of the input matrices.
[am, an] = size(a);
[bm, bn] = size(b);

% If one of the inputs is a vector, it can be either the first or second input.
% This conditional swap ensures that the first input is the matrix and the second is the vector.
if ((am == 1) & (bm > 1)) | ((an == 1) & (bn > 1))
   temp = a;
   a = b;
   b = temp;
   [am, an] = size(a);
	[bm, bn] = size(b);
end

% Check the sizes of the inputs to determine the default mode of operation.
if ((bm == 1) & (am > 1))
   default_mode = 'row-wise';
   if (an ~= bn)
      error('Input row vector must contain as many elements as there are columns in the input matrix.');
   end
elseif ((bn == 1) & (an > 1))
   default_mode = 'column-wise';
   if (am ~= bm)
      error('Input column vector must contain as many elements as there are rows in the input matrix.');
   end
else
   default_mode = 'overall';
   if (am ~= bm) | (an ~= bn)
      error('Input matrices must be the same size.');
   end
end

if isempty(flag)
   flag = default_mode;
elseif ~(strcmp(flag,'column-wise') | strcmp(flag,'row-wise') | strcmp(flag,'overall'))
   error('Invalid string flag.');
elseif strcmp(default_mode,'row-wise') & strcmp(flag,'column-wise')
   error('A column-wise comparison is not possible with a row vector input.');
elseif strcmp(default_mode,'column-wise') & strcmp(flag,'row-wise')
   error('A row-wise comparison is not possible with a column vector input.');
end

% The actual comparison.  Two flags are needed for the mode.
% The 'default_mode' determines how the comparison is actually made.
% The 'flag' determines how the comparison is output.
if strcmp(default_mode,'overall')
   if strcmp(flag,'column-wise')
      num = sum((a~=b),1);
      rat = num / am;
   elseif strcmp(flag,'row-wise')
      num = sum((a~=b),2);
      rat = num / an;
   else
      num = sum(sum(a~=b));
	   rat = num / (am*an);
   end
   if (nargout > 2)
      loc = a ~= b;
   end
elseif strcmp(default_mode,'column-wise')
   if (nargout < 3)
	   for i = 1:an,
   	   num(1,i) = sum(a(:,i)~=b);
   	end
   else
      loc = zeros(am,an);
      for i = 1:an,
         loc(:,i) = a(:,i) ~= b;
         num(1,i) = sum(loc(:,i));
      end
   end
   if strcmp(flag,'overall')
      num = sum(num);
      rat = num / (am*an);
   else
      rat = num / am;
   end
else
   if (nargout < 3)
	   for i = 1:am,
   	   num(i,1) = sum(a(i,:)~=b);
   	end
   else
      loc = zeros(am,an);
      for i = 1:am,
         loc(i,:) = a(i,:) ~= b;
         num(i,1) = sum(loc(i,:));
   	end
   end
   if strcmp(flag,'overall')
      num = sum(num);
      rat = num / (am*an);
   else
      rat = num / an;
   end
end

% [EOF] symerr.m
