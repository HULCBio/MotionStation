function mxpcscope
% MXPCSCOPE - Mask Initialization function for xPC Target scope block

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.13.6.2 $ $Date: 2004/04/08 21:03:15 $

if strcmpi(get_param(bdroot, 'BlockDiagramType'), 'library')
  return
end

ScopeTypes={'Host','Target','File'};

scopeBlocks=find_system(bdroot, 'FollowLinks',    'on',  ...
                                'LookUnderMasks', 'all', ...
                                'MaskType',       'xpcscopeblock');

tmp = str2num(char(get_param(scopeBlocks, 'scopeno')));
tmpsctypes = get_param(scopeBlocks, 'scopetype');


if length(unique(tmp)) < length(tmp)
   error(['The same scope number is used by more than one xPC Target scope ' ...
          'block']);
end


Fidx=strmatch('File',tmpsctypes,'exact');
filblks=scopeBlocks(Fidx);
filenames=get_param(filblks,'FileName');
if length(unique(filenames)) < length(filenames)
    error(['The same Filename is used by more than one xPC Target scope ' ...
          'block of Type File']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% scopeblks=unique(tmpsctypes);
% for i=1:length(scopeblks)
%        idx=strmatch(scopeblks{i},tmpsctypes,'exact');
%        if length(idx) > 10
%           error(['You can only have up to ten scope blocks of Type ',scopeblks{i}])
%       end
%  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[scopeno,scopetye,autostart,viewmode,formatstr,grid,ylimits,nosamples,noprepostsamples,...
interleave,triggermode,triggersignal,triggerlevel,triggerslope,triggerscope,...
triggersample,filename,mode,WriteSize,AutoRestart] = deal(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20);

scopetypestr=get_param(gcbh,'scopetype');
triggermodestr=get_param(gcbh,'triggermode');
viewrmodestr=get_param(gcbh,'viewmode');
%formatchboxVal=get_param(gcbh,'formatchbox');

mask_visibilities = get_param(gcbh,'maskvisibilities');
mask_enables_orig = get_param(gcbh,'maskenables');
mask_enables = mask_enables_orig;
switch scopetypestr
 case 'Host'
  mask_visibilities{viewmode}    = 'off';
  mask_visibilities{grid}        = 'off';
  mask_visibilities{ylimits}     = 'off';
  mask_visibilities{formatstr}   = 'off';
  mask_visibilities{mode}        = 'off';
  mask_visibilities{WriteSize}   = 'off';
  mask_visibilities{filename}    = 'off';
  mask_visibilities{AutoRestart} = 'off';
 case 'Target'
  mask_visibilities{viewmode}    = 'on';
  mask_visibilities{grid}        = 'on';
  mask_visibilities{ylimits}     = 'on';
  mask_visibilities{mode}        = 'off';
  mask_visibilities{WriteSize}   = 'off';
  mask_visibilities{filename}    = 'off';
  mask_visibilities{AutoRestart} = 'off';
  if strcmp(viewrmodestr,'Numerical')
    mask_visibilities{formatstr} = 'on';
    mask_visibilities{grid}      = 'off';
    mask_visibilities{ylimits}   = 'off';
    set_param(gcbh,'maskvisibilities',mask_visibilities)
  else
    mask_visibilities{formatstr} = 'off';
  end
 case 'File'
  mask_visibilities{viewmode}    = 'off';
  mask_visibilities{grid}        = 'off';
  mask_visibilities{ylimits}     = 'off';
  mask_visibilities{formatstr}   = 'off';
  mask_visibilities{mode}        = 'on';
  mask_visibilities{WriteSize}   = 'on';
  mask_visibilities{filename}    = 'on';
  mask_visibilities{AutoRestart} = 'on';

  %filename check for due to filename length limitation%%%%%%%%%%%
  fname = get_param(gcb,'filename');
  checkfname(fname);
end

switch triggermodestr
 case 'Scope triggering'
  mask_visibilities{triggerscope} = 'on';
  mask_visibilities{triggersample} = 'on';
  mask_visibilities{triggersignal}='off';
  mask_visibilities{triggerlevel}='off';
  mask_visibilities{triggerslope}='off';
 case 'Signal triggering'
  mask_visibilities{triggerscope} = 'off';
  mask_visibilities{triggersample} = 'off';
  mask_visibilities{triggersignal}='on';
  mask_visibilities{triggerlevel}='on';
  mask_visibilities{triggerslope}='on';
 case {'FreeRun','Software triggering'}
  mask_visibilities{triggerscope} = 'off';
  mask_visibilities{triggersample} = 'off';
  mask_visibilities{triggersignal}='off';
  mask_visibilities{triggerlevel}='off';
  mask_visibilities{triggerslope}='off';
end
set_param(gcbh,'maskvisibilities',mask_visibilities);


function checkfname(fname)
if isempty(fname)
  error('A filename must be specified')
end
[p, n, e] = fileparts(fname);
if ~isempty(e)
  e(1) = [];                            % remove the leading dot
end
if ~isempty(find(n == '.'))             % multiple dots in filename
  error('Illegal filename "%s"', fname);
elseif length(n) > 8
  error('Filename "%s" must be at most 8 characters long', n);
elseif length(e) > 3
  error('File extension "%s" must be at most 3 characters long', e);
end

% If the original filename is foo\bar\baz.ext, p will now be foo\bar.
% We recursively check p for illegal names until it is empty.
% If the original file name is d:\foo\bar\baz.ext, eventually (on
% recursion) p will be d:\ and n will be empty. It is then time to stop.
if ~isempty(p) && ~isempty(n)
  checkfname(p);
end
