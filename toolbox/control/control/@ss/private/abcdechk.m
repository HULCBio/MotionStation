function sys = abcdechk(sys,abcde)
%ABCDECHK  Checks that the state-space matrices of SYS define
%          a valid system and returns the empty string if no 
%          error is detected.

%   Author(s): P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.23 $  $Date: 2002/05/11 17:33:27 $

if ~any(abcde),
   return
end

% Check A,B,C,D,E data (should be real)
if (abcde(1) & ~CheckData(sys.a)) | ...
      (abcde(2) & ~CheckData(sys.b)) | ...
      (abcde(3) & ~CheckData(sys.c))
   error('Invalid model: A,B,C must be arrays of real or complex numbers.')
elseif abcde(5) & ~CheckData(sys.e),
   error('Invalid model: E must be an array of real or complex numbers.')
end

% Format D and check it contains real double data
if abcde(4),
   % Convert D to ND if specified as cell array
   if isa(sys.d,'cell')
      nd = cellfun('ndims',sys.d);
      if isempty(nd),
         sys.d = [];
      elseif any(nd(:)~=2),
         error('Invalid model: All D matrices must be two-dimensional.')
      else
         nio = size(sys.d{1});
         try 
            sys.d = cell2nd(sys.d,nio(1),nio(2));
         catch
            error('Invalid system: All D matrices must have the same dimensions.')
         end
      end
   elseif ~isa(sys.d,'double')
      error('Invalid model: D must be an array of real or complex numbers.')
   end
end
   
% Turn A,B,C into cell arrays
sd = size(sys.d);
sd = [sd , ones(1,4-length(sd))];  % make length>=4
sys.a = nd2cell(sys.a,sd(3:end));
sys.b = nd2cell(sys.b,sd(3:end));
sys.c = nd2cell(sys.c,sd(3:end));
sys.e = nd2cell(sys.e,sd(3:end));

% Determine I/O dimensions
if ~isempty(sys.b),
   sd(2) = max(size(sys.b{1},2),sd(2));
end
if ~isempty(sys.c),
   sd(1) = max(size(sys.c{1},1),sd(1));
end
if ~all(sd(1:2)) | isequal(sys.d,0), 
   sys.d = zeros(sd);  
end

% Check compatibility of array dimensions
ncells = [prod(size(sys.a)) , prod(size(sys.e)) , ...
          prod(size(sys.b)) , prod(size(sys.c)) , prod(sd(3:end))];
[nsys,imax] = max(ncells);   % # of models
if nsys>1 & any(ncells==1),
   % Replicate single-model data in multi-model case
   Fields = {'a' 'e' 'b' 'c'};
   if imax==5,
      ArraySizes = sd(3:end);
   else
      % RE: call built-in SUSBREF to retrieve actual field value (using
      %     GETFIELD/SETFIELD would call SS/SUBSREF and SS/SUBSASGN) 
      ArraySizes = size(builtin('subsref',sys,substruct('.',Fields{imax})));
      if ncells(5)==1,
         sys.d = repmat(sys.d,[1 1 ArraySizes]);
         sd = [sd(1:2) ArraySizes];
      end
   end
   for i=find(ncells(1:4)==1),
      repdata = repmat(builtin('subsref',sys,substruct('.',Fields{i})),ArraySizes);
      sys = builtin('subsasgn',sys,substruct('.',Fields{i}),repdata);
   end 
end
if ~isequal(size(sys.a),size(sys.b),size(sys.c),size(sys.e),sd(3:end)),
   error('Multi-dimensional arrays A,B,C,D,E have incompatible dimensions.')
end

% Check compatibility if I/O and state dimensions for each model
try
   for k=1:nsys,
      [sys.a{k},sys.b{k},sys.c{k},sys.d(:,:,k),sys.e{k}] = ...
         CheckLTIDims(sys.a{k},sys.b{k},sys.c{k},sys.d(:,:,k),sys.e{k},...
                      sd(1),sd(2),abcde,nsys,k);
   end
catch
   rethrow(lasterror)
end


%====================================================================

function [a,b,c,d,e] = CheckLTIDims(a,b,c,d,e,Ny,Nu,abcde,nsys,k)
%CHECKLTIDIMS  Checks compatibility of state/I/O dimensions

% Get dimensions of A,B,C,E matrices
sa = size(a);
sb = size(b);
sc = size(c);
sd = size(d);
se = size(e);
Nx = min(sa);   
Ne = min(se);
if nsys>1,
   Model = sprintf(' (in model #%d)',k);
else
   Model = '';
end

% Handle shorthand syntax
if Nx==0,  
   sa(1:2) = 0;  a = zeros(0);  
end
if Ne==0,  
   se(1:2) = 0;  e = zeros(0);  
end
if Nx==0 | Nu==0,  
   sb(1:2) = [Nx Nu];  b = zeros(Nx,Nu);  
end
if Nx==0 | Ny==0,  
   sc(1:2) = [Ny Nx];  c = zeros(Ny,Nx);  
end

% Check compatibility of I/O and state dimensions
if sa(1)~=sa(2) | se(1)~=se(2),
   error(sprintf('The A and E matrices must be square%s.',Model))
elseif Ne>0 & ~isequal(sa(1:2),se(1:2)),
   error(sprintf('The A and E matrices have incompatible dimensions%s.',Model))
elseif Nx~=sb(1),
   error(sprintf('The A and B matrices don''t have the same number of rows%s.',Model))
elseif Nx~=sc(2),
   error(sprintf('The A and C matrices don''t have the same number of columns%s.',Model))
elseif sb(2)~=Nu | sd(2)~=Nu,
   errmsg = ...
      sprintf('The B and D matrices don''t have the same number of columns%s.',Model);
   if any(abcde(2:4)~=1),
      errmsg = sprintf('%s\n%s',errmsg,...
         'Use SET(SYS,''b'',B,''d'',D) to modify the number of inputs');
   end
   error(errmsg)
elseif sc(1)~=Ny | sd(1)~=Ny,
   errmsg = ...
      sprintf('The C and D matrices don''t have the same number of rows%s.',Model);
   if any(abcde(2:4)~=1),
      errmsg = sprintf('%s\n%s',errmsg, ...
         'Use SET(SYS,''c'',C,''d'',D) to modify the number of outputs');
   end
   error(errmsg)    
end

% Check E is nonsingular
if Ne>0 & rcond(e)<eps,
   error(sprintf('The E matrix is singular to working precision%s.',Model))
end

% Handling of NaN and Inf in D matrix
% RE: NaN's allowed in D matrix so that I/O size can be specified even when
%     algebraic loop makes model data ill defined
if any(~isfinite(d(:))) 
   % Reduce all to static NaN gain
   d = repmat(NaN,Ny,Nu); 
   a = [];  e = [];  b = zeros(0,Nu);  c = zeros(Ny,0);
end

%==============================================================

function boo = CheckData(M)
%CHECKDATA  Checks A,B,C,D,E data is of proper type

if isa(M,'cell'),
   boo = cellfun('isclass',M,'double');
   boo = all(boo(:));
else
   boo = isa(M,'double') && all(isfinite(M(:)));
end







