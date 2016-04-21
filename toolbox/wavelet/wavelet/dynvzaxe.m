function dynvzaxe(option,fig,varargin)
%DYNVZAXE Dynamic visualization tool (View Axes).
%   DYNVZAXE(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-May-97.
%   Last Revision: 21-Mar-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $ $Date: 2004/03/15 22:40:27 $

% Tag property of objects.
%------------------------
tag_figzaxe = 'Fig_Zaxe';

switch option
    case 'ini'
        % varargin{1} = pos_gra_area.
        % varargin{2} = Tog_View_Axes
        %----------------------------
        oldFig = hdlFigZaxe(fig,tag_figzaxe);
        togBtn = varargin{2};
        if ~isempty(oldFig)
            dynvzaxe('close',oldFig,'direct'); return;
        end

        pos_gra = varargin{1};
        ax      = wfindobj(get(fig,'Children'),'flat','type','axes','Visible','on');
        nb_axes = length(ax);
        if nb_axes<=1 , set(togBtn,'value',0); return; end

        pos_ax  = get(ax,'Position');
        pos_ax  = cat(1,pos_ax{:});
        [pos_ax,ind] = sortrows(pos_ax,[2 1]);
        ax      = ax(ind);
        valmin  = min(pos_ax);
        valmax  = max(pos_ax);

        % Hide 1.
        %--------
        HideNoZoom = 1;
        axNoZoom = [];
        if HideNoZoom
            indHide = [];
            for k=1:length(ax)
                ud = get(ax(k),'userdata');
                if isstruct(ud)
                    if isfield(ud,'dynvzaxe')
                        if isequal(lower(ud.dynvzaxe.enable),'off')
                           indHide = [indHide k];
                        end
                   end
                end
            end
			idxSET = setdiff([1:length(ax)],indHide);
            for k=idxSET
                ud = getappdata(ax(k),'WTBX_UserData');
                if isstruct(ud)
                    if isfield(ud,'dynvzaxe')
                        if isequal(lower(ud.dynvzaxe.enable),'off')
                           indHide = [indHide k];
                        end
                   end
                end
            end
            if ~isempty(indHide)
                axNoZoom    = wfindobj(ax(indHide),'Visible','on');
                ax(indHide) = [];
                pos_ax(indHide,:) = [];
                nb_axes = nb_axes-length(indHide);
            end
        end

        % Hide 2.
        %--------
        ax2Hide = [];
        rapp = pos_ax(:,3)./pos_ax(:,4);
        maxr = 14;
        r    = find(rapp<1/maxr | rapp>maxr);
        lr   = length(r);
        if lr>0
            pos_ax(r,:) = [];
            ax2Hide = wfindobj(ax(r),'Visible','on');
            ax(r)   = [];
            nb_axes = nb_axes-lr;
            if nb_axes<=1, set(togBtn,'value',0); return; end
            valmin = min(pos_ax);
            valmax = max(pos_ax);
        end
		
        xmin = valmin(1);
        xmax = max(pos_ax(:,1)+pos_ax(:,3));
        wmin = valmin(3);
        wmax = valmax(3);

        ymin = valmin(2);
        ymax = max(pos_ax(:,2)+pos_ax(:,4));
        hmin = valmin(4);
        hmax = valmax(4);

        x0   = 0.025;
        x1   = 0.975;
        y0   = 0.025;
        y1   = 0.975;
        kx   = (x1-x0)/(xmax-xmin);
        ky   = (y1-y0)/(ymax-ymin);

        pos_btn = [...
                    kx*[pos_ax(:,1)-xmin]+x0 , ky*[pos_ax(:,2)-ymin]+y0 , ...
                    kx*pos_ax(:,3) , ky*pos_ax(:,4)];
        pos_fig = [0.02 0.5 0.15 0.20];
        win_units = 'normalized';
        figName = sprintf('View Axes for fig. %s', int2str(fig));
        locfig = wfigmngr('init', ...
                     'Name',figName,...
                     'Visible','Off', ...
                     'Unit',win_units,...
                     'Position',pos_fig...
                     );
        wfigmngr('extfig',locfig,'ExtFig_DynV');
        strnumfig = int2str(locfig);

        % Find UiMenus and UiControls to Diseable.
        %-----------------------------------------
        try
            uimACT = wfigmngr('get_activeHDL',fig,'uimenu');
        catch
            uimACT = [];
        end
        uim     = wfindobj(fig,'type','uimenu','enable','on');
        [a,b]   = wcommon(uim,uimACT);
        uim     = uim(~a);

        [closeBTN,closeUIM] = wfigmngr('get_activeHDL',fig,'close');
        uic     = wfindobj(fig,'type','uicontrol','enable','on');
        uicDYNV = dynvtool('handles',fig,'Array');
        try   ,  uicCOLM = utcolmap('handles',fig);
        catch ,  uicCOLM = [];
        end
        [a,b]   = wcommon(uic,[closeBTN;uicDYNV(:);uicCOLM(:)]);
        uic     = uic(~a);
        txt     = findobj(uic,'style','text');
        [a,b]   = wcommon(uic,txt);

        ud.caller       = fig;
        ud.callTog      = togBtn;
        ud.hdl          = ax;
        ud.savpos       = pos_ax;
        ud.zoompos      = pos_gra+[0.05 0.05 -0.1 -0.1];
        ud.oldpos       = [];
        ud.newpos       = [];
        ud.act          = [];
        ud.hide         = [axNoZoom ; ax2Hide ; getHide(fig,pos_gra)];
        ud.savClose.btn = closeBTN;
        ud.savClose.uim = closeUIM;
        ud.savClose.val = get(fig,'CloseRequestFcn');
        ud.hdlOff       = [uim ; uic(~a)];
        ud.axeTMP = [];
        new_CloseFcn    = ['delete(' strnumfig ');' ud.savClose.val];
        SetCloseFcn(ud,new_CloseFcn)

        surfBtn   = prod(pos_btn(:,[3 4])')';
        [nul,ind] = sort(surfBtn);

        [strBtn,cdataBtn] = setToggle(0);
        for j = nb_axes:-1:1
            k = ind(j);
            cb_tog = [mfilename '(''select'',' strnumfig ',' int2str(k) ');'];
            tog = uicontrol(...
                    'Parent',locfig,        ...
                    'Style','togglebutton', ...
                    'Units','normalized',   ...
                    'Position',pos_btn(k,:),...
                    'FontWeight','bold', ...
                    'String',strBtn, ...
                    'Value',0, ...
                    'Cdata',cdataBtn,...
                    'Userdata',k, ...
                    'Callback',cb_tog);
        end
        cb_close = [mfilename '(''close'',' int2str(locfig) ')'];
        wfigmngr('attach_close',locfig,mfilename);

        % Computing figure position.
        %---------------------------
        [xpixl,ypixl] = wfigutil('prop_size',locfig,1,1);
        wok  = 60*xpixl;
        hok  = 20*ypixl;
        rx   = 1/3;
        ry   = 2/3;
        wmax = max(pos_btn(:,3));
        hmax = max(pos_btn(:,4));
        wmin = min(pos_btn(:,3));
        hmin = min(pos_btn(:,4));
        xmul = wok/wmin;
        ymul = hok/hmin;
        if xmul>1  , pos_fig(3) = pos_fig(3)*xmul; end
        if xmul<rx , pos_fig(3) = pos_fig(3)*rx;   end
        if ymul>1  , pos_fig(4) = pos_fig(4)*ymul; end
        if ymul<ry , pos_fig(4) = pos_fig(4)*ry;   end
        widthmax = 0.20;
        heighmax = 0.35;
        if pos_fig(3)>widthmax
            mulx = widthmax/pos_fig(3);
        else
            mulx = 1;
        end
        if pos_fig(4)>heighmax
            muly = heighmax/pos_fig(4);
        else
            muly = 1;
        end
        if muly>3*mulx , muly = 3*mulx; end
        pos_fig = pos_fig.*[1 1 mulx muly];

        caller_pos = get(fig,'Position');
        pos_fig(1) = caller_pos(1)-pos_fig(3)-0.0075;
        if pos_fig(1)<0 , pos_fig(1) = 0.005; end
        pos_fig(2) = caller_pos(2)+caller_pos(4)-pos_fig(4);
        if pos_fig(2)<0 , pos_fig(2) = 0.005; end
        set(locfig,'Position',pos_fig);

        % Diseable UiMenus and UiControls.
        %---------------------------------
        set(ud.hdlOff,'enable','off');
        set(locfig,...
                'Visible','On',   ...
                'Userdata',ud,    ...
                'tag',tag_figzaxe ...
                );

    case 'zoom'
        if OKCloseFIG(fig) , return ; end
        num_btn = varargin{1};

        ud     = get(fig,'Userdata');
        act    = ud.act;
        hdl    = ud.hdl;
        savpos = ud.savpos;
        p_axe  = get(hdl,'position');
        nb_axe = size(p_axe,1);
        if nb_axe> 1 , p_axe = cat(1,p_axe{:}); end
        i_axe = setdiff([1:nb_axe],num_btn);
        if isempty(act)
            hdl_btn = GetHdlPUS(fig,num_btn);
            setToggle(1,hdl_btn);
            oldpos  = savpos(num_btn,:);
            newpos  = ud.zoompos;
            act     = num_btn;
            visHide = 'off';
            ud.axeTMP = wfindobj(hdl(i_axe),'visible','on');
            set(ud.axeTMP,'Visible',visHide);

        elseif num_btn==act
            hdl_btn = GetHdlPUS(fig,num_btn);
            setToggle(0,hdl_btn);
            act     = [];
            oldpos  = ud.newpos;
            newpos  = ud.oldpos;
            visHide = 'on';
            tmp = ud.axeTMP;          
            tmp = tmp(ishandle(tmp));
            set(tmp,'Visible',visHide);
            ud.axeTMP = [];
        else
            hdl_btn_new = GetHdlPUS(fig,num_btn);
            hdl_btn_old = GetHdlPUS(fig,act);
            setToggle(0,hdl_btn_old);
            setToggle(1,hdl_btn_new);
            oldpos  = ud.newpos;
            newpos  = ud.oldpos;
            p_axe   = getPos(p_axe,newpos,oldpos);
            oldpos  = savpos(num_btn,:);
            newpos  = ud.zoompos;
            act     = num_btn;
            visHide = 'off';
            tmp = ud.axeTMP;
            tmp = tmp(ishandle(tmp));
            set(tmp,'Visible','On');
            ud.axeTMP = wfindobj(hdl(i_axe),'Visible','on');
            set(ud.axeTMP,'Visible',visHide);
        end
        set(ud.hide,'Visible',visHide);
        p_axe = getPos(p_axe,newpos,oldpos);
        for k=1:length(hdl)
            set(hdl(k),'position',p_axe(k,:));
        end
        ud.act    = act;
        ud.oldpos = oldpos;
        ud.newpos = newpos;
        set(fig,'Userdata',ud);

    case 'select'
        if OKCloseFIG(fig) , return ; end
        num_btn = varargin{1};
        if ~isempty(num_btn)
            refresh(fig);
            dynvzaxe('zoom',fig,num_btn);
        end

    case 'close'
        % in3 = flag for direct closing
        %-------------------------------
        ud = get(fig,'Userdata');
        if ishandle(ud.caller)
            act = ud.act;
            if ~isempty(act) , dynvzaxe('zoom',fig,act); end
            set(ud.hdlOff,'enable','on');
            SetCloseFcn(ud)
            togBtn = ud.callTog;
            set(togBtn,'Value',0);
        end
        if nargin>2 ,  delete(fig); end

    case 'stop'
        figZaxe = wfindobj(0,'type','figure','tag',tag_figzaxe);
        caller  = [];
        if ~isempty(figZaxe)
            for k = 1:length(figZaxe)
               ud = get(figZaxe(k),'Userdata');
               caller = [caller ud.caller];
            end
        end
        [nul,indCaller] = intersect(caller,fig);
        delete(figZaxe(indCaller));
        
    case 'exclude'
        currentAxes = varargin{1};
        ud.dynvzaxe.enable = 'off';							
        setappdata(currentAxes,'WTBX_UserData',ud);				
        
end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function varargout = depOfMachine(varargin)

scrSize = get(0,'ScreenSize');
wclose  = 80*varargin{1};
if scrSize(4)<=600
    hclose = 22*varargin{2};
else
    hclose = 33*varargin{2};
end
varargout = {wclose,hclose};
%-----------------------------------------------------------------------------%
function [st,x] = setToggle(select,hdl)
st = '';
s = [8 8];
if select,
   x = {ones(s),zeros(s),zeros(s)};
else
   x = {0.6*ones(s),zeros(s),zeros(s)};
end
x = cat(3,x{:});
if nargin>1
    set(hdl,'String',st,'value',select,'cdata',x);
end
%-----------------------------------------------------------------------------%
function hdlFig = hdlFigZaxe(fig,tag)

hdlFig  = [];
figZaxe = wfindobj(0,'type','figure','tag',tag);
if ~isempty(figZaxe)
    for k = 1:length(figZaxe)
        ud = get(figZaxe(k),'Userdata');
        try        
          if isequal(fig,ud.caller)
              hdlFig = figZaxe(k); break;
          end
        end
    end
end
%-----------------------------------------------------------------------------%
function pos_axe = getPos(pos_axe,newpos,oldpos)

diltrans = newpos(3:4)./oldpos(3:4);
diltrans = [newpos(1:2)-oldpos(1:2).*diltrans diltrans];
for k=1:size(pos_axe,1);
    pos_axe(k,1:2) = pos_axe(k,1:2).*diltrans(3:4)+diltrans(1:2);
    pos_axe(k,3:4) = pos_axe(k,3:4).*diltrans(3:4);
end
%-----------------------------------------------------------------------------%
function hideHdl = getHide(fig,pos_gra)

ax      = wfindobj(get(fig,'children'),'flat','type','axes','Visible','off');
hideHdl = wfindobj(ax,'Visible','on');
uic     = wfindobj(fig,'type','uicontrol','Visible','on');
pos_uic = get(uic,'Position');
pos_uic = cat(1,pos_uic{:});
bool    = zeros(size(pos_uic,1),1);

pos_gra = [ pos_gra(1) pos_gra(1)+pos_gra(3) ...
            pos_gra(2) pos_gra(2)+pos_gra(4) ...
            ];
bool = bool+pinrect(pos_uic(:,1:2),pos_gra);
bool = bool + ...
    pinrect([pos_uic(:,1)+pos_uic(:,3),pos_uic(:,2)+pos_uic(:,4)],pos_gra);
bool = bool + ...
    pinrect([pos_uic(:,1)+pos_uic(:,3)/2,pos_uic(:,2)+pos_uic(:,4)/2],pos_gra);
hideHdl = [hideHdl; uic(bool>0)];
%-----------------------------------------------------------------------------%
function bool = pinrect(pts,rect)
%PINRECT Determine if points lie in or on rectangle.
%   Inputs:
%     pts  - n-by-2 array of [x,y] data
%     rect - 1-by-4 vector of [xlim ylim] for the rectangle
%   Outputs:
%     bool - length n binary vector 

[i,j] = find(isnan(pts));
bool = (pts(:,1)<rect(1))|(pts(:,1)>rect(2))|...
       (pts(:,2)<rect(3))|(pts(:,2)>rect(4));
bool = ~bool;
bool(i) = 0;
%-----------------------------------------------------------------------------%
function hdlPUS = GetHdlPUS(fig,num)

btn = wfindobj(fig,'style','togglebutton');
for k =1:length(btn)
    nn = get(btn(k),'Userdata');
    if isequal(nn,num) , hdlPUS = btn(k); break; end
end
%-----------------------------------------------------------------------------%
function SetCloseFcn(ud,CloseFcn)

if nargin<2 , CloseFcn = ud.savClose.val; end
set(ud.savClose.btn,'Callback',CloseFcn);
set(ud.savClose.uim,'Callback',CloseFcn);
set(ud.caller,'CloseRequestFcn',CloseFcn);
%-----------------------------------------------------------------------------%
function ok = OKCloseFIG(fig)

ud     = get(fig,'Userdata');
caller = ud.caller;
if ~ishandle(caller)
    ud.act    = [];
    ud.caller = [];
    set(fig,'Userdata',ud);
    dynvzaxe('close',fig,'direct');
    ok = 1;
else
    ok = 0;
end
%-----------------------------------------------------------------------------%
%=============================================================================%