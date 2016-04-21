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

%       Author(s): P. Gahinet, 5-1-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.18 $  $Date: 2002/04/10 06:13:14 $

% Initialize APPEND operation
sys = zpk(varargin{1});
Zero = sys.z;  Pole = sys.p;  Gain = sys.k;
sflag = isstatic(sys);  % 1 if SYS is a static gain
slti = sys.lti;
dmode = sys.Variable;
dispForm = sys.DisplayFormat;

% Incrementally build resulting system
for j=2:nargin,
   sysj = zpk(varargin{j});
   
   % Check dimension compatibility, and perform ND expansion 
   % of 2D transfer function
   sizes = size(Gain);
   ny = sizes(1);  nu = sizes(2);  
   sj = size(sysj.k);
   if length(sj)>2 & length(sizes)>2,
      if ~isequal(sj(3:end),sizes(3:end)),
         error('Arrays SYS1 and SYS2 must have compatible dimensions.')
      end
   elseif length(sizes)>2,
      sysj.z = repmat(sysj.z,[1 1 sizes(3:end)]);
      sysj.p = repmat(sysj.p,[1 1 sizes(3:end)]);
      sysj.k = repmat(sysj.k,[1 1 sizes(3:end)]);
   elseif length(sj)>2,
      Zero = repmat(Zero,[1 1 sj(3:end)]);
      Pole = repmat(Pole,[1 1 sj(3:end)]);
      Gain = repmat(Gain,[1 1 sj(3:end)]);
      sizes = size(Gain);
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

   % Append ZPK systems SYS and SYSj
   pad12 = cell([ny , size(sysj.k,2) , sizes(3:end)]);
   pad21 = cell([size(sysj.k,1) , nu , sizes(3:end)]);
   pad12(:) = {zeros(0,1)};   pad21(:) = {zeros(0,1)};
   Zero = cat(1,cat(2,Zero,pad12),cat(2,pad21,sysj.z));  % [Zero 0;0 Zeroj]
   Pole = cat(1,cat(2,Pole,pad12),cat(2,pad21,sysj.p));
   pad12 = zeros([ny , size(sysj.k,2) , sizes(3:end)]);
   pad21 = zeros([size(sysj.k,1) , nu , sizes(3:end)]);
   Gain = cat(1,cat(2,Gain,pad12),cat(2,pad21,sysj.k));
   
   % Select Variable  
   [dispForm,dmode] = dispVarFormatPick(dmode,sysj.Variable,dispForm,sysj.DisplayFormat,getst(slti));
end
   
% Create output
sys.z = Zero;
sys.p = Pole;
sys.k = Gain;
sys.Variable = dmode;
sys.DisplayFormat = dispForm;
sys.lti = slti;

