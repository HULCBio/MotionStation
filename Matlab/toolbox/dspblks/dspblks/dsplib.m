function dsplib(v)
%DSPLIB Open Signal Processing Blockset library.
%  DSPLIB opens the latest version of Signal Processing Blockset.
%
%  DSPLIB(V) opens major version number V of the Signal Processing Blockset, 
%  where V may currently be 2 or 3.
%  DSPLIB V will also open version V.
%
%  Other information available for the Signal Processing Blockset:
%    help dspblks   - to view the Contents file
%    info dspblks   - to view the Readme file
%
%    help dspdemos - Summary of Signal Processing Blockset demonstrations and examples
%    help dspmex   - Summary of Signal Processing Blockset S-functions

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.9.4.2 $  $Date: 2004/04/12 23:05:18 $

error(nargchk(0,1,nargin));

% Default is current version of Signal Processing Blockset:
if nargin == 0,
   vs = '4';
else
   % Argument could be a number or a string, due to command/fcn duality:
   if ischar(v),
      vs = v;
   else
      % Ignore any minor version numbers (fractions) specified
      vs = num2str(floor(v));
   end   
end

% Attempt to open library:
model = ['dsplibv' vs];
try
   open_system(model);
catch
   error(['Could not find Signal Processing Blockset version ' vs ' (' model '.mdl).']);
end

% end of dsplib.m
