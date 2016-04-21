function [info]=genxml(varargin)
%GENXML  Generates an XML Document from a Simulink system
%
%
%   GENXML('SYS') generates an XML document SYS.xml and
%   PNG Image files of all system(s) in the current working
%   directory. The XML file contains the general desctiption
%   of the Simulink diagram.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.7.6.1 $  $Date: 2004/01/22 18:35:49 $

ni=nargin;

if (ni == 1)
  if ~isa(varargin{1}, 'char')
    error('Input Argument must be a character array of a Simulink Diagram Name');
    return;
  end
  xmlFlag=1;
end

if (ni == 2)
  if isa(varargin(2), 'char')
    error('Second argument MUST be a character');
    return;
  end
  if ~strcmpi(varargin(2), 'struct')
    error('Wrong Flag passed. The correct flag to return a structure is ''struct''');
    return;
  end

  xmlFlag=0;
end

system=varargin{1};
compilecom=[system,'([],[],[],''compile'');'];

global SYSNAME
SYSNAME=system;

try
  evalc(['pt=',system,'pt']);
catch
  error(lasterr);
  return;
end
global BLOCKNAME PARAMNAME;

BLOCKNAME=cellstr(strvcat(1,pt.blockname));BLOCKNAME=BLOCKNAME(2:end);
PARAMNAME=cellstr(strvcat(1,pt.paramname));PARAMNAME=PARAMNAME(2:end);

mdlClosed = isempty(strmatch(system, find_system('type','block_diagram'), ...
                             'exact'));
try
  evalc(compilecom);
catch
  error('Can''t compile model');
  return;
end
termcom=[system,'([],[],[],''term'')'];
dirtyFlag = get_param(system, 'Dirty');
mdlbrowsestate=get_param(system,'ModelBrowserVisibility');
set_param(system,'ModelBrowserVisibility','off');
if (xmlFlag)
  disp(['###Generating.........XML version 1.0 writing to ',system,'.xml']);
  fid=fopen([system,'.xml'],'w');
  fprintf(fid,'<?xml version="1.0"?>\n');
  fprintf(fid,'\t<Rootsystem>\n');
  getsysinfo(system,[],fid);
  fprintf(fid,'\t</Rootsystem>\n');
  fclose(fid);
end

if ~(xmlFlag)
  info=getsysinfo(system,[]);
end
evalc(termcom);
set_param(system,'Dirty', dirtyFlag);
if mdlClosed
  close_system(system, 0);
end
%-----------------------------------------------------------------------
function info=getsysinfo(varargin)

ni=nargin;
if (ni == 3)
  fid = varargin{3};
  xmlFlag=1;
else
  xmlFlag=0;
end

system = varargin{1};
info   = varargin{2};

subsystems = find_system(system,                        ...
                         'LookUnderMasks', 'on',        ...
                         'FollowLinks',    'on',        ...
                         'BlockType',      'SubSystem', ...
                         'Parent',          system);
Taggedsubs = find_system(system,                        ...
                         'RegExp',         'On',        ...
                         'Description',    'noXML',     ...
                         'blocktype',      'SubSystem', ...
                         'Parent',         system);
mdlbrowsestate=get_param(system,'ModelBrowserVisibility');
if strcmp(mdlbrowsestate,'on')
  set_param(system,'ModelBrowserVisibility','off');
end

for ii=1:length(Taggedsubs)
  subid=strmatch(Taggedsubs{ii},subsystems','exact');
  temarry=1:length(subsystems);
  indarry=ones(size(temarry));
  indarry(subid)=0;
  subsystems=subsystems(logical(indarry));
end


msktype=get_param(subsystems,'MaskType');
trueindx=find(~(strcmpi(msktype,'Stateflow'))==1);
subsystems=subsystems(trueindx);
k=length(info)+1;
info(k).Children=subsystems;
info(k).Name=system;
formatname=system;

if (findstr(sprintf('\n'),formatname))
  formatname=strrep(formatname,sprintf('\n'),' ');
end

index=find([system,'/']=='/');
filename=[system(1:index(1)-1),'_s',num2str(k-1)];
info(k).PNG=[filename,'.png'];
open_system(system,'force');
print(['-s',system],'-dbitmap','tmp.bmp');
[X,map]=imread('tmp.bmp','BMP');
info(k).ImgSize=size(X);
global BLOCKNAME PARAMNAME;
xpcparam.blockname=BLOCKNAME;
xpcparam.paramname=PARAMNAME;
info(1).xpcparam=xpcparam;
if (xmlFlag)
  %------------------write ALL systems node to XML
  fprintf(fid,'\t\t<System>\n');
  fprintf(fid,'\t\t\t<Name>');
  fprintf(fid,formatname);
  fprintf(fid,'</Name>\n');
  fprintf(fid,'\t\t\t<Children>');
  fprintf(fid,num2str(length(info(k).Children)));
  fprintf(fid,'</Children>\n');
  fprintf(fid,'\t\t\t<PNGFileName>');
  fprintf(fid,info(k).PNG);
  fprintf(fid,'</PNGFileName>\n');
  fprintf(fid,'\t\t\t<Imgheight>');
  fprintf(fid,num2str(info(k).ImgSize(1)));
  fprintf(fid,'</Imgheight>\n');
  fprintf(fid,'\t\t\t<ImgWidth>');
  fprintf(fid,num2str(info(k).ImgSize(2)));
  fprintf(fid,'</ImgWidth>\n');
  fprintf(fid,'\t\t\t\t<Blocks>\n');
  %------------------------------------
end

dos('del tmp.bmp')
%delete('tmp.bmp');
imwrite(X,map,[filename,'.png'],'PNG');
disp(['###Generating.........PNG Imagefile ',filename,'.png']);
if ~isempty(find(system=='/'))
  close_system(system);
end
blockname=find_system(system,'followlinks','on','lookundermasks','all','Type','block','Parent',system);
% get block parameter information
info(k).DialogParameters= get_param(blockname,'DialogParameters');
info(k).BlockType= get_param(blockname,'BlockType');
info(k).BlockName= get_param(system,'Blocks');
if (xmlFlag)
  info(k).Object=getObjects(system,fid);
  fprintf(fid,'\t\t</System>\n');%end of each system node
else
  info(k).Object=getObjects(system);
end
for i=1:length(subsystems)
  if (xmlFlag)
    info=getsysinfo(subsystems{i},info,fid);
  else
    info=getsysinfo(subsystems{i},info);
  end
end
%--------------------------------------------------------------------
function data=getObjects(varargin)
%getObjects(system,fid);
ni=nargin;
if (ni == 2)
  fid = varargin{2};
  xmlFlag=1;
else
  xmlFlag=0;
end

model = varargin{1};
%blockname=find_system(model,'Type','block','Parent',model);
blockname=find_system(model,'followlinks','on','lookundermasks','all','Type','block','parent',model);
k=1;

actWidth=4;
DrawWidth=2;
global SYSNAME
% get all the information for blocks
positionCell = get_param(blockname','Position');
isSrcCell    = get_param(blockname', 'PortHandles');
if isempty(blockname)
  data.sigtwidth = [];
  data.Name=[];
  data.ObjectType=[];
  data.ActualPosition=[];
  data.ActivePosition= [];
  data.DrawPosition= [];
end

for i=1:length(positionCell)
  formatname = blockname{i};
  isSrc      = isSrcCell{k};
  if (findstr(sprintf('\n'),formatname))
    formatname = strrep(formatname,sprintf('\n'),' ');
  end
  formatname=formatname(length(SYSNAME)+2:end);

  data(k).Name=formatname;
  data(k).ActualPosition = positionCell{i};
  data(k).ObjectType     = 'Block';
  data(k).ObjectTypeInfo = get_param(blockname{i},'BlockType');
  data(k).ActivePosition = data(k).ActualPosition;
  data(k).DrawPosition   = data(k).ActivePosition;
  data(k).ObjectCluster  = i;
  data(k).isSrc          = isempty(isSrc.Inport) && ~isempty(isSrc.Outport);
  if (xmlFlag)
    %---------------Write Block Node to XML-----------------
    fprintf(fid,'\t\t\t\t\t<Block>\n');
    fprintf(fid,'\t\t\t\t\t\t<Name>');
    fprintf(fid,formatname);
    fprintf(fid,'</Name>\n');
    fprintf(fid,'\t\t\t\t\t\t<BlockType>');
    fprintf(fid,get_param(data(k).Name,'BlockType'));
    fprintf(fid,'</BlockType>\n');
    fprintf(fid,'\t\t\t\t\t\t<x1Pos>');
    fprintf(fid,num2str(data(k).ActualPosition(1)-1));
    fprintf(fid,'</x1Pos>\n');
    fprintf(fid,'\t\t\t\t\t\t<x2Pos>');
    fprintf(fid,num2str(data(k).ActualPosition(2)-1));
    fprintf(fid,'</x2Pos>\n');
    fprintf(fid,'\t\t\t\t\t\t<y1Pos>');
    fprintf(fid,num2str(data(k).ActualPosition(3)-1));
    fprintf(fid,'</y1Pos>\n');
    fprintf(fid,'\t\t\t\t\t\t<y2Pos>');
    fprintf(fid,num2str(data(k).ActualPosition(4)-1));
    fprintf(fid,'</y2Pos>\n');
    global xpcparam
    if isempty(strmatch(formatname,xpcparam,'exact'))
      fprintf(fid,'\t\t\t\t\t\t<Tunable>');
      fprintf(fid,'No');
      fprintf(fid,'</Tunable>\n');
    else
      fprintf(fid,'\t\t\t\t\t\t<Tunable>');
      fprintf(fid,'Yes');
      fprintf(fid,'</Tunable>\n');
    end
    fprintf(fid,'\t\t\t\t\t\t<BlockParameters>\n');
    %--------------------------------------------------------
    if ~strcmp(get_param(data(k).Name,'BlockType'),'SubSystem')
      parameters=get_param(blockname{i},'DialogParameters');
      if ~isempty(parameters)
        paramNames=fieldnames(parameters);
        %---------------Write Parameter Node to xML-----------------
        for j=1:length(paramNames)
          dfield=getfield(parameters,paramNames{j});
          dfieldType=fieldnames(dfield);
          fprintf(fid,'\t\t\t\t\t\t\t<Parameter>\n');
          fprintf(fid,'\t\t\t\t\t\t\t\t<Name>');
          fprintf(fid,paramNames{j});
          fprintf(fid,'</Name>\n');
          fprintf(fid,'\t\t\t\t\t\t\t\t<Prompt>');
          fprintf(fid,dfield.Prompt);
          fprintf(fid,'</Prompt>\n');
          fprintf(fid,'\t\t\t\t\t\t\t\t<Type>');
          fprintf(fid,dfield.Type);
          fprintf(fid,'</Type>\n');
          fprintf(fid,'\t\t\t\t\t\t\t\t<DlgActive>');
          if length(dfield.Attributes)>1
            tmpstr='on';
          else
            tmpstr='off';
          end
          fprintf(fid,tmpstr);
          fprintf(fid,'</DlgActive>\n');
          fprintf(fid,'\t\t\t\t\t\t\t\t<Enums>\n');
          Enums=dfield.Enum;
          for jj=1:length(Enums)
            fprintf(fid,'\t\t\t\t\t\t\t\t\t<Enum>\n');
            fprintf(fid,'\t\t\t\t\t\t\t\t\t\t<Name>');
            fprintf(fid,Enums{jj});
            fprintf(fid,'</Name>\n');
            fprintf(fid,'\t\t\t\t\t\t\t\t\t</Enum>\n');
          end % jj=1:length(Enums)
          fprintf(fid,'\t\t\t\t\t\t\t\t</Enums>\n');
          fprintf(fid,'\t\t\t\t\t\t\t</Parameter>\n');
        end % j=1:length(paramNames)
            %--------------------------------------------------------
      end %~isempty(parameters)
    end %~strcmp
    fprintf(fid,'\t\t\t\t\t\t</BlockParameters>\n'); %end of blkparam node
    fprintf(fid,'\t\t\t\t\t</Block>\n');    %end of each child blk node
  end % (xmlFlag)
  k=k+1;
end % i=1:length(positionCell)
if (xmlFlag)
  fprintf(fid,'\t\t\t\t</Blocks>\n');    %end of each blocks node
  fprintf(fid,'\t\t\t\t<SignalLines>\n');  %Begin of Signallines node
end % (xmlFlag)

% get all the information for signals
lines=get_param(model,'Lines');
linecat=cat(1,lines.SrcBlock);
if ~isempty(linecat)
  Lidx=find(linecat~=-1);
  lines=lines(Lidx);
end
for i=1:length(lines)
  tmp=getalllines(lines(i),[]);
  k1=k;
  for i1= 1:size(tmp,1)
    %%port info
    msktype=get_param(lines(i).SrcBlock,'MaskType');
    blksrcph=get_param(lines(i).SrcBlock,'Porthandles');
    blkporthd=blksrcph.Outport;
    Numoutputports=length(blkporthd);
    portwidth=get_param(blkporthd(str2num(lines(i).SrcPort)),'CompiledPortWidth');
    name=getfullname(lines(i).SrcBlock);
    if (findstr(sprintf('\n'),name))
      name=strrep(name,sprintf('\n'),' ');
    end
    if ~(strcmpi(msktype,'Stateflow'))
      if (Numoutputports > 1)
        name=[name,'/p',num2str(lines(i).SrcPort)];
      end
    else
      name=[name,'/',' SFunction ','/p',num2str(blkout2sfunout(lines(i).SrcBlock,str2num(lines(i).SrcPort)))];
    end
    data(k).sigtwidth = portwidth;
    name=name(length(SYSNAME)+2:end);
    if tmp(i1,1)==1 % x direction
      linePos= tmp(i1,2:end);
      data(k).Name=name;
      data(k).ObjectType='LineX';
      data(k).ActualPosition=linePos+1;
      data(k).ActivePosition= [linePos(1)-actWidth, linePos(2)-actWidth, linePos(3)+actWidth, linePos(4)+actWidth];
      data(k).DrawPosition= data(k).ActualPosition;
    elseif tmp(i1,1)==2 % y direction
      linePos= tmp(i1,2:end);
      data(k).Name=name;
      data(k).ObjectType='LineY';
      data(k).ActualPosition= linePos+1;
      data(k).ActivePosition= [linePos(1)-actWidth, linePos(2)-actWidth, linePos(3)+actWidth, linePos(4)+actWidth];
      data(k).DrawPosition= data(k).ActualPosition;
    elseif tmp(i1,1)==3 % diagnal direction
      linePos= tmp(i1,2:end);
      data(k).Name=name;
      data(k).ObjectType='nLine';
      data(k).ActualPosition= linePos+1;
      data(k).ActivePosition= [linePos(1)-actWidth, linePos(2)-actWidth, linePos(3)+actWidth, linePos(4)+actWidth];
      data(k).DrawPosition= data(k).ActualPosition;
    end % tmp(i1,1)==1
    if (xmlFlag)
      %-----------Write Signal elements to XML-------------
      fprintf(fid,'\t\t\t\t\t<Signal>\n'); %begin of each Signal node
      fprintf(fid,'\t\t\t\t\t\t<Name>');
      fprintf(fid,name);
      fprintf(fid,'</Name>\n');
      fprintf(fid,'\t\t\t\t\t\t<SignalWidth>');
      fprintf(fid,num2str(portwidth));
      fprintf(fid,'</SignalWidth>\n');
      fprintf(fid,'\t\t\t\t\t\t<LineMode>');
      fprintf(fid,data(k).ObjectType);
      fprintf(fid,'</LineMode>\n');
      fprintf(fid,'\t\t\t\t\t\t<x1Pos>');
      fprintf(fid,num2str(data(k).ActualPosition(1)));
      fprintf(fid,'</x1Pos>\n');
      fprintf(fid,'\t\t\t\t\t\t<y1Pos>');
      fprintf(fid,num2str(data(k).ActualPosition(2)));
      fprintf(fid,'</y1Pos>\n');
      fprintf(fid,'\t\t\t\t\t\t<x2Pos>');
      fprintf(fid,num2str(data(k).ActualPosition(3)));
      fprintf(fid,'</x2Pos>\n');
      fprintf(fid,'\t\t\t\t\t\t<y2Pos>');
      fprintf(fid,num2str(data(k).ActualPosition(4)));
      fprintf(fid,'</y2Pos>\n');
      fprintf(fid,'\t\t\t\t\t</Signal>\n');
      %---------------------------------------------------------
    end % (xmlFlag)
    k=k+1;
  end % i1= 1:size(tmp,1)
  for j=k1:k-1
    data(j).ObjectCluster=k1:k-1;
  end
end %i=1:length(lines)

if (xmlFlag)
  fprintf(fid,'\t\t\t\t</SignalLines>\n');
end

%---------------------------------------------------------
function lines=getalllines(line, lines)
%gets all line positions
for i=1:size(line.Points,1)-1
  sline=line.Points(i:i+1,:);
  % x direction
  if sline(1,2)==sline(2,2)
    if sline(1,1)>sline(2,1)
      sline=flipud(sline);
    end
    lines=[lines;[1,sline(1,1),sline(1,2),sline(2,1),sline(2,2)]];
  end
  % y direction
  if sline(1,1)==sline(2,1)
    if sline(1,2)>sline(2,2)
      sline=flipud(sline);
    end
    lines=[lines;[2,sline(1,1),sline(1,2),sline(2,1),sline(2,2)]];
  end
  %diagnal line
  if isempty(find(diff(sline)==0))
    if sline(1,2)>sline(2,2)
      sline=flipud(sline);
    end
    lines=[lines;[3,sline(1,1),sline(1,2),sline(2,1),sline(2,2)]];
  end
end
if ~isempty(line.Branch)
  for i=1:length(line.Branch)
    lines=getalllines(line.Branch(i),lines);
  end
end
