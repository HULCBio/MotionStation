function [data,varnames,casenames] = tblread(filename,delimiter)
%TBLREAD Retrieves tabular data from the file system.
%   [DATA, VARNAMES, CASENAMES] = TBLREAD retrieves data from an
%   interactively selected file.  The file contents should consist
%   of variable (column) names in the first row, case (row) names
%   in the first column and numeric data starting in the (2,2)
%   position, using a space as the delimiting character.
%
%   [DATA, VARNAMES, CASENAMES] = TBLREAD(FILENAME) does the same,
%   using the file name specified.  FILENAME is the complete path
%   to the desired file.
%
%   [DATA, VARNAMES, CASENAMES] = TBLREAD(FILENAME,DELIMITER) reads
%   from the file using DELIMITER as the delimiting character.
%   DELIMITER can assume any of the following values:
%   ' ', '\t', ',', ';', '|' or the corresponding string name 
%   'space', 'tab', 'comma', 'semi', 'bar';  'space' is the default.
%
%   VARNAMES is a string matrix containing the variable names (column
%   names) in the first row.
%
%   CASENAMES is a string matrix containing the case names (row names)
%   in the first column.
%
%   DATA is a numeric matrix with a value for each variable-case
%   pair.
%
%   Use TDFREAD to read mixed numeric/text data.
%
%   Example:
%      Use the command
%         [data,vname,cname] = tblread('sat.dat')
%      to read the 2-by-2 data matrix, the variable (column) names,
%      and the case (row) names from the file with contents:
%                        Male      Female	
%         Verbal         470       530
%         Quantitative   520       480
%
%   See also TDFREAD.

%   Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 2.22.4.1 $  $Date: 2003/10/21 12:28:11 $

% set the delimiter
tab = sprintf('\t');
if nargin < 2  
   delimiter = ' ';
else
   switch delimiter
   case {'tab', '\t'}
      delimiter = tab;
   case {'space',' '}
      delimiter = ' ';
   case {'comma', ','}
      delimiter = ',';
   case {'semi', ';'}
      delimiter = ';';
   case {'bar', '|'}
      delimiter = '|';
   otherwise
      delimiter = delimiter(1);
      fprintf('TBLREAD does not support the specified delimiter.\n');
      fprintf('We use %c supplied by you as the delimiter.\n',delimiter(1));
      fprintf('This may give bad results.\n');
   end
end

%%% open file
F = 1;
if nargin == 0
   [F,P]=uigetfile('*');
   filename = [P,F];
end
if isempty(filename)
   [F,P]=uigetfile('*');
   filename = [P,F];
end
  
if (isequal(F,0)), return, end
fid = fopen(filename,'rt');

if fid == -1
   disp('Unable to open file.');
   return
end

lf = sprintf('\n'); % line feed is platform dependant

% now read in the data
[bigM,count] = fread(fid,Inf);
fclose(fid);
if bigM(count) ~= lf
   bigM = [bigM; lf];
end

charM = char(bigM);
charM = charM(:)';
oldM = [];
a = real(delimiter);

tabtab = [tab tab];
spacetab = [' ' tab];
realtab = real(tab);
tabspace = [tab ' '];
delimtab = [char(delimiter) tab];
tabdelim = [tab char(delimiter)];
delim = char(delimiter);
delimspace = [char(delimiter) ' '];
spacedelim = [' ' char(delimiter)];
while ~strcmp(charM, oldM)
   oldM = charM;
   charM = strrep(charM,'  ',' ');
   charM = strrep(charM,'__','_');
   if a ~= realtab
      charM = strrep(charM,tabtab,tab);
      charM = strrep(charM,spacetab,' ');
      charM = strrep(charM,tabspace,' ');
      charM = strrep(charM,delimtab,delim);
      charM = strrep(charM,tabdelim,delim);
   else
      charM = strrep(charM,spacetab,tab);
      charM = strrep(charM,tabspace,tab);
   end
   charM = strrep(charM,delimspace,delim);
   charM = strrep(charM,spacedelim,delim);
end
bigM = real(charM');

% find out how many lines are there.
newlines = find(bigM == lf);

% get rid of spaces before line feed.
oldM = [];
while ~strcmp(charM, oldM)
   oldM = charM;
   b = find(bigM(newlines-1)==real(' '));
   bigM(newlines(b)-1) = [];
   newlines = find(bigM == lf);
end

% take the first line out from bigM, and put it to line1.
line1 = bigM(1:newlines(1)-1);
line1 = line1';
bigM(1:newlines(1)) = [];
newlines(1) = [];

% add a delimiter to the beginning and end of the line
if real(line1(1)) ~= a
   line1 = [delimiter, line1];
end
if real(line1(end)) ~= a
   line1 = [line1,delimiter];
end

% determine varnames
idx = find(line1==delimiter);
strlength = diff(idx)-1;
maxl = max(strlength);
nvars = length(idx)-1;
b = ' ';
varnames = repmat(b,nvars, maxl);
for k = 1:nvars;
   varnames(k,1:strlength(k)) = line1(idx(k)+1:idx(k+1)-1);
end

nobs = length(newlines);

delimitidx = find(bigM == a);

% check the size validation
if length(delimitidx) ~= nobs*nvars
   if length(delimitidx) == nobs*(nvars-1)
      varnames(1,:) = [];
      nvars = nvars-1;
   else
      error('stats:tblread:BadFileFormat',...
            'Requires the same number of delimiters on each line.');
   end
end
if nvars > 1
   delimitidx = (reshape(delimitidx,nvars,nobs))';
end

% now we need to re-find the newlines.
newlines = find(bigM == lf);
startlines = newlines;
startlines(nobs) = [];
startlines = [0;startlines];
if isempty(delimitidx)
   clength = newlines - 1 - startlines; % unusual case of names only, no data
else
   clength = delimitidx(:,1) - 1 - startlines;
end
maxlength = max(clength);
casenames = ' ';
casenames = repmat(casenames, nobs,maxlength);
data = zeros(nobs,nvars);
for k = 1:nobs
    casenames(k,1:clength(k)) = char((bigM(startlines(k)+1:startlines(k)+clength(k)))');
    for vars = 1:nvars
       if vars == nvars
            data(k,vars) = str2double(char(bigM(delimitidx(k,vars)+1:newlines(k)-1)'));
       else
            data(k,vars) = str2double(char(bigM(delimitidx(k,vars)+1:delimitidx(k,vars+1)-1)'));
       end
    end
end
