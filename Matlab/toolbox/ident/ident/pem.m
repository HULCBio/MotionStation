function m=pem(varargin)
%PEM	Computes the prediction error estimate of a general linear model.
%   MODEL = PEM(DATA,Mi)  or MODEL = PEM(DATA,Mi,Property/Value pairs)
%
%   MODEL: returns the estimated model in IDPOLY, IDSS or IDPROC object format
%   along with estimated covariances and structure information. 
%   MODEL.NoiseVariance contains the innovations variance, estimated from DATA.
%   For the exact format of MODEL see  HELP IDPOLY, HELP IDSS or HELP IDPROC.
%
%   DATA :  The estimation data in IDDATA or IDFRD object format.
%     See help IDDATA and help IDFRD.
%
%   Mi: Defines the model structure.
%     Mi can be an IDMODEL object like IDPOLY, IDSS, IDGREY or IDPROC
%     obtained by the object creator function, or any estimation or
%     transformation routine. See HELP for these objects.
%
%     Mi can also be an argument that defines the structure in a direct way.
%     STATE-SPACE MODELS:
%        Omittig Mi: MODEL = PEM(DATA) gives a default order linear 
%        state-space model with one delay from the inputs.
%        Mi = nx (an integer) gives a general linear state space model
%        of order nx.  MODEL = PEM(DATA,'nx',nx) also allows nx 
%        to be a vector of orders, where the final choice of orders
%        will be prompted for.See HELP IDSS/PEM for more details.
%
%     POLYNOMIAL MODELS:
%        Mi = [na nb nc nd nf nk] gives a general polynomial model:
%	     A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%        with the indicated orders (For multi-input data nb, nf and
%        nk are row vectors of lengths equal to the number of input channels.)
%        An alternative syntax is MODEL = PEM(DATA,'na',na,'nb',nb,...) with
%        omitted orders taken as zero. See HELP IDPOLY/PEM for more
%        details.
%
%     PROCESS MODELS:
%        Mi = 'P1D' gives a continuous time, first order model with time
%        delay. The acronym controls the order, possible integration,
%        possible underdamped modes, etc. See HELP IDPROC/PEM for details.
%
%   By MODEL = PEM(DATA,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See  HELP IDPROPS for a list of Property/Value pairs. 
%   Some important Properties to affect the model are
%       'nk': The delay from the input(s). (Not for IDGREY and IDPROC)
%       'InitialState': How to treat the initial filter conditions
%       'Focus': To focus the fit to certain frequency ranges.
%       'trace': Controls the information about the estimation process
%                that is displayed in the command window.
%
%   The covariance matrix of the residuals (the model's prediction errors)
%   is given in MODEL.NoiseCovariance.
%
%   See also IDPOLY, IDSS, IDGREY, IDPROC, ARMAX, OE, BJ, and IDPROPS.

%  

%	L. Ljung 10-1-86, 7-25-94
%       Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.31.4.1 $  $Date: 2004/04/10 23:19:12 $

if nargin<1
   disp('Usage: M = PEM(Z)  For quickstart')
   disp('       M = PEM(Z,M)  For model structure M')
   disp('       M = PEM(Z,NN,PVpairs)')
   if nargout, m = [];end
   return
end
if length(varargin)>1
    mtest = varargin{2};
    if length(mtest)>1&strcmp(lower(mtest(1:2)),'be')%'best' order
        varargin = varargin([1,3:length(varargin)]);
    end
    % Note: the below does not allow order confusion between data and model
    if iscell(mtest) % then it's probably an IDPROC argument
        mtest = mtest{1};
    end
    if ischar(mtest)&lower(mtest(1))=='p' % idproc!
        m0 = idproc(varargin{2});
        data = varargin{1};
        if isa(data,'frd'),data=idfrd(data);end
        if isa(data,'idfrd')
            data = iddata(data);
        end
        if ~isa(data,'iddata')
            error('The first argument must be an IDDATA object. See HELP IDDATA.')
        else
            data = setid(data);
            data = estdatch(data,0);
            if isempty(pvget(data,'Name'))
                 data = pvset(data,'Name',inputname(1));
            end
            [dum,datapv] = pnsortd(varargin(3:end));
            if~isempty(datapv), data = pvset(data,datapv{:});end
        end
        if length(varargin)>2
            m = pem(data,m0,varargin{3:end});
        else
            m = pem(data,m0);
        end
        return
    end
end
cvm = []; n4flag = 0;
for kk = 2:length(varargin)
   try
      if strcmp('co',lower(varargin{kk}(1:2)))
         cvm = varargin{kk+1};
      end
   end
end

if length(varargin)==1|(ischar(varargin{2})&~...
        (strcmp(lower(varargin{2}),'nx')|...
        strcmp(lower(varargin{2}),'na')|...
        strcmp(lower(varargin{2}),'nb')|...
        strcmp(lower(varargin{2}),'nc')|...
        strcmp(lower(varargin{2}),'nd')|...
        strcmp(lower(varargin{2}),'nf')))
    z = varargin{1};
    if isa(z,'frd'),z = idfrd(z);end
    if isa(z,'idfrd'); z = iddata(z);end
    if isa(z,'iddata')
        z = setid(z);
        z = estdatch(z);
            dom = pvget(z,'Domain');
               [dum,datarg] = pnsortd(varargin(2:end));
            if ~isempty(datarg),z = pvset(z,datarg{:});end
        else 
            dom = 'Time';
        end
     if length(varargin)==1
             mdum = n4sid(z,'best','cov','none');
        else
             mdum= n4sid(z,'best',varargin{2:end},'cov','none'); 
        end
    mdum = pvset(mdum,'CovarianceMatrix',cvm);
    n4flag = 1;
    
else
    try
        [mdum,z,order,args] = pemdecod('pem',varargin{:});
    catch
        error(lasterr)
    end
end
 if isa(z,'iddata')&isempty(pvget(z,'Name'))
    z=pvset(z,'Name',inputname(1));
end
if isa(z,'iddata')
    dom = pvget(z,'Domain');
else
    dom = 'Time'
end
if (isa(mdum,'idss')&~n4flag)|(isa(mdum,'double')&isempty(mdum))
         mdum = n4sid(z,order,args{:},'cov','None');
     mdum = pvset(mdum,'CovarianceMatrix',cvm);
    fixp = pvget(mdum,'FixedParameter');
    if ~isempty(fixp)
        fixflag = 1;
        if (iscell(fixp)|ischar(fixp))&isempty(pvget(mdum,'PName'))
            mdum = setpname(mdum);
            
            fixp=pnam2num(fixp,pvget(mdum,'PName'));
        end
        par = pvget(mdum,'ParameterVector');
        par(fixp)=zeros(length(fixp),1); mdum = parset(mdum,par);
    end
    
end
     m=pem(z,mdum);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

