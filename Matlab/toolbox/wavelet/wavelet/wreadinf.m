function [out1,fid] = wreadinf(fname,noerr)
%WREADINF Read ascii files.
%   [TXT,FID] = WREADINF(FNAME,NOERR) or 
%   [TXT,FID] = WREADINF(FNAME)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.13 $

% For Japanese local, open ja/fname.m if the file exists.

lang=get(0,'lang');
lang=[lang,'  '];   % Guarantee lang has two chars.
langdir=lang(1:2);

path=fileparts(which(fname));

if exist([path,filesep,langdir, filesep, fname]) == 2
     fid = fopen([path, filesep,langdir, filesep, fname], 'r');
else
	 fid = fopen(fname,'r');
end

if fid==-1
    if nargin==2 , out1 = ''; return; end
    errargt(mfilename,'File Error ...','msg');
    error('*');     
end
info = fread(fid);
fclose(fid);
info = (abs(info))';

% tabulation
j = find(info==9);
info(j) = 32*ones(size(j));

out1  = [];
if length(info)>0
    ind1  = find(info==10);
    ind2  = find(info==13);
    lind1 = length(ind1);
    lind2 = length(ind2);

    if lind1>0
        i_beg = [1,ind1(1:lind1-1)+1];
        if length(ind2)>0
            i_end = ind1-2;
        else
            i_end = ind1-1;
        end
        cols  = i_end-i_beg+1;
        nbcol = max(cols);
        out1  = 32*ones(lind1,nbcol);

        for k = 1:lind1
            out1(k,1:cols(k)) = info(i_beg(k):i_end(k));
        end
    elseif lind2>0
        i_beg = [1,ind2(1:lind2-1)+1];
        i_end = ind2-1;
        cols  = i_end-i_beg+1;
        nbcol = max(cols);
        out1  = 32*ones(lind2,nbcol);

        for k = 1:lind2
            out1(k,1:cols(k)) = info(i_beg(k):i_end(k));
        end
    else
        out1 = info;
    end
end
out1  = setstr(out1);
[r,c] = size(out1);
ibeg  = min(find(out1(:,1)=='%'));
if isempty(ibeg) , out1 = []; return; end   
if ibeg==r
    iend = r; 
else
    j = find(out1(:,1)~='%');
    k = find(j>ibeg);
    if isempty(k)
        iend = r;
    else
        iend = min(j(k))-1; 
    end
end
out1 = out1(ibeg:iend,2:end);
