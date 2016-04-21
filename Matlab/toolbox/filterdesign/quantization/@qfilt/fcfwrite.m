function fcfwrite(h,filename)
%FCFWRITE Write a filter coefficient file.
%   FCFWRITE(Hq) writes a filter coefficient ASCII-file using the quantized
%   filter object Hq. A dialog box is displayed to  fill in a file name.
%   The default file name is 'untitled.fcf'. 
%
%   FCFWRITE(H) can be used to write filter coefficient files for
%   discrete-time filter objects, DFILTS, multirate filter objects, MFILTs,
%   and adaptive filter objects, ADAPTFILTs. 
%
%   FCFWRITE(H,FILENAME) writes the file to a disk file called FILENAME in
%   the present working directory.
%
%   The extension '.fcf' will be added to FILENAME if it doesn't already
%   have an extension.
%
%   See also INFO, DFILT.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:20:30 $

error(nargchk(1,2,nargin));
if nargin < 2, filename = []; end

% File extension
ext = 'fcf';

if isempty(filename),
    filename = 'untitled.fcf';
    dlgStr = 'Export Filter Coefficients to .FCF file';
    [filename,pathname] = fduiputfile(filename,dlgStr,ext);
else
    % File will be created in present directory
    s = pwd;
    pathname = [s filesep];
end

if ~isempty(filename),
    if isempty(findstr(filename,'.')), filename=[filename '.' ext]; end
    filename = [pathname filename];
end

if ~any(filename == 0),
    save2fcffile(h,filename);
end


%--------------------------------------------------------------
function save2fcffile(h,file)

% Write the coefficients out to a file.
fid = fopen(file,'w');

% Display header information
fprintf(fid,'%s\n',sptfileheader);

txt = getfiletxt(h);

sz = size(txt);
for j = 1:sz(1), % Rows
    fprintf(fid, '%s\n', num2str(txt(j,:),10));
end
fprintf(fid, '\n');

fclose(fid);

% Launch the MATLAB editor (to display the generated file)
edit(file);

% -------------------------------------------------------------------------
function txt = getfiletxt(Hb)
% txt is a character array

strs = cell(length(Hb)*4, 1);    
for idx = 1:length(Hb)
    strs{idx*4-3} = info(Hb(idx));
    strs{idx*4-2} = sprintf('\n');
    strs{idx*4-1} = dispstr(Hb(idx));
    strs{idx*4}   = sprintf('\n');
end
txt = strvcat(strs{:});

% [EOF]
