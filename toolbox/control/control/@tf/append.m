function sys = append(varargin)
%APPEND  Group LTI models by appending their inputs and outputs.
%
%   SYS = APPEND(SYS1,SYS2, ...) produces the aggregate system
% 
%                 [ SYS1  0       ]
%           SYS = [  0   SYS2     ]
%                 [           .   ]
%                 [             . ]
%
%   APPEND concatenates the input and output vectors of the LTI
%   models SYS1, SYS2,... to produce the resulting model SYS.
%
%   If SYS1,SYS2,... are arrays of LTI models, APPEND returns an LTI
%   array SYS of the same size where 
%      SYS(:,:,k) = APPEND(SYS1(:,:,k),SYS2(:,:,k),...) .
%
%   See also SERIES, PARALLEL, FEEDBACK, LTIMODELS.

%   Author(s): P. Gahinet, 4-9-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/10 06:08:22 $

% Initialize APPEND operation
sys = tf(varargin{1});
num = sys.num;   den = sys.den;
sflag = isstatic(sys);  % 1 if SYS is a static gain
slti = sys.lti;
dmode = sys.Variable;

% Incrementally build resulting system
for j=2:nargin,
   sysj = tf(varargin{j});
   
   % Check dimension compatibility, and perform ND expansion 
   % of 2D transfer function
   sizes = size(num);
   ny = sizes(1);  nu = sizes(2);  
   sj = size(sysj.num);
   if length(sj)>2 & length(sizes)>2,
      if ~isequal(sj(3:end),sizes(3:end)),
         error('Arrays SYS1 and SYS2 must have compatible dimensions.')
      end
   elseif length(sizes)>2,
      sysj.num = repmat(sysj.num,[1 1 sizes(3:end)]);
      sysj.den = repmat(sysj.den,[1 1 sizes(3:end)]);
   elseif length(sj)>2,
      num = repmat(num,[1 1 sj(3:end)]);
      den = repmat(den,[1 1 sj(3:end)]);
      sizes = size(num);
   end
      
   % LTI property management   
   sfj = isstatic(sysj);
   if sflag | sfj,
      % Adjust sample time of static gains to prevent clashes
      % RE: static gains are regarded as sample-time free
      [slti,sysj.lti] = sgcheck(slti,sysj.lti,[sflag sfj]);
   end
   sflag = sflag & sfj;
   try
      slti = append(slti,sysj.lti);
   catch
      rethrow(lasterror)
   end
   
   % Append transfer functions
   pad12 = cell([ny , size(sysj.num,2) , sizes(3:end)]);
   pad21 = cell([size(sysj.num,1) , nu , sizes(3:end)]);
   pad12(:) = {0};   pad21(:) = {0};
   num = cat(1,cat(2,num,pad12),cat(2,pad21,sysj.num));  % [num 0;0 numj]
   pad12(:) = {1};   pad21(:) = {1};
   den = cat(1,cat(2,den,pad12),cat(2,pad21,sysj.den));  % [den 1;1 denj]
   
   % Select Variable
   dmode = varpick(dmode,sysj.Variable,getst(slti));
end
   
% Create output
sys.num = num;
sys.den = den;
sys.Variable = dmode;
sys.lti = slti;

