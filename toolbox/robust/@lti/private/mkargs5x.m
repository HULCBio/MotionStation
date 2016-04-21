function [emsg,nag1,xsflag,ts,varargout]=mkargs5x(types,inargs)

%  LTI/PRIVATE/MKARGS5X 
%  [EMSG,NAG1,XSFLAG,TS,O1,...,ON]= MKARGS5X(TYPES,INARGS) is like MKARGS5X, 
%     but does not accept PCK or MKSYS systems.  An error also results if
%     INARGS contains LTI's of types ZPK or TF but none of type SS.
%
% R. Y. Chiang & M. G. Safonov (4/3/98)
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.7.4.4 $

emsg='';
ssflag=0;

if nargin<2, error('Too few input arguments');  end

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
nout=nargout-4;         % length({O1,...,ON})
varargout=cell(1,nout); % {O1,...,ON}
temp=cell(1,10);        % empty cell array for temporary LTI data storage
ntypes=length(types);
xsflag=0;      % FALSE; becomes TRUE if any LTI objects in INARGS
kk=0;   % index-counter for TYPES; stops counting if KK=NTYPES
j=0;    % index-counter for VARARGOUT; returns value NAG1.

for k=1:nin,  % index-counter for INARGS
   o=inargs{k};
   
   % If MKSYS or PCK, then terminate with an informative error 
   if istree(o) & o(4)==27591,,  % If O is a MKSYS system
      disp('MKSYS and LTI systems found together');
      emsg='Use RCT2LTI to convert MKSYS to LTI'; 
      return;
   elseif exist('minfo')==2,        % Else, if Mu Synthesis Toolbox is installed,
      [info,junk,junk,junk]=feval('minfo',o);    
      if strcmp(info,'syst'),     % and if o is a Mu Toolbox PCK system
         disp(o);
         disp('PCK and LTI systems found together');
         emsg='Use RCT2LTI to convert PCK to LTI';
         return
      end
   end
   
   % For each of 3 possible cases, determine n and place data matrices in temp{1:n}:
   if isa(o,'lti')           % Case 1: If LTI system data-type
      %% WAS if get(o,'Td'), emsg='Non-zero delay SYS.Td found where zero delay expected'; return, end
      if hasdelay(o), emsg='Non-zero delay SYS.Td found where zero delay expected'; return, end
      % Get sampling time
      oTs=get(o,'Ts'); 
      if xsflag, % make sure all sampling times are the same
         if xor(ts,oTs),
            emsg='Cannot mix discrete and continuous-time LTI objects in INARGS';
            return
         elseif ts >0 & oTs >0 & ts~=oTs,
            emsg='All discrete-time LTI objects in INARGS must have the same Ts';
            return
         else
            ts=max([ts,oTs]);
         end
      else
         ts=oTs;
      end
      xsflag=1;
      ssflag = ssflag | isa(o,'ss');     % if lti/ss present, then set SSFLAG=TRUE
      if kk < ntypes, kk=kk+1; end
      ty1=lower(types{kk});
      if isempty(ty1),           % if no type specified
         [junk,ty1]=issystem(o); % default to TY1 
      end
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
               emsg='Encountered multi-input tf in input where single-input tf expected.';
            return
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
         if exist('issystem')==2 & feval('issystem',o),   % issystem(o);
            [i,ty,n]=feval('issystem',o);
            if issame(types{kk},ty) | length(types{kk})==0,               
               [temp{1:n}]=feval('branch',o); % [temp{1:n}]=branch(o);
            else
               emsg=['MKSYS system type ''' ty ''' found where type ''' types{kk} ''' required'];
               return
            end
         else            
            emsg=['Cannot expand an LTI object of type ''' ty '''' ];
            return
         end
      end      
   else % Case 2: if other than LTI
      n=1;
      temp{1}=o;
   end
   jj=j+n;
   if jj>nout,
      emsg='Too few output arguments to complete LTI data expansion.';
      return
   else
      varargout(j+1:jj)=temp(1:n);
      j=jj;
   end
end

% If no LTI/SS's found, terminate with error
if ~ssflag, 
   disp('LTI input arguments must include at least one of type SS'),
   emsg='Use SS(SYS) to convert LTI''s of types ZPK and TF to type SS';
   return
end

nag1=j;  % Number of outputs O1,...,ON required to complete LTI data expansion

% fill any extra outputs with NaN's
while j<nout,
   j=j+1;
   varargout{j}=NaN;
end


% -----------End of MKARGS5X.M ----------RYC/MGS 1997  

function [a,b1,b2,c1,c2,d11,d12,d21,d22]=tssdata(sys)
% [A,B1,B2,C1,C2,D11,D12,D21,D22]=tssdata(sys) extracts partitioned
%    state-space matrices from a TITO (two-input-two-output) system.
%
% See also:  ISTITO, MKTITO

% R. Y. Chiang & M. G. Safonov

[tito,u1,u2,y1,y2]=istito(sys);
%if ~tito,
%   error('SYS must be TITO')
%   return
%end

[a,b,c,d,e]=dssdata(sys);

b1=b(:,u1); b2 =b(:,u2);
c1=c(y1,:); c2 =c(y2,:);
d11=d(y1,u1);  d12=d(y1,u2);
d21=d(y2,u1);  d22=d(y2,u2);
% ----------- End of TSSDATA.M --------RYC/MGS 1997

function [tito,U1,U2,Y1,Y2]=istito(sys)
% [TITO,U1,U2,Y1,Y2]=ISTITO(SYS) tests whether a system has at
%    least two InputGroup and two OutputGroup channels.
%    If not, it returns TITO=0 (false); otherwise, TITO=1 (true)
%    is returned along with TITO channel indices in row vectors:
%        U1 = first input channel indices
%        U2 = second input channel indices
%        Y1 = first output channel indices
%        Y2 = second output channel indices
%
%  See also MKTITO

% R. Y. Chiang & M. G. Safonov

% Based on Gahinet's 1/98 partitioning specification:

% Initialize output variables:
tito=logical(1);
U1=[]; U2=[]; Y1=[]; Y2=[];

ip=get(sys,'InputGroup');
op=get(sys,'OutputGroup');

if isstruct(ip)
    ip=struct2cell(ip);
    op=struct2cell(op);
end

[rip,cip]=size(ip);
[rop,cop]=size(op);
if rip<2 | rop<2,
   tito=logical(0);   % no InputGroup present,
   return             % so set TITO=0 and exit
else
   tito=logical(1);
end

% quick return if U1 & U2 not needed
if nargout<2, 
   return 
end

U1=ip{1,1};
U2=ip{2,1};
Y1=op{1,1};
Y2=op{2,1};
    
% ----------- End of ISTITO.M --------RYC/MGS 1997

