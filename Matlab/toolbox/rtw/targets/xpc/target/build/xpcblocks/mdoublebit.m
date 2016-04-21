function [bitpatterns, dtypes, maskdisplay]=mdoublebit(bitpatterns, dtypes, type)

% MDOUBLEBIT Mask Initialization function for CAN bit-(un)packing blocks

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.4.4.1 $ $Date: 2004/03/04 20:09:38 $



if ~isa(bitpatterns,'cell')
  error('Bit Pattern parameter must be a cell array');
end
if size(bitpatterns,1)>1
  error('Bit Pattern parameter must be a row-vector cell array');
end
if type==1
  if ~isa(dtypes,'cell')
    error('Data Types parameter must be a cell array');
  end
  if size(dtypes,1)>1
    error('Data Types parameter must be a row-vector cell array');
  end
  if length(bitpatterns)~=length(dtypes)
    error('Bit Pattern Parameter and Data Types parameter must have the same number of cells');
  end
end

index=1;
if type==2
  used=zeros(1,64);
end

if type == 2
  portStr = 'input';
else
  portStr = 'output';
end

maskdisplay='';

for i=1:length(bitpatterns)
  bitpattern=round(bitpatterns{i});
  % if the ones at the end are -1, we ignore them
  % do this by nuking everything past the last non-negative entry
  bitpattern(max(find(bitpattern >= 0)) + 1 : end) = [];
  maskdisplay = [maskdisplay ...
                 'port_label(''' portStr ''',', num2str(i), ...
                 ','' ',xpcdarray2str(bitpattern),''');'];

  if type==1
    dtype=lower(dtypes{i});
    if ~isa(bitpattern,'double')
      error('Bit Pattern parameter elements must be double arrays');
    end
  end
  if size(bitpattern,1)>1
    error('Bit Pattern parameter elements must be row-vector double arrays');
  end
  if type==1
    if ~isa(dtype,'char')
      error('Data Types parameter elements must be character arrays');
    end
    if strcmp(dtype,'int8')
      dtypesout(i)=2;
      dsize=8;
    elseif strcmp(dtype,'uint8')
      dtypesout(i)=3;
      dsize=8;
    elseif strcmp(dtype,'int16')
      dtypesout(i)=4;
      dsize=16;
    elseif strcmp(dtype,'uint16')
      dtypesout(i)=5;
      dsize=16;
    elseif strcmp(dtype,'int32')
      dtypesout(i)=6;
      dsize=32;
    elseif strcmp(dtype,'uint32')
      dtypesout(i)=7;
      dsize=32;
    elseif strcmp(dtype,'boolean')
      dtypesout(i)=8;
      dsize=1;
    else
      error('Supported Data Types are: int, uint8, int16, uint16, int32, uint32, and boolean');
    end
    if length(bitpattern) > dsize
      error(['Too many bits specified to fit into data type: ',dtype]);
    end
  end
  tmp=bitpattern;
  tmp(find(tmp==-1))=[];
  if sum(tmp<0) | sum(tmp>63)
    error('Bit specifiers must be in the range 0..65');
  end
  if type==2
    if sum(used(tmp+1))
      error('Bits already assigned');
    else
      used(tmp+1)=ones(1,length(tmp));
    end
  end
  output(index)= length(bitpattern);
  output(index+1:index+1+length(bitpattern)-1)=bitpattern;
  index=index+2+length(bitpattern)-1;
end

if type==1
  dtypes=dtypesout;
elseif type==2
  dtypes=length(bitpatterns);
end
bitpatterns=output;
