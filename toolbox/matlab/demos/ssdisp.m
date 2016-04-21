function ssdisp(figNumber,string)
%SSDISP Display text from the Slide Show format.
%
%   SSDISP(figNumber,string) will display the supplied string
%   in the Comment Window of a Slide Show figure. If the Slide
%   Show GUI shell is not being used, SSDISP will display directly
%   to the command window.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 03:34:53 $

if figNumber==0,
    clc
    disp(' ');
    disp(string);
    disp(' ');
else
    hndlList=get(figNumber,'UserData');
    txtHndl=hndlList(1);
    set(txtHndl,'String',string);
end
