function varargout = engunits(varargin)
% ENGUNITS Convert scalar input to engineering units.
%   [Y,E,U]=ENGUNITS(X) converts input value X into a new value Y,
%   with associated scale factor E, such that Y = X * E.  The
%   engineering unit prefix is returned as a character in U.  If X
%   is a matrix the largest value will be used to determine the scale.
%
%   [...]=ENGUNITS(X,'latex') returns engineering unit prefix
%   U in Latex format where appropriate, for use with the TEXT
%   command.  In particular, U='u' for micro, whereas U='\mu'
%   if the Latex flag is passed.
%
%   [...]=ENGUNITS(...,'time') will cause conversion from
%   seconds to mins/hrs/days/etc when appropriate, and the new
%   units in U.
% 
%   EXAMPLE:
%   [y,e,u] = engunits(1000);
%
%   See also CONVERT2ENGSTRS.

%   Author(s): D. Orofino
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/11/21 15:36:11 $

error(nargchk(1,3,nargin));

noutputs = nargout;
if ~noutputs, noutputs = 1; end

isTime = strcmp(lower(varargin{end}),'time');
if isTime,
    % Time-domain units conversion:
    varargin(end)=[];
    [varargout{1:noutputs}] = getTimeUnits(varargin{:});
else
    % General engineering units conversion:
    [varargout{1:noutputs}] = getEngPrefix(varargin{:});
end

%--------------------------------------------------------------
function varargout = getTimeUnits(varargin)
% getTimeUnits Return new time-domain units from a seconds-based input

persistent time_units time_scale
if isempty(time_units),
   time_units      = {'secs','mins','hrs','days','years'};
   time_scale      = [1,60,3600,86400,31536000];
end

x = varargin{1};

% Use max to find the largest value to support matrices
i = max(find(max(x(:))>=time_scale));

if isempty(i),
   % No conversion to a higher unit - use general engineering prefix:
   [new_x,eng_exp,units_x] = getEngPrefix(varargin{:});
   if eng_exp == 1,
      units_x = 'secs';
   else
      units_x = [units_x 's'];
   end
else
   new_x   = x./time_scale(i);
   eng_exp = 1./time_scale(i);
   units_x = time_units{i};
end

varargout = {new_x,eng_exp,units_x};

return

% --------------------------------------------------------------
function [new_x, eng_exp, units_x] = getEngPrefix(x,latex,domain)
% getEngPrefix Return prefix for appropriate engineering units

persistent eng_units eng_units_latex units_offset
if isempty(eng_units),
   eng_units       = {'a','f','p','n',  'u','m','','k','M','G','T','P','E'};
   eng_units_latex = {'a','f','p','n','\mu','m','','k','M','G','T','P','E'};
   units_offset    = strmatch('',eng_units,'exact');
end

if nargin<2, latex='';  end  % default: non-latex characters

% Normalize input such that
%    x = norm_x * 10^norm_exp
if x==0,
   norm_exp = 0;
else
   norm_exp = max(max(ceil(log10(abs(x))))); % normalized exponent
end
norm_x   = x .* 10.^(-norm_exp);  % normalized mantissa

% Round to the nearest multiple of 3:
eng_exp    = 3.*floor(norm_exp./3);
scale_mant = x .* 10.^(-eng_exp);

% Select appropriate engineering units:
i = eng_exp./3 + units_offset;

% Update this section for vector inputs, if they
% become a required part of the spec:
%
if (i<1) | (i>length(eng_units)),
   % Out of range - return input unchanged:
   new_x   = x;
   units_x = '';
   eng_exp = 0;
else
   new_x = scale_mant;
   if ~isempty(latex),
      units_x = eng_units_latex{i};
   else
      units_x = eng_units{i};
   end
end

% Convert exponent to proper power of 10 for return:
eng_exp = 10 .^ (-eng_exp);

% [EOF]
