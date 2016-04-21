function [partition]=completepartitionstruct(partition,opt)
% COMPLETEPARTITIONSTRUCT   Shared memory partition utility
% COMPLETEPARTITIONSTRUCT(P,OPT) Shared memory is allocated using
%  hetergenenous bundles of data that are packed into memory partitions.
%  To provide flexible control over the ordering and alignment of data, a
%  partition structure is required.  This utility function provides a 
%  default version of the partition structure or accepts a user-supplied
%  partition structure.  
%
% Common Partition fields
%
%   P(1).Address - Offset into shared memory of first element
%   P(n).Type - Data type (ex. 'int32','double', etc)
%   p(n).Size - Array dimensions supplied as a vector of dimensions
%   p(n).Alignment - Byte alignment for this element
%
% Scramnet Support - When OPT is empty (or set to 'scramnet'), this utility
%   supports memory partitioning for the Scramnet board.
%  
%  COMPLETEPARTITIONSTRUCT(P) Extends P (partition structure) with 
%    default fields for Scramnet shared memory board
%  COMPLETEPARTITIONSTRUCT([]) Creates a default partition structure
%    for Scramnet shared memory board
% 
% Scramnet Fields: RIE, TIE, ExtTrigger1, ExtTrigger2 and HIPRO 
% (refer to full documentation for information on these fields)
% 
% VMIC Support - When OPT is set to '5565', this utility supports memory
% partitioning for the VMIC 5565 
%
%  COMPLETEPARTITIONSTRUCT(P,'5565') Extends P (partition structure) with 
%    default fields for VMIC 5565 shared memory board
%  COMPLETEPARTITIONSTRUCT([],'5565') Creates a default partition structure
%    for VMIC 5565 shared memory board
%
% See also COMPLETENODESTRUCT

%   Copyright 2002-2003 The MathWorks, Inc.
%  $Revision: 1.2.4.2 $ $Date: 2004/04/08 21:01:53 $

if nargin >=2, 
    if ischar(opt),
        indx = strmatch(opt,{'5565','scramnet'});
        if isempty(indx),
            error('Shared memory specification limited to ''5565'',''scramnet'' or ''TBD''');               
        end
        if indx == 1,
            partition = vmic5565net(partition);
            return;
        end
    else
        error('Shared memory specification limited to ''5565'',''scramnet'' or ''TBD''');
    end
end
partition = scramnet(partition);

%--------------------------------------------------------------------------
% VMIC implemenation 
%
function [partition] = vmic5565net(partition)
if isempty(partition)
    partition.Address='0x0';
    partition.Type='uint32';
    partition.Size='1';
    partition.Alignment='4';
   % partition.NetworkTrigger = 'off'  % 'off','1','2','3'
   % partition.NetworkTarget = 'any'   % or target id (0-255)
    
elseif ~isa(partition, 'struct')
    error('Data partition must be of class ''struct''');
end

for i=1:length(partition)
    if ~isfield(partition(i),'Address') | isempty(partition(i).Address)
        partition(i).Address='0x0';
    end
    if ~isfield(partition(i),'Type') | isempty(partition(i).Type)
        partition(i).Type='uint32';
    end
    if ~isfield(partition(i),'Size') | isempty(partition(i).Size)
        partition(i).Size='1';
    end
    if ~isfield(partition(i),'Alignment') | isempty(partition(i).Alignment)
        partition(i).Alignment='4';
    end
end

dtypes= zeros(1, length(partition),1);
sizes = zeros(1, length(partition)*2,1);
alignments= zeros(1, length(partition),1);
widths= zeros(1, length(partition),1);

for i=1:length(partition)
    [dtID, dtSize, ACsize]= getDataType(partition(i).Type);
    dtypes(i)=dtID;
    try
        if ischar(partition(i).Size),
            eval(['tsize=',partition(i).Size,';']);
        elseif isnumeric(partition(i).Size),
            tsize = round(partition(i).Size);
            partition(i).Size = ['[' num2str(tsize) ']'];
            eval(['tsize=',partition(i).Size,';']);
        else
            error('Size information is invalid type');
        end
    catch
        error('Size information is invalid');
    end
    if length(tsize)==1 % vector
        sizes(i*2-1)=tsize;
        dlength=tsize;
    else % matrix
        sizes(i*2-1)=tsize(1);
        sizes(i*2)=tsize(2);
        dlength=tsize(1)*tsize(2);
    end
    try
         if ischar(partition(i).Alignment),
            eval(['alignment=',partition(i).Alignment,';']);
        elseif isnumeric(partition(i).Alignment),
            tsize = round(partition(i).Alignment);
            partition(i).Size = ['[' num2str(Alignment) ']'];
            eval(['alignment=',partition(i).Alignment,';']);
        else
            error('Alignment information is invalid type');
        end
    catch
        error('Alignment information is invalid');
    end
    alignments(i)= alignment;    
    nBytes= dlength * dtSize;
    alignRem= rem(nBytes, alignment);
    if alignRem==0
        widths(i)=nBytes;
    else
        widths(i)=nBytes+alignment-alignRem;
    end  
end

% Compute address
baseAddress= partition(1).Address;
if ischar(baseAddress), 
    baseAddress= hex2dec(baseAddress(3:end));
elseif isnumeric(baseAddress),
    baseAddress= round(baseAddress);
    partition(1).Address = ['0x' dec2hex(baseAddress)];
end
address= baseAddress;
if rem(baseAddress, 4)~=0
    error(['the Specified address = '  partition(1).Address ' is not aligned on 32 bit boundaries, Try = 0x' dec2hex(bitshift(bitshift(baseAddress,-2)+1,2)) ]);
end

for i=2:length(partition)
    baseAddress= baseAddress + widths(i-1);
    partition(i).Address= ['0x',dec2hex(baseAddress)];
end
ndwords= ceil(sum(widths)/4);

partition(1).Internal.DTypes=dtypes;
partition(1).Internal.Sizes=sizes;
partition(1).Internal.Alignments=alignments;
partition(1).Internal.Widths=widths;
partition(1).Internal.NDwords=ndwords;
partition(1).Internal.Address=address;



%--------------------------------------------------------------------------
% Scramnet implemenation 
%
function [partition] = scramnet(partition)
if isempty(partition)
    partition.Address='0x0';
    partition.Type='uint32';
    partition.Size='1';
    partition.Alignment='4';
    partition.RIE='off';
    partition.TIE='off';
    partition.ExtTrigger1='off';
    partition.ExtTrigger2='off';
    partition.HIPRO='off';
end

if ~isa(partition, 'struct')
    error('Data partition must be of class ''struct''');
end

for i=1:length(partition)
    if ~isfield(partition(i),'Address') | isempty(partition(i).Address)
        partition(i).Address='0x0';
    end
    if ~isfield(partition(i),'Type') | isempty(partition(i).Type)
        partition(i).Type='uint32';
    end
    if ~isfield(partition(i),'Size') | isempty(partition(i).Size)
        partition(i).Size='1';
    end
    if ~isfield(partition(i),'Alignment') | isempty(partition(i).Alignment)
        partition(i).Alignment='4';
    end
    if ~isfield(partition(i),'RIE') | isempty(partition(i).RIE)
        partition(i).RIE='off';
    end
    if ~isfield(partition(i),'TIE') | isempty(partition(i).TIE)
        partition(i).TIE='off';
    end
    if ~isfield(partition(i),'ExtTrigger1') | isempty(partition(i).ExtTrigger1)
        partition(i).ExtTrigger1='off';
    end
    if ~isfield(partition(i),'ExtTrigger2') | isempty(partition(i).ExtTrigger2)
        partition(i).ExtTrigger2='off';
    end
    if ~isfield(partition(i),'HIPRO') | isempty(partition(i).HIPRO)
        partition(i).HIPRO='off';
    end
end

dtypes= zeros(1, length(partition),1);
sizes= zeros(1, length(partition)*2,1);
alignments= zeros(1, length(partition),1);
widths=zeros(1, length(partition),1);

ACRAM=[];

for i=1:length(partition)
    [dtID, dtSize, ACsize]= getDataType(partition(i).Type);
    dtypes(i)=dtID;
    try
        eval(['tsize=',partition(i).Size,';']);
    catch
        error('Size information is invalid');
    end
    if length(tsize)==1 % vector
        sizes(i*2-1)=tsize;
        dlength=tsize;
    else % matrix
        sizes(i*2-1)=tsize(1);
        sizes(i*2)=tsize(2);
        dlength=tsize(1)*tsize(2);
    end
    try
        eval(['alignment=',partition(i).Alignment,';']);
    catch
        error('Alignment information is invalid');
    end
    alignments(i)= alignment;    
    nBytes= dlength * dtSize;
    alignRem= rem(nBytes, alignment);
    if alignRem==0
        widths(i)=nBytes;
    else
        widths(i)=nBytes+alignment-alignRem;
    end
    % build ACRAM
    tmp=zeros(1,widths(i));
    %RIE
    if strcmp(lower(partition(i).RIE),'off')
    elseif strcmp(lower(partition(i).RIE),'first')
        tmp(1:ACsize)=tmp(1:ACsize)+1;
    elseif strcmp(lower(partition(i).RIE),'last')
        tmp(end-ACsize+1:end)=tmp(end-ACsize+1:end)+1;    
    elseif strcmp(lower(partition(i).RIE),'all')
        tmp=tmp+1;
    else
        error('Invalid value of field RIE');
    end
    %TIE
    if strcmp(lower(partition(i).TIE),'off')
    elseif strcmp(lower(partition(i).TIE),'first')
        tmp(1:ACsize)=tmp(1:ACsize)+2;
    elseif strcmp(lower(partition(i).TIE),'last')
        tmp(end-ACsize+1:end)=tmp(end-ACsize+1:end)+2;    
    elseif strcmp(lower(partition(i).TIE),'all')
        tmp=tmp+2;
    else
        error('Invalid value of field RIE');
    end
    %ExtTrigger1
    if strcmp(lower(partition(i).ExtTrigger1),'off')
    elseif strcmp(lower(partition(i).ExtTrigger1),'first')
        tmp(1:ACsize)=tmp(1:ACsize)+4;
    elseif strcmp(lower(partition(i).ExtTrigger1),'last')
        tmp(end-ACsize+1:end)=tmp(end-ACsize+1:end)+4;    
    elseif strcmp(lower(partition(i).ExtTrigger1),'all')
        tmp=tmp+4;
    else
        error('Invalid value of field ExtTrigger1');
    end
    %Trigger2
    if strcmp(lower(partition(i).ExtTrigger2),'off')
    elseif strcmp(lower(partition(i).ExtTrigger2),'first')
        tmp(1:ACsize)=tmp(1:ACsize)+8;
    elseif strcmp(lower(partition(i).ExtTrigger2),'last')
        tmp(end-ACsize+1:end)=tmp(end-ACsize+1:end)+8;    
    elseif strcmp(lower(partition(i).ExtTrigger2),'all')
        tmp=tmp+8;
    else
        error('Invalid value of field ExtTrigger2');
    end
    %HIPRO
    if strcmp(lower(partition(i).HIPRO),'off')  
    elseif strcmp(lower(partition(i).HIPRO),'on')
        tmp=tmp+16;
    else
        error('Invalid value of field HIPRO');
    end
    ACRAM=[ACRAM,tmp];
end

ndwords= ceil(sum(widths)/4);
ACRAM=[ACRAM, ACRAM(end)*ones(1,(4*ceil(length(ACRAM)/4))-length(ACRAM))];
ACRAM=reshape(ACRAM,4,length(ACRAM)/4);

for i=1:size(ACRAM,2)
    if length(unique(ACRAM(:,i)))~=1
        warning(['corrupted ACRAM at data type boundary with uint32 offset: ',num2str(i-1)]);
    end
    ACRAM(:,i)=max(ACRAM(:,i));
end
ACRAM=ACRAM(1,:);

baseAddress= partition(1).Address;
baseAddress= hex2dec(baseAddress(3:end));
address= baseAddress;

if rem(baseAddress, 4)~=0
    error('Specified address does not align');
end

for i=2:length(partition)
    baseAddress= baseAddress + widths(i-1);
    partition(i).Address= ['0x',dec2hex(baseAddress)];
end

partition(1).Internal.DTypes=dtypes;
partition(1).Internal.Sizes=sizes;
partition(1).Internal.Alignments=alignments;
partition(1).Internal.Widths=widths;
partition(1).Internal.NDwords=ndwords;
partition(1).Internal.Address=address;
partition(1).Internal.ACRAM=ACRAM;

function [dtID, dtSize, ACsize]= getDataType(typeStr)

if strcmp(typeStr,'double')
     dtID=0;
     dtSize=8;
     ACsize=4;
  elseif strcmp(typeStr,'single')
    dtID=1;
    dtSize=4;
    ACsize=4;
  elseif strcmp(typeStr,'int8')
    dtID=2;
    dtSize=1;
    ACsize=1;
  elseif strcmp(typeStr,'uint8')
    dtID=3;
    dtSize=1;
    ACsize=1;
  elseif strcmp(typeStr,'int16')
    dtID=4;
    dtSize=2;
    ACsize=2;
  elseif strcmp(typeStr,'uint16')
    dtID=5;
    dtSize=2;
    ACsize=2;
  elseif strcmp(typeStr,'int32')
    dtID=6;
    dtSize=4;
    ACsize=4;
  elseif strcmp(typeStr,'uint32')
    dtID=7;
    dtSize=4;
    ACsize=4;
  elseif strcmp(typeStr,'boolean')
    dtID=8;
    dtSize=1;
    ACsize=1;
  else
    error('the supported data types are: double, single, int, uint8, int16, uint16, int32, uint32, boolean');
  end








    
    