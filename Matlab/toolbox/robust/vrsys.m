function [v,n]=vrsys(s)
%VRSYS Verify system matrix type.
%
% [VARS,N] = VRSYS(NAME) returns string VARS and an integer N where VARS
%      contains the list of N variable names associated with a system
%      having system name NAME.  A valid system name is a string of the form
%             NAME = [TY '_' SUF]
%      where SUF is a suffix string which is appended to standard
%      variable names in a list determined by the string TY as follows:
% -----   -------------------------------  ---------------------------
% TY      VAR prior to appending suffixes  Description
% -----   -------------------------------  ---------------------------
% 'ss'    'a,b,c,d'                        Standard State-space (default)
% 'des'   'a,b,c,d,e'                      Descriptor System
% 'tss'   'a,b1,b2,c1,c2,d11,d12,d21,d22'  Two-port State-space
% 'tdes'  'a,b1,b2,c1,c2,d11,d12,d21,d22,e'Two-port Descriptor
% 'gsm'   'sm,dimx,dimu,dimy'              General state-space
% 'gdes'  'e,sm,dimx,dimu,dimy'            General descriptor
% 'gpsm'  'psm,deg,dimx,dimu,dimy'         General polynom. sys. matrix
% 'tf'    'num,den'                        Transfer function
% 'tfm'   'num,den,n,m'                    Transfer function matrix
% 'sm'    'sm,dim'                         State-space system matrix
% 'tsm'   'tsm,dim'                        Two-port state-space sys. mat.
% 'imp'   'y,ts,nu,ny'                     Impulse response
% ----------------------------------------------------------------------
% A capital TY string returns the string VAR as above, but in capitals.

% R. Y. Chiang & M. G. Safonov 10/25/90 (Rev 3/21/95)
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

   % Remove any spaces
   ind=find(s==' ');
   if length((ind))>0,
      s(ind)='';
   end

   % Get SUF and TY
   s = ['_' s '_'];
   ind=find(s=='_');
   [rind,cind]=size(ind);
   if ind(2)-ind(1)>1,
       ty = s(ind(1)+1:ind(2)-1);
   else
       ty ='ss';
   end
   if cind==2,
      suf = '';
   else
      suf = s(ind(2)+1:ind(3)-1);
   end

   if length((ty))==0, ty='ss',end

   ty1=ty;

   % if ty is capital, set CAPFLAG and convert to lowercase
   if ty(1)<'a',
      capflag=1;
      ty=ty+('a'-'A')*ones(1,size(ty)*[0;1]);
   else
      capflag=0;
   end

   % Pad ty with spaces to length 4
   ty=[ty '    '];
   ty=ty(1:4);

   % Assemble the string V containing variable names without SUF
   if ty=='gsm ',                  % General state-space
       v='sm,dimx,dimu,dimy';
   elseif ty=='gdes',              % General descriptor
       v='e,sm,dimx,dimu,dimy';
   elseif ty=='gpsm';              % General polynom. sys. matrix
       v='psm,deg,dimx,dimu,dimy';
   elseif ty=='ss  '               % Standard State-space
       v='a,b,c,d';
   elseif ty=='des ';              % Descriptor System
       v='a,b,c,d,e';
   elseif ty=='tss '               % Two-port State-space
       v='a,b1,b2,c1,c2,d11,d12,d21,d22';
   elseif ty=='tdes'               % Two-port Descriptor
       v='a,b1,b2,c1,c2,d11,d12,d21,d22,e';
   elseif ty=='tf  '
       v='num,den';
   elseif ty=='tfm '
       v='num,den,n,m';
   elseif ty=='sm  '
       v='sm,dim';
   elseif ty=='tsm '
       v='tsm,dim';
   elseif ty=='imp '
       v='y,ts,nu,ny';
   else
       v=['Error, invalid system type designator ''' ty1 ''''];
       n=0;
       return
   end

   % Capitalize V if needed
   if capflag==1,
      ind=find(v>='a');
      v(ind)=v(ind)+('A'-'a')*ones(1,size(ind)*[0;1]);
   end

   % Now insert suffix just after alphabetic part of each variable name
   v = [',' v ','];
   ind = find(v==',');
   [rind,cind]=size(ind);
   vtemp='';
   for j=1:cind-1,
      vj=v(ind(j)+1:ind(j+1)-1);
      nj=find(vj<'A');
      if length((nj))>0,
         [rvj,cvj]=size(vj);
         vj1=vj(1:nj(1)-1);
         vj2=vj(nj(1):cvj);
      else
         vj1 =vj;
         vj2 ='';
      end
      vtemp= [vtemp ',' vj1 suf vj2];
   end
   n=length((find(vtemp==',')));
   vtemp(1)='';  % Remove leading comma
   v=vtemp;
% ------- End of VRSYS.M -----------RYC/MGS 10/25/90 %