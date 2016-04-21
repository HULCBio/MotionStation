function h = iirxform(h,Wc,Wd,xform)
%IIRXFORM  IIR lowpass to lowpass/highpass/bandpass/bandstop transformation.
%   F = IIRXFORM(H,Wc,Wd,XFORM) performs a lowpass to something
%   transformation depending on the function handle given
%   in XFORM.

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:28:06 $ 

error(nargchk(4,4,nargin));


% Cache the current structure
s = filterstructure(h);

% Convert to df2t
h = convert(h,'df2t');

% Get reference coefficients
c = get(h,'ReferenceCoefficients');

% Transform the filter section by section
if ~iscell(c{1}), c = {c}; end

for n = 1:length(c),
	[b,a] = deal(c{n}{:});
	[bnew,anew] = feval(xform,b,a,Wc,Wd);
	c{n} = {bnew,anew};
end

% Set new coefficients
set(h,'ReferenceCoefficients',c);

if length(anew) == 1 & anew == 1,
    
    % Convert back to original structure
    h = convert(h,s);
end
