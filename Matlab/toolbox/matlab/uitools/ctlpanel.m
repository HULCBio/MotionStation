function varargout=ctlpanel(varargin)
%CTLPANEL Obsolete GUIDE function.
%   CTLPANEL function is obsolete. Use the
%	GUIDE command to edit FIG-files.  
%   
%   See also GUIDE, INSPECT.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.91 $ $Date: 2002/04/15 03:25:09 $

  warning('CTLPANEL function is obsolete. Use the GUIDE command instead.');
  
  switch nargin,

    case 0
      guide;
    
    case 1
      guide(varargin{1});
  
    otherwise
      error('Wrong number of input arguments for CTLPANEL.');
  
  end
