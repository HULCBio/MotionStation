function thd=c2d(thc,T,varargin)
%C2D  Converts a continuous time model to discrete time.
%   MD = C2D(MC,T,METHOD)
%
%   MC: The continuous time model as an IDMODEL object.
%
%   T: The sampling interval
%   MD: The discrete time model, an IDMODEL model object.
%   METHOD: 'Zoh' (default) or 'Foh', corresponding to the
%      assumptions that the input is Zero-order-hold (piecewise
%      constant) or First-order-hold (piecewise linear).
%
%   IDPOLY models are returned as IDPOLY.
%   IDSS models are returned as IDSS, but the 'Structured' parameterization
%        is changed to 'Free'.
%   IDGREY models are returned as IDGREY if 'CDmfile' == 'cd', otherwise as IDSS.
%   
%   InputDelay in MC is carried over to MD.
%   To handle InputDelays that are not multiples of T requires the
%   Control System Toolbox.
%
%   For IDPOLY models, the covariance matrix P of MC is translated by the
%   use of numerical derivatives. The step sizes used for the differences are 
%   given by th m-file NUDERST.  For IDSS, IDARX and IDGREY models, the 
%   covariance matrix is not translated, but covariance information about
%   the input-output properties are included.
%  
%   To inhibit the translation of covariance information (which may take
%   some time), use C2D(MC,T,Method,'CovarianceMatrix','None'). (Any abbreviations
%   will do.) (The same effect is obtained by first doing SET(MC,'Cov','No').)
%
%   If you have the Control System Toolbox and use
%   MD = C2D(MC,T,METHOD)
%   where METHOD is any of 'tustin','prewarp',or,'matched', the transformation
%   will be using the corresponding method. See HELP SS/C2D.  Then no covariance
%   information is transformed.
%
%   See also IDMODEL/D2C.

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2004/04/10 23:17:20 $

if nargin < 2
    disp('Usage: MD = C2D(MC,T)')
    return
end
usecstb = 0;
method = 'zoh';
if ~isa(T,'double')
    error('The second argument of c2d must be a positive number.')
elseif T<=0
    error('The second argument of c2d must be a positive number.')
end
if length(varargin)>0
    val ={'tustin','prewarp','matched','zoh','foh'};
    for kv = 1:length(varargin)
        try
            [method,status] = pnmatchd(lower(varargin{kv}),val);
            
        end
    end
    if ~isempty(method)
        if ~any(strcmp(method,{'zoh','foh'}))
            usecstb = 1;
            ermsg= ['The option ',method,' requires the Control System Toolbox.']; 
        end
    end
end
if length(varargin)>0
    covval = [];
    for kv = 1:length(varargin)
        try
            covval = pnmatchd(varargin{kv},{'CovarianceMatrix'});
        catch
            covval = [];
        end
        if ~isempty(covval)
            if length(varargin)<kv+1
                error('The argument ''CovarianceMatrix'' must be followed by ''None''.')
            end
            covnew = varargin{kv+1};
            if isempty(covnew)|strcmp(lower(covnew(1)),'n')
                thc =  pvset(thc,'CovarianceMatrix','None');
            else
                error('The argument ''CovarianceMatrix'' must be followed by ''None''.')
            end
        end
    end
end
if usecstb
    if ~exist('ss/c2d')
        error(ermsg)
    end
    was = warning;
    warning off
    ths = ss(thc);
    warning(was)
    if strcmp(method,'prewarp')
        if length(varargin)<2
            error(sprintf(['The option ''prewarp'' requires a fourth argument Wc',...
                    '\n that defines the critical frequency.']))
        end
        ths = c2d(ths,T,'prewarp',varargin{2});
    else
        ths = c2d(ths,T,method);
    end
    switch class(thc)
        case 'idpoly'
            thd = idpoly(ths);
        otherwise
            thd = idss(ths);
            stn = pvget(thd,'StateName');
            kk = strcmp(stn,''); 
            if any(kk)
                ns = length(find(kk==0));
                stn = defnum(stn(1:ns),'xe',length(kk));
                thd = pvset(thd,'StateName',stn);
            end
    end
    thd = pvset(thd,'EstimationInfo',pvget(thc,'EstimationInfo'));
    return   
end
try
    thd = c2daux(thc,T,method);
catch
    error(lasterr)
end

