function [m,n]=wk1read(filename, r, c, rng) 
%WK1READ Read spreadsheet (WK1) file. 
%   A = WK1READ('FILENAME') reads all the numeric data from a Lotus WK1 
%   spreadsheet file named FILENAME into matrix A. Cells containing text 
%   are set to zero. NaN text entries in cells are returned as type NaN. 
% 
%   A = WK1READ('FILENAME',R,C) reads data from a Lotus WK1 spreadsheet 
%   file starting at row R and column C, into the matrix A.  R and C 
%   are zero-based so that R=C=0 is the first cell of the spreadsheet. 
% 
%   A = WK1READ('FILENAME',R,C,RNG)  specifies a cell range or named 
%   range for selecting data from the spreadsheet.  A cell range is 
%   specified by RNG = [R1 C1 R2 C2] where (R1,C1) is the upper-left 
%   corner of the data to be read and (R2,C2) is the lower-right  
%   corner. RNG can also be specified using spreadsheet notation as  
%   in RNG = 'A1..B7' or a named range like 'Sales'. 
% 
%   [A,B] = WK1READ(...) same as above with text data stored in cell 
%   array B. 
% 
%   See also WK1WRITE, CSVREAD, CSVWRITE. 

%   Brian M. Bourgault 10/22/93 
%   Copyright 1984-2003 The MathWorks, Inc.
% 
%   $Revision: 5.21.4.3 $  $Date: 2004/04/10 23:29:47 $ 
% 
% include WK1 constants 
% 
wk1const; 

% Validate input args 
if nargin==0, error('Not enough input arguments.'); end 

% Get Filename 
if ~isstr(filename), error('Filename must be a string.'); end 

% do some validation 
if isempty(filename), error('Filename must not be empty.'); end 

% put extension on 
if all(filename~='.') filename = [filename '.wk1']; end 

% Make sure file exists 
if ~isequal(exist(filename), 2), error('File not found.'), end 

% open the file Lotus uses Little Endian Format ONLY 
fid = fopen(filename,'rb', 'l'); 
if fid == (-1) 
    error(['Could not open file ', filename ,'.']); 
end 

% 
% check/set row,col offsets 
% 
if nargin < 2 
    r = 0; 
end 
if nargin < 3 
    c = 0; 
end 
if nargin < 4 
    % max range of cells for WK1 format 
    rng = [1 1 8192 256]; 
end 
% 
% get the upper-left and bottom-right cells 
% of the range to read into MATLAB 
% 
ulc = []; brc = []; 
foundrng = 1; 
if ~isstr(rng) 
    % user gave us a range, in matlab form, to import [1 1 3 5] 
    ulc = rng(1:2); 
    brc = rng(3:4); 
else 
    x = str2rng(rng); 
    if ~isempty(x) 
        % user gave us a cell range to import 'A1..C5' 
        ulc = x(1:2)+1; 
        brc = x(3:4)+1; 
    else 
        foundrng = 0; 
    end 
end 

% 
% Flip ulc and brc since we assume ulc = [C R] and brc = [C R] below. 
% 
if ~isempty(ulc), 
  ulc = fliplr(ulc); 
  brc = fliplr(brc); 
end 

% 
% Read Lotus WK1 BOF 
% 
header = fread(fid, 6,'uchar'); 
if(header(1) ~= LOTWK1BOFSTR) 
    error('Not a valid WK1 file.'); 
end 

% 
% Start processing WK1 Records 
% Read WK1 record header 
% cell = [col row] 
% Note: Convert Lotus 0 based to 1 based cell coordinates  
% 
rec = fread(fid, 2, 'uint16'); %changed from 'ushort'
while(rec(1) ~= LOTEND(1)) 
    if(rec(1) == LOTNUMBER(1)) 
        % 
        % 8 byte double 
        % 
        fmt  = fread(fid, 1,'uchar'); 
        cell = fread(fid, 2,'uint16'); 
        cell = cell' + 1; 
        val  = fread(fid, 1,'double'); 
        if(~isempty(ulc) & (cell >= ulc) & (cell <= brc)) 
            m(cell(2)+r,cell(1)+c) = val(1); 
        end 
    else 
        if(rec(1) == LOTINTEGER(1)) 
            % 
            % 2 byte integer 
            % 
            fmt  = fread(fid, 1,'uchar'); 
            cell = fread(fid, 2,'uint16'); 
            val  = fread(fid, 1,'int16'); 
            cell = cell' + 1; 
            if(~isempty(ulc) & (cell >= ulc) & (cell <= brc)) 
                m(cell(2)+r,cell(1)+c) = val(1); 
            end 
        else 
            if(rec(1) == LOTFORMULA(1)) 
                % 
                % 8 byte double from a Formula 
                % 
                fmt  = fread(fid, 1,'uchar'); 
                cell = fread(fid, 2,'uint16'); 
                cell = cell' + 1; 
                val  = fread(fid, 1,'double'); 
                if((cell >= ulc) & (cell <= brc)) 
                    m(cell(2)+r,cell(1)+c) = val(1); 
                end 
                fread(fid, rec(2)-13,'uchar'); 
            else 
                if(rec(1) == LOTNRANGE(1) & isstr(rng)) 
                    % 
                    % Named Range 
                    % 
                    if isstr(rng)  
                        n = fread(fid, 16,'char'); 
                        n = char(n'); 
                        n = deblankwk1read(n); 
                        nrng = fread(fid, 4,'uint16'); %changed from 'ushort'
                        nrng = nrng'; 
                        % need to pad n with zeros, this is a bug in strcmp 
                        rng = char(rng); 
                        rng = deblankwk1read(rng); 
                        if strcmpi(rng,n) 
                            foundrng = 1; 
                            % found the named range the user wants 
                            ulc = nrng(1:2) + 1; 
                            brc = nrng(3:4) + 1; 
                         end 
                    end 
                else 
                    if(rec(1) == LOTLABEL(1)) 
                        % 
                        % String label 
                        % 
                        fmt  = fread(fid, 1,'uchar'); 
                        cell = fread(fid, 2,'uint16'); 
                        cell = cell' + 1; 
                        val  = fread(fid, rec(2) - 5,'uchar'); 
                        str = char(val'); 
                        if (str(1) == '''') 
                            % shave off trailing null 
                            str = str(2:end-1); 
                        end 
                        if(~isempty(ulc) & (cell >= ulc) & (cell <= brc)) 
                            n{cell(2)+r,cell(1)+c} = str; 
                        end 
                    else 
                        % 
                        % read past this record 
                        % 
                        fread(fid, rec(2),'uchar'); 
                    end 
                end 
            end 
        end 
    end 
    % 
    % get the next WK1 record header 
    % 
    rec = fread(fid, 2, 'uint16'); 
end 

% close file 
fclose(fid); 

% Return only the valid part 
if exist('m','var') 
    m = m(2*r+1:end,2*c+1:end); 
elseif nargout < 2 | foundrng == 0 
    if foundrng == 0 
        error('Invalid range string or unknown named range argument.'); 
    else 
        error('No numeric data in WK1 file - use two output args to look for text data.'); 
    end 
elseif exist('n','var') 
    m = zeros(size(n)); 
else 
    m = []; 
end 

% Handle text data 
if exist('n','var') 
   n = n(2*r+1:end,2*c+1:end); 
   % Ensure a fully qualified character cell array 
   % find empty entries in cell array 
   if ~isempty(n)
      idxEmpty=cellfun('isempty',n);  
      % replace empty matrices with empty strings 
      if any(any(idxEmpty))
         [n{idxEmpty}]=deal(''); 
      end
      
      % find NaN entries 
      [rnan,cnan] = find(strcmp(lower(n),'nan')); 
      % substitute zeros for NaN at indicated positions 
      if ~isempty(m) & size(m)>=size(n) 
         for i = 1:length(rnan) 
            m(rnan(i),cnan(i))=NaN; 
         end 
      end 
   end
else 
   n = {}; 
end 
%----------------------------------------------------------------------------
function r = deblankwk1read(s)
% remove trailing whitespace and char(0)
% find indices of non-whitespace
% find starting and ending indices of non-whitespace characters
nonwslogical = (s ~= char(0)) & ~isspace(s);
nonws = find(nonwslogical);
if numel(nonws) == 0 % Equivalent to ISEMPTY(nonws).
    r = '';
    return;
else            
    r = s(1:nonws(numel(nonws))); % Equivalent to nonws(END).
end

