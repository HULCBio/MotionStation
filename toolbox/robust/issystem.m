function [i,ty,n]=issystem(x)
% ISSYSTEM System matrix check (LTI or MKSYS or PCK or LTISYS).
%
%  [I,TY,N]=ISSYSTEM(X) checks whether or not X is a system such
%  as is created by either MKSYS, MKLTI, PCK, LTISS, SS, TF, 
%  or ZPK.  If X is a system, then
%                I    =  1  
%                TY   =  MKSYS equivalent system type
%                N    =  number of matrices in the system (depends on TY)
%  Otherwise, I=0, TY=[] and N=0.
%
%  See also MKLTI, MKSYS, PCK, LTISYS and BRANCH.

% R. Y. Chiang & M. G. Safonov 10/25/90 (rewritten for LTI 9/21/97)
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.8.4.3 $
% All Rights Reserved.

% Initialize
i=0;
ty=[];
n=0;

x=mu2lti(x);           % convert old mu PCK systems to LTI/SS                

% Check each of three possible cases:
if isa(x,'lti') 
   i=1;
   if nargout <2, return, end % quick return
   % Identify mksys-equivalent type of lti object X
   ty=class(x);
   if nargout <3, return, end % quick return
   switch ty
   case {'ss'}
      e=x.e;
      if ~isempty(e) & ~isequal(e,eye(size(x.a))),
         ty='des';
      end
      [it]=istito(x);
      if it,
         ty=['t' ty]; 
      end
   case {'tf','zpk'}  % treat all zpk's & tf's as tfm's, even if SISO
      %if size(x,2)==1, % single-input tf
      %   ty='tfm';
      % end
      ty='tfm';
   otherwise
      error(['LTI system of class ' ty ' has no MKSYS equivalent type'])
   end
   [junk,n]=vrsys(ty);
elseif isa(x,'double') & length(x)>3 & isequal(x(2:4),[29816;18341;27591]),
   % Case 2: old MKSYS TREE system
   %[i,ty]=istree(x,'ty');         % 27591 "magic number" MKSYS tree identifier
   i=1;
   ty=branch(x,'ty');
   [junk,n]=vrsys(ty);
end
% ----------- End of ISSYSTEM.M --------RYC/MGS 1997
