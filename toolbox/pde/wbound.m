function fid=wbound(bl,mn)
%WBOUND Write Boundary Condition Specification File.
%
%       FID=WBOUND(BL,MN) writes a Boundary M-file with the name
%       [MN,'.m']. The Boundary M-file is equivalent to the
%       Boundary Condition Matrix BL. FID is -1 if the file couldn't
%       be written.
%
%       The format of the Boundary Condition Matrix is
%       described in PDEBOUND.

%       A. Nordmark 8-08-94, AN 8-23-94, MR 9-14-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:23 $


fid=fopen([mn,'.m'],'w');
if fid==-1,
   return
end

mn=pdebasnm(mn);
umn=upper(mn);

nbs=size(bl,2);

% Write header
fprintf(fid,'function [q,g,h,r]=%s(p,e,u,time)\n',mn);
fprintf(fid,'%%%s\tBoundary condition data.\n',umn);
fprintf(fid,'%%\n');
fprintf(fid,'%%\n');
fprintf(fid,'%%\n');

format='';
k=1;
while 1
  format=[format '%g'];
  if k>=nbs
    break
  end
  format=[format ' '];
  k=k+1;
end
format=[format '\n'];

fprintf(fid,'bl=[\n');
fprintf(fid,format,bl.');
fprintf(fid,'];\n');
fprintf(fid,'\n');
fprintf(fid,'if any(size(u))\n');
fprintf(fid,'  [q,g,h,r]=pdeexpd(p,e,u,time,bl);\n');
fprintf(fid,'else\n');
fprintf(fid,'  [q,g,h,r]=pdeexpd(p,e,time,bl);\n');
fprintf(fid,'end\n');
fclose(fid);

