function varargout = wfusimg(varargin)
%WFUSIMG Fusion of two images.
%   XFUS = WFUSIMG(X1,X2,WNAME,LEVEL,AFUSMETH,DFUSMETH) returns the fusioned
%   image XFUS obtained by fusion of the two original images X1 and X2.
%   Each fusion method, defined by AFUSMETH and DFUSMETH, merges in a specific
%   way datailed below, the decompositions of X1 and X2, at level LEVEL 
%   and using wavelet WNAME.
%
%   Matrices X1 and X2 must be of same size and are supposed to be associated
%   to indexed images on a common colormap (see WEXTEND to resize images).
%
%   AFUSMETH and DFUSMETH define the fusion method for approximations and
%   details respectively.
%
%   [XFUS,TXFUS,TX1,TX2] = WFUSIMG(X1,X2,WNAME,LEVEL,AFUSMETH,DFUSMETH) 
%   returns in addition to matrix XFUS, three objects of the class WDECTREE
%   associated with XFUS, X1 and X2 respectively (see @WDECTREE).
%
%   WFUSIMG(X1,X2,WNAME,LEVEL,AFUSMETH,DFUSMETH,FLAGPLOT) plots in addition  
%   the objects TXFUS,TX1,TX2.
%
%   In the sequel Fusmeth denotes AFUSMETH or DFUSMETH. Available fusion
%   methods are:
%
%    - simple ones, Fusmeth can be 'max', 'min', 'mean', 'img1', 'img2' or 
%      'rand' which merges the two approximations or details structures
%      obtained from X1 and X2 elementwise by taking the maximum, the minimum,
%      the mean, the first element, the second element or a randomly chosen 
%      element;
%
%    - parameter-dependent ones, Fusmeth is of the following form 
%      Fusmeth = struct('name',nameMETH,'param',paramMETH) where nameMETH
%      can be:
%         - 'linear'
%         - 'UD_fusion' : Up-Down fusion  
%         - 'DU_fusion' : Down-Up fusion
%         - 'LR_fusion' : Left-Right fusion 
%         - 'RL_fusion' : Right-Left fusion
%         - 'UserDEF'   : User defined fusion
%   For the description of these options and the corresponding parameter
%   paramMETH, see WFUSMAT.
%
%   Example:
%    load mask; X1 = X;
%    load bust; X2 = X;
%    [XFUS,TXFUS,TX1,TX2] = wfusimg(X1,X2,'db2',5,'max','max','plot'); 
%     

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Jan-2003.
%   Last Revision: 18-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:42:52 $ 

% Syntax 2:
% ---------
%  VARARGOUT = WFUSIMG('PropName1',PropValue1,'PropName2',PropValue2,...)
%
%  The valid PropNames are: 
%     'X1' , 'X2' , 'wname' , 'level' , 'flagPlot' and
%     'AfusMeth' : method of fusion for approximation
%     'DfusMeth' : method of fusion for details
%
%    'X1' and 'X2' are required fields.
%
% The default values are:
%    wname_DEF     = 'db1';
%    level_DEF     = 2;
%    AfusMeth_DEF  = struct('name','linear','param',0.5);
%    DfusMeth_DEF  = struct('name','linear','param',0.5);
%    flagPlot_DEF  = 'plot';
%
% To avoid plots you can set 'flagPlot' to 'noplot'
%
% -----------------------------------------------------------------------
% Examples:
% ---------
%    load mask; X1 = X;
%    load bust; X2 = X;
%    wfusimg('X1',X1,'X2',X2,'wname','db3','level',2);
%    [X,t,t1,t2] = wfusimg('X1',X1,'X2',X2,'AfusMeth','max');

% Check arguments.
%-----------------
nbIN     = nargin;
stdINPUT = true;
if nbIN>0 , stdINPUT = ~ischar(varargin{1}); end
if stdINPUT
    if nbIN < 6
        error('Not enough input arguments.');
    elseif nbIN > 7
        error('Too many input arguments.');
    end
    X1 = varargin{1}; 
    X2 = varargin{2};
    wname = varargin{3};
    level = varargin{4};
    AfusMeth = varargin{5};
    DfusMeth = varargin{6};
    if nargin>6
        if strcmp(lower(varargin{7}),'plot')
            flagPlot = true; 
        else
            flagPlot = false;
        end
    else
            flagPlot = false;
    end
else
    % Defaults.
    %----------
    wname_DEF    = 'db1';
    level_DEF    = 2;
    fusMeth_DEF  = struct('name','linear','param',0.5);
    flagPlot_DEF = true;
    %--------------------------------------------------
    wname = wname_DEF;
    level = level_DEF;
    AfusMeth = fusMeth_DEF;
    DfusMeth = fusMeth_DEF;
    flagPlot = flagPlot_DEF;
    %--------------------------------------------------
    k    = 1;
    while k<=nbIN
        switch varargin{k}
            case 'X1'       , X1       = varargin{k+1};
            case 'X2'       , X2       = varargin{k+1};
            case 'wname'    , wname    = varargin{k+1};
            case 'level'    , level    = varargin{k+1};
            case 'AfusMeth' , AfusMeth = varargin{k+1};
            case 'DfusMeth' , DfusMeth = varargin{k+1};    
            case 'flagPlot' , flagPlot = varargin{k+1};
            otherwise
                error('Invalid input arguments.');
        end
        k = k+2;
    end
    if isempty(X1) || isempty(X2)
        error('Both images X1 and X2 must be given.');
    end
    if isempty(wname)    , wname = wname_DEF;  end
    if isempty(level)    , level = level_DEF;  end
    if isempty(AfusMeth)  , AfusMeth = fusMeth_DEF;  end
    if isempty(DfusMeth)  , DfusMeth = fusMeth_DEF;  end
    if strcmp(flagPlot,'noplot') || isempty(flagPlot)
        flagPlot = false;
    end
    if ischar(X1) , dummy = load(X1); X1 = dummy.X; end
    if ischar(X2) , dummy = load(X2); X2 = dummy.X; end
end
%--------------------------------------------------

if sum(size(X1)==size(X2))~=2
    error('Input images must be of the same size.');
end

% Decomposition.
%---------------
tIMG1 = wfustree(X1,level,wname);
clear X1
tIMG2 = wfustree(X2,level,wname);
clear X2

% Fusion.
%--------
[XFus,tFus] = wfusdec(tIMG1,tIMG2,AfusMeth,DfusMeth);

% Plot trees.
%------------
if flagPlot
    plot(tIMG1); plot(tIMG2); plot(tFus);
end

% Outputs
%--------
switch nargout
    case 0 ,
    case {1,2} , varargout = {XFus , tFus};
    otherwise  , varargout = {XFus , tFus, tIMG1,tIMG2};
end
