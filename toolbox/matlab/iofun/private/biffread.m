function biffvector = biffread(filename)
%BIFFREAD read biff vector from xls file

%   $Revision: 1.6.4.2 $  $Date: 2004/04/10 23:29:40 $
%   Copyright 1984-2003 The MathWorks, Inc.

% read the biff file using fread or error
%
% if the first byte is 9, this is an old style (pre excel 95) file
%     
% if byte 513 is 9, this is a Storage file with a short header
% 
% if byte 2049 is 9, this is a Storage file with a long header
% 
% if none of these are true, scan for [9 x] pairs in the biff
% vector and start reading from there.  x is the biff version
   
fid = fopen(filename,'r','l'); % always use little endian for read
if fid < 0
    error(['Unable to read XLS file ' filename '.  Can''t open file.']);
end
biffvector = uint8(fread(fid, inf, 'uchar'));
fclose(fid);
if length(biffvector) == 0
    error(['Unable to read XLS file ' filename '.  File is empty.']);
end

if biffvector(1) == 9
    % this is a pre excel95 biff file, use it as is
    biffvector = biffvector;
elseif length(biffvector) > 512 & biffvector(513) == 9 
    % this is a structured storage file with a 512 byte header.
    % the 1st record is a biff record throw away the 1st 512 bytes
    biffvector = biffvector(513:end);
elseif length(biffvector) > 2048 & biffvector(2049) == 9 
    % this is a structured storage file with a 2048 byte header or something other
    % than biff in the 1st record, throw away the 1st 2048 bytes
    biffvector = biffvector(2049:end);
else
    % look through the whole file for data of the form [9 x] where x is the
    % biff version. try biff versions 8 through 12 - if the biff version gets
    % much more than 12, we'll likely need to rewrite biffparse.
    start = [];
    for biffver = 8:12
        start = findHeader(biffvector, biffver);
        if ~isempty(start)
            biffvector = biffvector(start:end);
            break;
        end
    end
    if isempty(start)
        error(['Unable to read XLS file ' filename '.  File is not in recognized format.']);
    end
end

function start = findHeader(in, biffver)
% look for the 1st occurence of a 9 followed by the biff version - this is
% likely the 1st header
start = [];
nineIndexes = find(in == 9);
if ~isempty(nineIndexes)
    out = find(in(nineIndexes + 1) == biffver);
    if ~isempty(out)
        start = nineIndexes(out(1));
    end
end
