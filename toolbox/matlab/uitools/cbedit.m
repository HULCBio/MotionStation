function cbedit(varargin)
%CBEDIT Obsolete GUIDE function.
%   CBEDIT function is obsolete. Use the
%	GUIDE command to edit FIG-files.  
%   
%   See also GUIDE, INSPECT.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.75 $ $Date: 2002/04/15 03:24:59 $

  warning('CBEDIT function is obsolete. Use the GUIDE command instead.');
  
  switch nargin,

    case 0
      guide;
    
    case 1
      guide(varargin{1});
  
    otherwise
      error('Wrong number of input arguments for CBEDIT.');
  
  end
