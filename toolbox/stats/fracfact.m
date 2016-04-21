function [x, conf] = fracfact(gen)
%FRACFACT generates a two-level fractional factorial design.
%
%   X = FRACFACT(GEN) produces the fractional factorial design defined
%   by the generator string GEN.  GEN must be a sequence of "words" separated
%   by spaces.  If the generators string consists of P words using K letters
%   of the alphabet, then X will have N=2^K rows and P columns.
%
%   [X, CONF] = FRACFACT(GEN) also returns CONF, a cell array of
%   strings containing the confounding pattern for the design.
%
%   Example:
%      x = fracfact('a b c abc')
%
%   produces an 8-run fractional factorial design for four variables, where
%   the first three columns are an 8-run 2-level full factorial design for
%   the first three variables, and the fourth column is the product of the
%   first three columns.  The fourth column is confounded with the
%   three-way interaction of the first three columns.
%
%   See also FF2N, FULLFACT

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.3 $  $Date: 2004/01/24 09:33:46 $

% Check the input argument for validity
if (~ischar(gen)) | (size(gen,1) > 1)
   error('stats:fracfact:BadGenerators','Invalid generator string GEN.')
end
if (~all(isletter(gen) | isspace(gen) | (gen == '-')))
   error('stats:fracfact:BadGenerators','Invalid generator string GEN.')
end

% Find out the dimensions of the design
gen = lower(char(strread(gen, '%s', 'delimiter', ' ')));
alpha = 'abcdefghijklmnopqrstuvwxyz';
alpha = alpha(ismember(alpha, gen));
K = length(alpha);
if (K == 0)
   error('stats:fracfact:BadGenerators','Invalid generator string GEN.')
end
alpha = ['-' alpha];
N = 2^K;
P = size(gen, 1);
bitmat = (zeros(P, K+1) > 0);

% Generate a full factorial as the basis, augment with -1's
Full = [-ones(N,1) -1+2*ff2n(K)];
x = ones(N, P);

% Multiply columns as specified by generators; also create bit pattern
ident = eye(K+1);
for j=1:P
   g = deblank(gen(j,:));
   cols = loc(g, alpha);
   cols = sort(cols(cols>0));
   x(:,j) = prod(Full(:,cols), 2);
   bitmat(j,:) = mod(sum(ident(cols,:),1), 2);
end

if (nargout > 1)
   conf = confounding(bitmat, alpha, 2);
end

function conf = confounding(bitmat, alpha, maxint, names)
% CONFOUNDING returns the confounding pattern for the design whose
% generators are encoded in the rows of the matrix bitmat and whose
% words are written in the alphabet alpha.  The first letter of the
% alphabet is '-' and is treated specially.  The display shows
% interactions with up to maxint factors and gets factor names
% from the array names.
nfact = size(bitmat, 1);
K = length(alpha);
ident = eye(K);
if (nargin < 4)
   maxint = 2;
end
if (nargin < 5)
   names = [repmat('X', nfact, 1), strjust(num2str((1:nfact)'), 'left')];
end

% Write factor main effects into a cell array
conf = cell(nfact+1, 3);
conf(1,:) = {['Term'], ['Generator'], ['Confounding']};
for j=2:nfact+1
   conf{j,1} = deblank(names(j-1,:));
   mask = bitmat(j-1,:);
   if (sum(mask) > 0)
      gen = alpha(mask);
   else
      gen = '1';
   end
   conf{j,2} = gen;
end

% Write next higher order effects into the cell array
for j=2:min(maxint,K)
   
   % First allocate enough additional rows
   group = nchoosek(1:nfact, j);
   base = size(conf,1);
   ninter = size(group,1);
   conf{base+ninter, 1} = [];
   
   % Loop over all combinations
   for j1=1:ninter
      
      % Construct term name
      g = group(j1,:);
      name = conf{1+g(1),1};
      for j2=2:j
         name = [name, '*', conf{1+g(j2)}];
      end
      
      % Construct term generator
      mask = (mod(sum(bitmat(g,:),1), 2) > 0);
      jbase = base + j1;
      conf{jbase, 1} = name;
      if (sum(mask) > 0)
         conf{jbase,2} = alpha(mask);
      else
         conf{jbase,2} = '1';
      end
   end
end

% Fill in confounding entries
for j=2:size(conf, 1)
   if (length(conf{j,3}) == 0)      % only if this row is not yet done
      gen = conf{j,2};              % look at this generator
      if (isempty(gen))
         other = '- -';             % fake that will not match anything
      elseif (gen(1) == '-')
         other = gen(2:end);
      else
         other = ['-', gen];
      end
      
      % Find other terms with +/- the same generator
      rows1 = find(strcmp(conf(:,2), {gen}));
      rows2 = find(strcmp(conf(:,2), {other}));
      rows = sort([rows1(:); rows2(:)]);
      
      % Construct a confounding string for this term
      t = conf{rows(1),1};
      if (~strcmp(conf{rows(1), 2}, gen))
         t = ['-', t];
      end
      for j1=2:length(rows)
         if (strcmp(conf{rows(j1), 2}, gen))
            t = [t, ' + ', conf{rows(j1),1}];
         else
            t = [t, ' - ', conf{rows(j1),1}];
         end
      end
      for j1=rows1'
         conf{j1,3} = t;
      end
   end
end

% -----------------------
function x=loc(src, targ)
%LOC locates the first occurrence of each element of src in targ, returns index
x = zeros(size(src));
t = targ(:);
for j=length(t):-1:1
   x(src==t(j)) = j;
end
