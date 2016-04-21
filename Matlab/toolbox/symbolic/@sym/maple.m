function [result,status] = maple(varargin)
%MAPLE  Calls Maple with SYM inputs and outputs.
%   MAPLE(FUN,A1,A2,A3,...) takes SYMs, numbers, and strings as inputs. 
%   It converts any SYM objects to their corresponding Maple string 
%   representations and then calls MAPLEMEX to do the calculation.
%   The result is converted to a SYM object.
%
%   [RESULT,STATUS] = MAPLE(...) returns the warning/error status.
%   When the statement execution is successful, RESULT is the result
%   and STATUS is 0. If the execution fails, RESULT is the corresponding 
%   warning/error message, and STATUS is a positive integer.
%
%   MAPLE is not available for general use in the Student Version.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.26.4.2 $  $Date: 2004/04/16 22:22:52 $

% Convert all arguments to Maple text strings and concatenate arguments.

map1 = isstr(varargin{1}) && strcmp(varargin{1},'map');
map2 = isstr(varargin{1}) && strcmp(varargin{1},'map2');

if nargin == 1
   if ~isa(varargin{1},'sym')
      error('symbolic:sym:maple:errmsg1','Please do not use symbolic/@sym as the working directory.')
   end
   statement = char(varargin{1});

elseif (nargin==3) & ischar(varargin{2}) &  ...
   (length(varargin{2})==1 | strcmp(varargin{2},'&*'))

   % Special case, maple(A,'op',B)

   statement = ['(' char(varargin{1}) ')' varargin{2} ...
                '(' char(varargin{3}) ')'];
   if ~isempty(findstr('matrix',statement))
      statement = ['evalm(' statement ')'];
   end

else

   % Four possibilities:
   % maple('function',arg1,arg2,...)
   % maple('map','function',arg1,arg2,...)
   % maple('map2','function',arg1,arg2,...)
   % maple('evalm','function',arg1,arg2,...)

   maps = map1 | map2 | strcmp(varargin{1},'evalm');
   statement = [];
   for k = maps+2:nargin
      switch class(varargin{k})
        case 'sym'
           if (map1 && k==3) || (map2 && k==4)
              s = char(varargin{k},1);
           else 
              s = char(varargin{k});
           end
        case 'double'
           if (map1 && k==3) || (map2 && k==4)
              s = char(sym(varargin{k}),1);
           else
              s = char(sym(varargin{k}));
           end
        case 'char'
           s = varargin{k};
        otherwise
           error('symbolic:sym:maple:errmsg2','Input must be type sym, double, and/or char.')
      end;
      statement = [statement s ','];
   end
   statement(end) = [];
   if maps && (~isempty(findstr('matrix',statement)) || ~isempty(findstr('vector',statement)))
      statement = [varargin{1} '(' varargin{2} ',' statement ')'];
   else
      statement = [varargin{maps+1} '(' statement ')'];
   end
end

if length(statement) >= 9 & ~isempty(findstr('array([])',statement))
   result = sym([]); status = 0;
   return
end

% Access the Maple kernel via the string version of MAPLE function.
[result,status] = maple(statement);
if nargout < 2 & status ~= 0
   error('symbolic:sym:maple:errmsg3',result)
end

% Convert result to a SYM 
if status == 0
   result = sym(result);
   if map1
      result = reshape(result,size(varargin{3}));
   elseif map2
      result = reshape(result,size(varargin{4}));
   end
end
