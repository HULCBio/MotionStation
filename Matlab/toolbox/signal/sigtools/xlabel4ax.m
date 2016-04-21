function hxlabel = xlabel4ax(ax,str,varargin)
%XLABEL4AX Set the XLABEL on a specified axis. 
%   XLABEL4AX(AX,STR) sets the xlabel on axis AX to STR and returns a 
%   handle to it.  The difference between XLABEL4AX and XLABEL is that XLABEL 
%   calls GCA.
%
%   XLABEL4AX(AX,STR,PN,PV,...) passes through optional parameter-value pairs
%   to setting the axis.

%   Author(s): T. Bryan 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:50:08 $ 

hxlabel = get(ax,'XLabel');
set(hxlabel,'String',str,varargin{:});

% [EOF]
