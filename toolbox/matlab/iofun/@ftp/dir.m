function varargout = dir(h,str)
%DIR List directory on an FTP server.
%   DIR(FTP,DIRECTORY_NAME) lists the files in a directory. Pathnames and
%   wildcards may be used.  
%
%   D = DIR(...) returns the results in an M-by-1
%   structure with the fields: 
%       name  -- filename
%       date  -- modification date
%       bytes -- number of bytes allocated to the file
%       isdir -- 1 if name is a directory and 0 if not
%
%   Because FTP servers do not return directory information in a standard way,
%   the last three fields in the structure may be empty.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/03/18 17:59:19 $

% Make sure we're still connected.
connect(h)

error(nargchk(0,2,nargin))
if (nargin < 2)
    str = '.';
end

ftp=h.jobject;
remoteFileList=ftp.listFiles(str);
listing=[];
form = java.text.SimpleDateFormat('dd-MMM-yyyy hh:mm:ss');
%form = java.text.DateFormat.getDateInstance(java.text.DateFormat.LONG,java.util.Locale.US);
for i=1:length(remoteFileList);
    file=remoteFileList(i);
    listing(i,1).name=char(file.getName);
    listing(i,1).date=char(form.format(file.getTimestamp.getTime));
    listing(i,1).bytes=file.getSize;
    listing(i,1).isdir=~logical(file.isFile);
end

% For Window's FTP server, listFiles is empty.  Just get the names.
if isempty(listing)
    names=ftp.listNames(str);
    for i=1:length(names)
        listing(i,1).name=char(names(i));
        listing(i,1).date='';
        listing(i,1).bytes=[];
        listing(i,1).isdir=[];
    end
end

switch nargout
case 0
    disp(' ');
    if ~isempty(listing)
        disp(convertListToColumns(strvcat(listing.name)));
    end
    disp(' ');
case 1
    varargout={listing};
end

%================================================================================
function list=convertListToColumns(list)

% Pad the list out with two extra spaces to separate the columns
list=[list ' '*ones(size(list,1),2)];

% Calculate the number of columns that fit on the screen
windowWidth=get(0,'CommandWindowSize')*[1;0];
numberOfColumns=floor(windowWidth/size(list,2));
if (numberOfColumns==0)
    numberOfColumns=1;
end

% Calculate the number of rows and pad out the remaining column
rows=ceil(size(list,1)/numberOfColumns);
pad=rows*numberOfColumns-size(list,1);
list=[list;' '*ones(pad,size(list,2))];

% Reshape the list into the columns (trick from Zhiping)
[r,c]=size(list);
[I,J]=find(ones(rows,r*c/rows));
ind=sub2ind(size(list), floor((J-1)/c)*rows+I, rem(J-1,c)+1);
list=reshape(list(ind),rows,r*c/rows);
