function [X,nX] = vmap0rdx(filepath,Xfilename)
%VMAP0RDX Read the Vector Map Level 0 index file.
%
% [X, nX] = VMAP0RDX(filepath,filename) reads the Vector Map Level 0  index
% file.  [filepath filename] must form a valid full filename.  X is a
% matrix containing the Byte offset from beginning of file and the number
% of bytes in the table record for each entry.  nX is the number of index
% records (scalar)
%
% See also: VMAP0READ, VMAP0RHEAD

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:24:08 $

if nargin ~= 2 ; error('Incorrect number of input arguments'); end

nX = 0;
X = [];

fid = fopen([filepath,Xfilename],'rb', 'ieee-le');

if fid == -1
	[filename,filepath] = uigetfile(filename,['Where is ',Xfilename,'?']);
	if filename == 0 ; return; end
	fid = fopen([filepath,filename],'rb', 'ieee-le');
end

nX = fread(fid, 1, 'integer*4');           % number of records in the table being indexed
nHeaderBytes = fread(fid, 1, 'integer*4');
X =  fread(fid, [2, nX], 'integer*4');    % Byte offset from beginning of file
	                                  % Number of bytes in table record

fclose(fid);

