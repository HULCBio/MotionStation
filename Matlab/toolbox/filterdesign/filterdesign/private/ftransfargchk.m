function errmsg = ftransfargchk(var,varname,varargin)
%FTRANSFARGCHK Input argument check.
%   ERRMSG = FTRANSFARGCHK(VAR,VARNAME,ATTRIBUTE1,ATTRIBUTE2,...) returns an error
%   message string if variable VAR does not match attributes in strings
%   ATTRIBUTE1, ....  The name for the variable used in the error message is
%   contained in string VARNAME.  If VARNAME is empty, then the name of the
%   variable VAR is used.
%
%   FTRANSFARGCHK(...) with no output arguments calls ERROR.

%   Author(s): Tom Bryan (The MathWorks), Dr. Artur Krukowski (University of Westminster).
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 15:39:33 $

% --------------------------------------------------------------------

if isempty(varname)
  varname = inputname(var);
end

errmsg = '';
for k=1:length(varargin)

   switch(varargin{k})

      case 'overlap'
         [wt,idx] = sort(var(2,:));
         wo       =      var(1,idx);
         Flag     = 1;
         for k=1:2:length(wt)-1,
            if wo(k) > wo(k+1),
               Flag = 0;
               break;
            end;
         end;
         if ~Flag,
            errmsg = [varname, ' should not specify overlapped bands.'];
         end;

      case 'real'
         if ~isreal(var),
            errmsg = [varname,' must be real.'];
         end

      case 'positive'
         if var < 0,
            errmsg = [varname,' must be positive.'];
         end

      case 'negative'
         if var > 0,
            errmsg = [varname,' must be negative.'];
         end

      case 'int'
         if mod(var,1) > eps,
            errmsg = [varname,' must be an integer.'];
         end

      case 'scalar'
         if ~isscalar(var),
            errmsg = [varname,' must be a scalar.'];
         end

      case 'string'
         if ~ischar(var),
            errmsg = [varname,' must be a string.'];
         end

      case 'pass/stop'
         if ~strcmp(lower(var),'pass') & ~strcmp(lower(var),'stop'),
            errmsg = [varname,' can only be ''pass'' or ''stop''.'];
         end

      case 'vector'
         if ~isvector(var),
            errmsg = [varname,' must be a vector.'];
         end

      case 'vector2'
         if ~isvector(var) | length(var)~=2,
            errmsg = [varname,' must be a two element vector.'];
         end

      case 'numeric'
         if ~isnumeric(var),
            errmsg = [varname,' must be a numeric.'];
         end

      case 'normalized'
         if (min(var(:)) <= 0)  | (max(var(:)) >= 1),
            errmsg = [varname,' must be between 0 and 1.'];
         end

      case 'normalized + edge'
         if (min(var(:)) < 0)  | (max(var(:)) > 1),
            errmsg = [varname,' must be between 0 and 1 inclusive.'];
         end

      case 'full normalized'
         if (min(var(:)) <= -1) | (max(var(:)) >= 1),
            errmsg = [varname,' must be between -1 and 1.'];
         end

      case 'full normalized + edge'
         if (min(var(:)) < -1) | (max(var(:)) > 1),
            errmsg = [varname,' must be between -1 and 1 inclusive.'];
         end

      case 'even'
         if mod(length(var),2) > eps,
            errmsg = [varname,' must have even number of elements.'];
         end

      case 'odd'
         if mod(length(var),2) - 1 > eps,
            errmsg = [varname,' must have odd number of elements.'];
         end

      otherwise
         error('Unrecognized attribute');

   end;

   if ~isempty(errmsg), break, end;

end;

if nargout==0,
   error(errmsg)
end


% --------------------------------------------------------------------

function t = isvector(v)
%ISVECTOR  True for a vector.
%   ISVECTOR(V) returns 1 if V is a vector and 0 otherwise.

t = (ndims(v) == 2) & (min(size(v)) <= 1);

% --------------------------------------------------------------------

function t = isscalar(v)
%ISSCALAR  True for a scalar or empty.
%   ISSCALAR(V) returns 1 if V is a scalar and 0 otherwise.

t = (ndims(v) == 2) & (max(size(v)) <= 1);
