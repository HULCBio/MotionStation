% function txhan = mkdragic(message,fig,string,position,gonum,ax)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function txhan = mkdragic(message,fig,string,position,gonum,ax)

%   Creates TEXT object of which a copy can be dragged into
%   other windows


global MUDUMMYICONS % handles of the extra icons
global MUDRAGICON

if strcmp('create',message)
    loc = find(MUDUMMYICONS(:,1)==fig);
    if nargin == 5
        axe_to_grind = MUDUMMYICONS(loc,2);
    else
        axe_to_grind = ax;
    end
    if gca ~= axe_to_grind	% try to keep visible off
        axes(axe_to_grind);
    end
    bdf = ['mkdragic(''changedummy'',''' string ''',' int2str(gcf) ',' int2str(gonum) ');'];
    ud = [];
    ud = ipii(ud,string,1);
    ud = ipii(ud,gcf,2);
    ud = ipii(ud,gonum,3);
    bdf = 'mkdragic(''changedummy'');';
    txhan = text('position',position,...
                'string',string,...
                'color',[0 0 0],...
                'userdata',ud,...
		'interpreter','none',...
                'buttondownfcn',bdf);
elseif strcmp(message,'changedummy')
    co = get(gcf,'currentobject');
    ud = get(co,'userdata');
    string = xpii(ud,1);
    fig = xpii(ud,2);
    gonum = xpii(ud,3);
    MUDRAGICON = [fig gonum];     % gcf, gonum
    for i=1:size(MUDUMMYICONS,1)
        set(MUDUMMYICONS(i,3),'string',string,'visible','off')
        set(MUDUMMYICONS(i,1),'windowbuttonmotionfcn','mvtext');
        tmp = ['set(' int2str(MUDUMMYICONS(i,1)) ...
            ',''windowbuttonmotionfcn'','' '');mkdragic(''stopDRAG'');'];
        set(MUDUMMYICONS(i,1),'windowbuttonupfcn',tmp); % this stops it in the current windoe
    end
elseif strcmp(message,'stopDRAG')
        for i=1:size(MUDUMMYICONS,1)  % this loop stops it in all windows
                set(MUDUMMYICONS(i,1),'windowbuttonmotionfcn',' ');
                set(MUDUMMYICONS(i,1),'windowbuttonupfcn',' ');
                set(MUDUMMYICONS(i,3),'visible','off');
        end
        pw = get(0,'pointerwindow');
        pl = get(0,'pointerlocation');
        if pw~=0
            BINLOC = gguivar('BINLOC',pw);  % Every Tool has BINLOC variable,
                                            % within the tool, there are different WINDOWS
            if ~isempty(BINLOC)
                wpos = get(pw,'position');              % window pixel position
                npos = [(pl-wpos(1:2))./wpos(3:4)];   % NORMALIZED position
                binpt = find(BINLOC(:,1)==pw & ...
                            BINLOC(:,2)<npos(1) & ...
                            BINLOC(:,2)+BINLOC(:,4)>npos(1) & ...
                            BINLOC(:,3)<npos(2) & ...
                            BINLOC(:,3)+BINLOC(:,5)>npos(2));
                if ~isempty(binpt)
                    % Every tool has variables ULINKNAMES,UDNAME,TOOLTYPE
                    if MUDRAGICON(2) == 0
                        varstr = get(MUDUMMYICONS(1,3),'string');
                        curstr = get(BINLOC(binpt,6),'string');
                        set(BINLOC(binpt,6),'string',[curstr  varstr]);
                    else
                        varstr = get(MUDUMMYICONS(1,3),'string');
                        curstr = get(BINLOC(binpt,6),'string');
                        exstr = ['grabvar(' int2str(MUDRAGICON(1)) ',''' varstr ''')'];
                        set(BINLOC(binpt,6),'string',[curstr exstr]);
                    end
                end
            end
        end
end
