function varargout = newtext(varargin)
% NEWTEXT  Add editable text
%    NEWTEXT(X,Y,STRING)  adds text to the current axes
%       at point X,Y.  When used from the command line,
%       the text string can be edited by double clicking
%       on the text.  Font and color properties can also
%       be edited by right clicking.
%
%    Use the PLOTEDIT toolbar to add draggable text. 
%
%    See also PLOTEDIT.

%   jae H. Roh
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/15 04:05:31 $

switch nargin
case 0
   x = mean(get(gca,'XLim'));
   y = mean(get(gca,'YLim'));
   HG = text(x,y,'text',...
	   'EraseMode','normal',...
           'Editing','on');
   th = scribehandle(axistext(HG));
case 1
   x = mean(get(gca,'XLim'));
   y = mean(get(gca,'YLim'));
   HG = text(x,y,varargin{:},...
	   'EraseMode','normal',...
           'Editing','on');
   th = scribehandle(axistext(HG));   
otherwise
   HG = text(varargin{:},...
	   'EraseMode','normal',...
           'Editing','on');
   th = scribehandle(axistext(HG));
   set(th,'Prefix',{'set','EraseMode','xor'});
end

% set for Text Properties dialog
set(get(get(HG,'Parent'),'Parent'),'CurrentObject',HG);

waitfor(HG,'Editing','off');

if ishandle(HG) & isempty(deblank(get(HG,'String')))
   delete(HG);
   HG = [];
end

if nargout==1
   if ishandle(HG) 
      varargout{1} = th;
   else
      varargout{1} = [];
   end
end
