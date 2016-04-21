function A = arrowline(varargin)
%ARROWLINE/ARROWLINE Make an arrowline object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.18.4.1 $  $Date: 2004/01/15 21:11:19 $

switch nargin
case 0
   A.Class = 'arrowline';
   A.arrowhead = [];
   A.line = [];
   A.fullline = [];
   A.hScale = [];
   A.vScale = [];
   A = class(A,'arrowline', editline);
   return
case 1  % reconstructing an arrow object from one of its
        % components.  Appdata has been stripped away.
   HG = varargin{1};  % one of the arrow components
   arrowID = get(HG,'UserData');
   fig = get(get(HG,'Parent'),'Parent');
   components = findall(fig,'UserData',arrowID);
   
   %accomodate arrow objects (r12) and line objects (r11)
   fulllineH = double(find(handle(components),'-class','graph2d.arrow'));
   if isempty(fulllineH)
       fulllineH = findobj(components,'Tag','ScribeArrowlineObject');
   end
   lineH     = findobj(components,'Tag','ScribeArrowlineBody');
   headH     = findobj(components,'Tag','ScribeArrowlineHead');
   
   if isempty(fulllineH)
       fulllineH = setdiff(components,[lineH,headH]);
       set(fulllineH,'Tag','ScribeArrowlineObject');
   end

   [fulllineH, lineH, headH, hscale, vscale] ...
           = makearrow(fulllineH,lineH,headH);

otherwise
   [fulllineH, lineH, headH, hscale, vscale] = makearrow(varargin{:});

   % store redundant information so that we can rebuild it
   % use the full line handle as an identifier
   arrowID = sprintf('%d',double(fulllineH));
   set([fulllineH, lineH, headH], {'Tag' 'UserData'},...
           {''                       arrowID;...
            'ScribeArrowlineBody'    arrowID;...
            'ScribeArrowlineHead'    arrowID});
    
    %r12 arrow objects don't need an explicit tag
    if ~isa(handle(fulllineH),'graph2d.arrow')
        set(fulllineH,'tag','ScribeArrowlineObject');
    end
    
end

A.Class = 'arrowline';
A.arrowhead = headH;
A.line = lineH;
A.fullline = fulllineH;


% this isn't enough: it doesn't change with resize...
A.hScale = hscale;
A.vScale = vscale;

X = get(lineH,'XData');
Y = get(lineH,'YData');

set([fulllineH lineH headH],'EraseMode','normal');

editlineObj = editline(fulllineH);

u = getscribecontextmenu(fulllineH); 
setscribecontextmenu(lineH, u); 
setscribecontextmenu(headH, u); 

A = class(A,'arrowline', editlineObj);
scribehandle(A);

