function hgsave(varargin)
% HGSAVE  Saves an HG object hierarchy to a MAT file.
% 
% HGSAVE(H, 'Filename') saves the objects identified by handle array H
% to a file named 'Filename'.  If 'Filename' contains no extension,
% then the extension '.fig' is added.  If H is a vector, none of the
% handles in H may be ancestors or descendents of any other handles in
% H.
%
% HGSAVE('Filename') saves the current figure to a file named
% 'Filename'.
%
% HGSAVE(..., 'all') overrides the default behavior of excluding
% non-serializable objects from the file.  Items such as the default
% toolbars and default menus are marked as non-serializable, and are
% normally not saved in FIG-files, because they are loaded from
% separate files at figure creation time.  This allows the size of
% FIG-files to be reduced, and allows for revisioning of the default
% menus and toolbars without affecting existing FIG-files. Passing
% 'all' to HGSAVE insures non-serializable objects are also saved.
% Note: the default behavior of HGLOAD is to ignore non-serializable
% objects in the file at load time, and that can be overridden using
% the 'all' flag with HGLOAD.
%
% HGSAVE(..., '-v6') saves a FIG-file that can be loaded by versions
% prior to MATLAB 7. When creating a figure to be saved and used in a
% version prior to MATLAB 7 use the 'v6' option to the plotting
% commands. See the help for PLOT, BAR and other plotting commands for
% more information.
%
% See also HGLOAD, SAVE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   D. Foti  11/10/97

error(nargchk(1, inf, nargin));

% pull off handle + 'filename,' or just 'filename'
if(isstr(varargin{1}))
  h = gcf;
  filename = varargin{1};
  first_pass_through = 2;
else
  h = varargin{1};
  if any(~ishandle(h))
    error('Invalid handle');
  end
  filename = varargin{2};
  first_pass_through = 3;
end

% any trailing args that start with '-' are passed to save
save_args = nargin+1;
while save_args > first_pass_through && ...
      isstr(varargin{save_args-1}) && ...
      varargin{save_args-1}(1) == '-'
  save_args = save_args - 1;
end

[path, file, ext] = fileparts(filename);

% fileparts returns everything from the last . to the end of the
% string as the extention so the following test will catch
% an extention with 0, 1, or infinity dots.
% for example, all these filenames will have .fig added to the end:
%  foo.
%  foo..
%  foo.bar.
%  foo.bar...

if isempty(ext) | strcmp(ext, '.')
  filename = fullfile(path, [file , ext, '.fig']);
end

% Revision encoded as 2 digits for major revision,
% 2 digits for minor revision, and 2 digits for
% patch revision.  This is the minimum revision 
% required to fully support the file format.
% e.g. 070000 means 7.0.0

% if saving a figure and plotedit, zoom or rotate3d
% are on, save their states and
% turn them off before saving
% and if scribe clear mode callback appdata
% exists, remove it.
plotediton = zeros(length(h),1);
rotate3dstate = cell(length(h),1);
zoomstate = cell(length(h),1);
scmcb = cell(length(h),1);

olddata = cell(length(h),1);
for i = 1:length(h)
  if strcmp(get(h(i), 'type'), 'figure')
    plotediton(i) = plotedit(h(i), 'isactive');
    rotate3dstate{i} = getappdata(h(i),'Rotate3dOnState');
    zoomstate{i} = getappdata(h(i),'ZoomOnState');
    datacursorstate(i) = strcmp(datacursormode(h(i),'ison'),'on');
    panstate(i) = pan(h(i),'ison');
    s = getappdata(h(i),'ScribeClearModeCallback');
    if ~isempty(s) & iscell(s)
        scmcb{i} = s;
        rmappdata(h(i),'ScribeClearModeCallback');
    end
    if plotediton(i)
        plotedit(h(i),'off');
    end
    if ~isempty(rotate3dstate{i})
        rotate3d(h(i),'off');
    end
    if ~isempty(zoomstate{i})
        zoom(h(i),'off');
    end    
    if datacursorstate(i)
        datacursormode(h(i),'off');
    end
    if panstate(i)
        pan(h(i),'off');
    end
  end
  fch = findall(h(i));
  for k=1:length(fch)
    hh = handle(fch(k));
    if ismethod(hh,'preserialize')
      olddata{i}(2*k-1:2*k) = {hh,preserialize(hh)};
    end
  end
end

hgS_070000 = handle2struct(h, varargin{first_pass_through:save_args-1});

% restore plotedit, zoom and rotate3d states if saving a figure
for i = 1:length(h)
    for k=1:length(olddata{i})
      if ismethod(olddata{i}{k},'postserialize')
        postserialize(olddata{i}{k:k+1});
      end
      k=k+1;
    end
    if strcmp(get(h(i),'type'),'figure')
        % if plotedit was on, restore it
        if plotediton(i)
            plotedit(h(i),'on');
        end
        % if rotate3d was on, restore it
        if ~isempty(rotate3dstate{i})
            rotate3d(h(i),rotate3dstate{i});
        end
        % if zoom was on, restore it
        if ~isempty(zoomstate{i})
            zoom(h(i),zoomstate{i});
        end
        if datacursorstate(i)
           datacursormode(h(i),'on');
        end
        if panstate(i)
           pan(h(i),'on');
        end
        % if there was a scribeclearmodecallback, reset it
        if ~isempty(scmcb{i})
            setappdata(h(i),'ScribeClearModeCallback',scmcb{i});
        end   
    end
end

save(filename, 'hgS_070000',varargin{save_args:end});
