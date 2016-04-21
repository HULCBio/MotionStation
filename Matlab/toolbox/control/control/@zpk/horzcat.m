function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of LTI models.
%
%   SYS = HORZCAT(SYS1,SYS2,...) performs the concatenation 
%   operation
%         SYS = [SYS1 , SYS2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the LTI models SYS1, SYS2,...
% 
%   See also VERTCAT, STACK, LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $  $Date: 2002/04/10 06:12:43 $

% Effect on other properties
% UserData and Notes are deleted

% Remove all empty arguments
ni = nargin;
EmptyModels = logical(zeros(1,ni));
for i=1:ni,
   sizes = size(varargin{i});
   EmptyModels(i) = ~any(sizes(1:2));
end
varargin(EmptyModels) = [];

% Get number of non empty model
nsys = length(varargin);
if nsys==0,
   sys = zpk;  return
end

% Initialize output SYS to first input system
sys = zpk(varargin{1});
Z = sys.z;
P = sys.p;
K = sys.k;
slti = sys.lti;
var = sys.Variable;
dispForm = sys.DisplayFormat; 
sflag = isstatic(sys);  % 1 if SYS is a static gain

% Concatenate remaining input systems
for j=2:nsys,
   sysj = zpk(varargin{j});

   % Check dimension compatibility
   sizes = size(K);
   sj = size(sysj.k);
   if sj(1)~=sizes(1),
      error('In [SYS1 , SYS2], SYS1 and SYS2 must have the same number of outputs.')
   elseif ~isequal(sj(3:end),sizes(3:end)),
      if length(sj)>2 & length(sizes)>2,
         error('In [SYS1 , SYS2], arrays SYS1 and SYS2 must have compatible dimensions.')
      elseif length(sj)>2,
         % ND expansion of SYS
         Z = repmat(Z,[1 1 sj(3:end)]);
         P = repmat(P,[1 1 sj(3:end)]);
         K = repmat(K,[1 1 sj(3:end)]);
      else
         % ND expansion of SYSj
         sysj.z = repmat(sysj.z,[1 1 sizes(3:end)]);
         sysj.p = repmat(sysj.p,[1 1 sizes(3:end)]);
         sysj.k = repmat(sysj.k,[1 1 sizes(3:end)]);
      end
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
      slti = [slti , sysj.lti];
   catch
      rethrow(lasterror)
   end

   % Update output system data
   Z = [Z , sysj.z];
   P = [P , sysj.p];
   K = [K , sysj.k];   
   [dispForm ,var] = dispVarFormatPick(var,sysj.Variable,dispForm,sysj.DisplayFormat,getst(slti));   
end

% Create result
sys.z = Z;
sys.p = P;
sys.k = K;
sys.DisplayFormat = dispForm;
sys.Variable = var;
sys.lti = slti;

