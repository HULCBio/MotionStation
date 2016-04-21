% function pim = ipii(pim,item,i1,i2)
%
%   IPII: Insert Packed Indexed Item
%
%       If indexed item (by i) already exists in PIM,
%       then it is overwritten with ITEM.  If the
%       i'th item does not exist, the ITEM becomes the
%       i'th indexed element of PIM.
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function pim = ipii(pim,item,i1,i2)

 largenum = 123456;

 if nargin < 3
    error('IPII needs 3 arguments');
   return
 end
 if nargin==3
    if floor(i1)~=ceil(i1) | i1<1
        error('Index must be a positive integer');
        return
    end
    i2 = 1;
 elseif nargin == 4
    if any(floor([i1;i2])~=ceil([i1;i2])) | i1<1 | i2<1
        error('Indices must be positive integers');
        return
    end
 end

 if isempty(pim)
    rowd = [];
    cold = [];
    num = 0;
    datavec = [];
    repindex = [];
    a = [];
    if nargin == 3
        ldpim = largenum;
        i = i1;
    elseif nargin == 4
        ldpim = i1;
        i = i1 + ldpim*(i2-1);
    end
 else
    ldpim = pim(1);
    if i1>ldpim & ldpim>0
        error('Leading dimension not sufficient')
        return
    elseif ldpim==largenum & i2>1
        error('PIM is a column PIM - change lead_dim for ARRAY PIM');
        return
    else
        i = i1 + ldpim*(i2-1);
    end
    num = pim(3);        % how many are in there
    repindex = pim(4:3+1*num); % indices of present ones
    rowd = pim(4+1*num:3+2*num); % row data
    cold = pim(4+2*num:3+3*num); % column data
    %   datavec = pim(4+3*num:length(pim)); % actual data
    a = find(repindex == i);
 end


 [rd,cd] = size(item);
 if isstr(item)
   rd = -rd;
   item = abs(item);
 end
 if isempty(a)
   % Remove a warning about incommensurate empty array (size [1 0])  GJW 09/06/96
   if isempty(pim)
     pim = [ldpim;inf;num+1;repindex;i;rowd;rd;cold;cd;reshape(item,abs(rd)*cd,1)];
   else
%    pim = [ldpim;num+1;repindex;i;rowd;rd;cold;cd;datavec;reshape(item,abs(rd)*cd,1)];
     pim = [ldpim;inf;num+1;repindex;i;rowd;rd;cold;cd;pim(4+3*num:length(pim));reshape(item,abs(rd)*cd,1)];
   end
 else
   lenv = abs(rowd).*cold;
   if lenv(a)==abs(rd*cd);
     pim(num+3+a) = rd;
     pim(2*num+3+a) = cd;
     sp = sum(lenv(1:a-1));
     pim(3*num+4+sp:3*num+3+sp+lenv(a)) = reshape(item,abs(rd)*cd,1);
   else
     sp1 = sum(lenv(1:a-1));
     sp2 = sp1 + lenv(a);
     datavec = pim(4+3*num:length(pim));

     % the next is actually used
     %     pim([4+3*num:3+3*num+sp1 sp2+4+3*num:sum(lenv)+3*num+3]);

     % protect against non-commensurate empty matrices  GJW 09/10/96
     % pim = [ldpim;inf;num;...
     %  repindex(1:a-1);repindex(a+1:num);i; ...
     %  rowd(1:a-1);rowd(a+1:num);rd; ...
     %  cold(1:a-1);cold(a+1:num);cd; ...
     %  datavec([1:sp1 sp2+1:sum(lenv)]); reshape(item,abs(rd)*cd,1)];

     % One more bit of protection  GJW 09/11/96
     foo = datavec([1:sp1 sp2+1:sum(lenv)]);
     if length(foo) == 0
       foo = [];
     end;

     pim = [ldpim;inf;num;...
      repindex(1:a-1,1);repindex(a+1:num,1);i; ...
      rowd(1:a-1,1);rowd(a+1:num,1);rd; ...
      cold(1:a-1,1);cold(a+1:num,1);cd; ...
      foo; reshape(item,abs(rd)*cd,1)];
   end
 end