function varargout = panner(varargin)
%PANNER Panner management function.
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.11 $

if nargin < 1
    action = 'init';
else
    action = varargin{1};
end

switch lower(action)

%-----------------------------------------------------------------
% curs = panner('motion',fig)
%  returns 1 if currentpoint is over panner patch, 0 else
%
  case 'motion'
    fig = varargin{2};
    ud = get(fig,'userdata');
    panaxes = ud.panner.panaxes;
    p = get(panaxes,'currentpoint');
    panpatch = ud.panner.panpatch;
    xd = get(panpatch,'xdata');
    yd = get(panpatch,'ydata');
    varargout{1} = pinrect(p(1,1:2),[xd([1 2]) yd([1 3])]);
    
%-----------------------------------------------------------------
% panner  -or-  panner('init',fig)
%  startup code - adds panner to fig
%
  case 'init'

    if nargin<2
       fig = gcf;
    else
       fig = varargin{2};
    end

    ud = get(fig,'userdata');

    % create panner axes and patch
    panaxes = axes( ...
        'parent',fig,...
        'tag', 'panaxes', ...
        'box', 'off', ...
        'units','pixels',...
        'xlim', ud.limits.xlim,...
        'ylim', ud.limits.ylim,...
        'xtick', [], ...
        'ytick', [] );

    edgecolor = get(panaxes,'xcolor');

    pc = get(panaxes,'color');
    if ~isstr(pc)  % might be 'none', in which case don't set x,ycolor of axes
        set(panaxes,'xcolor',pc)
        set(panaxes,'ycolor',pc)
    else
        fc = get(fig,'color');
        set(panaxes,'xcolor',fc)
        set(panaxes,'ycolor',fc)
    end
    
    set(get(panaxes,'ylabel'),'string','Panner','tag','pannerxlabel',...
            'color',edgecolor,'fontsize',8)
    
    ud.panner.panaxes = panaxes;

    xlim = get(ud.mainaxes,'xlim');
    ylim = get(ud.mainaxes,'ylim');
    xd = xlim([1 2 2 1 1]);
    yd = ylim([1 1 2 2 1]);
    panpatch = patch( ...
        xd, ...
        yd, ...
        [1 1 1],...
        'facecolor',pc, ...
        'erasemode', 'xor', ...
        'parent',panaxes,...
        'tag','panpatch',...
        'edgecolor',edgecolor,...
        'buttondownfcn', 'sbswitch(''pandown'',0)');

    set(panpatch,'facecolor','none')
    ud.panner.panpatch = panpatch;

    ud.prefs.tool.panner = 1;

    set(fig,'userdata',ud)

    panner('resize',1,fig)

    set(fig,'resizefcn',appstr(get(fig,'resizefcn'),...
                'sbswitch(''panner'',''resize'')'))

%-----------------------------------------------------------------
% panner('close',fig)
%  shutdown code - removes panner from browser
%   Inputs:
%     fig - figure handle of browser
%
  case 'close'
    fig = varargin{2};
    ud = get(fig,'userdata');
    ud.prefs.tool.panner = 0;
    delete(findobj(fig,'tag','panaxes')) % delete panner axes (and all children)
    % clear the line cache:
    ud.linecache.ph = [];
    ud.linecache.phh = [];

    for i=1:length(ud.lines)
        ud.lines.ph = [];
    end
    
    set(fig,'resizefcn',remstr(get(fig,'resizefcn'),...
          'sbswitch(''panner'',''resize'')'))
    set(fig,'userdata',ud)

%-----------------------------------------------------------------
% panner('resize',create_flag,fig)
%  ResizeFcn for panner
%
  case 'resize'
    if nargin >= 2
        create_flag = varargin{2};
    else
        create_flag = 0;
    end
    if nargin >= 3
        fig = varargin{3};
    else
        fig = gcbf;
    end

    ud = get(fig,'userdata');
    sz = ud.sz;

    fp = get(fig,'position');   % in pixels already

    toolbar_ht = 0;
    
    ruler_port = [0 0 fp(3) sz.rh*ud.prefs.tool.ruler];
    panner_port = [0 ruler_port(4) ...
                    fp(3) sz.ph*ud.prefs.tool.panner];

    % fancy way:
    % xl = get(ud.panner.panaxes,'xlabel');
    % xlUnits = get(xl,'units');
    % set(xl,'units','points')
    % ex = get(xl,'extent');
    % set(xl,'units',xlUnits)

    % simple way:
    %ex = [0 0 0 16];   % guess height of xlabel in pixels
    ex = [0 0 0 0];  %<-- don't leave room for xlabel; moved to ylabel; TPK 6/21/99
    if strcmp(computer,'PCWIN'),
        tweak = 5;
    else
        tweak = 0;
    end    
    pan_pos = panner_port + [sz.ffs sz.ffs+ex(4)+tweak -2*sz.ffs -sz.ffs-ex(4)-tweak];

    % Make panner width same as main axes: TPK 6/21/99
    ax_pos = get(ud.mainaxes,'position');
    pan_pos(1) = ax_pos(1); pan_pos(3) = ax_pos(3);

    set(ud.panner.panaxes,'position',pan_pos)

%-----------------------------------------------------------------
% panner('update',fig)
%   assume xlimits of panaxes are correctly set to full view
%   reset patch to limits of mainaxes
%
  case 'update'
     if nargin >= 2
         fig = varargin{2};
     else
         fig = gcf;
     end
     ud = get(fig,'userdata');
     panaxes = ud.panner.panaxes;
     xlim = get(ud.mainaxes,'xlim');
     ylim = get(ud.mainaxes,'ylim');
     panpatch = ud.panner.panpatch;
     setpdata(panpatch,xlim,ylim)

% ----------------------------------------------------------------------
% panner('zoom',xlim,ylim)
%   set patch limits based on limits input
  case 'zoom'
     xlim = varargin{2};
     ylim = varargin{3};
     if nargin > 3
         fig = varargin{4};
     else
         fig = gcf;
     end
     ud = get(fig,'userdata');
     panpatch = ud.panner.panpatch;
     setpdata(panpatch,xlim,ylim)

end

function setpdata(panpatch,xlim,ylim)
%setpdata - set x and ydata of patch object to rectangle specified by
% xlim and ylim input
 
     set(panpatch,'xdata',[xlim(1) xlim(2) xlim(2) xlim(1) xlim(1)], ...
              'ydata',[ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)]) % thumb patch
    

