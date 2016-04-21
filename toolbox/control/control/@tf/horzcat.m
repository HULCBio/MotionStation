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
%   $Revision: 1.16 $  $Date: 2002/04/10 06:07:53 $

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
   sys = tf;  return
end

% Initialize output SYS to first input system
sys = tf(varargin{1});
num = sys.num;
den = sys.den;
slti = sys.lti;
var = sys.Variable;
sflag = isstatic(sys);  % 1 if SYS is a static gain

% Concatenate remaining input systems
for j=2:nsys,
   sysj = tf(varargin{j});
  
   % Check dimension compatibility
   sizes = size(num);
   sj = size(sysj.num);
   if sj(1)~=sizes(1),
      error('In [SYS1 , SYS2], SYS1 and SYS2 must have the same number of outputs.')
   elseif ~isequal(sj(3:end),sizes(3:end)),
      if length(sj)>2 & length(sizes)>2,
         error('In [SYS1 , SYS2], arrays SYS1 and SYS2 must have compatible dimensions.')
      elseif length(sj)>2,
         % ND expansion of SYS
         num = repmat(num,[1 1 sj(3:end)]);
         den = repmat(den,[1 1 sj(3:end)]);
      else
         % ND expansion of SYSj
         sysj.num = repmat(sysj.num,[1 1 sizes(3:end)]);
         sysj.den = repmat(sysj.den,[1 1 sizes(3:end)]);
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
   num = [num , sysj.num];
   den = [den , sysj.den];
   var = varpick(var,sysj.Variable,getst(slti));
end
   
% Create result
sys.num = num;
sys.den = den;
sys.Variable = var;
sys.lti = slti;

