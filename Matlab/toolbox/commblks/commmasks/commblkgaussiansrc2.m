function varargout = commblkgaussiansrc2(block, varargin)
%COMMBLKGAUSSIANSRC2 Mask function for Gaussian Noise Generator block

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2004/03/24 20:33:32 $

% --- Field numbers
MeanValue    = 1;
VarValue     = 2;
Seed         = 3;
SampleTime   = 4;
FrameBased   = 5;
SampPerFrame = 6;
Orient       = 7;

% --- Field data
Vals  = get_param(block, 'maskvalues');
Vis   = get_param(block, 'maskvisibilities');
En    = get_param(block, 'maskenables');
   
nvarargin = nargin - 1;
switch nvarargin
	case 0
		action = '';
	case 1
		action = varargin{1};
		Args = {};
	otherwise
		action = varargin{1};
		Args = varargin{2:end};

      if(~strcmpi(action,'backprop'))
         % --- Breakout the arguments if required
         if((nvarargin > 1) && (isa(Args,'cell')))
            Mask_m = Args{1};
            Mask_d = Args{2};
            Mask_s = Args{3};
         end;
      end;
end;

%*********************************************************************
% Function:			initialize
% Description:		Set the dialogs up based on the parameter values.
%					MaskEnables/MaskVisibles are not save in reference 
%					blocks.
% Inputs:			current block
% Return Values:	none
%********************************************************************

if(strcmp(action,'init'))
 
   vLen = []; ValsNum = cell(1,3); vSize = cell(1,3);
   for idx=1:3,
      % Numeric values of Vals
      ValsNum{idx} = str2num(Vals{idx});
      
      % Length of each of the first 3 parameters
      vLen         = [vLen length(ValsNum{idx})];
      
      % Dimension of each of the first 3 parameters
      vSize{idx}   = size(ValsNum{idx});
   end
   
   lenmax = max(vLen);            % Largest of all the parameter lengths
   [var_m var_n] = size(ValsNum{VarValue});
   
   % --- Exit code and error message definitions
   eStr.ecode = 0;
   eStr.emsg  = '';
   
   % Initial error checks
   if ~isnumeric(ValsNum{MeanValue}) || ~isnumeric(ValsNum{VarValue}) ...
       || ~isnumeric(ValsNum{Seed}) 
      error('Mean, Variance and Initial seed must be numeric arrays.');
   end
   if ismatrix(ValsNum{MeanValue}) || ismatrix(ValsNum{Seed})
      error('Mean and Initial seed cannot be a matrix.');
   end   
   
   % Check Variance is one of the following: scalar/vector/square matrix
   if ~isequal(var_m,1) && ~isequal(var_n,1) && ~isequal(var_m,var_n)
      eStr.ecode = 1;
      eStr.emsg = ['The Variance must be only a scalar, a vector or', ...
                    'a square matrix.'];
   end
   
   % If there exist vector parameters, check for consistency among vector
   % parameter lengths
   if ~isequal(lenmax,1)
      
      % Check if vector lengths agree    
      if any(vLen(vLen~=1)~=lenmax),
         error(['Mean, Variance and Initial seed must be either all ',...
                'scalars, or if more than one of them is a vector, ',...
                'their vector sizes, should agree.  If Variance is a ',...
                'matrix, it must be a square matrix with its sides ',...
                'being of the same length as the other vectors.']);
         
      % If dimensions are to be preserved, check if they agree 
      % (for Mean and Seed only)
      elseif strcmp(Vals{Orient},'off') && strcmp(Vals{FrameBased},'off') ...
             && isequal(vLen(MeanValue),vLen(Seed)) ...
             && ~isequal(vSize{MeanValue},vSize{Seed})
         eStr.ecode = 1;
         eStr.emsg  = ['Dimensions of parameter values in ', block, ...
                       ' are inconsistent.'];
      end

   end
   
   [varargout{1:3}] = feval(mfilename,block,'UpdateWs',Args);
   cbFrameBased(block);
   cbOrient(block);
   UpdateBlocks(block);
   
   varargout{4}=eStr;

end;

if(strcmp(action,'cbFrameBased'))
    cbFrameBased(block);
end

if(strcmp(action,'cbOrient'))
    cbOrient(block);
end

%----------------------------------------------------------------------
%	Block specific update functions
%----------------------------------------------------------------------
%*********************************************************************
% Function:			UpdateWs
% Description:		Set the simulink blocks as required
% Inputs:			current block
% Return Values:	values to be set in the workspace
%********************************************************************
if(strcmp(action,'UpdateWs'))
   [varargout{1:3}]=gwexpand(Mask_m,Mask_d,Mask_s);
end;


%*********************************************************************
% Function:			UpdateFields
% Description:		Update the dialog fields.
%						Indicate that block updates are not required
% Inputs:			current block
% Return Values:	none
%********************************************************************
if(strcmp(action,'UpdateFields'))
end;

%*********************************************************************
% Function:			UpdateIc
% Description:		Create the initial conditions for the buffer
% Inputs:			m,d,s
% Return Values:	localBuffIc
%********************************************************************
if(strcmp(action,'UpdateIc'))
   
   [M,D,S] = gwexpand(Mask_m,Mask_d,Mask_s);
   
   % Calculate initial frame for buffer
   currseed = S(1);
   localBuffIc = wgn(1, length(D), 1, 1, currseed, 'linear', 'real')*D + M;
   for idx = 2:str2num(Vals{SampPerFrame}),
      localBuffIc = [localBuffIc; wgn(1,length(D),1,1,'linear','real')*D+M];
   end
   
   varargout{1} = localBuffIc;
end;

%----------------------------------------------------------------------
%	Dynamic dialog specific field functions
%----------------------------------------------------------------------
%----------------------------------------------------------------------
%	Setup/Utility functions
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:	'default'
% Description:		Set the block defaults (development use only)
% Inputs:			current block
% Return Values:	none
%********************************************************************

if(strcmp(action,'default'))
	Cb{MeanValue}    = '';
	Cb{VarValue}     = '';
	Cb{Seed}         = '';
	Cb{SampleTime}   = '';
	Cb{FrameBased}    = 'commblkgaussiansrc2(gcb,''cbFrameBased'');';
	Cb{SampPerFrame}  = '';
	Cb{Orient}        = 'commblkgaussiansrc2(gcb,''cbOrient'');';

	En{MeanValue}    = 'on';
	En{VarValue}     = 'on';
	En{Seed}         = 'on';
	En{SampleTime}   = 'on';
    En{FrameBased}    = 'on';
    En{SampPerFrame}  = 'off';
    En{Orient}        = 'on';
    
    Vis{MeanValue}   = 'on';
    Vis{VarValue}    = 'on';
    Vis{Seed}        = 'on';
    Vis{SampleTime}  = 'on';
    Vis{FrameBased}   = 'on';
    Vis{SampPerFrame} = 'on';
    Vis{Orient}       = 'on';
    
    % --- Set Callbacks, enable status and visibilities
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities',Vis);
    
    % --- Set the startup values.  '' Indicates that the default saved will be used
    Vals{MeanValue}   = '[0]';
    Vals{VarValue}    = '[1]';
    Vals{Seed}        = '[41]';
    Vals{SampleTime}  = '1';
    Vals{FrameBased}   = 'off';
    Vals{SampPerFrame} = '1';
    Vals{Orient}       = 'off';

	MN = get_param(gcb,'MaskNames');
	for n=1:length(Vals)
		if(~isempty(Vals{n}))
			set_param(block,MN{n},Vals{n});
		end;
	end;

   % --- Set the copy function
	set_param(block,'CopyFcn','');

	% --- Ensure that the block operates correctly from a library
	set_param(block,'MaskSelfModifiable','on');

end;

%----------------------------------------------------------------------
%	Subfunctions
%----------------------------------------------------------------------

function UpdateBlocks(block)

MeanValue    = 1;
VarValue     = 2;
Seed         = 3;
%SampleTime   = 4;
FrameBased   = 5;
SampPerFrame = 6;
Orient       = 7;

Vals  = get_param(block, 'maskvalues');
vLen = []; ValsNum = cell(1,3); vSize = cell(1,3);
for idx=1:3,
   % Numeric values of Vals
   ValsNum{idx} = str2num(Vals{idx});
   
   % Length of each of the first 3 parameters
   vLen         = [vLen length(ValsNum{idx})];
   
   % Dimension of each of the first 3 parameters
   vSize{idx}   = size(ValsNum{idx});
   
end

% Get index of the first vector parameter
% Not assigned or used if all parameters are scalars
if vLen(MeanValue)>1
   dimcomp = MeanValue;
elseif vLen(Seed)>1
   dimcomp = Seed;
end

% Sample-based case
if(strcmp(Vals{FrameBased},'off')) 
   set_param([block, '/Frame Status Conversion'],'outframe','Sample-based');   
   set_param([block, '/Buffer'],'N','1');   % Do not buffer up
   set_param([block, '/Buffer'],'ic','0');   % Do not buffer up
   
   % Interpret as 1-D; OR scalar output
   if(strcmp(Vals{Orient},'on')) || ~any(vLen-1)
      set_param([block, '/Reshape'],'OutputDimensionality','1-D array');
      
      % 2-D vector output
   else
      
      % Decide which orientation to follow
      
      % At least one of Mean and Seed is a vector.  Adopt orientation of Mean/Seed.
      if exist('dimcomp', 'var')   
         vec = vSize{dimcomp};
         % Both Mean and Seed are scalars; Variance is vector/matrix.
         %   Take orientation of Variance.  Adopt if vector.
      else
         vec = vSize{VarValue};
      end
      
      % Column vector
      if vec(1) > vec(2)
         set_param([block, '/Reshape'],'OutputDimensionality','Column vector');
         % Row vector
      elseif  vec(1) < vec(2)
         set_param([block, '/Reshape'],'OutputDimensionality','Row vector');
         
         % Both Mean and Seed are scalars.  Variance is a matrix.
         %   Therefore output is unoriented.
      else
         set_param([block, '/Reshape'],'OutputDimensionality','1-D array');
      end   
      
   end
   
   % Frame-based case
else
   set_param([block, '/Frame Status Conversion'],'outframe','Frame-based');   
   set_param([block, '/Buffer'],'N','sampPerFrame');   % Buffer up
   set_param([block, '/Reshape'],'OutputDimensionality','Customize');
   set_param([block, '/Reshape'],'OutputDimensions','[sampPerFrame,length(s)]');
   
   if (str2num(Vals{SampPerFrame})>1)
      set_param([block, '/Buffer'],'ic','buffic');
   else
      set_param([block, '/Buffer'],'ic','0');
   end
   
end;

%*********************************************************************
% Function Name:	'cbFrameBased'
%  - Callback function for 'frameBased' parameter
%********************************************************************

function cbFrameBased(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnSamp   = En{6};
oldEnOrient = En{7};

if(strcmp(Vals{5},'off'))
    En{6}  = 'off';
    En{7}  = 'on';
else % 'Frame-based'
    En{6}  = 'on';
    En{7}  = 'off';
end;

if strcmp(oldEnSamp, En{6}) == 0 || strcmp(oldEnOrient, En{7}) == 0
    set_param(block,'MaskEnables',En);
end

%*********************************************************************
% Function Name:	'cbOrient'
%  - Callback function for 'orient' parameter
%********************************************************************

function cbOrient(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnFrame = En{5};

if(strcmp(Vals{7},'on'))  % Interpret as 1-D
    En{5}  = 'off';
else
    En{5}  = 'on';
end;

if strcmp(oldEnFrame, En{5}) == 0
    set_param(block,'MaskEnables',En);
end

%*********************************************************************
% Function Name:	'gwexpand'
%  - Helper function to build up the covariance matrix
%********************************************************************

function [m, d, s] = gwexpand(m, d, s)
%GWEXPAND generate valid mean, standard deviation and seeds for GWEXPAND block.
%	[M, D, S] = GWEXPAND(M, D, S) checks input mean M, standard deviation
%	D, and seed S. When they are not valid, validate them for GWEXPAND
%	block, or give an error message.

m = m(:).';
s = s(:)';
l_m = length(m);
l_s = length(s);
[n_d, m_d] = size(d);
if n_d ~= m_d
	if min(n_d, m_d) == 1
		if any(d < 0)
			error('Standard deviation must consist of nonnegative numbers only.');
		end
		d = diag(d);
	else
		error('Standard deviation for Gaussian noise block is not valid.');
	end;
else
	[not_used, m_d] = chol(d);
	if (m_d ~= 0) && ~all(all(d == 0))
		error('The covariance matrix must be symmetric and nonnegative definite.');
	end;
end;
l_d = length(d);
if ((l_m < l_d) && (l_m ~= 1)) || ((l_m > l_d) && (l_d ~= 1))
	error(['The dimensions of the Mean and Variance for Gaussian noise ',...
           'generator block are not compatible.']);
end;
max_l = max(l_m, l_d);
if l_s < max_l
    new_seed = 1;
    while l_s < max_l
        seed_pos = find(s == new_seed);
        if (isempty(seed_pos))
            s = [s, new_seed];
            l_s = length(s);
        end
        new_seed = new_seed + 1;
    end    
elseif l_s > max_l
    if max_l ~= 1
        s = s(1 : max_l);
    else
        d = eye(l_s) * d;
    end;
end;
if ~all(all(d == 0))
    [d, tmp] = chol(d);
    if (tmp > 0)
        error('The covariance matrix must be symmetric and nonnegative definite.');
    end;
end
