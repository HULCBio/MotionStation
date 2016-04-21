function Hd = fcfileread(filename)
%FCFILEREAD FDATool coefficient file reader.
%   FILTOBJ = FCFILEREAD(FILENAME) reads the filter coefficients defined in
%   the FDATool generated .FCF (FDATool Coefficient File) and returns a DFILT
%   or QFILT object. 

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:31:40 $ 

error(nargchk(1,1,nargin));

% We don't check for valid file extension, i.e., .FCF, so that we can
% import text coefficient files which were generated in previous releases.

% Create a cell array with the contains of the entire file
filecontents = textread(filename,'%s','delimiter','\n','whitespace','');

% Attempt to read the filter structure from the header comments (files
% generated after R13+)
fsconstructor = getFSconstructor(filecontents);

% If we find the filter structure string, get the corresponding key words 
if ~isempty(fsconstructor),
    kwcell = getkwcellfromFS(fsconstructor);
end

% Remove comments from the file contents
filecell = sptrmcharsfromcell(filecontents,'%');

% No Filter structure string found (file created prior to R13+), determine
% the filter structure from the key words found within the file.
if isempty(fsconstructor),
    [fsconstructor,kwcell] = getFSfromKw(filecell);
end
if isempty(fsconstructor), error('Unable to read filter coefficient file.'); end

% Build subcells of coefficients
coeffs = getsubcell(filecell,kwcell);

% Create a DFILT object
Hd = feval(str2func(['dfilt.',fsconstructor]),coeffs{:});



%-------------------------------------------------------------------
%                     File utility functions
%-------------------------------------------------------------------
function subcell = getsubcell(filecell,keyword)
% Build a cell array(s) which starts with the element following the keyword 
% and ends with the element prior to the next keyword. For the case when the
% next keyword is the last 

% Get the index of the keywords
for m = 1:length(keyword),
    kwidx(m) = strmatch(keyword{m},filecell);
end

if length(kwidx)>1,
    for n = 1:length(kwidx),
        if kwidx(n) == kwidx(end),
            % Special case the last subcell
            subcell{n} = str2num(str2mat(filecell{kwidx(n)+1:end}));
        else
            subcell{n} = str2num(str2mat(filecell{kwidx(n)+1:kwidx(n+1)-1}));
        end
    end
else
    subcell{1}= str2num(str2mat(filecell{kwidx+1:end}));
end


%-------------------------------------------------------------------
function fsconstructor = getFSconstructor(filecell)
% Get the filter structure object constructor from the header of the text
% file, for example:
%
% Filter structure    : Direct form FIR

fsconstructor = '';

% Determine the index of the Keyword
kwidx = strncmpi('% Filter structure ',filecell,19);

% Didn't find the Keyword
if ~any(kwidx),return; end

% Get the filter structure string
[t,fsstr] = strtok(filecell{find(kwidx)},':');
fsconstructor = getconstructorfromstructure(fsstr(3:end));

    
%-------------------------------------------------------------------
function [fsconstructor,kw] = getFSfromKw(filecell)
% Get the filter structure from the key words. 

fsconstructor = '';
[kwcell,fc] = getkeywords;

for n = 1:length(kwcell),
    bool = true;
    for m = 1:length((kwcell{n})),
        bool = boolean(double(bool)*double(any(strcmpi(kwcell{n}{m},filecell))));
    end
    if bool, 
        fsconstructor = fc{n};
        kw = kwcell{n};
        break;
    end
end



%-------------------------------------------------------------------
function [kwcell,fccell] = getkeywords
% List all key words and possible filter constructors.

% Key word cell
kwcell = {{'Numerator:','Denominator:'},...
        {'Numerator:'},...
        {'SOS matrix:','Gain:'},...
        {'A:','B:','C:','D:'},...
        {'Lattice:','Ladder:'},...
        {'Lattice:'}};

% Filter constructors
fccell = {'df2',...
        'dffir',...
        'df2sos',...
        'statespace',...
        'latticearma',...
        'latticeallpass'};

% Need to add support for Lattice coupled-allpass filter, Lattice coupled-allpass 
% power-complementary filter. Also for FIRs, we should be able to check if
% coefficients are symmetric so that we can create a dfsymfir


%-------------------------------------------------------------------
function kwcell = getkwcellfromFS(fsconstructor)
% Construct a default DFILT object so that we don't have to maintain a list
% of keywords, which are defined in the coefficientnames method.

Hd = feval(str2func(['dfilt.',fsconstructor]));
kwcell = coefficientnames(Hd);

% [EOF]
