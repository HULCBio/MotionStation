function m=pem_grey_f(data,m0,varargin)
%IDGREY/PEM	Computes the prediction error estimate of a general linear model.
%   MODEL = PEM(DATA,Mi)  
%
%   MODEL: returns the estimated model in IDGREY object format
%   along with estimated covariances and structure information. 
%   For the exact format of M type  IDPROPS IDGREY.
%
%   DATA:  The estimation data in IDDATA object format. See help IDDATA.
%
%   Mi: A IDGREY object that defines the model structure. See help IDGREY.
%
%  By MODEL = PEM(DATA,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%  all properties associated with the model structure and the algorithm
%  can be affected. Type IDPROPS IDGREY and IDPROPS ALGORITHM for a list of
%  Property/Value pairs. Note in particular that the properties
%  'InitialState' and 'DisturbanceModel' can be set to values that
%  extend or override the parameterization in the m-file.


%	L. Ljung 10-1-86, 7-25-94
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.3.4.1 $ $Date: 2004/04/10 23:17:00 $


if nargin<1
   disp('       M = PEM(Z,Mi)  For IDSS model Mi')
   disp('       M = PEM(Z,Mi,Property_1,Value_1,...,Property_n,Value_n)')
   return
end


%
%  *** Set up default values ***

if isa(m0,'iddata') | isa(m0,'idfrd') % forgive order confusion
   datn = inputname(2);
   z=m0;
   m0 = data;
   data = z;
else
  datn = inputname(1);
end

if isa(data,'idfrd')
  data = iddata(data);
  forcenox0 = 1;
else
  forcenox0 = 0;
end


% % TM - check implications
% imatch = strmatch('wfoc',lower(varargin(1:2:end))); 
% if ~isempty(imatch)
%   Wfoc = varargin{2*imatch};
%   varargin = varargin([1:2*imatch-2,2*imatch+1:end]);
% else
%   Wfoc = [];
% end
% 
[ny,nu]=size(m0);
if  ~isa(data,'iddata')
   if ~numeric(data)
      error(['The data must either be an IDDATA object or a matrix.'])
   end
   nz = size(data,2);
   if nz~=ny+nu+1
      error(sprintf(['The model size is not consistent with the number of',...
            '\ncolumns in the data.']))
   end
   ddata = iddata(data(:,1:ny),data(:,ny+1:end-1));
   data = pvset(ddata,'Domain','Frequency','SamplingInstants',data(:,end));
   iddataflag = 0;
else
   iddataflag = 1;
   Tsdata = pvget(data,'Ts');
   [N,nyd,nud]=size(data);
   if nyd~=ny|nud~=nu
      error(sprintf(['The model size is not consistent with the number of',...
            'inputs \nand outputs in the data.']))
   end
end
if ~strcmp(pvget(data,'Domain'),'Frequency'),
  error('This code is for Domain-Frequency only' );
end
if isempty(pvget(data,'Name'))
   data=pvset(data,'Name',datn);
end

[Ncap,ny,nu]=size(data);
Tsdata = pvget(data,'Ts');
Tsdata = Tsdata{1}; % TM We assume all experiments have same sampling time

% $$$ y=pvget(data,'OutputData');
% $$$ u=pvget(data,'InputData');
% $$$ z = [y{1},u{1}]; 
if nargin>2
   if ~isstr(varargin{1})|...
         (strcmp(lower(varargin{1}),'trace')&...
         fix(length(varargin)/2)~=length(varargin)/2)% old syntax 
      npar=length(pvget(m0,'ParameterVector'));
      varargin = transf(varargin,npar);
   end
   set(m0,varargin{:}) 
end

Ts=pvget(m0,'Ts'); 

%chkmdinteg(Ts,pvget(data,'Ts'),pvget(data,'InterSample'),1);

[A,B,C,D,K] = ssdata(m0);
nx = size(A,1);
ei = eig(A-K*C);
algorithm=pvget(m0,'Algorithm');
Zstab = algorithm.Advanced.Threshold.Zstability;
Sstab = algorithm.Advanced.Threshold.Sstability;
 if (Ts==0&max(real(ei))>Sstab&norm(K)==0)|(Ts>0&max(abs(ei))>Zstab)
    
   warning(sprintf(['The initial model has an unstable predictor.',...
         '\nMake sure',...
         ' that the model''s sampling interval ',num2str(Ts),' is correct.'...
         '\nINIT may',...
         ' be used to find a stable initial model.']))
end

idm = pvget(m0,'idmodel');

if Ts>0
   if Ts~=Tsdata
      disp(['Model sampling interval changed to ',num2str(Tsdata), ...
            ' (Data''s sampling interval).'])
      m0 = pvset(m0,'Ts',Tsdata);
   end
end
Inpd = pvget(m0,'InputDelay');
if Ts==0
   Tsdata = pvget(data,'Ts'); Tsdata = Tsdata{1};
   if Tsdata==0, 
     %TM This might happen when data is an idfrd object
   else
     Inpd = Inpd/Tsdata;%%LL be careful. This should not be OK
   end
   if any(Inpd ~= fix(Inpd))
      error(sprintf(['The InputDelay for a time continuous model must ',...
            'be a multiple of the data sampling interval.']))
   end
end
dats = nkshift(data,Inpd);
[z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag]=idprep_f(dats,0,datn);
error(errflag)

% if ~isempty(Wfoc), % Do weighting
%   if ~iscell(Wfoc),
%     Wfoc = {Wfoc};
%   end
%   for kexp = 1:length(z),
%     z = [spdiags(Wfoc{kexp},0,length(Wfoc{kexp}),length(Wfoc{kexp}))* ...
% 	 z{kexp}(:,1:end-1),z{kexp}(:,end)]; 
%   end
% end

struc.type='ssgen';
struc.realflag = realdata(data);
data = complex(data); % This is to get correct covariance matrix
struc.modT=Tsdata;
struc.lambda = pvget(m0,'NoiseVariance');
if ischar(pvget(m0,'CovarianceMatrix'))
   struc.cov = 0;
else
   struc.cov = 1;
end
if strcmp(pvget(m0,'MfileName'),'procmod')
    arg = pvget(m0,'FileArgument');
    dnr = arg{6}; %parameternumbers for the delay parameters
    bnr = arg{7}; %parameter number and bounds [dn-by-3]
%     if
%     if any(type{1}=='D')
%         dnr = 2+eval(type{1}(2));
        struc.dflag = dnr;
        if ~isempty(bnr)
        struc.bounds = bnr;
    end
%     else
%         struc.dflag = 0;
%     end
end
isint = pvget(data,'InterSample');
if strcmp(m0.CDmfile,'d') & (strcmp(isint,'foh') | strcmp(isint, ...
						  'bl')),
  error(['InterSample=', isint, ' and CDmfile=' m0.CDmfile, ...
	 ' are not compatible']);
end

% $$$ try % To handle time series
% $$$    struc.intersample = isint{1,1};
% $$$ catch
% $$$    struc.intersample = 'zoh';
% $$$ end

struc.intersample = isint{1};
if strcmp(m0.CDmfile,'c')
   struc.Tflag = 1; % Sample system (not if bl though)
   if strcmp(isint{1},'bl'),
     struc.Tflag = 0; % No sampling %%LL think aobut this
     struc.modT = 0;  % CT model
   end
else
   struc.Tflag = 0;
end
% if strcmp(m0.CDmfile,'cd'),
%   switch isint{1},
%    case 'bl'
%     struc.Tflag = 0; % No sampling
%     struc.modT = 0;  % CT model
%    case 'foh'
%     struc.Tflag = 0; % Sample FOH %%LL was 1
%   end
% end  

par=pvget(m0,'ParameterVector'); 
if isstr(algorithm.MaxSize),...
      algorithm.MaxSize = idmsize(Ncap,length(par));
end


foc = algorithm.Focus;
if ~isempty(foc)
    if ischar(foc) % Stability, Simulation, Predition .. Nothing to do ...
    else
        foc = foccheck(foc,Tsdata,0,'f');
        data = idfilt(data,foc); % exceptional case of cellarray of length==Ne=2=4
    end
end

% war =0;
% if ~ischar(foc)
%    war =1;
% elseif ~strcmp(foc,'Prediction')
%    war =1;
% end
% if war
%    warning(['''Focus'' other than ''Prediction'' is not',...
%          ' supported for IDGREY models.'])
% end
algorithm.LimitError = 0; %No lim for FD data
 
if algorithm.LimitError~=0|any(strcmp(m0.InitialState,{'Estimate','Auto'}))
   [e,xi]=pe_f(data,m0,'e');
   if struc.realflag
       xi = real(xi);
   end
end
if algorithm.LimitError~=0
   e1 = pvget(e,'OutputData');
   ee=[];
   for kexp = 1:length(e1)
      ee=[ee;e1{kexp}];
   end
   Ncap=size(ee,1);
   algorithm.LimitError = ...
      median(abs(ee-ones(Ncap,1)*median(ee)))*algorithm.LimitError/0.7;
end
struc.pname = pvget(m0,'PName');

% *** Select InitialState
struc.init = m0.InitialState;
% Overrides:
if Ne>1
   switch m0.InitialState
   case 'Estimate'
      disp(sprintf(['InitialState = ''Estimate'' cannot be used ',...
            'for multiple experiment data.',...
            '\nIt cas been changed to ''Backcast''.']));
      struc.init= 'Backcast';
      
   case 'Auto'
      struc.init = 'Backcast';
   case 'Model'
      disp(sprintf(['InitialState = ''Model'' may not be suited ',...
            'for multiple experiment data.',...
            '\nThe same initial state will be used for all the experiments.',...
            '\nConsider changing it to ''Backcast''.']));
      
   end
end
if strcmp(struc.init,'Auto')
   e2 = pe_f(data,m0,'z'); % fix iddata and cell array
   e =pvget(e,'OutputData');
   e2 =pvget(e2,'OutputData');
   nor1 = norm(cat(1,e2{:})); nor2 =norm(cat(1,e{:}));%(e{1});
   if nor1/nor2>algorithm.Advanced.Threshold.AutoInitialState
     if strcmp(m0.MfileName,'procmod')
            struc.init = 'BackCast';
        else
            struc.init= 'Estimate';
        end
   else
      struc.init= 'Model';
   end
end
 
% *** Display the initial estimate ***
if strcmp(algorithm.Trace,'On')|strcmp(algorithm.Trace,'Full')
   disp([' INITIAL ESTIMATE'])
   disp(['Current loss: ' num2str(det(pvget(m0,'NoiseVariance')))])
   disp(['par-vector:'])
   disp(par)
end
if algorithm.MaxIter(1)==0,m=m0;return,end % Assign output !!LL%%LL

% *** Minimize the prediction error criterion ***
 
par=pvget(m0,'ParameterVector');
 es = pvget(m0,'EstimationInfo');
ut = pvget(m0,'Utility');
if strcmp(m0.DisturbanceModel,'Estimate')% for internal use during
                                         % minimization
  error('DisturbanceModel=Estimate is not suported'); %TM
  m0.DisturbanceModel = 'K';
  try
   Ki = ut.K;
  catch
    Ki = zeros(nx,ny);
  end
  par = [par;Ki(:)];
  m0 = parset(m0,par);
end

  
if strcmp(struc.init,'Estimate') % for internal use during minimization
% $$$    disp('Setting to x0')
% $$$    isa(m0,'idgrey')

  m0.InitialState = 'x0';
   par = [par;xi];
   m0 = parset(m0,par);
   nxi = length(xi);
end
struc.model=m0;
struc.domain = 'f';
[parnew,strucnew,it_inf,cov,lambda]=minloop(z,par,struc,algorithm,es);

if strcmp(m0.InitialState,'x0')
   ut.X0 = parnew(end-nxi+1:end,1);
   parnew = parnew(1:end-nxi,1);
   if ~ischar(cov)
     try
       cov = cov(1:end-nxi,1:end-nxi);
     end
   end
   m0.InitialState = 'Estimate';
end
if strcmp(m0.DisturbanceModel,'K')
  Kvec  = parnew(end-nx*ny+1:end,1);
  ut.K = reshape(Kvec,nx,ny);
  parnew = parnew(1:end-nx*ny,1);
  if ~ischar(cov)
    try
      cov = cov(1:end-nx*ny,1:end-nx*ny);
    end
  end
  m0.DisturbanceModel = 'Estimate';
end
m=m0;
idmod=pvget(m,'idmodel');

it_inf.DataLength=Ncap; 
it_inf.DataTs=Tsdata;
it_inf.DataInterSample=pvget(data,'InterSample');
it_inf.DataDomain = 'Frequency';
it_inf.Status='Estimated model (PEM)';
it_inf.DataName=pvget(data,'Name');
it_inf.Method = 'PEM';
idmod=pvset(idmod,'CovarianceMatrix',cov,'NoiseVariance',lambda,...
   'EstimationInfo',it_inf,'ParameterVector',parnew,...
	    'InputName',pvget(data,'InputName'),...
	    'OutputName',pvget(data,'OutputName'),'InputUnit',...
	    pvget(data,'InputUnit'),'OutputUnit',...
	    pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'),'Utility',ut);

% m.idmodel = idmod;
m = pvset(m,'idmodel',idmod);  

% $$$  disp(' TM fix');
% $$$   m=pvset(m,'CovarianceMatrix',cov,'NoiseVariance',lambda,...
% $$$      'EstimationInfo',it_inf,'ParameterVector',parnew,...
% $$$   	    'InputName',pvget(data,'InputName'),...
% $$$   	    'OutputName',pvget(data,'OutputName'),'InputUnit',...
% $$$   	    pvget(data,'InputUnit'),'OutputUnit',...
% $$$   	    pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'),'Utility',ut);



% if ~strcmp(cov,'None')
% 	setcov(m)
% end


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function argnew = transf(argold,npar)
ml=length(argold);
prop={'fixedpar','maxiter','tol','lim','maxsize'};
for kk=1:ml
   if strcmp(argold(kk),'trace');
      argnew{2*kk-1}='trace';argnew{2*kk}='Full';
   else
      if kk==1&~isempty(argold{kk})
         argold{kk}=indinvert(argold{kk},npar);
      end
      
      argnew{2*kk-1}=prop{kk};
      argnew{2*kk}=argold{kk};
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind3 = indinvert(ind1,npar);
if npar==0
   error('Transformation of old syntax for INDEX failed.')
end

ind2 = [1:npar]';
indt = ind2*ones(1,length(ind1))~=ones(npar,1)*ind1(:)';
if size(indt,2)>1, indt=all(indt');end
ind3 = ind2(find(indt));
