function noselection( state, fig )
%NOSELECTION Select/Deselect all objects in Figure.
%   NOSELECTION SAVE finds all objects with the Selected property 
%   of 'on'. Turns them all 'off'. Saves the handles so the Selected
%   values can be restored. This is useful when printing so that we
%   do not print the selection handles.
%
%   NOSELECTION RESTORE returns any previously changed objects'
%   Selected properties to their original values.
%
%   NOSELECTION(...,FIG) operates on the specified figure.
%
%   See also PRINT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/10 23:29:08 $

persistent NoSelectedOriginalValues;

if nargin == 0 ...
    | ~isstr( state ) ...
    | ~(strcmp(state, 'save') | strcmp(state, 'restore'))
    error([mfilename ' needs to know if it should ''save'' or ''restore'''])
elseif nargin ==1
    fig = gcf;
end

if strcmp( state, 'save' )
    %Get all objects we need to change, 
    %be careful about setting root property back.
    hiddenH = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');
    dberror = disabledberror;
    try
        h = findobj(fig,'Selected','on');
        err = 0;
    catch
        err = 1;
    end
    enabledberror(dberror);
    set(0,'showhiddenhandles', hiddenH)
    if err
        error(lasterr)
    end
    
    NoSelectedOriginalValues.handles = h;
    NoSelectedOriginalValues.origValue = get(h, {'Selected'});
    set(h,'Selected','off');
else
    orig = NoSelectedOriginalValues;
    set(orig.handles, {'Selected'}, orig.origValue);
end
