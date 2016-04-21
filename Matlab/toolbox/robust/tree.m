function tr = tree(varargin)
%TREE Hierarchical data structure.
%
% TR = TREE(NM,B1,B2,...,BN) creates a hierarchical data structure TR
%     called a "tree"  consisting of a single column vector into which
%     is encoded all the data and dimension information from its
%     branches B1, B2,...,BN along with a numerical index and a string-
%     name for each branch. The input argument NM assigns names to the
%     branches; it must be of the form
%           NM = 'name1,name2,...,nameN'
%     The names may be any valid MATLAB variable names and must be
%     separated by commas; if no names are to be assigned, set NM=''.
%     The arguments B1,B2,...,BN (called the "root branches" of the
%     tree) may be matrices, vectors, strings, or trees themselves.
%     Related functions include the following:
%         BRANCH   returns branches of a tree
%         ISTREE   tests existence of a specified branch
%         BRANCH(TR,0)  returns NM
%         TR(1)    returns the number N of root branches
%

% R. Y. Chiang & M. G. Safonov 10/01/90
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

if nargin==0,error('missing input arguments');end

% Initialize variables
n = nargin-1;       % number of branches N
ind = 7+n;          % point to beginning of B0 data subfield of DAT
dat = [];
ptr = [];
magic1 = 29816;
magic2 = 18341;
nm=varargin{1};

% create header for tree
header = [n;magic1;magic2;0;0];
% Note:  The tree TR has the "magic numbers" 29816 and 18341 in
% positions 2 and 3 , respectively.  These magic numbers are used
% by other functions to distinguish a tree from an ordinary vector
% The two zero entries in positions 4 and 5 have no significance
% other than as place holders; they may be overwritten with data
% for specialized applications.

msg = 'first input argument must be string of names separated by commas';
[rnm,cnm]=size(nm);
if rnm>1,error(msg),end
if rnm==1 & ~isstr(nm),error(msg),end

% Remove any spaces from NM
nm=[nm ' ']; nm(find(nm==' '))='';
b0 = nm;                  % Let NM be branch zero of the tree

% Now check names in NM for validity
nm1=[',' nm ','];
ind1=find(nm1==',');
c=max(size(ind1))-1;
if c~=n & min(size(nm))>0,
   error(['Number of names in string ' 13 10 '''' nm '''' 13 10 'is not equal to number of branches of tree'])
end
for i=1:c,
   nmi=nm1(ind1(i)+1:ind1(i+1)-1);
   temp=find((nmi>='0' & nmi<='9')|(nmi>='A' & nmi<='Z')|nmi=='_'|(nmi>='a' & nmi<='z'));
   if min(size(nmi))>0
      temp=nmi(temp);
      if ~issame(temp,nmi) | ~(nmi(1)>=65),
         error([' ' nmi ' is not a valid branch name.'])
      end
   end
end

% Now create DAT vector with data on B0, B1, B2 et cetera and a PTR vector
% containing pointers pointing to the beginning of the subfields of
% DAT corresponding to each of B0,B1, etc.

% Create a subfield of DAT for each of the branches B0, B1, B2, etc.
for i = 0:n,
   %% eval(['b = b' sprintf('%d',i) ';'])   % B = i-th branch
   b=varargin{i+1};
   [rb,cb]=size(b);
%% WAS DELETED 1 LINE TO HANDLE NON-SQUARE EMPTY MATRIX b
%%   if cb>0,
      ptr = [ptr;ind];
      % if B is string, set rb=-rb,end  % minus flags string branch
      if isstr(b(:)'),
         rb=-rb;    % string data marked by negative sign
      end
%% WAS      dat = [dat;rb;cb;b(:)]; % Append Bdat to DAT field
      dat = [dat;rb;cb;double(b(:))]; % Append Bdat to DAT field
      ind=ind+size(b(:))*[1;0]+2;
           % IND points to start of data field for branch i+1
%% WAS DELETED 3 LINES TO HANDLE NON-SQUARE EMPTY MATRIX b
%%   else
%%       ptr = [ptr;1];      % PTR for empty matrix is 1
%%   end
end
% PTR vector now has length N+1 with first entry pointing to start
% of the NM field (i.e., B0) and the remaining N entries pointing
% to the start of the fields containing the data for B1,B2,...,BN

% Now assemble the tree vector TR
% Format:
% index     1        6       PTR(0)  ...      PTR(N)
      %     HEADER   PTR     B0dat   ...      BNdat ];
%% WAS tr = 1*[header; ptr; dat];
tr = [header; ptr; dat];

% ------ End of TREE.M --- RYC/MGS 10/05/90 %