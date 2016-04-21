function schema

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:05 $

    pkg = findpackage('DAStudio');
    cls = schema.class ( pkg, 'ModelExplorer');
    pkg.JavaPackage  = 'com.mathworks.toolbox.dastudio.explorer';
    cls.JavaInterfaces = {'com.mathworks.toolbox.dastudio.explorer.ModelExplorerInterface'};

    p = schema.prop(cls,'jModelExplorer','handle');
    p.AccessFlags.PublicSet = 'off';
    p.Visible = 'off';

    p = schema.prop(cls, 'scope', 'handle');
    p.GetFunction = @getScope;
    p.SetFunction = @setScope;

    p = schema.prop(cls, 'selected', 'handle vector');
    p.GetFunction = @getSelected;
    p.SetFunction = @setSelected;

    p = schema.prop(cls, 'followLinks', 'bool');
    p.GetFunction = @getFollowLinks;
    p.SetFunction = @setFollowLinks;

    p = schema.prop(cls, 'lookUnderMasks', 'bool');
    p.GetFunction = @getLookUnderMasks;
    p.SetFunction = @setLookUnderMasks;

    p = schema.prop(cls, 'viewLibraries', 'bool');
    p.GetFunction = @getViewLibraries;
    p.SetFunction = @setViewLibraries;

    p = schema.prop(cls, 'tab', 'string');
    p.GetFunction = @getTab;
    p.SetFunction = @setTab;

    p = schema.prop(cls, 'visible', 'int32');
    p.FactoryValue = 1;
    p.AccessFlags.PublicSet = 'off';
    p.GetFunction = @getVisible;


% --- Scope ------------------------------------------------------------------------

function sv = getScope(h, currentV)
    if isempty(h.jModelExplorer)
        sv = [];
    else
        javaHandle = java(h.jModelExplorer);
        wrapper = javaHandle.getScope;
        if isempty(wrapper)
            sv = [];
        else
            sv = handle(wrapper.getDao);
        end
    end

function sv = setScope(h, inputV)
    sv = inputV;
    if (~isempty(h.jModelExplorer))
        javaHandle = java(h.jModelExplorer);
        javaHandle.setScope(com.mathworks.toolbox.dastudio.DATreeNode.create(java(inputV)));
    end



% --- Selected ------------------------------------------------------------------------

function sv = getSelected(h, currentV)
    if isempty(h.jModelExplorer)
        sv = [];
    else
        javaHandle = java(h.jModelExplorer);
        % returns an array of the selected UDD objects from the list display pane
        datns = javaHandle.getSelected;

        if isempty(datns)
            sv = [];
        else
            for i = 1:length(datns)
                sv(i) = handle(datns(i).getDao);
            end
        end
    end


function sv = setSelected(h, inputV)
    sv = inputV;
    if (~isempty(h.jModelExplorer))
        javaHandle = java(h.jModelExplorer);
        % selects an array of UDD objects in the list display pane
        scope = [];
        for i = 1:length(inputV)
            datns(i) = com.mathworks.toolbox.dastudio.DATreeNode.create(java(inputV(i)));
            daparent = datns(i).getParent;
            if isempty(daparent)
                error('All selections must have a valid parent scope');
            else
                parent = handle(daparent.getDao);
            end
            if isempty(scope)
                scope = parent;
            else
                if parent ~= scope
                    error('Multiple selections must all have the same scope');
                end
            end
        end
        setScope(h, scope);
        javaHandle.setSelected(datns);
    end


% --- Visible ------------------------------------------------------------------------

function sv = getVisible(h, currentV)
    p = h.findprop('visible');
    sv = p.FactoryValue;
    if (~isempty(h.jModelExplorer))
        javaHandle = java(h.jModelExplorer);

        sv = javaHandle.isVisible;
    end



% --- Tab ------------------------------------------------------------------------

function sv = getTab(h, currentV)
    if isempty(h.jModelExplorer)
        sv = '';
    else
        javaHandle = java(h.jModelExplorer);
        sv = java(handle(javaHandle.getTab));
    end

function sv = setTab(h, inputV)
    sv = inputV;
    if (~isempty(h.jModelExplorer))
        javaHandle = java(h.jModelExplorer);
        javaHandle.setTab(inputV);
        newTab = java(handle(javaHandle.getTab));
        if ~isequal(newTab, inputV)
            error([inputV ' is not a valid ModelExplorer tab']);
        end
    end


% --- Links ------------------------------------------------------------------------

function sv = getFollowLinks(h, currentV)
    if isempty(h.jModelExplorer)
        sv = 0;
    else
        javaHandle = java(h.jModelExplorer);
        sv = javaHandle.getFollowLinks;
    end

function sv = setFollowLinks(h, inputV)
    sv = inputV;
    if (~isempty(h.jModelExplorer))
        javaHandle = java(h.jModelExplorer);
        javaHandle.setFollowLinks(inputV);
    end


% --- Masks ------------------------------------------------------------------------

function sv = getLookUnderMasks(h, currentV)
    if isempty(h.jModelExplorer)
        sv = 0;
    else
        javaHandle = java(h.jModelExplorer);
        sv = javaHandle.getLookUnderMasks;
    end

function sv = setLookUnderMasks(h, inputV)
    sv = inputV;
    if (~isempty(h.jModelExplorer))
        javaHandle = java(h.jModelExplorer);
        javaHandle.setLookUnderMasks(inputV);
    end


% --- Libraries ------------------------------------------------------------------------

function sv = getViewLibraries(h, currentV)
    if isempty(h.jModelExplorer)
        sv = 0;
    else
        javaHandle = java(h.jModelExplorer);
        sv = javaHandle.getViewLibraries;
    end

function sv = setViewLibraries(h, inputV)
    sv = inputV;
    if (~isempty(h.jModelExplorer))
        javaHandle = java(h.jModelExplorer);
        javaHandle.setViewLibraries(inputV);
    end

  