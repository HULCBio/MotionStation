function htitle = title4ax(ax,str,varargin)
%TITLE4AX Set the TITLE on specified axis.
%   TITLE4AX(AX,STR) sets the TITLE on axis AX to STR and returns a 
%   handle to it.  The difference between TITLE4AX and TITLE is that TITLE 
%   calls GCA.
%
%   TITLE4AX(AX,STR,PN,PV,...) passes through optional parameter-value pairs
%   to setting the axis.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:50:21 $ 

htitle = get(ax,'Title');
set(htitle,'String',str,varargin{:});

% [EOF]
