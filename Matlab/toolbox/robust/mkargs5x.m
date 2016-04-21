function [emsg,nag1,xsflag,ts,varargout]=mkargs5x(types,inargs)
%  [EMSG,NAG1,XSFLAG,TS,O1,...,ON]= MKARGS5X(TYPES,INARGS) sequentially
%     writes the contents of cell-vector INARGS={I1,...,IM} onto the
%     outputs O1,...ON, expanding each LTI object to its corresponding 
%     data matrices.  Obsolete MKSYS or PCK systems, if present,  
%     are converted to LTI before expansion.  Cell-vector TYPES 
%     specifies data format.  For example, TYPES = {'ss','tf'} indicates
%     that the first LTI object in list {I1,...,IM} expands to its
%     state-space (a,b,c,d) matrices and each subsequent LTI object 
%     expands to (num,den) vectors.  Admissible values are:
%       TYPES      Expansion                  Expanded Objects
%                  Description                Number & Type
%       'ss'   --- [a,b,c,d]=ssdata(sys)         4     matrices
%       'des'  --- [a,b,c,d,e]=dssdata(sys)      5     matrices 
%       'tss'  --- [a,b1,b2,c1,c2,d11,...        9     matrices
%                    d12,d21,d22] state-space
%       'tdes' --- [a,b1,b2,c1,c2,d11,...        10    matrices
%                    d12,d21,d22,e] descriptor
%       'tf'   --- [num,den] (SIMO only)         2     matrices
%       'tfm'  --- [num,den,n,m] (MIMO)          4     num matrix,
%                                                      den vector,
%                                                      n m integers
%       'lti'  --- LTI (no expansion)            1     LTI  Object 
%               
%     NAG1 returns the number of outputs O1,...,ON written; excess
%         outputs are returned as NaN's.
%     XSFLAG=1, if any LTI objects are in INARGS; otherwise XSFLAG=0.
%     TS returns LTI object sampling time (default: TS=0).
%     EMSG returns and error message, empty if no error     

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.7.4.3 $
% All rights reserved.

%     Programmer's Note:
%     MKARGS5X facilitates 'one-line' conversion of Control/Robust/Mu 
%     Toolbox functions to accept LTI object inputs while preserving 
%     compatability with earlier non-LTI syntax.  It also recognizes 
%     obsolete system objects previously used by Mu & Robust Toolboxes,
%     performing appropriate conversions where possible.
%
%     EXAMPLE: 'ONE LINE' CONVERSION OF A FICTITIOUS FUNCTION (MYADD.M)
%       function [a,b,c,d]=myadd(varargin)         % input arg's replaced by varargin
%       % SYS=MYADD (SYS1,SYS2)                     (new LTI syntax), or
%       % [A,B,C,D]=MYADD (A1,B1,C1,D1,A2,B2,C2,D2) (original non-LTI syntax)
%       % adds two LTI systems SYS=SYS1+SYS2
%   
%       % Input data replacement ('one-line'):
%       [emsg,nag1,xsflag,ts,a1,b1,c1,d1,a2,b2,c2,d2]=mkargs5x('ss',varargin);
%
%       % main body of old function:
%       a=diagmx(a1,a2); b=[b1;b2]; c=[c1,c2]; d=d1+d2;
% 
%       % Output data replacement ('one-line'):
%       if xsflag, a=ss(a,b,c,d,ts), end
% 
%       % --------End of Sample LTI Converion of MYADD .M -------

emsg='';
if nargin<2, error('Too few input arguments'); end

% If TYPES is comma-separated-strings, put the strings in a cell vector
if isstr(types),
   f=types;
   nf=0;
   types={};
   if min(size(f))>0,
      fflag=1;            % FFLAG nonzero indicates admissible system types are
      f=[',' f ', '];     % restricted to values in string F.
      f(find(f==' '))=''; % Remove spaces from F.
      ind=find(f==',');   % IND = indices of commas in string F
      nf=max(size(ind))-1;% Number of system types specified in F
      types=cell(1,nf);
   end   
   for i=1:nf,
      types{i}=f(ind(i)+1:ind(i+1)-1);
   end   
end

% Check types 
if length(types)==0,
   types=cell(1,1); 
end 

% initialize variables
ts=0;
nin=length(inargs);
nout=nargout-3;         % length({O1,...,ON})
varargout=cell(1,nout); % {O1,...,ON}
temp=cell(1,10);        % empty cell array for temporary LTI data storage
ntypes=length(types);
xsflag=logical(0);      % FALSE; becomes TRUE if any LTI objects in INARGS
kk=0;   % index-counter for TYPES; stops counting if KK=NTYPES
j=0;    % index-counter for VARARGOUT; returns value NAG1.

for k=1:nin,  % index-counter for INARGS
   o=inargs{k};
   [i,ty,n]=issystem(o);   % [i,ty,nn]=issystem(o);
   % CASE 1: if O is not a system
   if ~i, 
      n=1;
      temp{1}=o;
   else  % else O is a system
     if kk < ntypes, kk=kk+1; end
     ty1=lower(types{kk});
     if isempty(ty1),           % if no type specified
         ty1=ty; % default to TY1=TY 
     end
     % CASE 2: if system O is already of right type TY
     if ~isa(o,'lti') & issame(ty1,ty),
        [temp{1:n}]=branch(o);
        oTs=0;
        if istree(o,'Ts'),  
          oTs=branch(o,'Ts');
        end
        if xsflag, % make sure all sampling times are the same
           if xor(ts,oTs),
              emsg='Cannot mix discrete and continuous-time LTI objects in INARGS'; return
           elseif ts >0 & oTs >0 & ts~=oTs,
            emsg='All discrete-time LTI objects in INARGS must have the same Ts'; return
           else
              ts=max([ts,oTs]);
           end
        else
          ts=oTs;
        end      
        xsflag=logical(1);     % set XSFLAG=TRUE
     % CASE 3: O is a system which must be converted to specified type TYPES{kk}      
     else
        o=rct2lti(inargs{k});  % convert system O to LTI if not already LTI
        if ~isa(o,'lti'), 
             disp(o); 
             emsg=['System type ' ty ' found where type ' ty1 ' expected']; return
          end
          % Get sampling time
          oTs=get(o,'Ts'); 
          if xsflag, % make sure all sampling times are the same
             if xor(ts,oTs),
                emsg='Cannot mix discrete and continuous-time LTI objects in INARGS'; return
             elseif ts >0 & oTs >0 & ts~=oTs,
                emsg='All discrete-time LTI objects in INARGS must have the same Ts'; return
             else
                ts=max([ts,oTs]);
             end
          else
             ts=oTs;
          end
          xsflag=logical(1);     % set XSFLAG=TRUE
          switch ty1
          case {'lti'}  % LTI (no expansion)
             n=1;
             temp{1}=o;
          case {'ss'}   % state space [a,b,c,d]
             n=4;
             [temp{1:n}]=ssdata(o);  
          case {'tss'}  % two-port state-space [a,b1,b2,c1,c2,d11,d12,d21,d22]
             n=9;
             if ~istito(o), 
                emsg='Encountered non-partitioned SYS where two-port expected.';
                return
             end
             [temp{1:n}]=tssdata(o);
          case {'tdss','tdes'}  % two-port state-space [a,b1,b2,c1,c2,d11,d12,d21,d22]
             n=10;
             if ~istito(o), 
                emsg='Encountered non-partitioned SYS where two-port expected.';
                return
             end
             [temp{1:n-1}]=tssdata(o);
             temp{n}=get(o,'e');
          case {'dss','des'}  % descriptor [a,b,c,d,e]
             n=5;
             [temp{1:n}]=dssdata(o);
          case {'tfm','tf'}   % MIMO transfer function [num,den,n,m]
             if isequal(ty1,'tf'), 
                n=2;
                if size(o,2)>1, 
                   disp(o)
                   emsg='Encountered multi-input tf in input where single-input tf expected.'; return
                end  
             else
                n=4;
             end
             [temp{3:4}]=size(o);  % n,m
             [num,den]=tfdata(o);
             num = cat(1,num(:));  % reshape num
             den = cat(1,den(:));  % reshape den
             nm=length(num);
             if nm>1, % if not SISO
                numdeg=zeros(nm,1);dendeg=numdeg;
                for i=1:nm, %determine length of num's & den's
                   numdeg(i)=length(num{i});
                   dendeg(i)=length(den{i});
                end
                nummax=max(numdeg);
                denmax=max(dendeg);
                for i=1:nm, % now pad with zeros to make lengths the same
                   num{i}=[zeros(1,nummax-numdeg(i)) num{i}(:)'];
                   den{i}=[zeros(1,denmax-dendeg(i)) den{i}(:)'];
                end 
             end
             nummat=cat(1,num{:}); % extract data from cells
             denmat=cat(1,den{:}); %
             if size(denmat,1)>1 & norm(diff(denmat),1)<eps,
                denmat=denmat(1,:);
             end
             temp{1}=nummat;
             temp{2}=denmat;
          otherwise
             emsg=['System of MKSYS type ''' ty ''' found where type ''' types{kk} ''' required']; return   
          end
       end
    end
    jj=j+n;
    if jj>nout,
       emsg='Too few output arguments to complete MKSYS system data expansion.'; return
    else
       varargout(j+1:jj)=temp(1:n);
       j=jj;
    end
end
nag1=j;  % Number of outputs O1,...,ON required to complete LTI data expansion

% fill any extra outputs with NaN's
while j<nout,
   j=j+1;
   varargout{j}=NaN;
end


% -----------End of MKARGS5X.M ----------RYC/MGS 1997  

