function write_numeric(nn,index,data)
%WRITE_NUMERIC - Writes data into DSP memory.
% 
% WRITE_NUMERIC(MM,DATA) - write DATA into the DSP memory pointed to by the object handle MM.
% 
% WRITE_NUMERIC(MM,DATA,INDEX) - write DATA into the nth element of MM, where n is specified by  INDEX.
% 
% WRITE_NUMERIC(MM,DATA,INDEX,TIMEOUT) - write DATA into the nth element of MM, where n is specified by INDEX. 
%     TIMEOUT specifies the duration of the WRITE_NUMERIC execution.
% 
% WRITE_NUMERIC(MM,DATA,[ ],TIMEOUT) - same as first syntax except with TIMEOUT specified.
% 
% Important Notes:
% 
% ·	If DATA is above the maximum allowed value or below the minimum allowed value for MM, 
%     the final value is saturated, meaning either the minimum or maximum value is written into DSP 
%     memory.
% 
% Example:
% MM - object handle to a scalar variable having a 16-bit wordsize and 'unsigned' representation
% 	write_numeric(mm,-3) - results to writing 0 (the min) into memory.
% 	write_numeric(mm,70000) - results to writing 65535 (the max) into memory.
% 
% 
% ·	If DATA contains more number of elements than the specified size for MM, DATA will be truncated 
%     such that only the first set of elements that fit into the memory block which MM points to is 
%     written. On the other hand, if DATA contains less number of elements than the specified size for 
%     MM, only the memory space where DATA can fit into will be populated. The remaining memory space 
%     is unaffected.
% 
% Example:
% MM - object handle to a [1x10] variable
% 	write_numeric(mm,[1:15]) - results to writing [1:10] into memory.
% 	write_numeric(mm,[1:5]) - results to writing [1:5] into memory.
%  
%   See also READ, WRITEBIN, WRITEHEX.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.5 $ $Date: 2004/04/08 20:46:43 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC handle.');
end
if nargin==2,   
    data  = index;
    index = [];
end

% Is data a valid input
if ~isnumeric(data),
    error(generateccsmsgid('InvalidInput'),'DATA must be a numeric array.'); %or hexidecimal string');
end

% Process address offset from index
linearoffset = 1; % 1-based array offset
if nargin==3,
    [addroffset,linearoffset] = ComputeOffsetFromIndex(nn,nargin,index);
end

% Reshape value according to ARRAYORDER property
data = ArrangeBasedOnArrayOrder(nn,data);
% Do we have sufficent values ?
data = CheckForSize(data,nn.size,index,linearoffset);

% Convert numeric values into array of AUs 
%  where each column is the the AUs necessary for one numeric value
%  The data will be little-endian (swapped later if necessary)
%  thus cc.write([1 256]), where storageunitspervalue = 3, represent = 'unsigned', bitsperstorageunit = 8
%  fdata = 
%    1  0
%    0  1
%    0  0
switch (nn.represent),
    case {'unsigned','ufract'},
        % Adjust binary point, if any 
        data = AdjustBinaryPoint(data,nn.represent,nn.binarypt);
        
        % Check if data is within allowed range - saturate if above or below
        maxval = 2^nn.wordsize-1;
        minval = 0;
        data = CheckIfWithinRange(data,minval,maxval);
        
        % Breakdown data into it equivalent set of unsigned integers
        uidata = ConvertUnsignedInt2Raw(nn,data);
        
    case {'signed','fract'},  % 2's Complement
        % Adjust binary point, if any 
        data = AdjustBinaryPoint(data,nn.represent,nn.binarypt);
        
        % Check for occurence of special cases
        conversion_method = Signed_SpecialCase(nn,data);
        
        % Check if data is within allowed range - saturate if above or below
        minval = -1*2^(nn.wordsize-1);
        maxval = abs(minval)-1;
        data   = CheckIfWithinRange(data,minval,maxval);
        
        % Breakdown data into it equivalent set of unsigned integers
        if conversion_method==1
            uidata = ConvertSignedInt2Raw_m1(nn,data);
        else
            uidata = ConvertSignedInt2Raw_m2(nn,data);
        end
        
    case 'float',
        if nn.wordsize == 32, % Single
            uidata = ConvertIeeeSingle2Raw(nn,data);
        elseif nn.wordsize == 64, % Double
            uidata = ConvertIeeeDouble2Raw(nn,data);
        else
            error(generateccsmsgid('InvalidFloatSize'),'Floating point representation limited to 32 and 64 bit values.');
        end
        
    otherwise 
        error(generateccsmsgid('InvalidRepresentation'),['Unexpected numeric representation: ''' nn.represent '''.']);
end

% Endianness swap (if necessary), Big endian only    
if strcmp( nn.endianness,'big') & (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end    

% doubles get stored differently on little endian arm, the 2-32bit words
% get swapped in addition to the fact that the right most bytes are most 
% the most significant.
if (any(strcmpi(nn.procsubfamily,{'R1x','R2x'})) && strcmpi(nn.represent,'float') &&...
        nn.wordsize == 64 && strcmp( nn.endianness,'little'))
    % swap words
    uidata = [uidata([5:8],:) ; uidata([1:4],:)] ;
end

    
% Write raw values to memory
if nargin == 2,
    write_memoryobj(nn,uidata);
else % timeout % index version - one value only!
    write_memoryobj(nn,addroffset,uidata);
end

%-----------------------------------------
function [addroffset,linearoffset] = ComputeOffsetFromIndex(nn,numargs,index)
if isempty(index),      
    addroffset   = 1;
    linearoffset = 1; % 1-based offset
else
    index = p_checkerforindex(nn,index);
    if ~isequal(length(index),length(nn.size)) & length(index)
        error(generateccsmsgid('InvalidIndexInput'),['Index must be a (1 x '  num2str(length(nn.size)) ') array.' ]);
    end
    if length(nn.size)>1,
        index = p_sub2ind(nn,nn.size,index,nn.arrayorder);
    end
    addroffset = (index-1).*nn.storageunitspervalue + 1;
    linearoffset = index;
end

%-----------------------------------
function fdata = ArrangeDataInCFormat(nn,data)
a = [];
siz = size(data);
totalnumel = prod(siz);
if totalnumel<prod(nn.size)
    a   = p_ind2sub(nn,siz,[1:totalnumel]',nn.arrayorder);
    ndx = p_sub2ind(nn,siz,a,'col-major');
elseif totalnumel==prod(nn.size)
    a   = p_ind2sub(nn,nn.size,[1:totalnumel]',nn.arrayorder);
    ndx = p_sub2ind(nn,nn.size,a,'col-major');
else
    a   = p_ind2sub(nn,siz,[1:totalnumel]',nn.arrayorder);
    ndx = p_sub2ind(nn,siz,a,'col-major');
end
fdata = data(ndx);
%----------------------------------------------
function bindata = GetBinaryRep(val,wordsize)
onebin  = dec2bin(1,wordsize);
negdata = dec2bin(abs(val),wordsize);
negdata = strrep(negdata,'1','x');
negdata = strrep(negdata,'0','1');
negdata = strrep(negdata,'x','0');
bindata = addbinstr(negdata,onebin);
%------------------------------
function out = addbinstr(data,onebin)
rem = '0';
for i=length(data):-1:1
    [out(i),rem_n] = addbin(data(i),onebin(i));
    for j = 1:length(rem)
        [out(i),rem_n(j+1)] = addbin(out(i),rem(j));
    end
    rem = rem_n;
end
%----------------------------
function [out,rem] = addbin(bin1,bin2)
if bin1=='1' & bin2=='1'
    out = '0';  rem = '1';
elseif ~strcmp(bin1,bin2)
    out = '1';  rem = '0';
else
    out = '0';  rem = '0';
end
%--------------------------------
function data = CheckIfWithinRange(data,minval,maxval)
if any( maxval < data),
    warning(generateccsmsgid('DataIsSaturated'),'Overflow: Saturation was required to fit into the specified numeric range.');
    [maxdat,inx] = max(data);
    while maxdat > maxval,
        data(inx) = maxval;
        [maxdat,inx] = max(data);
    end
end
if any(minval > data),
    warning(generateccsmsgid('DataIsSaturated'),'Underflow: Saturation was required to fit into the specified numeric range.');
    [mindat,inx] = min(data);
    while mindat < minval,
        data(inx) = minval;
        [mindat,inx] = min(data);
    end
end
%------------------------------------------
function data = CheckForSize(data,objsize,index,linearoffset)
nvalues = numel(data);
nvaldef = prod(objsize);
if isempty(index),
    if nvalues < nvaldef,
        warning(generateccsmsgid('NotEnoughData'),sprintf(['DATA has less elements than the specified numeric array size,\n',...
                'DATA will only be applied to beginning of memory area.']));
    elseif nvalues > nvaldef,
        warning(generateccsmsgid('TooManyData'),sprintf(['DATA has more elements than the specified numeric array size,\n',...
                'DATA will be be limited to defined memory area.']));
        data = data(1:nvaldef);  % Truncate!
    end
else
    if (length(linearoffset)==1) && (linearoffset<=nvaldef) && ((linearoffset+nvalues-1)>nvaldef),
        warning(generateccsmsgid('DataIsTruncated'),'DATA has extra elements, DATA will be truncated.');
        data = data(1:nvaldef-linearoffset+1);  % Truncate!
    end
end
%---------------------------------------
function data = ArrangeBasedOnArrayOrder(nn,data)
sizdata = size(data);
if length(sizdata)==2 && any(sizdata==1) && strcmp(nn.arrayorder,'row-major')
    % if writing a vector to a row-major, no arranging of data necessary
    return;
end
if strcmp(nn.arrayorder,'col-major')
    data = data(1:numel(data));  % linear - write as it is referenced by Matlab
else
    data = reshape( ArrangeDataInCFormat(nn,data),1,[] );
end
%--------------------------------------
function conversion_method = Signed_SpecialCase(nn,data);
if nn.wordsize==64 & any(data<0),
    conversion_method = 2;
else
    conversion_method = 1;
end
%--------------------------------------------
function uidata = ConvertSignedInt2Raw_m1(nn,data)
% Regular approach
negEs   = (0 > data)*2^nn.wordsize;
rawdata = data + negEs;
rawdata = rawdata * 2^nn.prepad;  % scale data by prepend to shift bits within word    
bscaler = nn.bitsperstorageunit*(0:nn.storageunitspervalue-1);
uidata = [];
%code changed here
for k = 1:numel(rawdata)
    val = rawdata(k);  % Do conversion
    uidata = horzcat(uidata,mod(fix(val./2.^bscaler),2^nn.bitsperstorageunit)');
end
%-----------------------------------------
function uidata = ConvertSignedInt2Raw_m2(nn,data)
% Special approach - bec 2^64 (65-bits) cannot be represented by MATLAB
uidata = [];
for val = data,
    if val>0,   
        bindata = dec2bin(val,nn.wordsize);
    else        
        bindata = GetBinaryRep(val,nn.wordsize);
    end
    % note: the following only applies to one element
    rawdata = []; endof = nn.wordsize;
    for i=1:nn.storageunitspervalue
        startof = endof-nn.bitsperstorageunit + 1;
        rawdata = vertcat(rawdata,bin2dec( bindata(startof:endof) ));
        endof   = startof-1;
    end
    uidata = horzcat(uidata,rawdata);
end
%-----------------------------------------
function uidata = ConvertUnsignedInt2Raw(nn,data)
% Breakdown data into it equivalent set of unsigned integers
data = data*2^nn.prepad;  % scale data by prepend to shift bits within word    
bscaler = nn.bitsperstorageunit*(0:nn.storageunitspervalue-1);
uidata = [];
%code changed here
for k = 1:numel(data)
    val = data(k);  % Do conversion
    uidata = horzcat(uidata,mod(fix(val./2.^bscaler),2^nn.bitsperstorageunit)');
end
%--------------------------------------------
function uidata = ConvertIeeeDouble2Raw(nn,data)
% Format of final raw data:
%          Data1   Data2   Data3   ...   DataN
% LSByte | _____ | _____ | _____ | ... | _____ | 
% ...    | _____ | _____ | _____ | ... | _____ | 
% MSByte | _____ | _____ | _____ | ... | _____ | 
%
% Note: this data will be written to memory up-down per column, left-right

uidata = [];        
data = double(data); % convert to a format that built-in ML commands accept - ths does change the value
for eachd = data,
    audata = reshape(sprintf('%bX',eachd),[],nn.storageunitspervalue)';
    % note: removed next routine that flips byte per byte left-right
    uidata = horzcat(uidata,hex2dec(audata)); 
    % !!! old: SPRINTF for doubles outputs LSHexPair-->BSHexPair
    % !!! new: SPRINTF for doubles outputs BSHexPair-->LSHexPair
end
uidata = flipud(uidata); % !!! reaction to new sprintf behavior
                         % !!! ideal output of uidata: LSHexPair-->BSHexPair

%--------------------------------------------
function uidata = ConvertIeeeSingle2Raw(nn,data)
% Format of final raw data:
%          Data1   Data2   Data3   ...   DataN
% LSByte | _____ | _____ | _____ | ... | _____ | 
% ...    | _____ | _____ | _____ | ... | _____ | 
% MSByte | _____ | _____ | _____ | ... | _____ | 
%
% Note: this data will be written to memory up-down per column, left-right

uidata = [];
data = double(data); % convert to a format that built-in ML commands accept - ths does change the value
for eachd = data,
    audata = reshape(sprintf('%tX',eachd),[],nn.storageunitspervalue)';
    % Flip byte per byte left-right to MSbyte-LSbyte format
    if any(strcmp(nn.procsubfamily,{'C6x','R1x','R2x'})) % C6x,R1x,R2x
        [row col] = size(audata);
        index = fliplr(2*[2:col/2]);
        for i=index
            temp = audata(:,i-1:end);
            audata(:,col-1:end) = audata(:,i-3:i-2);
            audata(:,i-3:end-2) = temp;
        end
    end
    % !!! SPRINTF for floats outputs MSHexPair-->LSHexPair
    uidata = horzcat(uidata,hex2dec(audata)); % Add FLIPUD to "uidata = horzcat(uidata,hex2dec(audata))" 
                                              % such that first element of uidata is LSHexPair
end
uidata = flipud(uidata);

%------------------------------
function data = AdjustBinaryPoint(data,represent,binarypt)
data = double(data);
if strcmp(represent,'fract') | strcmp(represent,'ufract'),
    data = floor( data.*(2^binarypt) ); % shift binary point to the left 15 times and disregard fractional part
else
    if sum(rem(data,1))~=0,
        warning(generateccsmsgid('DataIsRounded'),'Data contains fractions and will be rounded to the nearest integer value.');
    end
    data = round(data);
end 

% [EOF] write_numeric.m