function resp = read_numeric(nn,index,timeout)
%READ_NUMERIC Retrieves memory area and converts into a numeric array
%  DN = READ_NUMERIC(NN)
%  DN = READ_NUMERIC(NN,[],TIMEOUT) - reads all data from the specified memory 
%  area and converts it into a numeric representation.  Numeric conversion is 
%  controlled by the properties of the NN object.  The output 'DN' will be a 
%  numeric array that has dimensions defined by NN.SIZE, which is the dimensions 
%  array. Each element in the dimensions array contains the size of the array in 
%  that dimension.  If SIZE is a scalar, the output is a column vector of the specified 
%  length. 
%
%  DN = READ_NUMERIC(NN,INDEX)
%  DN = READ_NUMERIC(NN,INDEX,TIMEOUT) - read a subset of the numeric values from
%  the specified numeric array.  Each row of INDEX is applied as a subscript into the 
%  full NN array.  The output DN will be a column vector with one value per entry in the
%  INDEX.  Arrays indices start at 1 and range up the maximum value defined by SIZE.
%  If INDEX is a vector, each row is an single index  that defines one entry
%  from the defined numeric array.  The output DN will be a column vector of values
%  corresponding to the specified indices.   A new TIMEOUT value can be
%  explicitly passed to temporarily modify the default timeout property of the nn object.  
%
% Array properties
% NN.SIZE - Dimensions of output numeric array.  This defines the size of 'DN'
% NN.ARRAYORDER - Defines how sequential memory locations are mapped into matrices.
%   The default is 'col-major', which is the arrangment used by MATLAB.  Alternatively,
%   use 'row-major', which is the memory organization applied in C.
% Numeric representation 
%  NN.REPRESENT - Numeric representation
%    'float' - IEEE floating pointer representation (32 or 64 bits)
%    'signed' - 2's Compliment signed integers
%    'unsigned'- Unsigned binary integer
%    'fract' - Fractional fixed-point, see nn.p
%  NN.WORDSIZE - Number of valid bits in numeric representation.  This
%   property is computed from other properties such as 'storageunitspervalue' and therefore
%   read-only
%  NN.BINARYPT
%  Other properties of NN control the placement and arrangement of
%  the numeric values in memory.
%
%  Changes to the numeric representation are possible by modifying the
%  class properties.  However, the CONVERT method implements the adjusting
%  the properties to implement some common data types.
%
%   See also READ, WRITE, CONVERT, INT32.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.3 $ $Date: 2004/04/08 20:46:40 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC handle.');
end

% Needed to make a decision whether we can use 'cc.read' directly 
nnIsBigEndian = IsobjBigEndian(nn);

% Initialization
resp = [];
uidata = [];
nvalues = 1;

% Call base class (memoryobj) to get unformatted data
if nargin == 1
    index = [];
    [uidata,dtype,bool] = SpecialReadmemoryobj(nn,index,[]);
    nvalues = prod(nn.size);
elseif nargin == 3 && isempty(index) ,
    [uidata,dtype,bool] = SpecialReadmemoryobj(nn,[],timeout);
    nvalues = prod(nn.size);
elseif nargin >= 2
    if nargin == 2,     dtimeout = nn.timeout;
    else                dtimeout = timeout;
    end
    [uidata,dtype,bool] = SpecialReadmemoryobj(nn,index,dtimeout);
    nvalues  = size(uidata,2);
end

if (~bool) % data was not read directly
    % Endianness swap (if necessary) - must default to 'little' order from this point on 
    uidata = ApplyEndianness(nn,uidata);
    
    % Trim pre/post bytes (if necessary)
    % For now, limited to increments of bitsperstorageunit
    uidata = ApplyPadding(nn,uidata);
end

% Convert adjusted array of 'valid' au into numeric values
switch (nn.represent), 
    case {'fract','signed'}
        if (bool && isempty(index))
            fdata = uidata;  % data already read in right format
        else
            fdata = ConvertRaw2SignedInt(nn,uidata,nvalues);
            % If fractional, adjust the binary point
            fdata = AdjustBinaryPoint(fdata,nn.represent,nn.binarypt);
        end
        
    case {'ufract','unsigned'}
        if (bool && isempty(index))
            fdata = uidata;  % data already read in right format
        else
            fdata = ConvertRaw2UnsignedInt(nn,uidata,nvalues);
            % If fractional, adjust the binary point
            fdata = AdjustBinaryPoint(fdata,nn.represent,nn.binarypt);
        end
        
    case 'float',
        if nargin == 3 dtimeout = timeout;
        else dtimeout = nn.timeout;
        end
        
        if (nargin>=2 && ~isempty(index)),     % Indexed, need to readbin
            index = ShapeAndCheckIndex(nn,index);
            bidata = readbin(nn,index,dtimeout);
            nvalues  = size(bidata,2);
            fdata = ConvertRaw2IeeeFloatingPt(nn,bidata,nvalues);
        elseif bool,  %non-indexed and endianess has not been changed by user
            fdata = double(read(nn.link,nn.address,dtype,nvalues,dtimeout));
        else
            bidata = readbin(nn,[],dtimeout);   % endianess has been changed
            fdata = ConvertRaw2IeeeFloatingPt(nn,bidata,nvalues);
        end
    otherwise  
        error(generateccsmsgid('InvalidRepresentation'),['Unexpected numeric representation: ''' nn.represent '''.']);
end



% Indexed and regular
if length(nn.size) > 1 & ((nargin == 1) | (nargin == 3 & isempty(index))),  % Non-indexed, arrange according to 'arrayorder' prop
    if strcmp(nn.arrayorder,'row-major'),
        fdata = fdata( GetMatlabIndex(nn) );
    end
    resp = double(reshape(fdata,nn.size)); %why cast to double???
    
else   % Indexed - Don't bother shaping it
    resp = double(fdata);  %why cast to double???
end

%-------------------------------------------------
function [uidata,dtype,bool] = SpecialReadmemoryobj(nn,index,timeout)
[bool,dtype] = CanDataBeReadDirectly(nn,index);
switch (nn.represent),
    case 'float'
         uidata = []; % not really needed for boosting up speed
    otherwise %fract,signed,ufract,unsigned
        if isempty(index) && isempty(timeout)  % non-indexed with object timeout
            if bool
                nvalues = prod(nn.size);
                uidata = read(nn.link,nn.address,dtype,nvalues,nn.timeout);
            else
                uidata  = read_memoryobj(nn);
                uidata  = reshape(uidata,nn.storageunitspervalue,[]);
            end
            
            
        elseif (nargin >= 2 && ~isempty(index)) %indexed
            % Re-arrange data as described by object
            index_shaped = ShapeAndCheckIndex(nn,index);
            addrange = ( index2addr(nn,index_shaped)' );
            uidata   = read_memoryobj(nn,addrange,timeout);
            uidata   = reshape(uidata,nn.storageunitspervalue,[]);
            
        else %non-indexed with user timeout
            if bool
                nvalues = prod(nn.size);
                uidata = read(nn.link,nn.address,dtype,nvalues,timeout);
            else
                 uidata  = read_memoryobj(nn,index,timeout);
                 uidata  = reshape(uidata,nn.storageunitspervalue,[]);
            end

        end    
end


%--------------------------------------------------
function [bool,dtype] = CanDataBeReadDirectly(nn,index)
cc = nn.link;
nnIsBigEndian = IsobjBigEndian(nn);

% To boost up speed when reading data, we can call "read(cc,...)" 
% directly. However, we can not do this for all read's. Three 
% conditions have to be met, and hopefully when you look at them,
% you will understand why?
condition1 = isequal(cc.info.isbigendian,  nnIsBigEndian);
condition2 = isempty(index);
condition3 = any(nn.wordsize == [8 16 32 64]);
if (condition1 && condition2 && condition3)
    bool = logical(1);
    switch (nn.represent),
        case 'signed'
            if isequal(nn.wordsize,64)
                bool = logical(0);
                dtype = '';
            else
                dtype = ['int' num2str(nn.wordsize)];
            end
        case 'unsigned'
            if isequal(nn.wordsize,64)
                bool = logical(0);
                dtype = '';
            else
                dtype = ['uint' num2str(nn.wordsize)];
            end
        case 'float'
            if rem(nn.wordsize,32) ~= 0  %only allow 32,64 bits for wordsize
                error(generateccsmsgid('InvalidFloatSize'),'Floating point data type limited to 32 and 64 bits on this platform!');
            end
            
            if any(strcmp(nn.procsubfamily,{'C6x','R1x','R2x','C28x'})) % C6x,R1x,R2x,C28x
                if nn.wordsize == 64,  dtype = 'double'; 
                else dtype = 'single';
                end
            else      
                dtype = 'single'; %C54x
            end 
        otherwise
            bool = logical(0);
            dtype = '';           
    end
    
else
    bool = logical(0);
    dtype = '';
end
%--------------------------------------------------
            
function index_shaped = ShapeAndCheckIndex(nn,index)
index = p_checkerforindex(nn,index);

if size(index,1) == 1  %[k l m n.....]
    try    
        index_shaped = round(reshape(index,length(nn.size),[])');
    catch  
        error(generateccsmsgid('InvalidIndexInput'),['Index Array must be an (N x '  num2str(length(nn.size)) ') vector. ' ]);
    end
elseif length(nn.size) ~= size(index,2)
    error(generateccsmsgid('InvalidIndexInput'),['Index Array must be an (N x '  num2str(length(nn.size)) ') vector. ' ]);
else
    index_shaped = index; %already shaped by user [k l...;m n..;...]
end

for k = 1:size(index_shaped,1),
    subscript = index_shaped(k,:);
    ndx = find(subscript > nn.size);
    if any(subscript < 1) | any(ndx),
        error(generateccsmsgid('InvalidIndexInput'),['INDEX has an entry: [' num2str(subscript) '], which exceeds the defined size of object. ']);
    end
end

%-----------------------------------------
function linearindex = GetMatlabIndex(nn)
nsize = nn.size;
subsc = [];
totalnumel = prod(nsize);
len = length(nsize);
subsc = p_ind2sub(nn,nsize,[1:totalnumel],'col-major'); % index in a) C if row-major b) Matlab if col-major
linearindex = p_sub2ind(nn,nsize,subsc,'row-major'); % map indices to native Matlab array order
if ~isequal(unique(linearindex),sort(linearindex))
    error(generateccsmsgid('WrongComputation'),'Error generating linear index. Please report this error to MathWorks.');
end

%-------------------------------------
function uidata = ApplyPadding(nn,uidata)
if nn.prepad > 0 ||  nn.postpad > 0,
    preaus  = nn.prepad/nn.bitsperstorageunit;
    postaus = nn.postpad/nn.bitsperstorageunit;
    if nn.postpad<nn.bitsperstorageunit, % Required by C5500 for pointers (24 bits)
        postaus = floor(postaus);
        fract_padding = 1;
    else
        fract_padding = 0;
    end
    if preaus + postaus > nn.storageunitspervalue,
        error(generateccsmsgid('InvalidPrePostPadValue'),' Pre/Post padding exceeds available memory area.');
    end    
    uidata = uidata(1+preaus:end-postaus,:); % extract only relevant bits
    if fract_padding, % Required by C5500 for pointers (24 bits)
        uidata(end,:) = bitand( uidata(end,:), 2^(nn.bitsperstorageunit-nn.postpad)-1);
    end
end 

%------------------------------
function fdata = AdjustBinaryPoint(fdata,represent,binarypt)
if strcmp(represent,'fract') || strcmp(represent,'ufract'),
    fdata = fdata./ 2^(binarypt);
end 

%------------------------------
function uidata = ApplyEndianness(nn,uidata)
if ~strcmp( nn.endianness,'little') && (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end

%------------------------------------
function fdata = ConvertRaw2SignedInt(nn,uidata,nvalues)
validaus  = size(uidata);  % Not storageunitspervalue (padding!!)
validaus  = validaus(1);
maxposbit = 2^(nn.bitsperstorageunit-1)-1; 
maxpos    = 2^(nn.bitsperstorageunit)-1;  
scale     = 2.^(0:nn.bitsperstorageunit:nn.bitsperstorageunit*validaus-1)';
for iv=1:nvalues,
   uival = double(uidata(:,iv))';
   if uival(validaus) > maxposbit,  % Negative 
       uival = maxpos-uival; 
       fdata(iv) = uival*scale;
       fdata(iv) = -1*(fdata(iv)+1);
   else % Positive 
      fdata(iv) = uival*scale;
   end 
end 

%------------------------------------
function fdata = ConvertRaw2UnsignedInt(nn,uidata,nvalues)
validaus = size(uidata);  % Not storageunitspervalue (padding!!)
validaus = validaus(1);
scale    = 2.^(0:nn.bitsperstorageunit:nn.bitsperstorageunit*validaus-1)';
for iv=1:nvalues,
   uival = double(uidata(:,iv))';
   fdata(iv) = uival*scale;
end

%-----------------------------
function fdata = ConvertRaw2IeeeFloatingPt(nn,bidata,nvalues)
if nn.wordsize==32,       precision = 'single';
elseif nn.wordsize==64,   precision = 'double';
else    error(generateccsmsgid('InvalidFloatSize'),'Floating point data type limited to 32 and 64 bits on this platform.');
end
for iv = 1:nvalues,        
    fdata(iv) = bin2float(nn,precision, bidata{iv});
end

%-----------------------------
function bool = IsobjBigEndian(nn)
if strcmp(nn.endianness,'big'), bool = 1;
else bool = 0;
end

% [EOF] read_numeric.m