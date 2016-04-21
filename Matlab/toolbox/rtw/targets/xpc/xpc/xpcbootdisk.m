function xpcbootdisk(gui, force,actpropval)
% XPCBOOTDISK Create xPC Target Boot Floppy Disk
%
%   XPCBOOTDISK creates a xPC Target boot floppy for the current
%   Environment which has been updated before with UPDATEXPCENV. Creating an
%   xPC Target boot floppy consists of writing the correct bootable kernel
%   image on disk. The user is asked to insert an empty, formatted floppy disk
%   into the floppy drive.
%
%   NOTE: All existing files will be erased by XPCBOOTDISK. If the inserted
%   floppy already is an xPC Target boot floppy for the same environment
%   settings, XPCBOOTDISK exits without writing a new boot image to the
%   floppy. At the end, XPCBOOTDISK displays a summary of the creation
%   process.
%
%   See also SETXPCENV, GETXPCENV, UPDATEXPCENV, XPCSETUP.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.10.6.5 $ $Date: 2004/03/04 20:09:52 $

if nargin < 3
  xpcinit;
  load(xpcenvdata);
end
if nargin < 2
  force = 0;
end

if nargin < 1
  gui = 0;
end

if force
  gui = 0;
end

if ~force
  if gui
    h = questdlg(['Insert a formatted floppy disk into your host PC''s ' ...
                  'disk drive and click OK to continue'],                ...
                 'Bootdisk', 'OK', 'Cancel', 'OK');
    if ~strcmp(h,'OK')
      return
    end
  else
    disp(['Insert a formatted floppy disk into your host PC''s' 10 ...
          'disk drive and press a key to continue' 10 ' ']);
    pause
  end
end

if force && exist('A:\checksum.dat') == 2
  delete('A:\checksum.dat');
end

n = length(actpropval);

if nargin == 3
  fvisibiltystat = get(0, 'showhiddenhandles');
  set(0,'showhiddenhandles', 'on')
  fighandle = findobj(0, 'type', 'figure', 'tag', 'xpcmngr');
  set(0, 'showhiddenhandles', fvisibiltystat);
  figure(fighandle)
end

%check
if strcmp(actpropval{11},'RS232')
  checksum=sprintf('%s,%s,%s,%s,%s,%s,%s,%s',...
                   actpropval{1},...
                   actpropval{7},...
                   actpropval{8},...
                   actpropval{11},...
                   actpropval{13},...
                   actpropval{23},...
                   actpropval{24},...
                   actpropval{25});
else
  checksum=sprintf('%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s',...
                   actpropval{1},...
                   actpropval{7},...
                   actpropval{8},...
                   actpropval{14},...
                   actpropval{15},...
                   actpropval{16},...
                   actpropval{17},...
                   actpropval{18},...
                   actpropval{19},...
                   actpropval{20},...
                   actpropval{21},...
                   actpropval{23},...
                   actpropval{24},...
                   actpropval{25});
end

if exist('a:\checksum.dat','file')
  fid  = fopen('a:\checksum.dat','r');
  cont = fread(fid, '*char')';
  fclose(fid);
  if strcmp(checksum,cont)
    if gui
      showError(@warndlg, ...
                ['Inserted floppy is an xPC Target boot floppy disk '   ...
                 'for the current xPC Target environment. ',            ...
                 'Insert a formatted floppy disk into your host PC''s ' ...
                 'disk drive and then create the boot floppy disk.']);
    else
      disp(' ');
      disp(['Inserted floppy is an xPC Target boot floppy disk ' ...
            'for the current xPC Target environment']);
      disp(' ');
    end
    return
  end
end

[pathToKernel, origKernel] = getimgname(actpropval);

kernel = fullfile(pwd, origKernel);
copyfile(pathToKernel, kernel);
xpcpatch(kernel, actpropval);

if gui
  bar = waitbar(0, 'Please wait...');
  set(bar, 'Name', 'Creating xPC Target boot disk');
  waitbar(50/100);
end;

if strcmp(actpropval{25},'BootFloppy')
  success = bootdisk(kernel, gui);
end

if strcmp(actpropval{25},'DOSLoader')
  embDir = fullfile(xpcroot, 'target\kernel\embedded');
  copyfile(kernel, 'a:');
  if ~exist('a:\xpcboot.com','file')
    copyfile(fullfile(embDir, 'xpcboot.com'), 'a:');
  end
  if exist('a:\autoexec.bat','file')
    if exist('a:\autoexec.old','file')
      delete('a:\autoexec.old');
    end
    !ren a:\autoexec.bat autoexec.old
  end
  fid=fopen('a:\autoexec.bat','w');
  fprintf(fid,'xpcboot %s', origKernel);
  fclose(fid);
  success = 1;
end

delete(kernel);

if success
  fid = fopen('a:\checksum.dat','w');
  fwrite(fid,checksum);
  fclose(fid);
end

if gui
  waitbar(100/100);
  close(bar);
end;

function success = bootdisk(img, quiet)
% Write the bootdisk from the file img. Prints status if quiet == 0.
% Returns success (1) or failure (0).

% Assume failure; will reset if we succeed.
success = 0;

curr = pwd;
cd(fullfile(xpcroot, 'xpc', 'bin'));
if ~quiet
  fprintf(1,'Creating xPC Target boot disk ... please wait\n');
end
[s, out] = dos(['bootdisk ' img ' a:']);
if length(out)<85
  [s, out] = dos(['bootd16 ' img ' a:']);
end
if ~isempty(strfind(out, 'contiguous'))
  index = strfind(out, 'RTA');
  errMess = out( index : end);
  if quiet
    showError(@errordlg, errMess);
  else
    fprintf(1, '\nERROR: %s', errMess);
  end
elseif isempty(strfind(out,'writing boot sector...'))
  if quiet
    showError(@warndlg, ...
              ['Creation of xPC Target boot disk failed. ' ...
               'Floppy disk may not be inserted correctly or ' ...
               'floppy disk may be damaged']);
  else
    fprintf(1, ['\nERROR: Creation of xPC Target boot disk failed.\n' ...
                'Floppy disk may not be inserted correctly\n' ...
                'or floppy disk may be damaged\n\n']);
  end
else
  if ~quiet
    fprintf(1,'\nxPC Target boot disk successfully created\n\n');
  end
  success = 1;
end
cd(curr);

function showError(func, msg)
% Show the error using func (errordlg or warndlg). Resume execution when
% done.
h = func(msg);
set(h, 'CloseRequestFcn', 'uiresume(h)');
uiwait(h);

% EOF xpcbootdisk.m
