function Hq = coeread(filename, flag)
%COEREAD Read a XILINX CORE Generator(tm) coefficient (.COE) file.
%   Hd = COEREAD(FILENAME) extracts the Distributed Arithmetic FIR filter 
%   coefficients defined in a XILINX CORE Generator .COE file specified by 
%   FILENAME and creates a fixed-point DFILT filter object, Hd.
%
%   If no extension is given with FILENAME, the extension '.coe' is assumed.
%  
%   See also DFILT/COEWRITE.

%   Author(s): P. Costa
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/12 23:31:51 $ 

error(nargchk(1,2,nargin));

% Left here as an undocumented way to create a QFILT from .COE files.
if nargin < 2, flag = 'dfilt'; end
switch lower(flag)
    case 'qfilt'
        isqfilt = true;
    case 'dfilt'
        isqfilt = false;
    otherwise
        error(generatemsgid('invalidInput'), 'Class flag must be ''dfilt'' or ''qfilt''.');
end

% Check for valid .COE file extension
if isempty(findstr(filename,'.'))
    filename=[filename,'.coe'];
else
    [pathstr,name,ext,versn] = fileparts(filename);
    if ~strcmpi(ext,'.coe'),
        error('Not a valid XILINX .COE file.');
    end
end

% Create a cell array with the contains of the entire file
filecontents = textread(filename,'%s','delimiter',',');

% Remove comments from file contents
filecell = sptrmcharsfromcell(filecontents,';');

% Get the radix
radix = getkeywordval(filecell,'radix');
if isempty(radix),error('Keyword ''Radix'' not found.'); end

% Determine the CoefficientFormat and get the coefficients.  
[b, q] = getCoeffsNFormat(filecell,'coefficient_width',radix);

% Determine the FIR filter structure
fstructstr = getfiltstructstr(filecell, b);

% Get the InputFormat & OutputFormat quantizers
qiw = getIOFormat(filecell,'input_width');
qow = getIOFormat(filecell,'output_width');

if isqfilt
    % Create a QFILT object
    Hq = qfilt(fstructstr,{b},'CoefficientFormat',q,...
        'InputFormat',qiw,...
        'OutputFormat',qow,...
        'MultiplicandFormat',quantizer('none'),...
        'ProductFormat',quantizer('none'),...
        'SumFormat',quantizer('none'));
else
    Hq = dfilt.dffir(b);
    set(Hq, ...
        'Arithmetic', 'Fixed', ...
        'CoeffAutoScale', false, ...
        'CoeffWordLength', q.Format(1), ...
        'NumFracLength', q.Format(2));
    
    % If the quantizers are none, there was no information in the file
    % about how to set them.  Just ignore.
    if ~strcmpi(qiw.Mode, 'none')
        set(Hq, ...
            'InputWordLength', qiw.Format(1), ...
            'InputFracLength', qiw.Format(2));
    end
    if ~strcmpi(qow.Mode, 'none')
        set(Hq, ...
            'OutputMode', 'SpecifyPrecision', ...
            'OutputWordLength', qow.Format(1), ...
            'OutputFracLength', qow.Format(2));
    end
end

%-------------------------------------------------------------------
function [b, q] = getCoeffsNFormat(C,keyword,radix)
% Determine the CoefficientFormat and get the coefficients.  

% Get a cell array with the coefficient data 
coeffcell = getsubcell(C,'coefdata'); 

% Look for the 'Coefficient_Width' keyword
wordlen = getkeywordval(C,keyword);

% Coefficient wordlength could not be determined, infer it from
% the coefficients 
if isempty(wordlen),
    switch radix,    
    case 2,  
        % Assume binary always shows leading zeros
        wordlen = length(coeffcell{1}); 
    case 10, 
        wordlen = ceil(1+log2((abs(max(str2num(char(coeffcell)))))));
    case 16, 
        wordlen = gethexcoeffwl(char(coeffcell));
    end
end

q = quantizer([wordlen 0]);

% Get the quantized coefficients
switch radix,
case 2,  b = bin2num(q,char(coeffcell)); 
case 10, b = pow2(str2num(char(coeffcell)),-q.fractionlength); 
case 16, b = hex2num(q,char(coeffcell));
end


%-------------------------------------------------------------------
function symstr = getfiltstructstr(filecell, b)
% Get the FIR FilterStructure

% If symmetry is given, use it. If not, figure it our from the coeffs.
symcell = getsubcell(filecell,'impulse_response_symmetry');

if isempty(symcell),
    tol = 0; % Since we have integers
    symstr = signalpolyutils('symmetrytest',b,[],0);
else
    symstr = symcell{:};
end

switch symstr,
case {'false','none'},                 symstr = 'fir';
case {'true','symmetric','hermitian'}, symstr = 'symmetricfir'; 
case {'antisymmetric','antihermitian'},symstr = 'antisymmetricfir';
end


%-------------------------------------------------------------------
function qw = getIOFormat(filecell,keyword)
% Build a quantizer object from the supplied Input/Output wordlength 
% if not supplied, create a default quantizer('none')

iowidth = getkeywordval(filecell,keyword);
if isempty(iowidth),
    qw = quantizer('none');
else
    qw = quantizer([iowidth 0]);
end


%-------------------------------------------------------------------
function wordlen = gethexcoeffwl(c)
% Get the Wordlength for Radix 16 coefficients

maxwl = length(c(1,:))*4;
u = quantizer('ufixed',[maxwl 0]);

try
    % g 194518
    x = hex2num(u,c);
catch
    c = [c repmat(',', size(c, 1), 1)]';
    error('File is corrupted.  Cannot convert ''%s'' to decimal.', c);
end

if max(x)>=2^(maxwl-1)
    wordlen = maxwl;
else
    error('Can''t determine wordlength for ''Radix 16'' coefficients');
end 


%-------------------------------------------------------------------
%                       Cell-array / File utility functions
%-------------------------------------------------------------------
function subcell = getsubcell(filecell,keyword)
% Build a cell array which starts with the element containing the keyword 
% and ends with the first occurence of a semicolon.  If no keyword was 
% found, and empty cell array is returned.

% Get the index of the keyword followed by an '=' sign.
kwindex = search4str(filecell,keyword,'modifiedkeyword');

% Get the index of the first ; after the keyword
index_2 = search4str({filecell{kwindex:end}},';');

% Form a new cell array to extract extra strings
if isempty(kwindex) & isempty(index_2),
    subcell = {};
else
    subcell = extractfromcell({filecell{kwindex:(kwindex+index_2-1)}});
end


%-------------------------------------------------------------------
function index = search4str(C,str2find,modkeyword)
% Search cell array elements for a particular string
%
% Inputs:
%   C - Cell array 
%   STR2FIND - String containing a keyword to search for
%   MODKEYWORD - Flag indicating that we are looking for a particular string 
%   (keyword) or looking for a keyword followed by an '=' or ' =' after it.
%   This avoids the cases when keywords are within comments.

index = [];

% Looking for different permutations of the keyword
if nargin == 3,
    str2find = {[str2find '='],[str2find ' =']};
else
    str2find = {str2find};
end

for n = 1:length(C),
    for m = 1:length(str2find),
        index = findstr(lower(C{n}),str2find{m});
        if ~isempty(index), index = n; return; end
    end
end


%-------------------------------------------------------------------
function newstr = extractfromcell(C)
% Extract extra strings from cell array elements

for m = 1:length(C),
    [t,newstr{m}] = strtok(C{m},'=');
    
    % Return the original string if '=' is not found 
    if isempty(newstr{m}); newstr{m} = t; end
    
    % Strip out extra characters
    torm = {'=',' ',';'};
    for n = 1:length(torm),
        newstr{m} = strrep(newstr{m},torm{n},'');
    end
end


%-------------------------------------------------------------------
function val = getkeywordval(C,keyword)
% Returns an empty if no keyword is found
%
% Inputs:
%   C - Cell array
%   STR2FIND - String containing a keyword 

% Buid a cell array containing keyword information
subcell = getsubcell(C,keyword);

% Ignore empty cells (for the case of multi-line keyword fields)
val = [];
if ~isempty(subcell),
    for n = 1:length(subcell),
        if ~isempty(subcell{n}) | ~strcmpi(subcell{n},keyword),
            val = str2num(subcell{n});
        end
    end
end

% [EOF]
