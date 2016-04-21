function menuedit(varargin)
%MENUEDIT Obsolete GUIDE function.
%   MENUEDIT function is obsolete. Use the
%	GUIDE command to edit FIG-files.  
%   
%   See also GUIDE, INSPECT.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.47 $ $Date: 1996/01/04 16:45:53 

  warning('MENUEDIT function is obsolete. Use the GUIDE command instead.');
  
  switch nargin,

    case 0
      guide;
    
    case 1
      guide(varargin{1});
  
    otherwise
      error('Wrong number of input arguments for MENUEDIT.');
  
  end
