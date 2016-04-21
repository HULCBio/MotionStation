function varargout = dnglib(v)
%DNGLIB Open Dials & Gauges Blockset library.
%  DNGLIB opens the latest version of the Dials & Gauges Blockset.
%
%  DNGLIB(V) opens major version number V of the Dials & Gauges
%  Blockset, where V may currently be 1.
%  DNGLIB V will also open version V.
%

% Author(s): K. Kohrt, D. Orofino (dsplib.m)
% Copyright 1998-2004 The MathWorks, Inc.
% $Revision: 1.6.4.1 $  $Date: 2003/12/15 15:53:21 $

error(nargchk(0,1,nargin));

% Default is current version of the Blockset:
if nargin == 0,
   vs = '1';
else
   % Argument could be a number or a string, due to command/fcn duality:
   if ischar(v),
      vs = v;
   else
      % Ignore any minor version numbers (fractions) specified
      vs = num2str(floor(abs(v)));
   end   
end

% Attempt to open library:
model = ['dnglibv' vs];
if( nargout == 1 & v == -1 )
    % Make cell array of known D&G libraries that may be opened
    varargout{1} = { 'dnglibv1', 'dng_gmslib' };
else
    % Open the requested model
	try
       open_system(model);
	catch
       error(['Could not find D&G Blockset version ' vs ' (' model '.mdl).']);
	end
end
% end of dnglib.m
