function h=copybuffer(varargin)
%COPYBUFFER creates the scribe copybuffer object
%  H=SCRIBE.COPYBUFFER creates a scribe.copybuffer
%
%  See also PLOTEDIT

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $  $

h = scribe.copybuffer;

% initialize property values -----------------------------

h.figure = handle(figure('Tag','ScribeCBFig',...
           'IntegerHandle','off',...
           'HandleVisibility','off',...
           'NumberTitle','off',...
           'Visible','off',...
           'Resize','off'));
       
h.axes = handle( axes('Tag','ScribeCBAx',...
           'HandleVisibility','off',...
           'Visible','on',...
           'Parent',double(h.figure)));

h.copies = [];

%set up listeners-----------------------------------------
l       = handle.listener(h,h.findprop('copies'),...
			  'PropertyPostSet',@changedCopies);

h.PropertyListeners = l;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%LISTENER CALLBACKS%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedCopies(hProp,eventData)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
