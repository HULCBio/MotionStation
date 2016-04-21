function noanimate( state, fig )
%NOANIMATE Modify figure to make all objects have normal erasemode.
%   NOANIMATE SAVE changes the EraseMode property of all animated
%   graphics objects in the current figure to 'normal', so they may be
%   rendered into the Z-Buffer, and printed with TIFF.
%
%   NOANIMATE RESTORE returns any previously changed objects'
%   EraseMode properties to their original values.
%
%   NOANIMATE(...,FIG) operates on the specified figure.
%
%   See also PRINT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/10 23:28:55 $

persistent NoAnimateOriginalEraseModes;

if nargin == 0 ...
    | ~isstr( state ) ...
    | ~(strcmp(state, 'save') | strcmp(state, 'restore'))
    error('NOANIMATE needs to know if it should ''save'' or ''restore''')
elseif nargin ==1
    fig = gcf;
end

if strcmp( state, 'save' )
    %Get all objects we need to change, 
    %be careful about setting root property back.
    hiddenH = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');
    try
        h = [findobj(fig,'erasemode','xor');...
                findobj(fig,'erasemode','none');...
                findobj(fig,'erasemode','background')];
        err = 0;
    catch
        err = 1;
    end
    set(0,'showhiddenhandles', hiddenH)
    if err
        error(lasterr)
    end
    
    NoAnimateOriginalEraseModes.handles = h;
    NoAnimateOriginalEraseModes.origModes = get(h, {'erasemode'});
    set(h,'erasemode','normal');
else
    if ~isempty(NoAnimateOriginalEraseModes)
        orig = NoAnimateOriginalEraseModes;
        set(orig.handles, {'erasemode'}, orig.origModes);
    end
end
