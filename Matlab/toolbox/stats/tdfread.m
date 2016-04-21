function tdfread(filename,delimiter,displayopt)
%TDFREAD Retrieves tabular data from the file system.
%   TDFREAD displays a dialog box for selecting a file, then reads
%   data from the file.  The file should have variable names
%   separated by tabs in the first row, and data values separated
%   by tabs in the remaining rows.
%
%   TDFREAD(FILENAME) does the same, but using the file specified.
%
%   TDFREAD(FILENAME,DELIMITER) uses the specified delimiter in
%   place of tabs.  Allowable values of DELIMITER can be any of the
%   following:
%        ' ', '\t', ',', ';', '|' or their corresponding string name 
%        'space', 'tab', 'comma', 'semi', 'bar'; 'tab' is the default. 
%
%   See also TBLREAD.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2004/01/24 09:37:00 $

% set the delimiter
tab = sprintf('\t');
if nargin < 2  
   delimiter = tab;
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
      fprintf('TDFREAD does not support the specified delimiter.\n');
      fprintf('We use %c supplied by you as the delimiter.\n',delimiter(1));
      fprintf('This may give bad results.\n');
   end
end

%%% open file
F = 1;
if nargin == 0
   filename = '';
end
if isempty(filename)
   [F,P]=uigetfile('*.*');
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
   vn = line1(idx(k)+1:idx(k+1)-1);
   vn = strrep(vn, ' ', '_');
   varnames(k,1:strlength(k)) = vn;
end

nobs = length(newlines);

delimitidx = find(bigM == a);

% check the size validation
if length(delimitidx) ~= nobs*(nvars-1)
   error('stats:tdfread:BadFileFormat',...
         'Requires the same number of delimiters on each line.');
end
maxlength = max(diff(delimitidx));
if nvars > 1
   delimitidx = (reshape(delimitidx,nvars-1,nobs))';
end

% now we need to re-find the newlines.
newlines = find(bigM == lf);
startlines = newlines;
startlines(nobs) = [];
startlines = [0;startlines];
delimitidx = [startlines, delimitidx, newlines];
if (isempty(maxlength))
   maxlength = max(newlines - startlines);
end
for vars = 1:nvars
   x = repmat(' ', nobs,maxlength);
   for k = 1:nobs
       v = bigM(delimitidx(k,vars)+1:delimitidx(k,vars+1)-1)';
       x(k,1:length(v)) = v;
   end
   y = str2num(x);
   if (length(y) > 0)
      x = y;
   else
      x = deblank(x);
   end
   vname = deblank(varnames(vars,:));
   ok = 0;
   if (isvarname(vname))
      try
         assignin('base', vname, x);
         ok = 1;
      catch
      end
   end
   if (~ok)
      newname = ['tdfread_' num2str(vars)];
      disp(sprintf(['Failed to create variable named %s, ' ...
                    'trying %s instead.'], ...
                   vname, newname));
      try
         assignin('base', newname, x);
         if (length(newname) > size(varnames,2))
            varnames = [varnames ...
                        repmat(' ', size(varnames,1), ...
                               length(newname)-size(varnames,2))];
         end
         varnames(vars,:) = ...
                [newname repmat(' ',1,size(varnames,2)-length(newname))];
      catch
         disp(sprintf(['Failed to create variable named %s, ' ...
                       'skipping column %d from file.'], ...
                       newname, vars));
      end
   end
end

vn = [varnames, repmat(' ', size(varnames,1), 1)]';
if (nargin<3 || ~isequal(displayopt, 'off'))
   evalin('base', ['whos ', vn(:)']);
end

