function figh=statdisptable(tbl,maintitle,header,footer,digits,infigh,pfigh,varargin)
%STATDISPTABLE Display a table for the Statistics Toolbox
%
%    Utility function used by other functions to display tables

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.2 $  $Date: 2004/01/24 09:36:56 $

if ((nargin == 0) & ~isempty(gcbo)), resizetable(gcbo); return; end
if ((nargin == 1) & isequal(tbl,'copy')), copytext(gcbf); return; end

if (nargin < 4), footer = ''; end

% Get text form of table, with separator line
if (nargin < 5)
   disptxt = displayform(tbl);
else
   disptxt = displayform(tbl,digits);
end
disptxt = [disptxt(1,:); repmat('-',1,size(disptxt,2)); disptxt(2:end,:)];

% Create new figure unless one was passed in
if (nargin<6 | isempty(infigh))
   figure(varargin{:});
   infigh = gcf;
end

% Put stuff into figure, don't do careful layout yet
h = findobj(infigh, 'Tag', 'Table');
if (isempty(h))
   uicontrol(infigh, 'style', 'list', 'string', disptxt, ...
          'min',1,'max',size(disptxt,1),'value',[],...
          'FontName', 'FixedWidth', 'BackGroundColor', 'w', ...
          'HorizontAlalignment','left', 'Tag', 'Table');
else
   set(h, 'string', disptxt, 'min',1,'max',size(disptxt,1),'value', ...
          []);
end

h = findobj(infigh, 'Tag', 'Heading');
if (isempty(h))
   uicontrol(infigh, 'style', 'text', 'string', header, ...
          'fontweight','bold', 'fontsize',12, 'Tag','Heading');
else
   set(h, 'string', header);
end

if (~isempty(footer))
   h = findobj(infigh, 'Tag', 'Caption');
   if (isempty(h))
      uicontrol(infigh, 'style', 'text', 'string', footer, 'Tag','Caption', ...
          'HorizontalAlignment','center', 'BackGroundColor', 'w', ...
          'ForeGroundColor', 'b');
   else
      set(h, 'string', footer);
   end
end

% Adjust layout
set(infigh,'ResizeFcn','statdisptable', 'Name',maintitle, ...
           'PaperPositionMode','auto');
resizetable(infigh);

% Save info in figure so we can copy table to clipboard
if (nargin<7), pfigh = []; end
ud.ParentHandle = pfigh;
ud.TableData = tbl;
ud.Header = header;
ud.Footer = footer;
set(infigh, 'UserData',ud);

% Add "copy text" option to Edit menu unless already done
h = findall(infigh, 'Label','&Edit');
if (~isempty(h))
   hh = findobj(h,'Label','Copy Te&xt');
   if (isempty(hh))
      uimenu(h, 'Label','Copy Te&xt', 'Callback','statdisptable(''copy'')');
   end
end

if (nargout>0), figh = infigh; end

% --------------------------
function m = displayform(tbl,digits)
%DISPLAYFORM Creates a text representation of a table for display

[nr,nc] = size(tbl);

if (nargin<2), digits = repmat(-1,nc,1); end

blanks = repmat(' ', nr, 3);
m = [strvcat(tbl{:,1}) blanks];
for c=2:nc
   if (c == nc), blanks = ''; end
   m = [m displaycol(tbl(2:end,c),tbl{1,c},digits(c)) blanks];
end

% --------------------------
function txt = displaycol(t,h,d)
%DISPLAYCOL Creates a text representation of a column for display
%   t = table column, h = header, d = number of digits after decimal

nrows = size(t,1);
nbefore = 0;        % digits to the left of the decimal
nafter = 0;         % digits to the right of the decimal
maxlen = 0;         % length
doit = false(nrows,1);
fmt = '%g';

% Convert each entry to text and collect info on it
usefmt = 0;
for r=1:nrows
   val = t{r};
   v = sprintf(fmt, val);
   len = length(v);
   if (isempty(val))
      t{r} = ' ';
   elseif ((all(v==' ') | isnan(val)))
      t{r} = v;
      maxlen = max(maxlen, len);
   elseif (any(v=='e'))
      doit(r) = 1;
   else
      usefmt = 1;
      doit(r) = 1;
      j = find(v=='.');
      if (isempty(j))
         nbefore = max(nbefore, length(v));
      else
         nbefore = max(nbefore, j(1));
         nafter  = max(nafter,  len-j(1));
      end
   end
end

% Figure out what f format we really want
if (any(doit))
   if (usefmt)
      if (d < 0), d = max(0, 7-nbefore); end
      w = max(maxlen, nbefore + d);
      fmt = sprintf('%%%d.%df', w, d);
   end

   for r=1:nrows
      if (doit(r))
         v = sprintf(fmt, t{r});          % impose this format
         if (any(v=='.') & ~any(v=='e'))  % blank out trailing 0's
            n = length(v);
            x = n+1-find(v~='0',1,'last');
            if (v(n-x+1)~='.'), x = x-1; end
            if (x>0), v(n-x+1:n) = '%'; end
         end
         t{r} = v;
      end
   end
end

% Justify, remove blanks, but don't remove everything
txt = strjust(strvcat(t));
nlines = size(txt,1);
txt(txt=='%') = ' ';
txt = deblank(txt);
if (nlines > size(txt,1)), txt = repmat(' ', nlines, 1); end

% Center heading over column if requested
if (nargin>1)
   n1 = length(h);
   n2 = size(txt,2);
   n = size(txt,1);
   dif = n1-n2;
   if (dif>0)
      txt = [h; repmat(' ',n,floor(dif/2)) txt repmat(' ',n,ceil(dif/2))];
   else
      txt = [repmat(' ',1,floor(-dif/2)) h repmat(' ',1,ceil(-dif/2)); txt];
   end
end

%-----------------------
function resizetable(fig)
% RESIZEANOVA Resize callback for statdisptable
old_units = get(fig,'Units');
set(fig,'Units','pixels');
figpos = get(fig,'Position');
set(fig,'Units',old_units);

u = findobj(fig,'Tag','Heading');
if (isempty(u)), set(fig, 'ResizeFcn', ''); return; end
hExt = get(u,'Extent');
headheight = hExt(end);
upos = [0 max(0,figpos(4)-headheight) figpos(3) headheight];
old_units = get(u,'Units');
set(u,'Units','pixels');
set(u,'Position',upos);
set(u,'Units',old_units);

u = findobj(fig,'Tag','Caption');
if (isempty(u))
   capheight = 0;
else
   cExt = get(u,'Extent');
   capheight = cExt(end);
   upos = [0 0 figpos(3) capheight];
   old_units = get(u,'Units');
   set(u,'Units','pixels');
   set(u,'Position',upos);
   set(u,'Units',old_units);
end

u = findobj(fig,'Tag','Table');
if (isempty(u)), set(fig, 'ResizeFcn', ''); return; end
upos = [0 capheight figpos(3) max(1,figpos(4)-headheight-capheight)];
old_units = get(u,'Units');
set(u,'Units','pixels');
set(u,'Position',upos);
set(u,'Units',old_units);

%-----------------------
function copytext(fig)
% COPTEXT Copy table to clipboard as tab-delimitted text
ud = get(fig, 'UserData');
if (~isstruct(ud)), return; end

% Get table information from user data
if (isfield(ud, 'TableData'))
   t = ud.TableData;
else
   t = cell(0,0);
end
if (isfield(ud, 'Header'))
   h = ud.Header;
else
   h = '';
end
if (isfield(ud, 'Footer'))
   f = ud.Footer;
else
   f = '';
end

% Create string with header, then table contents, then footer
txt = '';
if (~isempty(h)), txt = sprintf('%s\n',h); end
for j=1:size(t,1);
   l = '';
   for k = 1:size(t,2)
      x = t{j,k};
      if (isnumeric(x))
         x = num2str(x);
      elseif (~ischar(x))
         x = ' ';
      end
      l = sprintf('%s\t%s', l, x);
   end
   txt = sprintf('%s%s\n', txt, l(2:end));
end
if (~isempty(f)), txt = sprintf('%s%s\n', txt, f); end

% Put on clipboard
clipboard('copy', txt);
