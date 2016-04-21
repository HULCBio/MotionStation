function resp = readbin(nn,index,timeout)
%READBIN Retrieves a block of DSP memory as binary strings.
%   DN = READBIN(NN)
%   DN = READBIN(NN,INDEX)
%   DN = READBIN(NN,[],TIMEOUT)
%   DN = READBIN(NN,INDEX,TIMEOUT)
%
%   HS = READBIN(NN) - returns a binary string representation of 
%   the DSP's numeric values.  For arrays, the returned values will 
%   be a cell array of binary strings.  Conversely, if MM.SIZE equals 1,
%   (indicating a scalar), the output is an array of hex characters. 
%
%   DN = READBIN(MM,INDEX,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the MM.TIMEOUT property of the MM object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, CAST, NUMERIC.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2003/11/30 23:11:43 $


error(nargchk(1,3,nargin));
if ~ishandle(nn),
    error('First Parameter must be a RNUMERIC Handle.');
end
if nargin<=2,
    dtimeout = nn.timeout;
else                
    CheckIfNumeric(timeout,'timeout','Third Parameter ');
    dtimeout = timeout;
end

% Call base class (memoryobj) to get unformatted data
if nargin==1,
    [uidata,nvalues,readwhat] = ReadRawData(nn,'all');
elseif nargin<=3 && isempty(index),
    [uidata,nvalues,readwhat] = ReadRawData(nn,'empty-index',dtimeout);
else
    [uidata,nvalues,readwhat] = ReadRawData(nn,'indexed',dtimeout,index);
end

% Endianness swap (not - necessary)    

% Trim pre/post bytes (if necessary)
uidata = ApplyPadding(nn,uidata);

% Convert adjusted array of 'valid' au into numeric values (unsigned integers)
uidata   = double(uidata);  % Data format that built-in ML commands understand
validaus = size(uidata,1);  % Not storageunitspervalue (tahe into account padding!!)
for iv=1:nvalues,
	uival = dec2bin(uidata(:,iv),nn.bitsperstorageunit); % change back to binary format
	tmp = [];
	for su=validaus:-1:1,
       tmp = horzcat(tmp,uival(su,:));
	end
	% tmp = RemoveLeadingZeros(tmp);
	fdata{iv} = tmp;
end

% Arrange data such that it conforms with the SIZE and ARRAYORDER properties
% resp = ArrangeDataBasedOnProps(nn,fdata); % ----> No need to do this if reading 1 element

resp = fdata;

%-----------------------------------------
function linearindex = GetMatlabIndex(nn)
nsize = nn.size;
subsc = [];
totalnumel = prod(nsize);
len = length(nsize);
subsc = p_ind2sub(nn,nsize,[1:totalnumel],'col-major'); % index in a) C if row-major b) Matlab if col-major
linearindex = p_sub2ind(nn,nsize,subsc,'row-major'); % map indices to native Matlab array order
if ~isequal(unique(linearindex),sort(linearindex))
    error('Error generating linear index. Please report this error to MathWorks.');
end

%-----------------------------------
% Endianness swap (if necessary)    
function uidata = ApplyEndianness(nn,uidata)
if ~strcmp( nn.endianness,'little') & (nn.storageunitspervalue > 1),
    uidata = flipud(uidata);
end

%---------------------------------------
% Trim pre/post bytes (if necessary)
% For now, limited to increments of bitsperstorageunit
function uidata = ApplyPadding(nn,uidata)
if nn.prepad > 0 |  nn.postpad > 0,
    if nn.prepad + nn.postpad > nn.storageunitspervalue * nn.bitsperstorageunit,
        error(' Pre/Post padding exceeds available memory area');
    end    
    % prepad
    uidata(1) = bitshift(uidata(1),-1 * nn.prepad,nn.bitsperstorageunit);
    % postpad
    uidata(end) = bitand( uidata(end),bitshift(2^nn.bitsperstorageunit-1,-nn.postpad,nn.bitsperstorageunit) );
end 

%----------------------------------------
% Shape index such that 
% Example: index = [[1 2] [3 1] [1 1]]
%   index_shaped = [ 1 2 ]
%                  [ 3 1 ]
%                  [ 1 1 ]
function index_shaped = ShapeIndexInput(index,siz)
try
    index_shaped = round(reshape(index,length(siz),[])'); % arrange index
catch
    error(['Index must be an (N x '  num2str(length(siz)) ') vector of indices' ])
end
if sum(any(index_shaped<1)) || sum(any(mod(index_shaped,1)~=0)),
  error(['INDEX has an invalid value, INDEX must contain positive integer numbers. ']);
end
for subscript = index_shaped',
    if any(subscript < 1) || any(subscript' > siz),
      error(['INDEX has an entry: [' num2str(subscript') '], which exceeds the defined size of object. ']);
    end
end

%-----------------------------
function CheckIfNumeric(prop,propname,optl)
if ~isnumeric(prop),
    error([ optl upper(propname) ' must be numeric. ']);
end

%--------------------------------------------------
% Call base class (memoryobj) to get unformatted data
function [uidata,nvalues,readwhat] = ReadRawData(nn,opt,dtimeout,index)
error(nargchk(2,4,nargin));
readwhat = 'all';
switch opt,
case 'all'
    uidata  = read_registerobj(nn);
    uidata  = reshape(uidata,nn.storageunitspervalue,[]);
    nvalues = 1; % prod(nn.size);
    
case 'empty-index'
    CheckIfNumeric(dtimeout,'timeout','Third Parameter ');
    uidata  = read_registerobj(nn,[],dtimeout);
    uidata  = reshape(uidata,nn.storageunitspervalue,[]);
    nvalues = 1; % prod(nn.size);
    
case 'indexed'
    CheckIfNumeric(index,'index','Second Parameter ');
    index_shaped = ShapeIndexInput(index,nn.size);
    uidata   = read_registerobj(nn,index_shaped,dtimeout);
    uidata   = reshape(uidata,nn.storageunitspervalue,[]);
    nvalues  = size(uidata,2);
    readwhat = 'indexed';
    
otherwise
end

%---------------------------------
function tmp = RemoveLeadingZeros(tmp)
i = find(tmp=='1');
tmp = tmp(i(1):end);

%----------------------------------
% Arrange data such that it conforms with the SIZE and ARRAYORDER properties
function resp = ArrangeDataBasedOnProps(nn,fdata) 
 
if length(nn.size)>1 && strcmp(readwhat,'all'),  % Non-indexed, arrange according to 'arrayorder' prop
    if strcmp(nn.arrayorder,'row-major'),
        fdata = fdata( GetMatlabIndex(nn) );
    end
    if length(nn.size)==1,
        resp = reshape(fdata,1,nn.size);
    else
        resp = reshape(fdata,nn.size);
    end
else   % Indexed or 1-dim - Don't bother shaping it
    resp = fdata;
end

% [EOF] readbin.m