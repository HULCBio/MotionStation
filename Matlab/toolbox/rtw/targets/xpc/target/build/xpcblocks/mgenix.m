function [initData, offset8255, control8255]=mgenix(flag, fileName, ref, boardType)

% MGENIX - InitFcn and Mask Initialization for 8255 boards used to initialize Genix.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/03/25 04:10:03 $

persistent pool

if flag==1
  pool=[];
end

if flag==2

  switch boardType

   case 1
    maskdisplay='disp(''CIO-DIO24\nComputerBoards\nGenix'');';
    maskdescription=['CIO-DIO24',10,'ComputerBoards',10,'Genix'];
    boardref=['ref',num2str(ref)];
    control8255=130;
    offset8255=0;
   case 2
    maskdisplay='disp(''PCI-DIO24\nComputerBoards\nGenix'');';
    maskdescription=['PCI-DIO24',10,'ComputerBoards',10,'Genix'];
    boardref='ref';
    if length(ref)==2
      ref=1000*ref(1)+ref(2);
    end
    if ref>=0
      boardref=[boardref,num2str(ref)];
    end
    control8255=130;
    offset8255=0;
  end

  set_param(gcb,'MaskDisplay',maskdisplay);
  set_param(gcb,'MaskDescription',maskdescription);

  boardtype=['btype',num2str(boardType)];

  if ~isfield(pool,boardtype)
    eval(['pool.',boardtype,'=[];']);
  end
  level1=getfield(pool,boardtype);
  if ~isfield(level1,boardref)
    eval(['level1.',boardref,'=1;']);
  else
    error('only one block per physical board allowed');
  end

  initData=[];
  if ~isempty(fileName)
    if isempty(find(fileName=='.'))
      fileName=[fileName,'.rkb'];
    end
    if ~exist(fileName,'file')
      error(['Genix initialization file ',fileName,' not found']);
    end
    fid= fopen(fileName);
    if fid<0
      error(['unable to open Genix initialization file ',fileName]);
    end
    initData= fread(fid, [1, inf]);
    fclose(fid);
  end

  pool=setfield(pool,boardtype,level1);

end
