function [hcomponent, hcontainer] = javacomponent(hcomponent, position, parent)
%JAVACOMPONENT Create a Java AWT Component and put it in a figure
%
% JAVACOMPONENT(HCOMPONENT) places the Java component HCOMPONENT on the
% current figure PARENT or creates a new figure if one is not available.
% The default position is [20 20 60 20].
%
% JAVACOMPONENT(HCOMPONENT, POSITION, PARENT) places the Java component
% HCOMPONENT on the figure PARENT at position POSITION. POSITION is in
% pixel units with the format [left, bottom, width, height].   
%
% [HCOMPONENT, HCONTAINER] = JAVACOMPONENT(HCOMPONENT, POSITION, PARENT)
% places the Java component HCOMPONENT on the figure PARENT at position
% POSITION. It returns the handles to the Java component and its HG
% container in HCONTAINER. HCONTAINER is only returned when pixel
% positioning is used. It can be used to change the units, position,
% and visibility of the Java component after it is added to the figure.
%
% JAVACOMPONENT(HCOMPONENT, CONSTRAINT, PARENT) places the Java component
% HCOMPONENT next to the figure's drawing area using CONSTRAINT. CONSTRAINT
% that can be NORTH, SOUTH, EAST, OR WEST placement - following Java AWT's
% BorderLayout rules. The handle to the Java component is returned on
% success, empty is returned on error. If parent is a uitoolbar handle,
% CONSTRAINT is ignored and the component is placed last in the child list
% for the given toolbar. 
%
%   Examples:
%
%   f = figure('WindowStyle', 'docked');
%   b1 = javax.swing.JButton('Hi!');
%   set(b1,'ActionPerformedCallback','disp Hi!');
%   javacomponent(b1);
%
%   f = figure;
%   sp = javax.swing.JSpinner;
%   [comp, container] = javacomponent(sp);
%   set(container,'Position', [100, 100, 100, 40]); 
%   set(container,'Units', 'normalized'); 
%
%   f = figure;
%   tr = javax.swing.JTree;
%   javacomponent(tr, java.awt.BorderLayout.WEST, f);
%
%   f = figure('WindowStyle', 'docked');
%   ta = javax.swing.JTable(3,10);
%   javacomponent(ta, java.awt.BorderLayout.SOUTH, f);
%
%   f = figure;
%   tb = uitoolbar('Parent',f);
%   b2 = javax.swing.JButton('Hi again!');
%   set(b2,'ActionPerformedCallback','disp(''Hi again!'')');
%   javacomponent(b2,[],tb); % Note: Position is ignored.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2004/04/15 00:06:58 $

if ~isempty(nargchk(1,3,nargin))
    error(usage);
end

if nargin < 3 
    parent = gcf;
end

if nargin < 2
    position = [20 20 60 20];
end

parentIsFigure = false;

if isa(handle(parent), 'figure')
    parentIsFigure = true;
    peer = get(parent,'JavaFrame');
elseif isa(handle(parent), 'uitoolbar')
    peer = get(parent,'JavaContainer');
    if isempty(peer)
        drawnow;
        peer = get(parent,'JavaContainer');
    end
else
    error(sprintf('Invalid parent handle\n%s', usage))
end

if isempty(peer)
    error('Java figures are not enabled')
end

hcontainer = [];

if nargin == 1
    hgp = peer.add(hcomponent);
    % parent must be a figure, we default to gcf upstairs
    hcontainer = createPanel(parent, hgp, position, peer, hcomponent);
    hgp.setUIContainer(hcontainer);
else
    if parentIsFigure
        if isnumeric(position)
            if isempty(position)
                position = [20 20 60 20];
            end
            % numeric position is not set here, rely on the uicontainer
            % listeners below.
            hgp = peer.add(hcomponent);
            hcontainer = createPanel(parent, hgp, position, peer, hcomponent);
            hgp.setUIContainer(hcontainer);
        elseif ...
                isequal(char(position),char(java.awt.BorderLayout.NORTH)) || ...
                isequal(char(position),char(java.awt.BorderLayout.SOUTH)) || ...
                isequal(char(position),char(java.awt.BorderLayout.EAST))  || ...
                isequal(char(position),char(java.awt.BorderLayout.WEST))
            hgp = peer.add(hcomponent, position); 
            hcontainer = [];
        else
            error(sprintf('Invalid component position\n%s', usage))
        end
    else
        % component position is ignored for now
        peer.add(hcomponent);
        hcontainer = [];
    end

    % make sure the component is on the screen so the
    % caller can interact with it right now.
    % drawnow;
end

end

function str=usage
str = [sprintf('\n') ...
       'usage: javacomponent(hJavaComponent, position, parent) ' sprintf('\n') ...
       '- position can be [left bottom width height] in pixels ' sprintf('\n') ...
       '  or the string North, South, East, or West' sprintf('\n') ...
       '- parent can be a figure or a uitoolbar handle.'];
end

function out = createPanel(parent, hgp, position, peer, hcomponent)
 % add delete listener
 out = uicontainer('Parent', parent, 'Units', 'Pixels');

 % add resize listener to parent (parent must be a figure or this dies quietly)
 % this is for normalized units
 hl = addlistener(parent, 'ResizeEvent', {@handleResize, out, hgp});

 % add resize listener to container
 % this is for non-normalized units
 h2 = addlistener(out, 'Position', 'PropertyPostSet', {@handleResize, out, hgp});

 % add visible listener 
 h3 = addlistener(out, 'Visible', 'PropertyPostSet', {@handleVisible, out, hgp});

 % force though 1st resize event
 set(out,'Position', position); 
 set(out,'DeleteFcn',{@handleDelete, peer, hcomponent, [hl, h2, h3]});
 
 if isa(hcomponent,'com.mathworks.hg.peer.FigureChild')
     hcomponent.setUIContainer(out);
 end

 function handleDelete(obj, evd, peer, hcomponent, listeners)
  peer.remove(hcomponent)
  delete(listeners)
 end

 function handleResize(obj, evd, out, hgp)
   setpixelposition(hgp,getpixelposition(out))
 end

 function handleVisible(obj, evd, out, hgp)
   hgp.setVisible(strcmp(get(out,'Visible'),'on'))
 end
end

