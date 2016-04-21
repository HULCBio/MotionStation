function [varargout] = branch(tr,varargin)
% BRANCH Branch of "TREE" variable (optional system matrix data structure).
%
% [B1,B2,...,BN] = BRANCH(SYS) or
% [B1,B2,...,BN] = BRANCH(SYS,V1,...VN) returns N system data
%     matrices [B1,...,BN] from an LTI system; optional inputs V1,...VN
%     are string names of variables to be retrieved. The list of
%     valid names V1,...,VN for SYS is returned by BRANCH(SYS,0).
%
% [B1,B2,...,BN] = BRANCH(TR,PATH1,PATH2,...,PATHN) returns N sub-branches
%     of a tree variable created by TREE.  If NARGIN==1, the root branches
%     are returned in sequence by numerical index; otherwise, the
%     branches returned are determined by the paths PATH1, PATH2,...,PATHN.
%     Each path is normally a STRING of the form
%           PATH = '/name1/name2/.../namen'
%     where name1,name2, et cetera are the string names of the branches
%     which define the path from the tree root to the sub-branch of
%     interest.  Alternatively, one may substitute for any PATH a row
%     vector containing the integer indices of the branches which define
%     the PATH.  For example, if S=TREE('a,b,c','foo',[49 50],'bar') then
%     BRANCH(S,'c') and BRANCH(S,3) both return the value 'bar'.
%
%  See also ISTREE, TREE, MKSYS, BRANCH.

%
% R. Y. Chiang & M. G. Safonov 10/01/90 (rev. 9/21/97, 4/22/98)
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.9.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

% Initialize
nin = nargin-1;
if nin==-1,error('no input specified'),end
n=max([nargout,1]);
varargout=cell(1,n);

% If MUTOOLS PCK system, convert to LTI 
if exist('minfo')==2,       % If Mu Synthesis Toolbox is installed,
   tr=mu2lti(tr);           % convert old mu PCK systems to LTI/SS                
end

% Get branches [B1,...,BN] of LTI's created by MKSYS using MKARGS5X
if isa(tr,'lti')
   % Determine MKSYS system type TY and number of variables
   [flag,ty,nvars]=issystem(tr);
   if nin==0,
       temp=cell(1,nvars+1);
       [emsg,nag1,xsflag,Ts,temp{1:nvars}]=mkargs5x({ty},{tr});error(emsg);
       temp{nvars+1}=ty;
       varargout(1:n)=temp(1:n);
   elseif nin==1 & n==1 & issame(varargin{1},0),  % Case B1=BRANCH(SYS,0)
      varargout{1}=[vrsys(ty) ',ty' ];
   else % retrieve data matrices specified by V1,...,VN 
      
      % Put VRSYS(TY) &  'ty,Ts' cell vector VARS
      temp=[',' vrsys(ty) ',ty,Ts,'];
      ind=find(temp==',');         
      vars=cell(1,nvars+2);
      for i=1:nvars+2, vars{i}=temp(ind(i)+1:ind(i+1)-1); end
      
      % Put data matrices in cell-vector TEMP
      temp=cell(1,nvars+2);
      [emsg,nag1,xsflag,Ts,temp{1:nvars}]=mkargs5x({ty},{tr}); error(emsg);
      temp{nvars+1}=ty;
      temp{nvars+2}=Ts;
      % Write data to [B1,...,BN], as determined by [V1,...,VN]
      k=0; % index counter for B1,...,BN
      for i=1:nin, 
         inds=varargin{i};
         ind=zeros(0,1);
         % ind=indices specified by Vi:
         if isstr(inds), % Case: string names for variables
            while any(inds),
               [nm,inds]=strtok(inds,',');
               tmpind=strmatch(nm,vars,'exact');
               if length(tmpind)==0, 
                  error(['There is no variable ''' nm ''' associated with system type ''' ty ''''])
               else
                  ind=[ind; tmpind];
               end
            end
         elseif isa(inds,'double') & length(inds)==1 & fix(inds)==inds & inds>0 & inds<nvars+2,
               % case of numerical index specification (instead of string name)
               ind=inds;
         else
            index=inds,
            error(['Index must be an integer between 1 and ' sprintf('%d',nvars+1)])
         end
         kk=k+length(ind);
         varargout(k+1:kk)=temp(ind);
         k=kk;
         if k==n,
            return % DONE
         end         
      end
      if n>k, error('Too many output arguments'), end
   end
   return % DONE
end

%


magic1 = 29816; % Every tree vector TR includes these two "magic numbers"
magic2 = 18341; % in postions TR(2) and TR(3) for identification purposes.

%  Check that TR is a tree
msg='first input argument must be either a TREE or an LTI created by MKSYS';
%  Check that TR is a vector and has length at least 5
if max(size(tr))<6 | min(size(tr))~=1,
  error(msg);
end
% If TR is a row vector, transpose it
tr=tr(:);
% Check magic numbers to ensure that TR is a tree
if tr(2)~=magic1 |tr(3)~=magic2
  error(msg);
end

% Now get the paths I1,...,IN:
% If no paths specified, assign values I1=1,...,IN=n; otherwise
% copy Ij's from Jj's, breaking up string Jj's at commas.
if nin==0,
   for j=1:n,
      temp=['i' sprintf('%d',j) '=' sprintf('%d',j) ';'];
      eval(temp);
   end
   iind=n;
end
if nin>0,
  iind=0;
  for jind=1:nin,
     %% eval(['jj=j' sprintf('%d',jind) ';']),
     jj=varargin{jind};
     if isstr(jj),             % If Jj is a string, create one
        jj=[',' jj ','];       % extra Ij for each comma in Jj
        ind=find(jj==',');
        [rind,cind]=size(ind);
        for j=1:cind-1,
            iind=iind+1;
            ptr1=ind(j)+1;
            ptr2=ind(j+1)-1;
            eval(['i' sprintf('%d',iind) '=jj(ptr1:ptr2);']),
        end
     else                      % otherwise, simply copy Jj onto Ij
        iind=iind+1;
        eval(['i' sprintf('%d',iind) '=jj;'])
     end
  end
end
nin=iind;

% Number of paths must not be less the NARGOUT
if n>nin,
   msg ='Too many output arguments.';
   error(msg),
end

%  For each J=1,...,N follow path IJ to get branch BJ
for j = 1:n,
   temp =['ij = i' sprintf('%d',j) ';'];  % IJ = Ij
   eval(temp);
   [rj,cj]=size(ij);
   if rj~=1 | cj==0,error('invalid path or index'),end
   if isstr(ij),           % case of string-name path IJ=PATHJ
      flag=1;
      ij=[ij '/'];           % append extra '/' to string ij
      if ij(1)~='/',ij=['/' ij];end  %if missing add leading '/'
      pptrj=find(ij=='/');   % PPTRJ = pointers to /'s in PATH IJ
      lj=max(size(pptrj))-1; % path length (number of names)
   else                      % case of numeric path INDEX IJ
      flag=0;
      lj=max(size(ij));      % path length (number of indices)
   end
   x = tr;
   % Now descend tree X one branch at a time, recursively
   % overwriting X with root branch having index IJ(K)
   for k=1:lj,
     % Check to make sure X is a TREE
     if max(size(x))<6 | min(size(x))~=1,
       error('Invalid path or branch');
     end
     if x(2)~=magic1 |x(3)~=magic2
        error('Invalid path or branch');
     end

     [rx1,cx1]=size(x);
     if flag ==1,
        nm = branch(x,0);
        nm=[',' nm ','];  % nm = ',name1,name2,..,namen,'

        % Now get k-th name in pathj
        if pptrj(k+1)-pptrj(k)>1,
            nmjk = ij(pptrj(k)+1:pptrj(k+1)-1);
        else
            error('empty string encountered in path')
        end

        if max(nmjk)<='9' & min(nmjk)>=0,  % If NMJK contains a string
           [rnmjk,cnmjk]=size(nmjk);       % representation of an
           njk=0;                          % integer, set NJK equal
           for jjj=1:cnmjk,                % to that integer
               njk=nmjk(jjj)-'0'+10*njk;
           end
        else                               % otherwise...
           % compare NMJK with names in NM and set
           % NJK = (position in nm of name matching NMJK); if no
           % match found then set fflag = 0 and announce error
           nmptr=find(nm==',');
           nnm = max(size(nmptr))-1; % number branch names in nm
           fflag=0;
           iter=0;
           while fflag==0 & iter<nnm
              temp=nm(nmptr(iter+1)+1:nmptr(iter+2)-1);
              if size(nmjk)==size(temp),    % if match found
                 if nmjk==temp,             % set NJK=ITER+1
                   njk=iter+1;              % and exit while
                   fflag=1;                 % loop
                 end
              end
              iter=iter+1;
           end
           if fflag==0,
              error(['branch ' ij(1:pptrj(k+1)-1) ' not present']);
           end
        end
     else
        njk = ij(k);
     end
     msg=['branch B' sprintf('%d',j) ' index out of range'];
     if njk>x(1)| njk<0 | njk+6>rx1, error(msg),end
     ptr1 = x(njk+6);   % points to start of njk-th subfield of DAT
     if ptr1~=1,
         rx = x(ptr1);  % rows of branch
         if rx1>=ptr1+1,
            cx = x(ptr1+1);   % cols of x
         else
            error('Invalid path or branch')
         end
     else
         rx=0;          % empty matrix is indicated by ptr1=1
     %% WAS ADDED 1 LINE for to handle non-square empty matrix
         cx=0;
     end
     if rx<0,     % RX is negative if the branch contains string data
          rx = abs(x(ptr1));
          sflag=1;
     else
          sflag=0;
     end
     lx= rx*cx;       % length of x
     if lx>0 & ptr1+lx+1<=rx1,  % if new X empty and old X is big enough
        xcol = x(ptr1+2:ptr1+lx+1); % Store new X data into XCOL
        x = zeros(rx,cx);      % Create a new X matrix of correct dimension
        x(:) = xcol(:);        % Now fill in new X with XCOL data
     elseif lx==0,
%% WAS CHANGED 1 LINE to handle non-square empty matrix
%%        x=[];
        x=zeros(rx,cx);
     else
        error('invalid path or index')
     end
   end
   if sflag==1,
      x=setstr(x);  %set string bit
   end
   %% temp=['b' sprintf('%d',j) ' = x;'];
   %% eval(temp);
   varargout{j}=x;
end
% ------ End of BRANCH.M --- RYC/MGS 10/05/90 (rev 9/97)%
