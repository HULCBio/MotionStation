function hylabel = ylabel4ax(ax,str,varargin)
%YLABEL4AX Set the YLABEL on specified axis.
%   YLABEL4AX(AX,STR) sets the ylabel on axis AX to STR and returns a 
%   handle to it. The difference between YLABEL4AX and YLABEL is that YLABEL 
%   calls GCA.
%
%   YLABEL4AX(AX,STR,PN,PV,...) passes through optional parameter-value pairs
%   to setting the axis.

%   Author(s): T. Bryan 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:50:05 $ 

hylabel = get(ax,'Ylabel'); 
set(hylabel,'String',str,varargin{:});

% [EOF]
