function [sestring,icstring,sostring,nistring,numse,numso,numni] = getsys(figtitle),
%GETSYS Get a DEE block's system definition.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.15 $
%   Revised Karen D. Gondoly 7-12-96

%************************************************************************
% check to see if this system was prviously defined and update sestring,
% icstring, sostring and nistring appropriately
%************************************************************************


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update sestring and icstring and deparse sestring
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count = 1;
intgBlocks=find_system(figtitle,'SearchDepth',1,'BlockType','Integrator');
fcnBlocks=strrep(intgBlocks,'Integ','x');
numse=length(intgBlocks);
sestring=cell(size(fcnBlocks));
icstring=cell(size(intgBlocks));
for i=1:numse,
  sestring{i} = get_param(fcnBlocks{i},'Expr');
  icstring{i} = get_param(intgBlocks{i},'InitialCondition');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update nistring, compute numni and offset to pass to dparseit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MuxStr     = get_param([figtitle,'/SysMux'],'inputs');
muxputs    = str2num(MuxStr);
inBlocks   = find_system(figtitle,'SearchDepth',1,'BlockType','Inport');
if ~isempty(inBlocks),
  numni    = muxputs-numse;
  nistring = num2str(numni);
else
  numni    = 0;
  nistring = '0';
end

offset = numni;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deparse sestring - this has to come after offset is defined since
% offset is a parameter needed by dparseit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmpstring=cell(size(fcnBlocks));
for i=1:numse,
  sestring{i}=dparseit(sestring{i},offset);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update sostring and deparse the equations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outBlocks = find_system(figtitle,'SearchDepth',1,'BlockType','Outport');
fcnBlocks = strrep(outBlocks,'Port','y');
numso     = length(outBlocks);
sostring=cell(size(outBlocks));
for i=1:numso,
  sostring{i} = dparseit(get_param(fcnBlocks{i},'Expr'),offset);
end
