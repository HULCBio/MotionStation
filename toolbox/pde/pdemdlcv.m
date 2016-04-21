function pdemdlcv(infile,outfile)
%PDEMDLCV Convert PDE Toolbox Model M-files for use in MATLAB 5.
%   PDEMDLCV INFILE OUTFILE converts the PDE Toolbox version 1.0
%   Model M-file to a Model M-file that can be used with the MATLAB 5
%   compliant version of the PDE Toolbox. The new Model M-file is saved
%   in OUTFILE.

%   Magnus Ringh 10-04-96.
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2003/11/01 04:28:22 $

% Error checks:
if nargin~=2
  error('PDE:pdemdlcv:nargin', 'Both input file and output file must be specified.')
end
if ~(ischar(infile) && ischar(outfile))
  error('PDE:pdemdlcv:InputsNotStrings',...
      'INFILE and OUTFILE must be strings.')
end
fidin = fopen(infile,'r');
if fidin==-1
  error('PDE:pdemdlcv:CannotOpenInputFile', ['Couldn''t open ', infile])
end
n = length(outfile);
if n>2
  if ~strcmp(lower(outfile(n-1:n)),'.m')
    outfile=[outfile '.m'];
  end
else
  outfile=[outfile '.m'];
end
if strcmp(infile,outfile)
  fclose(fidin);
  error('PDE:pdemdlcv:InputsNotDistinct',...
      'OUTFILE must not be the same file as the INFILE.')
end
fidout = fopen(outfile,'w');
if fidout==-1
  fclose(fidin);
  error('PDE:pdemdlcv:CannotOpenOutputFile', ['Couldn''t open ', outfile])
end

% Read all lines and modify if necessary;
while 1
  line = fgetl(fidin);
  if ~ischar(line)
    break
  end
  % Call pdeinit with output arguments
  if strcmp(line,'pdeinit;')
    line = '[pde_fig,ax]=pdeinit;';
  end
  % Replace AspectRatio with DataAspectRatio
  k = findstr(line,'Aspect');
  if ~isempty(k)
    lb = find(line=='[');
    rb = find(line==']');
    oar = str2double(line(lb:rb));
    oar = oar(2); % Old data ratio
    line = sprintf('set(ax,''DataAspectRatio'',[1 %.17g 1])',oar);
    fprintf(fidout,[line,'\n']);
    line = 'set(ax,''PlotBoxAspectRatio'',[1.5 1 1])';
  end
  % Replace 'grid on;' with 'pdetool('gridon','on')'
  if strcmp(line,'grid on;')
    line = 'pdetool(''gridon'',''on'')';
  end
  % Replace 'pdetool('snapon');' with 'pdetool('snapon','on')'
  if strcmp(line,'pdetool(''snapon'');')
    line = 'pdetool(''snapon'',''on'')';
  end
  % Remove the lines 'pde_fig=gca;','ax=gca;',
  % 'gridh=findobj(get(pde_fig,''Children''),''Tag'',''PDEGrid'');', and
  % 'set(gridh,''Checked'',''on'')'.
  if ~(strcmp(line,'pde_fig=gcf;') || strcmp(line,'ax=gca;') ||...
        strcmp(line,...
        'gridh=findobj(get(pde_fig,''Children''),''Tag'',''PDEGrid'');') ||...
        strcmp(line,'set(gridh,''Checked'',''on'')'))
    line = strrep(line,'%','%%');
    fprintf(fidout,[line,'\n']);
  end
end

fclose(fidin);
fclose(fidout);

