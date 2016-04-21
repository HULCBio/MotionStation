function write_rnumeric(rn,index,data)
%WRITE_REGISTER Writes a value into a DSP register.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $ $Date: 2004/04/01 16:03:07 $

error(nargchk(2,3,nargin));
if ~ishandle(rn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RNUMERIC Handle.');
end

if nargin==2,   
    data = index;
else
    index = p_checkerforindex(rn,index);
    if  mod(length(index),length(rn.size))~=0,
        error(generateccsmsgid('InvalidIndex'),['Index must be a (N x '  num2str(length(rn.size)) ') array ' ]);
    end
end
% Is data a valid numeric input?
if ~isnumeric(data),
    error(generateccsmsgid('InvalidDataFormat'),'DATA must be a numeric array or hexidecimal strings (cell array) ');
end

% Reshape value according to ARRAYORDER property
data = ArrangeBasedOnArrayOrder(data,rn.arrayorder);
% Do we have sufficent values ?
data = CheckForSize(data,rn.size);
 
% Convert numeric values into array of AUs 
%  where each column is the the AUs necessary for one numeric value
%  The data will be little-endian (swapped later if necessary)
%  thus cc.write([1 256]), where storageunitspervalue = 3, represent = 'unsigned', bitsperstorageunit = 8
%  fdata = 
%    1  0
%    0  1
%    0  0
switch (rn.represent)
case {'unsigned','ufract'},
    data = AdjustBinaryPoint(data,rn.represent,rn.binarypt);
    
    maxval = 2^rn.wordsize-1;
    minval = 0;
    data = CheckIfWithinRange(data,minval,maxval);
    
    uidata = ConvertRaw2UnsignedInt(rn,data);
    
case {'signed','fract'},  % 2's Complement
    data = AdjustBinaryPoint(data,rn.represent,rn.binarypt);

    minval = -1*2^(rn.wordsize-1);
    maxval = abs(minval)-1;
    data   = CheckIfWithinRange(data,minval,maxval);

    conversion_method = Signed_SpecialCases(rn,data);
    if conversion_method==1
       uidata = ConvertRaw2SignedInt_m1(rn,data);
	else
       uidata = ConvertRaw2SignedInt_m2(rn,data);
	end

case 'float',
    if rn.wordsize == 32, % Single
        uidata = ConvertRaw2IeeeSingle(rn,data);
    elseif rn.wordsize == 64, % Double
        uidata = ConvertRaw2IeeeDouble(rn,data);
    else
        error(generateccsmsgid('InvalidFloatingPtSize'),'Floating point representation is limited to 32 and 64 bit values');
    end
    
otherwise 
    error(generateccsmsgid('InvalidNumericRepresentation'),['Unexpected numeric representation: ''' rn.represent]);
end

% Endianness swap (not - necessary)    
   
% Write raw values to memory
write_registerobj(rn,uidata);

%------------------------------
% Indexed write - comment this out because indexing >1 is not supported for
% registers, but this feature might be supported in the future
% if nargin==2,
% 	write_registerobj(rn,uidata);
% else % timeout % index version - one value only!
%     write_registerobj(rn,(index-1).*rn.storageunitspervalue+1,uidata);
% end

%------------------------------------
function out = addbinstr(data,onebin)
rem = '0';
for i=length(data):-1:1
    [out(i),rem_n] = addbin(data(i),onebin(i));
    for j = 1:length(rem)
        [out(i),rem_n(j+1)] = addbin(out(i),rem(j));
    end
    rem = rem_n;
end
%-------------------------------------
function [out,rem] = addbin(bin1,bin2)
if bin1=='1' & bin2=='1'
    out = '0';  rem = '1';
elseif ~strcmp(bin1,bin2)
    out = '1';  rem = '0';
else
    out = '0';  rem = '0';
end
%------------------------------------
function data = CheckForSize(data,obj_size)
nvalues = numel(data);
nvaldef = prod(obj_size);
if nvalues==nvaldef,
    return;
end
if nvalues < nvaldef,
    % Not applicable in register objects, do nothing!!
    % warning('DATA has less elements than specified numeric array, DATA will only be applied to beginning of memory area');
elseif nvalues > nvaldef,
    warning(generateccsmsgid('DataHasLessNumOfValues'),'DATA has more elements than specified numeric array, DATA will be be limited to defined register area ');
    % data = data(1:nvaldef);  % Truncate!
    data = data(1);
end
%-------------------------------
function data = ArrangeBasedOnArrayOrder(data,arrayorder)
% Array-ordering not YET applicable to registers, do nothing
% if strcmp(arrayorder,'row-major'),
%     data = reshape(permute(data,[2 1]),1,[]);
% else  
%     data = reshape(data,1,[]);
% end

%--------------------------------
function data = CheckIfWithinRange(data,minval,maxval)
if any( maxval < data),
    warning(generateccsmsgid('DataIsSaturated'),'Overflow: Saturation was required to fit into the specified numeric range');
    [maxdat,inx] = max(data);
    while maxdat > maxval,
        data(inx) = maxval;
        [maxdat,inx] = max(data);
    end
end
if any(minval > data),
    warning(generateccsmsgid('DataIsSaturated'),'Underflow: Saturation was required to fit into the specified numeric range');
    [mindat,inx] = min(data);
    while mindat < minval,
        data(inx) = minval;
        [mindat,inx] = min(data);
    end
end
%----------------------------------------------
function bindata = GetBinaryRep(val,wordsize)
onebin  = dec2bin(1,wordsize);
negdata = dec2bin(abs(val),wordsize);
negdata = strrep(negdata,'1','x');
negdata = strrep(negdata,'0','1');
negdata = strrep(negdata,'x','0');
bindata = addbinstr(negdata,onebin);

%---------------------------------------------
function data = AdjustBinaryPoint(data,represent,binarypt)
data = double(data);
if strcmp(represent,'ufract') | strcmp(represent,'fract'),  % Adjust binary point 
    data = data.*(2^binarypt);
else
    if sum(rem(data,1))~=0,
        warning(generateccsmsgid('DataIsRounded'),'Data contains fractions and will be rounded to the nearest integer value. ');
    end
    data = round(data);
end

%-----------------------------------------------
function uidata = ConvertRaw2UnsignedInt(rn,data);
data = data*2^rn.prepad;  % scale data by prepend to shift bits within word    
bscaler = rn.bitsperstorageunit*(0:rn.storageunitspervalue-1);
uidata = [];
for val = data,  % Do conversion
    uidata = horzcat(uidata,mod(fix(val./2.^bscaler),2^rn.bitsperstorageunit)');
end
%----------------------------------------------
function uidata = ConvertRaw2SignedInt_m1(rn,data)
negEs = (0 > data)*2^rn.wordsize;
data = data + negEs;
data = data*2^rn.prepad;  % scale data by prepend to shift bits within word    
bscaler = rn.bitsperstorageunit*(0:rn.storageunitspervalue-1);
uidata = [];
for val = data,  % Do conversion
    uidata = horzcat(uidata,mod(fix(val./2.^bscaler),2^rn.bitsperstorageunit)');
end

%----------------------------------------------
function uidata = ConvertRaw2SignedInt_m2(rn,data)
% Special approach - bec 2^64 (65-bits) cannot be represented by MATLAB
negdata = GetBinaryRep(data,rn.wordsize);
uidata  = [ bin2dec(negdata(rn.bitsperstorageunit+1:rn.wordsize)), ...
            bin2dec(negdata(1:rn.bitsperstorageunit))];

%----------------------------------------------
function conversion_method = Signed_SpecialCases(rn,data)
if rn.wordsize==64 & any(data<0),
    conversion_method = 2;
else
    conversion_method = 1;
end
%----------------------------------------------
function uidata = ConvertRaw2IeeeSingle(rn,data)
uidata = [];
data = double(data);
for eachd = data,
    % Sprintf output is in Big Endian mode
    audata = reshape(sprintf('%tX',eachd),[],rn.storageunitspervalue)';
    uidata = hex2dec(audata);
    if any(strcmp(rn.procsubfamily,{'C54x','C55x','C28x'}))
        uidata = flipud(uidata); % In C54x & C55x, float contains 2 32-bit registers in big-endian mode;
    end                          % flip to default to 'little'
end

%----------------------------------------------
function uidata = ConvertRaw2IeeeDouble(rn,data)
uidata = [];        
data = double(data);
for eachd = data,
    % !!! old: sprintf for doubles outputs LSHexPair-->BSHexPair
    % !!! new: sprintf for doubles outputs BSHexPair-->LSHexPair
    audata = reshape(sprintf('%bX',eachd),[],rn.storageunitspervalue)';
    audata = flipud(audata); %% new line
     % !!! Since the sprintf output has been corrected in R14, there's no
    % need to flip the output byte per byte, left to right -->
    %     Flip byte per byte left-right from 
    %     [row col] = size(audata);
    %     index = fliplr(2*[2:col/2]);
    %     for i=index
    %         temp = audata(:,i-1:end);
    %         audata(:,col-1:end) = audata(:,i-3:i-2);
    %         audata(:,i-3:end-2) = temp;
    %     end
    uidata = horzcat(uidata,hex2dec(audata));
end


%------------------------------------------
% Endianness swap (if necessary), Big endian only        
function uidata = ApplyEndianness(rn,uidata)
if strcmp( rn.endianness,'big') & (rn.storageunitspervalue > 1),
	uidata = flipud(uidata);
end    

% [EOF] write_rnumeric.m