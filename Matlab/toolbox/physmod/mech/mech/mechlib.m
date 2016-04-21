function varargout=mechlib(v)
%MECHLIB SimMechanics library.
%  MECHLIB opens the latest version of SimMechanics.
%
%  MECHLIB(V) opens major version number V of SimMechanics
%  MECHLIB V will also open version V.
%
%  LIB = MECHLIB returns the name of the latest version of 
%  SimMechanics, but does NOT open it.
%

% Copyright 1998-2003 The MathWorks, Inc.
% $Revision: 1.6.2.3 $  $Date: 2004/04/16 22:17:00 $

error(nargchk(0,1,nargin,'struct'));

% Default is current version of SimMechanics
if nargin == 0,
   vs = '1';
else
   % Argument could be a number or a string, due to command/fcn duality:
   if ischar(v),
      vs = v;
   else
      % Ignore any minor version numbers (fractions) specified
      vs = num2str(floor(v));
   end   
end

model = ['mblibv' vs];

if (nargout == 0)
  % Attempt to open library:
  try
    open_system(model);
  catch
    error('physmod:mech:mechlib:CannotFindSimMechanics',...
          'Could not find SimMechanics %s (%s.mdl).',vs,model);
  end
else 
  if (nargout > 0)
    varargout{1} = model;
  end
end


