function h = firxform(h,xform,varargin)
%FIRXFORM  FIR Type I lowpass to lowpass/highpass transformation.
%   F = FIRXFORM(H,XFORM) performs a lowpass to lowpass or lowpass
%   to highpass transformation depending on the function handle given
%   in XFORM.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:28:39 $ 

error(nargchk(2,3,nargin));

if numberofsections(h) > 1,
    error('Can''t transform an FIR filter with multiple sections.');
end

% Check for valid filter
if ~isfir(h),
    ft = firtype(filt);
    if iscell(ft), ft = [ft{:}]; end
    if all(ft == 1),
        error('Filter to be transformed must be a type I FIR filter.');
    end
end

% Gather the filter structure info
s = filterstructure(h);

% Convert to df2t
h = convert(h,'df2t');

% Get reference coefficients
c = get(h,'ReferenceCoefficients');

% Transform the filter section by section
if iscell(c{1}),
    [b,a] = deal(c{1}{:});
else
    [b,a] = deal(c{:});
    
end
bnew = feval(xform,b./a,varargin{:});
c = {bnew,1};

% Set new coefficients
set(h,'ReferenceCoefficients',c);

% Convert back to original structure
h = convert(h,s);

