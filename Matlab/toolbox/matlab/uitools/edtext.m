function outstr = edtext(action)
%EDTEXT  Interactive editing of axes text objects.
%  EDTEXT edits the string property of the GCO by moving an editable
%  text uicontrol on top of the GCO, making it visible, and setting it's
%  string property to that of the GCO.  When the uicontrol's callback is
%  triggered, the GCO's string property is set to whatever the user has
%  entered.
%
%  To use this function to edit the string of an axes text object,
%  set the buttondownfcn of the axes text object to 'edtext'.
%  If you want to execute a callback after editing the string, put the
%  callback string in the 'UserData' of the axes text object.
%
%  EDTEXT uses the invisible edit uicontrol with tag 'edtext' in gcf.  
%  If such an object can't be found, one is created.
%
%  EDTEXT('hide') hides the editable text object.
%
%  EXAMPLE:
%  The following two commands install point-and-click editing of
%  all the text objects (title, xlabel, ylabel) of the current figure:
%     set(findall(gcf,'type','text'),'buttondownfcn','edtext')
%     set(gcf,'windowbuttondownfcn','edtext(''hide'')')
%   
%  See also GCO, GCBO.

%  Author: T. Krauss, 10/94
%  Copyright 1984-2003 The MathWorks, Inc.
%  $Revision: 1.18.4.2 $  $Date: 2004/04/10 23:33:34 $

if nargin < 1
    if isempty(allchild(0))
        error('No text objects to edit')
    end
   if isempty(gco)
      h=gcbo;
   else
      h=gco;
   end
      
   str = get(h,'string');      
   
   t = findobj(gcf,'tag','edtext');
   if isempty(t)
      t = uicontrol('style','edit','backgroundcolor',[1 1 1],'tag','edtext'); 
   end
   
   ax = ancestor(h,'axes');   % axes
   
   h_units = get(h,'units');
   ax_units = get(ax,'units');
   
   set(h,'units','pixels');
   set(ax,'units','pixels');
   
   ax_pos = get(ax,'position');
   pos = get(h,'extent')+ax_pos.*[1 1 0 0];
   
   if get(h,'rotation')~=0
      % create temporary text object with zero rotation and get it's
      % extent
      temp_text = text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,...
         get(h,'string'),...
         'erasemode','xor',...
         'fontname',get(h,'fontname'),...
         'fontsize',get(h,'fontsize'), ...
         'horizontalalignment','center',...
         'units','pixels');
      pos = get(temp_text,'extent');
      delete(temp_text)
      set(h,'visible','off')  % hide rotated text in case it peeks
      % out from under the uicontrol!
      % Unfortunately this causes an axes redraw
   end
   
   % make the edit box alfa times as wide as the extent of the text object:
   alfa = 2;
   if length(str)==1, alfa = 6; end   % handle 'skinny' fields
   if length(str)==2, alfa = 3; end
   pos(1) = pos(1) - pos(3)*(alfa-1)/2;
   pos(3) = pos(3)*alfa;
   % make the edit box alfa1 times as tall as the extent of the text object:
   alfa1 = 1;
   pos(2) = pos(2) - pos(4)*(alfa1-1)/2;
   pos(4) = pos(4)*alfa1;
   
   set(t,'visible','on','string',str,...
      'callback',['THEETEXTSTR = edtext(''done''); ' ...
         'if ~isempty(THEETEXTSTR),' ...
         '    eval(THEETEXTSTR),' ...
         'end, clear THEETEXTSTR'], ...
      'units','pixels',...
      'position',pos,...
      'userdata',h)
   
   set(h,'units',h_units);
   set(ax,'units',ax_units);
   
elseif strcmp(action,'done')
   t = findobj(gcf,'tag','edtext');
   h = get(t,'userdata');
   str = get(t,'string');
   if ~isempty(deblank(str))
      set(h,'string',str)
   end
   set(h,'visible','on')
   set(t,'visible','off')
   ud = get(h,'userdata');   % contains callback
   if isstr(ud)    % prepare output string for eval
      outstr = ud;
   else 
      outstr = [];
   end
   
elseif strcmp(action,'hide')
   t = findobj(gcf,'tag','edtext');
   if ~isempty(t)
      set(t,'visible','off')
      set(get(t,'userdata'),'visible','on')
   end   
end

