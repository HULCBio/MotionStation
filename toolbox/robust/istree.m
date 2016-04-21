function [y,b] = istree(tr,ij)
%ISTREE Check "TREE" variable.
%
% I=istree(X) returns I=1 if X is a tree (e.g, as created by the
%     function TREE); otherwise it returns I=0.
%
% [I,B]=ISTREE(X,PATH) returns I=1 if both X is a tree and PATH is
%     a valid PATH in the tree X; otherwise it returns I=0.  If the
%     optional output argument B is present, then B returns the value
%     of the branch specified by PATH, provided X is a tree and PATH
%     is a valid path in X.
%

% R. Y. Chiang & M. G. Safonov 10/01/90
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

%  This function uses essentially the same code as BRANCH with only
%  minor modification at beginning and end of code, and the replacement
%  of ERROR with RETURN throughout

nin=nargin-1;
nout=nargout;
y=0;
b=[];
magic1 = 29816; % Every tree vector TR includes these two "magic numbers"
magic2 = 18341; % in postions TR(2) and TR(3) for identification purposes.

if nin==-1, error('No input argument'),end

%  Check that TR is a tree
% msg='first input argument must be a TREE';
%  Check that TR is a vector and has length at least 5
if length((tr))<6 | min(size(tr))~=1,
  % error(msg);
  return
end
% If TR is a row vector, transpose it
tr=tr(:);
% Check magic numbers to ensure that TR is a tree
if tr(2)~=magic1 |tr(3)~=magic2
  % error(msg);
  return
end
if nin==0, y=1; return, end

% Now check whether IJ is a valid branch of TR

j=1;

% Start of part that is same as BRANCH.M, execept RETURN's replacing ERROR's
%--------------------------------------------------------------------------
   [rj,cj]=size(ij);
   if rj~=1| cj==0,
        % error('invalid path or index')
        return
   end
   if isstr(ij),           % case of string-name path IJ=PATHJ
      flag=1;
      ij=[ij '/'];           % append extra '/' to string ij
      if ij(1)~='/',ij=['/' ij];end  %if missing add leading '/'
      pptrj=find(ij=='/');   % PPTRJ = pointers to /'s in PATH IJ
      lj=length((pptrj))-1; % path length (number of names)
   else                      % case of numeric path INDEX IJ
      flag=0;
      lj=length((ij));      % path length (number of indices)
   end
   x = tr;
   % Now descend tree X one branch at a time, recursively
   % overwriting X with root branch having index IJ(K)
   for k=1:lj,
     % Check to make sure X is a TREE
     if length((x))<6 | min(size(x))~=1,
       % error('Invalid path or branch');
       return
     end
     if x(2)~=magic1 |x(3)~=magic2
        % error('Invalid path or branch');
        return
     end

     [rx1,cx1]=size(x);
     if flag ==1,
        nm = branch(x,0);
        nm=[',' nm ','];  % nm = ',name1,name2,..,namen,'

        % Now get k-th name in pathj
        if pptrj(k+1)-pptrj(k)>1,
            nmjk = ij(pptrj(k)+1:pptrj(k+1)-1);
        else
            % error('empty string encountered in path')
            return
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
           nnm = length((nmptr))-1; % number branch names in nm
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
              % error(['branch ' ij(1:pptrj(k+1)-1) ' not present']);
              return
           end
        end
     else
        njk = ij(k);
     end
     % msg=['branch B' sprintf('%d',j) ' index out of range'];
     if njk>x(1)| njk<0 | njk+6>rx1,
        % error(msg),
        return
     end
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
     lx = rx*cx;       % length of x
     if lx>0 & ptr1+lx+1<=rx1,  % if new X empty and old X is big enough
        xcol = x(ptr1+2:ptr1+lx+1); % Store new X data into XCOL
        x = zeros(rx,cx);      % Create a new X matrix of correct dimension
        x(:) = xcol(:);        % Now fill in new X with XCOL data
     elseif lx==0,
%% WAS CHANGED 1 LINE to handle non-square empty matrix
%%        x=[];
        x=zeros(rx,cx);
     else
        % error('invalid path or index')
        return
     end
   end
   if sflag==1,
      x=setstr(x);  %set string bit
   end
% ------------End of part that is same as BRANCH.M  -----------------

   b=x;
   y=1;
% ------ End of  ISTREE.M --- RYC/MGS 10/25/90 %