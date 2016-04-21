function dataValue = wtbxappdata(option,fig,dataName,dataValue)
%WTBXAPPDATA Cache for GUIDATA, SETAPPDATA, GETAPPDATA.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-Jan-2003.
%   Last Revision: 03-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:43:33 $

figDATA = guidata(fig);
switch option
    case 'new'
		if ~isfield(figDATA,dataName)
            figDATA.(dataName) = dataValue;
            guidata(fig,figDATA);
		end
        
    case 'set' , 
        figDATA.(dataName) = dataValue;
        guidata(fig,figDATA);
        
    case 'get'
		if isfield(figDATA,dataName)
            dataValue = figDATA.(dataName);
        else
            dataValue = '';
		end

    case 'del'
		if isfield(figDATA,dataName)
            dataValue = figDATA.(dataName);
            figDATA = rmfield(figDATA,dataName);
            guidata(fig,figDATA);
        else
            dataValue = '';
		end
end
