function cmd = tlcsetup(varargin);
%TLCSETUP Utility function for tlc_c and tlc_ada.
%

%    Copyright 1994-2002 The MathWorks, Inc.
%    $Revision: 1.4 $

  cmd = [];
  for i = 2:nargin
    if i > 2
      cmd = [cmd ','];
    end
    cmd = [cmd, '''', varargin{i},''''];
  end
  
%endfunction

