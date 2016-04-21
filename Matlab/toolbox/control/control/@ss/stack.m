function sys = stack(arraydim,varargin)
%STACK  Stack LTI models into LTI array.
%
%   SYS = STACK(ARRAYDIM,SYS1,SYS2,...) produces an array of LTI
%   models SYS by stacking the LTI models SYS1,SYS2,... along
%   the array dimension ARRAYDIM.  All models must have the same 
%   number of inputs and outputs, and the I/O dimensions are not
%   counted as array dimensions.
%
%   For example, if SYS1 and SYS2 are two LTI models with the 
%   same I/O dimensions,
%     * STACK(1,SYS1,SYS2) produces a 2-by-1 LTI array
%     * STACK(2,SYS1,SYS2) produces a 1-by-2 LTI array
%     * STACK(3,SYS1,SYS2) produces a 1-by-1-by-2 LTI array.
%
%   You can also use STACK to concatenate LTI arrays SYS1,SYS2,...
%   along some array dimension ARRAYDIM.
%
%   See also HORZCAT, VERTCAT, APPEND, LTIMODELS.

%   Author(s): P. Gahinet, 1-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:00:20 $


% Offset by the two I/O dimensions
if ~isa(arraydim,'double') | ~isequal(size(arraydim),[1 1]) | arraydim<=0,
   error('First argument DIM must be a positive integer.')
end
absdim = arraydim+2;

% Initialize output SYS to first input system
sys = ss(varargin{1});
sflag = isstatic(sys);  % 1 if SYS is a static gain

% Concatenate remaining input systems
for j=2:length(varargin),
   sysj = ss(varargin{j});
   
   % Pad with unit sizes up to dimension DIM
   sizes = size(sys.d);
   sizes = [sizes , ones(1,absdim-length(sizes))];
   sj = size(sysj.d);
   sj = [sj , ones(1,absdim-length(sj))];
   
   % Check consistency
   sizes(absdim) = [];    
   sj(absdim) = [];
   if ~isequal(sizes(1:2),sj(1:2)),
      error('I/O size mismatch.')
   elseif ~isequal(sizes(3:end),sj(3:end)),
      error(sprintf('Sizes of stacked model arrays can only differ only array dimension #%d.',arraydim))
   end
   
   % LTI property management   
   sfj = isstatic(sysj);
   if sflag | sfj,
      % Adjust sample time of static gains to prevent clashes
      % RE: static gains are regarded as sample-time free
      [sys.lti,sysj.lti] = sgcheck(sys.lti,sysj.lti,[sflag sfj]);
   end
   sflag = sflag & sfj;
      
   try 
      sys.lti = stack(arraydim,sys.lti,sysj.lti,size(sys.d),size(sysj.d));
   catch
      rethrow(lasterror)
   end  
   
   % Perfom concatenation
   sys.a = cat(arraydim,sys.a,sysj.a);
   sys.b = cat(arraydim,sys.b,sysj.b);
   sys.c = cat(arraydim,sys.c,sysj.c);
   sys.d = cat(absdim,sys.d,sysj.d);
   
   [sys.e,sysj.e] = ematchk(sys.e,sys.a,sysj.e,sysj.a);
   sys.e = cat(arraydim,sys.e,sysj.e);  
   sys.e = ematchk(sys.e);
   
   % Merge state names
   sys.StateName = xmerge(sys.StateName,sysj.StateName);
end

% Exit checks
Nx = size(sys,'order');
if length(Nx)>1 | Nx~=length(sys.StateName),
   % Uneven number of states: delete state names
   sys.StateName = repmat({''},[max(Nx(:)) 1]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Xname = xmerge(Xname1,Xname2)

if isequal(Xname1,Xname2) | all(strcmp(Xname2,'')),
   Xname = Xname1;
elseif all(strcmp(Xname1,'')),
   Xname = Xname2;
else
   % Clash: delete state names
   Xname = Xname1;
   Xname(:) = {''};
end
