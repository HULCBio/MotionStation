function varargout=rct2lti(varargin)
% VARARGOUT=RCT2LTI(VARARGIN) copies input argument list onto output
%   list, converting any obsolete MKSYS, LTISYS or PCK systems into 
%   LTI systems.  Supported MKSYS system types are
%     'ss', 'tss', 'des', 'tdes', 'tf' and 'tfm'. 
%
% See also:  MKSYS, LTI

% R. Y. Chiang & M. G. Safonov 9/27/97
% Revised M. G. Safonov 4/4/98
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.5.4.3 $
% All rights reserved.

varargout=varargin;
for k=1:nargin;
   sys=varargin{k};
   if istree(sys) & sys(4)==27591,, % If SYS is a MKSYS system,
       Ts=0;
       [i,ty,n]=issystem(sys);
       temp=cell(1,n);
       [temp{:}]=branch(sys);         % extract data matrices from sys
       if i & sys(1)>n+1 & istree(sys,'Ts'),
          Ts=branch(sys,'Ts');
       end
       varargout{k}=mklti(temp{:},Ts,ty);       %  then convert SYS to lti
   else
       varargout{k}=mu2lti(sys);  % If PCK, then convert to lti
   end
end
% ----------- End of RCT2LTI.M --------RYC/MGS 1997
