function figOut = openfig(filename, policy, visible)
%OPENFIG Open new copy or raise existing copy of saved figure.
%    OPENFIG('NAME.FIG','new') opens figure contained in .fig file,
%    NAME.FIG, and ensures it is completely on screen.  Specifying the
%    .fig extension is optional. Specifying the full path is optional
%    as long as the .fig file is on the MATLAB path.
%
%    If the .fig file contains an invisible figure, OPENFIG returns
%    its handle and leaves it invisible.  The caller should make the
%    figure visible when appropriate.
%
%    OPENFIG('NAME.FIG') is the same as OPENFIG('NAME.FIG','new').
%
%    OPENFIG('NAME.FIG','reuse') opens figure contained in .fig file
%    only if a copy is not currently open, otherwise ensures existing
%    copy is still completely on screen.  If the existing copy is
%    visible, it is also raised above all other windows.
%
%    OPENFIG(...,'invisible') opens as above, forcing figure invisible.
%
%    OPENFIG(...,'visible') opens as above, forcing figure visible.
%
%    F = OPENFIG(...) returns the handle to the figure.
%
%    See also: OPEN, MOVEGUI, GUIDE, GUIHANDLES, SAVE, SAVEAS.

%    OPENFIG(...,'auto') opens as above, forcing figure invisible on
%    creation.  Subsequent calls when the second argument is 'reuse' will
%    obey the current visibility setting.
%
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.29.4.3 $  $Date: 2004/04/10 23:28:57 $

error(nargchk(1,inf,nargin));
if nargin < 3
    visible = '';
else
    visible = lower(visible);
end

if ~isempty(visible) & ~isequal(visible,'invisible') & ~isequal(visible,'visible') & ~isequal(visible,'auto')
    error('Third input argument must be ''invisible'' or ''visible''.');
end

if nargin < 2
    policy = 'new';
end

if ~isequal(policy,'new') & ~isequal(policy,'reuse')
    error('Second input argument must be ''new'' or ''reuse''.');
end

[path, name, ext] = fileparts(filename);

if isempty(ext)
    ext = '.fig';
elseif ~isequal(lower(ext), '.fig')
    error('Argument must be a .fig file');
end

filename = fullfile(path, [name ext]);

% We will use this token, based on the base name of the file
% (without path or extension) to track open instances of figure.
fname = filename;
flag = isletter(fname) | fname == '_' | ('0' <= fname & fname <= '9');
if (~all(flag))
    fname(find(~flag))=[];
end
fname = fliplr(fname);            % file name is more important
TOKEN = ['OpenFig_' fname '_SINGLETON']; % hide leading kruft
TOKEN = TOKEN(1:min(end, 31));

% get the existing list of figures, and prune out stale handles.
figs = getappdata(0, TOKEN);
figs = figs(ishandle(figs));

% are we reusing an existing figure?
reusing = false;

switch policy
 case 'new'
  % create another one, unconditionally
  [fig, oldvis] = hgload(filename, struct('Visible','off'));
  figs = [figs(:)' fig(:)'];
 case 'reuse'
  % create one only if there are no others
  if isempty(figs)
      [figs, oldvis] = hgload(filename, struct('Visible','off'));
  else
      oldvis = get(figs(end),{'Visible'});
      reusing = true;
  end
  % reuse the one at the end of the list:
  fig = figs(end);
end

if ~reusing && isappdata(fig,'GUIOnScreen')
    rmappdata(fig,'GUIOnScreen');
end

% bubble vis to top
if ~isempty(oldvis)
  oldvis = oldvis{1};
  if isstruct(oldvis)
    oldvis = oldvis.Visible;
  else
    oldvis = get(0,'DefaultFigureVisible');
  end
end

% remember all instances of this figure.
setappdata(0, TOKEN, figs);

% ensure the figure is completely on the screen:
for n = 1:length(fig)
  movegui(fig(n), 'onscreen');
end

% decide whether to adjust visible
if isempty(visible)
    set(fig,'Visible',oldvis);
else
    switch visible
     case 'invisible'
      set(fig,'Visible','off');
     case 'visible'
      set(fig,'Visible','on');
     case 'auto'
      if reusing
          % if oldvis is 'on', this will raise the figure to the foreground
          % it will do nothing if oldvis is 'off'
          set(fig,'Visible',oldvis);
      else
          set(fig,'Visible','off');
      end
    end
end
      
if nargout
    figOut = fig;
end

