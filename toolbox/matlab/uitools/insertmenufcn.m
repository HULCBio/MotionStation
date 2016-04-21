function insertmenufcn(hfig, cmd)
%INSERTMENUFCN Implements part of the figure insert menu.
%  INSERTMENUFCN(CMD) invokes insert menu command CMD on figure GCBF.
%  INSERTMENUFCN(H, CMD) invokes insert menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    Xlabel
%    Ylabel
%    Zlabel
%    Title
%    Legend
%    Colorbar
%    DoubleArrow
%    Arrow
%    Line
%    Text
%    Textbox
%    Rectangle
%    Axes
%    Light

%  CMD Values For Internal Use Only:
%    InsertPost

%  Copyright 1984-2003 The MathWorks, Inc.

error(nargchk(1,2,nargin))

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

switch cmd
    case 'InsertPost'
        LUpdateInsertMenu(hfig);
    case 'Xlabel'
        domymenu menubar addxlabel
    case 'Ylabel'
        domymenu menubar addylabel
    case 'Zlabel'
        domymenu menubar addzlabel
    case 'Title'
        domymenu menubar addtitle
    case 'Legend'
        lmenu = findall(hfig,'Tag','figMenuInsertLegend');
        ltogg = uigettoolbar(hfig,'Annotation.InsertLegend');
        cax = get(hfig,'CurrentAxes');
        if ~isempty(cax)
            if (~isempty(lmenu) && isequal(lmenu,gcbo) && strcmpi(get(lmenu,'checked'),'off')) ||...
                    (~isempty(ltogg) && isequal(ltogg,gcbo) && strcmpi(get(ltogg,'state'),'on'))
                legend(cax,'-defaultstrings');
            else
                legend(cax,'off');
            end
        else
            if ~isempty(ltogg)
                set(ltogg,'State','off');
            end
        end

    case 'Colorbar'
        cbmenu = findall(hfig,'Tag','figMenuInsertColorbar');
        cbtogg = uigettoolbar(hfig,'Annotation.InsertColorbar');
        cax = get(hfig,'CurrentAxes');
        if ~isempty(cax)
            if (~isempty(cbmenu) && isequal(cbmenu,gcbo) && strcmpi(get(cbmenu,'checked'),'off')) ||...
                    (~isempty(cbtogg) && isequal(cbtogg,gcbo) && strcmpi(get(cbtogg,'state'),'on'))
                colorbar('peer',cax);
            else
                colorbar('peer',cax,'off');
            end
        else
            if ~isempty(cbtogg)
                set(cbtogg,'State','off');
            end
        end
    case 'DoubleArrow'
        startscribeobject('doublearrow',hfig)
    case 'Arrow'
        startscribeobject('arrow',hfig)
    case 'TextArrow'
        startscribeobject('textarrow',hfig)
    case 'Line'
        startscribeobject('line',hfig)
    case 'Text'
        domymenu menubar addtext
    case 'Textbox'
        startscribeobject('textbox',hfig)
    case 'Rectangle'
        startscribeobject('rectangle',hfig)
    case 'Ellipse'
        startscribeobject('ellipse',hfig)
    case 'Axes'
        domymenu menubar addaxes
    case 'Light'
        domymenu menubar addlight
end

%-----------------------------------------------------------------------%
function LUpdateInsertMenu(fig);

insertMenuItems = allchild(findobj(allchild(fig),'flat','Type','uimenu','Tag','figMenuInsert'));
if ~isempty(insertMenuItems)
    % Set Enable Flag values
    menuEnable='on';
    if isempty(findobj(fig,'type','axes'));
        % if no axes in figure, disable everything in menu
        menuEnable='off';
    else
        titleAndLabelEnable='on';
        ax = get(fig,'CurrentAxes');
        if ~isempty(ax)
            tag = get(ax,'Tag');
            if strcmpi(tag,'legend') || strcmpi(tag,'Colorbar')
                % if current axes is a colorbar or legend, disable
                % X,Y,Z label and Title
                titleAndLabelEnable='off';
            else
                zLabelEnable='on';
                if is2D(ax)
                    % if axes is 2D, disable Z label
                    zLabelEnable='off';
                end
            end   
        end
    end
    % Enable/Disable Menu Items
    % Use Cell array to maintain correct indexing
    eMenus= {findobj(insertMenuItems,'tag','figMenuInsertYLabel')
        findobj(insertMenuItems,'tag','figMenuInsertXLabel')
        findobj(insertMenuItems,'tag','figMenuInsertZLabel')
        findobj(insertMenuItems,'tag','figMenuInsertTitle')
        findobj(insertMenuItems,'tag','figMenuInsertLegend')
        findobj(insertMenuItems,'tag','figMenuInsertColorbar')
        findobj(insertMenuItems,'tag','figMenuInsertLight')
        findobj(insertMenuItems,'tag','figMenuInsertAxes')};
    if ~isempty(eMenus)
        % All items present set to menu enable
        set([eMenus{1:7}],'Enable',menuEnable);
        if strcmpi(menuEnable,'on')
            % Any of first four present set to title/label enable
            set([eMenus{1:4}],'Enable',titleAndLabelEnable);
            if strcmpi(titleAndLabelEnable,'on')
                % third set to z label enable
                set(eMenus{3},'Enable',zLabelEnable');
            end
        end
    end
    % Always enable insert axes;
    set(eMenus{8},'Enable','on');
end

%-------------------------------------------------------------------------%