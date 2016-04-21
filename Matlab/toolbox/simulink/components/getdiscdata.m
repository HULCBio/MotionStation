function discData = getdiscdata(sys, varargin)
%GETDISCDATA gets model data for model discretizer
%

% $Revision: 1.8.4.2 $ $Date: 2004/04/06 01:10:47 $
% Copyright 1990-2003 The MathWorks, Inc.

%Check if model is open. If not, then open it; otherwise, give an error message.
if iscell(sys)
    model = sys{1};    
else   
    model = sys;
end
loaded = 0;
if isstr(model)
   slash = findstr(model,'/');
   if ~isempty(slash)
       model = model(1:slash-1);
   end    
   if isempty(find_system('SearchDepth', 0, 'Name', model)) ...
       &  isempty(find_system('SearchDepth', 0, 'handle', model))
     if exist(model) == 4
        load_system(model);
        loaded = 1;
     else
        error(sprintf('The model ''%s'' cannot be found, you must open the model first.', model));
     end
   end
end
model = get_param(bdroot(model),'name');
isLibrary = strcmp(get_param(model, 'BlockDiagramType'), 'library');
if isLibrary,
    set_param(model, 'Lock', 'off');
end


try
    disc_configurable_lib = get_param(model,'disc_configurable_lib');
    load_system(disc_configurable_lib);
    hasConfigurable = 0;
catch
    disc_configurable_lib = 'none';
    hasConfigurable = 1;
end

libName = disc_configurable_lib;
if nargin == 2
    tempsys = varargin{1};
else
    tempsys = new_system;
end
% open_system(tempsys);

%find blocks in 'model'
blocks = find_system(model);
discRules = rules;

import java.lang.*;
import java.util.Vector;
%discData = javaArray('java.lang.Object',length(blocks));
discData_tmp = Vector;

type = get_param(model,'type');
if strcmpi(type,'block_diagram')
       rowData = javaArray('java.lang.Object',12);
       hasContinuous = iscontinuous(blocks{1},discRules);
       rowData(1) = Integer(hasContinuous);                     %has continuous blocks?
       rowData(2) = Integer(0);                                 %Is this block discretizable?
       rowData(3) = java.lang.Double(get_param(blocks{1},'handle'));      %Block handle
       rowData(4) = String(blocks{1});                          %Block full path name
       rowData(5) = String('');      %Parent
       rowData(6) = String(get_param(blocks(1),'type'));      %Block type
       rowData(7) = String('');      %Mask type
       rowData(8) = String('');      %Mask
       rowData(9) = String('');      %Link status
       rowData(10) = String(get_param(blocks(1),'Name'));
       
       rowData(11) = String(libName);                           %configurable library name
       rowData(12) = String(get_param(tempsys, 'name'));        %temporary mdl name for storing continuous blocks       
       discData_tmp.addElement(rowData); 
else
       i = 1;
       rowData = javaArray('java.lang.Object',13);
       isconf = isconfigurable(libName, blocks{i});
       
       if isconf
           hasContinuous = 1;
           isDiscretizable = 0;
       else
           hasContinuous = iscontinuous(blocks{i},discRules);
           [isDiscretizable,discfcn] = chkrules(blocks{i},discRules);
       end
       rowData(1) = Integer(hasContinuous);                     %has continuous blocks?
       rowData(2) = Integer(isDiscretizable);                   %Is this block discretizable?       
       rowData(3) = java.lang.Double(get_param(blocks{i},'handle'));      %Block handle
       rowData(4) = String(blocks{i});                          %Block full path name
       rowData(5) = String(get_param(blocks{i},'Parent'));      %Parent
       rowData(6) = String(get_param(blocks{i},'BlockType'));   %Block type
       rowData(7) = String(get_param(blocks{i},'MaskType'));    %Mask type       
       rowData(8) = String(get_param(blocks{i},'Mask'));        %Mask
       if isconf
           rowData(8) = String(get_param(get_param(blocks{i},'templateblock'),'memberblocks'));        %member blocks
       end
       rowData(9) = String(get_param(blocks{i},'LinkStatus'));  %Link status
       rowData(10) = String(get_param(blocks(i),'Name'));       
       if isconf
           rowData(11) = String(getContinuousBlk(get_param(blocks{i}, 'templateblock')));
       elseif isDiscretizable
           srcBlk = addToTemp(tempsys, blocks{i});
           rowData(11) =   String(srcBlk);                               % source block           
       else
           rowData(11) = String('');
       end
       rowData(12) = Integer(isconf);             % is a configurable subsystem
       rowData(13) = Integer(0);                  % is inside a configurable subsystem
       
       discData_tmp.addElement(rowData);
end

id = 2;
for i=2:length(blocks),
       
       isconf = isconfigurable(libName, blocks{i});
       isParentConf = isconfigurable(libName, get_param(blocks{i},'Parent'));
       
       if isconf
           hasContinuous = 1;
           isDiscretizable = 0;
       elseif isParentConf & strcmpi(get_param(blocks{i},'BlockType'), 'subsystem')
           hasContinuous = 1;
           isDiscretizable = 0;
       else
           hasContinuous = iscontinuous(blocks{i},discRules);
           [isDiscretizable,discfcn] = chkrules(blocks{i},discRules);
       end
       %load continuous blocks only
       if hasContinuous == 0 & ~hasVariableTransportDelay(blocks{i})
           continue;
       end
       rowData = javaArray('java.lang.Object',13);
       rowData(1) = Integer(hasContinuous);                    %has continuous blocks?
       rowData(2) = Integer(isDiscretizable);                   %Is this block discretizable?       
       rowData(3) = java.lang.Double(get_param(blocks{i},'handle'));      %Block handle
       rowData(4) = String(blocks{i});                          %Block full path name
       rowData(5) = String(get_param(blocks{i},'Parent'));      %Parent
       rowData(6) = String(get_param(blocks{i},'BlockType'));   %Block type
       if(isDiscretizable)
           rowData(6) = String('block');  % Block type
       end
       rowData(7) = String(get_param(blocks{i},'MaskType'));    %Mask type       
       rowData(8) = String(get_param(blocks{i},'Mask'));        %Mask
       if isconf
%            rowData(8) = String(get_param(get_param(blocks{i},'templateblock'),'memberblocks'));        %member blocks
           rowData(8) = String(get_param(blocks{i},'memberblocks'));        %member blocks
       end
       rowData(9) = String(get_param(blocks{i},'LinkStatus'));  %Link status
       rowData(10) = String(get_param(blocks(i),'Name'));       
       if isconf
           rowData(11) = String(getContinuousBlk(get_param(blocks{i}, 'templateblock')));
       elseif isDiscretizable
           srcBlk = addToTemp(tempsys, blocks{i});
           rowData(11) =   String(srcBlk);                               % source block           
       else
           rowData(11) = String('');
       end
       rowData(12) = Integer(isconf);             % is a configurable subsystem
       rowData(13) = Integer(0);                  % is inside a configurable subsystem
       
       
       if isParentConf & ~strcmpi(get_param(blocks{i},'BlockType'), 'subsystem')
           continue;
       end
       if isParentConf & strcmpi(get_param(blocks{i},'BlockType'), 'subsystem')
           data = getConfBlockData(blocks{i}, libName, tempsys);
           for n = 1:length(data),
               discData_tmp.addElement(data{n});
               id = id + 1;
           end
           continue;
       end
       discData_tmp.addElement(rowData);
       id = id + 1;

end

if nargout > 0
    discData = javaArray('java.lang.Object',discData_tmp.size);
    discData_tmp.copyInto(discData);
end

%end getdiscdata

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% recursively get block properties from a configurable subsystem
% block - the current block choice in a configurable subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = getConfBlockData(block, libName, tempSys)

import java.lang.*;
conBlk = getContinuousBlk(get_param(get_param(block,'parent'), 'templateblock'));
blocksInCon = find_system(conBlk);

blocks = find_system(block, 'followlinks', 'on', 'searchdepth', 1);

blocks = blocks(2:length(blocks));
id = 0;
data = {};
for k = 2:length(blocksInCon),
   blockInCur = getBlkInCur(blocks, get_param(blocksInCon{k},'name'));
   isconf = isconfigurable(libName, blocksInCon{k});

       rowData = javaArray('java.lang.Object',13);
       if isconf
           hasContinuous = 1;
           isDiscretizable = 0;
       else
           hasContinuous = iscontinuous(blocksInCon{k},rules);
           [isDiscretizable,discfcn] = chkrules(blocksInCon{k},rules);
       end
       rowData(1) = Integer(hasContinuous);                     %has continuous blocks?
       rowData(2) = Integer(isDiscretizable);                   %Is this block discretizable?       
       rowData(3) = java.lang.Double(get_param(blockInCur,'handle'));      %Block handle
       rowData(4) = String(blockInCur);                          %Block full path name
       rowData(5) = String(get_param(get_param(blockInCur,'Parent'),'parent'));      %Parent
       rowData(6) = String(get_param(blockInCur,'BlockType'));   %Block type
       rowData(7) = String(get_param(blockInCur,'MaskType'));    %Mask type
       rowData(8) = String(get_param(blockInCur,'Mask'));        %Mask
       if isconf
           rowData(8) = String(get_param(get_param(blockInCur,'templateblock'),'memberblocks'));        %member blocks
       end
       rowData(9) = String(get_param(blockInCur,'LinkStatus'));  %Link status
       rowData(10) = String(get_param(blockInCur,'Name'));       %name of block       
       if isDiscretizable
           srcBlk = addToTemp(tempSys, blocksInCon{k});
           rowData(11) =   String(srcBlk);                               % source block
       else
           rowData(11) = String('');                            % source block
       end
       if isconf
           rowData(12) = Integer(1);    % is a configurable subsystem?
       else
           rowData(12) = Integer(0);    % is a configurable subsystem?
       end
       rowData(13) = Integer(1);    % is inside a configurable subsystem

       id = id + 1;
       data{id} = rowData;

       isParentConf = isconfigurable(libName, get_param(blockInCur,'Parent'));       
       if isParentConf & strcmpi(get_param(blockInCur,'BlockType'), 'subsystem')
           data1 = getConfBlockData(blockInCur, libName, tempSys);
           for n = 1:length(data1),
               id = id + 1;
               data{id} = data1{n};
           end
       end
end

%end getConfBlockData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the block in current block choice matching the name in continuous member block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function block = getBlkInCur(blocks, matchName)

block = '';
for k = 1:length(blocks)
    if strcmp(get_param(blocks{k}, 'name'), matchName)
        block = blocks{k};
        break;
    end
end

%end getBlkInCur

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the continuous block (full path name) in a configurable subsystem 'block'
% block - the template block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function conBlk = getContinuousBlk(block)

member = get_param(block,'memberblocks');
[t,r] = strtok(member,',');
continuousName = '';
while ~isempty(r)
    if isempty(findstr(lower(t),'discrete version'))
        continuousName = t;
        break;
    end
end
if isempty(continuousName)
    conBlk = '';
else
    conBlk = findMemberBlk(continuousName, bdroot(block));
end

%end getContinuousBlk

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add a block 'src' to the specified temporary model 'tmpSys'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function block = addToTemp(tmpSys, src)

if strcmpi(tmpSys, 'none')
    block='';
    return;
end

blocks = find_system(getfullname(tmpSys), 'searchdepth', 1);
names = zeros(length(blocks) - 1, 1);

maxy = 0;
for k = 2:length(blocks),
    names(k-1) = str2num(get_param(blocks{k},'name'));
    pos = get_param(blocks{k}, 'position');
    if pos(4) > maxy
        maxy = pos(4);
    end    
end

maxname = max(names);
if length(names) > 0
    maxname = max(names);
else
    maxname = 0;
end
x = 50;
y = 50;

if maxname > 0
    lastblock = [get_param(tmpSys, 'name'),'/',num2str(maxname)];
    pos = get_param(lastblock, 'position');
    x = pos(3) + 50;
    y = pos(2);
end
if x > 800
    x = 50;
    y = maxy + 50;
end

if maxname == 0
    newname = '1';
else
    newname = num2str(maxname + 1);    
end

block = [get_param(tmpSys, 'name'),'/',newname];
pos = get_param(src, 'position');
w = pos(3) - pos(1);
h = pos(4) - pos(2);
pos = [x, y, x+w, y+h];
add_block(src, block, 'position',pos,'showname','on');

%end addToTemp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blkName - a string in which '\n' is replaced by white-space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function block = findMemberBlk(blkName,sysName)

tmpBlks = find_system(sysName,'searchdepth',1);
block = '';
for jj = 2:length(tmpBlks),
    tmpName = get_param(tmpBlks{jj},'name');
    if strcmpi(strrep(tmpName,sprintf('\n'),' '), blkName)
        block = tmpBlks{jj};
    end
end
%end findMemberBlk

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Check if there are any variable transport delay blocks in the block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = hasVariableTransportDelay(blk)

if isempty(find_system(blk, 'BlockType', 'VariableTransportDelay'))
    ret = 0;
else
    ret = 1;
end

% end function hasVariableTransportDelay


%[EOF] getdiscdata.m


