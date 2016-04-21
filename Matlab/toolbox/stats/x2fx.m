function [D,flags] = x2fx(x,model,flags)
%X2FX   Factor settings matrix (x) to design matrix (fx).
%   D = X2FX(X,'MODEL') Transforms a matrix of system inputs, X, to 
%   the design matrix for a regression analysis. The optional string
%   input, MODEL, controls the order of the regression model. By 
%   default, X2FX returns the design matrix for a linear additive
%   model with a constant term. MODEL can be following strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms
%     'quadratic'     interactions plus squared terms
%     'purequadratic' includes constant, linear and squared terms
%   
%   Alternatively, MODEL can be a matrix of terms. Each row of MODEL 
%   represents one term. The value in a column is the exponent to raise 
%   the same column in X for that term. D(i,j) = prod(x(i,:).^model(j,:)). 
%   This allows for models with polynomial terms of arbitrary order.
%
%   The order of columns for a quadratic model is:
%       a.  the constant term
%       b.  the linear terms (the input X columns 1,2,...,k)
%       c.  interaction terms formed by taking pairwise products of
%           X columns (1,2), (1,3), ..., (1,k), (2,3), ..., (k-1,k)
%       d.  squared terms in the order 1,2,...,k
%   Other models use a subset of these terms but keep them in this order.
%
%   Example: x = [1 2 3]' model = [0 1 2]'
%   D = [1 1 1; 1 2 4; 1 3 9] 
%   The first column is x to the 0th power. The second column is x to
%   the 1st power. And the last column is x squared.
% 
%   X2FX is a utility function for RSTOOL, REGSTATS and CORDEXCH.
%   See also RSTOOL, CORDEXCH, ROWEXCH, REGSTATS. 

%   Undocumented input/output FLAGS allows this function to be called
%   repeatedly and efficiently during a D-optimal design generation.
   
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.18.4.4 $  $Date: 2004/01/24 09:37:26 $

[m,n]  = size(x);
ncols = 1;

if isa(x,'single')
   Dclass = 'single';
else
   Dclass = 'double';
end

if nargin<2
   model = 'linear';
end
if isnumeric(model)
   flags = [];
elseif nargin<3 | isempty(flags)
   flags = [1 1 0 0];        % const, linear, interaction, quadratic
   if nargin == 1 | strcmp(model,'linear') | strcmp(model,'l') | ...
      strcmp(model,'L') | strcmp(model,'Linear') | ...
      strcmp(model,'additive') | strcmp(model,'Additive')
      flags(2) = 1;
   
   elseif strcmp(model,'interaction') | strcmp(model,'i') | ...
          strcmp(model,'Interaction') | strcmp(model,'interactions') | ...
          strcmp(model,'Interactions') | strcmp(model,'I')
      flags(2:3) = 1;
      
   elseif strcmp(model,'quadratic') | strcmp(model,'q') | ...
          strcmp(model,'Q') | strcmp(model,'Quadratic')
      flags(2:4) = 1;
   
   elseif strcmp(model,'purequadratic') | strcmp(model,'p') | ...
          strcmp(model,'Purequadratic') | strcmp(model,'P')
      flags(2:2:4) = 1;
      
   else
      flags = [];
   end
end

if ~isempty(flags)
   % Create matrix of linear, interaction, and squared terms as flagged
   ncols = sum(flags .* [1, n, n*(n-1)/2, n]);
   D = ones(m,ncols,Dclass);
   prevcol = 1;
   if flags(2)
      cols = prevcol+1:prevcol+n;
      D(:,cols) = x;
      prevcol = prevcol + n;
   end
   if flags(3)
      first = repmat(1:n,n,1);
      second = first';
      t = first<second;
      cols = prevcol+1:prevcol+n*(n-1)/2;
      D(:,cols) = x(:,first(t)).*x(:,second(t));
      prevcol = prevcol + n*(n-1)/2;
   end
   if flags(4)
      cols = prevcol+1:prevcol+n;
      D(:,cols) = x.^2;
   end

elseif isstr(model)
    D = feval(model,x);  %Allows for extensions to named higher order models. (e.g. 'cubic')

else
   [row,col] = size(model);
   if col ~= n
      error('stats:x2fx:BadSize',...
            ['A numeric second argument must have the same number ' ...
             'of columns as the first argument.']);
   end
   D = zeros(m,row,Dclass);
   for idx = 1:row
      carat = model(idx,:);
      t = carat>0;
      tmp = x(:,t).^carat(ones(m,1),t);
      if size(tmp,2) == 1
         D(:,idx) = tmp;
      else
         D(:,idx) = prod(tmp,2);
      end
   end
end
