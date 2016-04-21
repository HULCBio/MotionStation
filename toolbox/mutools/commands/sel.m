% function out = sel(mat,rowdata,coldata)
%
%   Selects rows and columns from a VARYING matrix.
%   Selects outputs and inputs from a SYSTEM matrix.
%   The string ':' is used to select all rows, or all columns.
%
%   See also: GETIV, REORDSYS, SRESID, TRUNC, UNPCK,
%             VUNPCK, XTRACT and XTRACTI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out] = sel(mat,rdata,cdata)
 if nargin ~= 3
   disp('usage: out = sel(mat,rowdata,coldata)')
   return
 end
 if isempty(cdata) | isempty(rdata)
        out = [];
        return
 end
 [nr,nc] = size(mat);
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if isstr(rdata)
   if strcmp(rdata,':')
     rdata = 1:mrows;
   else
     error('Use '':'' to select all ROWS(OUTPUTS)');
     return
   end
 end
 if isstr(cdata)
   if strcmp(cdata,':')
     cdata = 1:mcols;
   else
     error('Use '':'' to select all COLUMNS(INPUTS)');
     return
   end
 end
 if min(size(rdata)) ~= 1 | min(size(cdata)) ~= 1
   error('ROWDATA and COLDATA should be vectors')
   return
 end
 if mtype == 'vary'
   if max(cdata) <= mcols & min(cdata) > 0 ...
     & max(rdata) <= mrows & min(rdata) > 0
     [nrd ncd] = size(rdata);
     if nrd == 1
       rdatacv = rdata';
     else
       rdatacv = rdata;
     end
     npts = mnum;
     nrout = max(size(rdatacv));
     ncout = max(size(cdata));
     out = zeros(nrout*npts+1,ncout+1);
     out(nrout*npts+1,ncout+1) = inf;
     out(nrout*npts+1,ncout) = npts;
     out(1:npts,ncout+1) = mat(1:mnum,nc);
     out(1:nrout*npts,1:ncout) = mat(ksum(mrows*(0:npts-1)',rdatacv),cdata);
   else
     error('column or row data out of range')
     return
   end
 elseif mtype == 'syst'
   if max(cdata) <= mcols & min(cdata) > 0 ...
     & max(rdata) <= mrows & min(rdata) > 0
     [nnr,nnc] = size(cdata);
     if nnc == 1
	cdata = cdata';
     end
     cols = [1:mnum mnum+cdata nc];
     [nnr,nnc] = size(rdata);
     if nnc == 1
	rdata = rdata';
     end
     rows = [1:mnum mnum+rdata nr];
     out = mat(rows,cols);
   else
     error('input or output data out of range')
     return
   end
 elseif mtype == 'cons'
   if max(cdata) <= mcols & min(cdata) > 0 ...
      & max(rdata) <= mrows & min(rdata) > 0
     out = mat(rdata,cdata);
   else
     error('column or row data out of range')
     return
   end
 else
   out = [];
 end