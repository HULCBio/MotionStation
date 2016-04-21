function hfig = movieview(movieData,name)
%MOVIEVIEW Show MATLAB movie with replay button
% MOVIEVIEW(MOVIEFILE) Shows movie with replay button, filename is title.
% MOVIEVIEW(M) Shows movie with replay button.
% MOVIEVIEW(M,NAME) Same as above using NAME in title.
%
% See also UILOAD, OPEN, SOUNDVIEW, IMAGEVIEW

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:31:57 $

error(nargchk(1,2,nargin))

figname = 'Movie Viewer';

if ischar(movieData)
    s = importdata(movieData);
    if ~isstruct(s)
        errordlg(['Unable to preview movie in file ' movieData]);
    end
    figname = [figname ' - ' movieData];
    movieData = s;
end

if nargin == 2
    figname = [figname ' - ' name];
end

h = figure('menubar','none', ...
           'toolbar','none', ...
           'name',figname, ...
           'numbertitle','off', ...
           'visible','off', ...
           'color',get(0,'defaultuicontrolbackgroundcolor'), ...
           'userdata',movieData);
if nargout
    hfig = h;
end
set(h,'units','pixels');
ss = get(0,'screensize');
fs = get(h,'position');
b1 = uicontrol('style','pushbutton',...
              'string','Play again',...
               'HandleVisibility','callback', ...
              'units','pixels',...
              'position',[5 5 100 30],...
              'callback','movie(gcbf,get(gcbf,''userdata''),1,[],get(gcbo,''userdata''))');

b2 = uicontrol('style','pushbutton',...
              'string','Done',...
               'HandleVisibility','callback', ...
              'units','pixels',...
              'position',[110 5 100 30],...
              'callback','try, close(gcbf), end');
a = gca;
set(a,'visible','off')
set(h,'visible','on')
pos = size(movieData(1).cdata);

btop = 30 + 5;

% resize figure to fit buttons and movie
width = max(pos(2) + 10, 215);
height = btop + 5 + pos(1) + 5;
set(h,'position',[fs(1) fs(2) width height])
fs = get(h,'position');

% recenter figure on screen
set(h,'position',[(ss(3) - fs(3))/2 (ss(4) - fs(4))/2 fs(3) fs(4)])

% recenter buttons on figure
if width ~= 215
    leftGap = 5 + (width - 215) / 2;
    p1 = get(b1,'position');
    set(b1,'position',[leftGap p1(2:end)]);
    p2 = get(b2,'position');
    set(b2,'position',[leftGap + 110 p2(2:end)]);
end

% place movie
left = (fs(3) - pos(2)) / 2;
bottom = (fs(4) - btop - 5 - pos(1)) / 2 + btop + 5;
set(b1,'userdata',[left bottom 1 1]);

if nargout == 0
    set(h,'HandleVisibility','callback');
end

try
    movie(h,movieData,1,[],[left bottom 1 1])
catch
    % throw error unless window was closed 
    if ishandle(h)
        delete(h)
        error(lasterr)
    end
end
