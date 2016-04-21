function varargout = size(obj,dim)
%SIZE Size of data acquisition object.  
%
%    D = SIZE(OBJ), for M-by-N data acquisition object, OBJ, returns the
%    two-element row vector D = [M, N] containing the number of rows and
%    columns in the data acquisition object, OBJ.  
%
%    [M,N] = SIZE(OBJ) returns the number of rows and columns in separate
%    output variables.  
%
%    [M1,M2,M3,...,MN] = SIZE(OBJ) returns the length of the first N dimensions
%    of OBJ.
%
%    M = SIZE(OBJ,DIM) returns the length of the dimension specified by the 
%    scalar DIM.  For example, SIZE(OBJ,1) returns the number of rows.
% 
%    See also DAQHELP, DAQCHILD/LENGTH.
%

%    MP 4-14-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.4 $  $Date: 2003/08/29 04:41:27 $

if nargin==1,
   dim=':';
elseif nargin==2,
   if ~isnumeric(dim) || dim~=floor(dim) || dim<=0,
      error('daq:size:argcheck', 'DIM must be a positive integer.')
   end
end

% The handle property of the object indicates the number of 
% objects that are concatenated together.
h = struct(obj);
if isfield(h,'handle')
   out = builtin('size', h.handle);
else
   % This is needed otherwise struct(obj) will fail.
   out=[1 1];
end

% Assign the size to the appropriate output variables.
switch nargout
case {0,1}
   if nargin==2 && dim>2,
      varargout{1} = 1;
   else
      varargout{1} = out(dim);
   end
case 2
   if nargin==2,
      error('daq:size:command', 'Unknown command option.')
   else
      varargout{1} = out(1);
      varargout{2} = out(2);
   end
otherwise
   if nargin == 2
      error('daq:size:command', 'Unknown command option.');
   else
      varargout{1} = out(1);
      varargout{2} = out(2);
      if nargout == 3
         varargout{3:nargout} = deal(1);
      else
         varargout(3:nargout) = deal({1});
      end
   end
end
