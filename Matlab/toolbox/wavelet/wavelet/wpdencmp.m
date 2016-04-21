function varargout = wpdencmp(varargin)
%WPDENCMP De-noising or compression using wavelet packets.
%   [XD,TREED,PERF0,PERFL2] =
%   WPDENCMP(X,SORH,N,'wname',CRIT,PAR,KEEPAPP)
%   returns a de-noised or compressed version XD of input
%   signal X (1-D or 2-D) obtained by wavelet packet
%   coefficients thresholding.
%   The additional output argument TREED is the
%   wavelet packet best tree decomposition of XD.
%   PERFL2 and PERF0 are L^2 recovery and compression
%   scores in percentages.
%   PERFL2 = 100*(vector-norm of WP-cfs of XD)^2 over
%   (vector-norm of WP-cfs of X)^2
%
%   SORH ('s' or 'h') is for soft or hard thresholding
%   (see WTHRESH for more details).
%   Wavelet packet decomposition is performed at level N,
%   and 'wname' is a string containing the wavelet name.
%   Best decomposition is performed using entropy criterion
%   defined by string CRIT and parameter PAR (see WENTROPY
%   for details). Threshold parameter is also PAR.
%   If KEEPAPP = 1, approximation coefficients cannot be
%   thresholded; otherwise, they can be.
%   ---------------------------------------------------------
%   [XD,TREED,PERF0,PERFL2] =
%   WPDENCMP(TREE,SORH,CRIT,PAR,KEEPAPP)
%   has same output arguments, using the same options as
%   above, but obtained directly from the input wavelet
%   packet tree decomposition TREE of the
%   signal to be de-noised or compressed.
%   In addition if CRIT = 'nobest' no optimization is done
%   and the current decomposition is thresholded.
%
%   See also DDENCMP, WDENCMP, WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.4.2 $

%
%--------------%
% OLD VERSION  %
%--------------%
%   [XD,TREED,DATAD,PERF0,PERFL2] =
%   WPDENCMP(X,SORH,N,'wname',CRIT,PAR,KEEPAPP)
%   returns a de-noised or compressed version XD of input
%   signal X (1-D or 2-D) obtained by wavelet packets
%   coefficients thresholding.
%   The additional output arguments [TREED,DATAD] are the
%   wavelet packet best decomposition structure of XD,
%   PERFL2 and PERF0 are L^2 recovery and compression
%   scores in percentages.
%   PERFL2 = 100*(vector-norm of WP-cfs of XD)^2 over
%   (vector-norm of WP-cfs of X)^2
%   SORH ('s' or 'h') is for soft or hard thresholding
%   (see WTHRESH for more details).
%   Wavelet packet decomposition is performed at level N
%   and 'wname' is a string containing wavelet name.
%   Best decomposition is performed using entropy criterion
%   defined by string CRIT and parameter PAR (see WENTROPY
%   for details). Threshold parameter is also PAR.
%   If KEEPAPP = 1, approximation coefficients cannot be
%   thresholded, otherwise it is possible.
%
%   [XD,TREED,DATAD,PERF0,PERFL2] =
%   WPDENCMP(TREE,DATA,SORH,CRIT,PAR,KEEPAPP)
%   has same output arguments, using the same options as
%   above, but obtained directly from the input wavelet
%   packet decomposition structure [TREE,DATA] of the
%   signal to be de-noised or compressed.
%   In addition if CRIT = 'nobest' no optimization is done
%   and the current decomposition is thresholded.
%
%   See also DDENCMP, WDENCMP, WENTROPY, WPDEC, WPDEC2.

% Check arguments and set problem dimension.
oldFlag = 0;
nbIN    = nargin;
nbOUT   = nargout;
switch nbIN
    case {5,6}
      Ts = varargin{1};
      if nbIN==5    % NEW VERSION
          okOUT = [1:4];
          Ds  = Ts;
          num_IN = 2;
      else          % OLD VERSION
          okOUT = [1,3:5];
          Ds    = varargin{2};
          num_IN  = 3;
          oldFlag = 1;
      end
      if ~any(okOUT==nbOUT)
          error('Invalid number of output arguments.');
      end
	  [sorh,crit,par,keepapp] = deal(varargin{num_IN:end});

	  if oldFlag
		  verWTBX = wtbxmngr('version','nodisp');
		  if ~isequal(verWTBX,'V1')
			  WarnString = strvcat(...
				  'Warning: The number of output arguments for the wpdencmp', ...
				  'function has change and this calling syntax is obsolete.', ...
				  'Please type "help wtbxmngr" at the MATLAB prompt', ...
				  'for more information.' ...
				  );
			  DlgName = 'Warning Dialog';
			  wwarndlg(WarnString,DlgName,'bloc');
			  varargout = cell(1,nargout); 
			  return
		  end
	  end

	  if oldFlag
		  sizdat = wdatamgr('rsizes',Ds);
      else
          sizdat = read(Ds,'sizes');
      end
      dim = size(sizdat,1);

    case 7
      switch nbOUT
        case {1,2,4} , okOUT = nbOUT;               % NEW VERSION
        case {3,5}   , okOUT = nbOUT; oldFlag = 1;  % OLD VERSION
        otherwise    , oldFlag = 1;                 % ERROR
      end
      if ~any(okOUT==nbOUT)
          error('Invalid number of output arguments.');
      end
      [x,sorh,n,w,crit,par,keepapp] = deal(varargin{1:7});
      if errargt(mfilename,n,'int'), error('*'), end
      if errargt(mfilename,w,'str'), error('*'), end
      dim = 1; if min(size(x)) ~= 1, dim = 2; end

    otherwise % ERROR for NEW or OLD VERSION
      if ~any([5:7]==nbIN)
          error('Invalid number of input arguments.');
      end
      if ~any([0:5]==nbOUT)
          error('Invalid number of output arguments.');
      end
end
if errargt(mfilename,sorh,'str'), error('*'), end
if errargt(mfilename,crit,'str'), error('*'), end

num_OUT = 1;
if oldFlag	% OLD VERSION.
	
	if oldFlag
		verWTBX = wtbxmngr('version','nodisp');
		if ~isequal(verWTBX,'V1')
			WarnString = strvcat(...
				'Warning: The number of output arguments for the wpdencmp', ...
				'function has change and this calling syntax is obsolete.', ...
				'Please type "help wtbxmngr" at the MATLAB prompt', ...
				'for more information.' ...
				);
			DlgName = 'Warning Dialog';
			wwarndlg(WarnString,DlgName,'bloc');
			varargout = cell(1,nargout); 
			return
		end
	end
	
	if nargin==7
		% Wavelet packet decomposition of x.
        if dim==1
            [Ts,Ds] = wpdec(x,n,w,crit,par);
        else
            [Ts,Ds] = wpdec2(x,n,w,crit,par);
        end

    elseif strcmp(crit,'nobest') == 0
        % Update entropy.
        Ds = entrupd(Ts,Ds,crit,par);
    end
    if strcmp(crit,'nobest') == 0
        % Perform best tree.
        [Ts,Ds] = besttree(Ts,Ds);
    end

    % Wavelet packet coefficients thresholding.
    Dsd = wpthcoef(Ds,Ts,keepapp,sorh,par);
    Tsd = Ts;

    % Wavelet packet reconstruction of xd.
    varargout{num_OUT} = wpcoef(Tsd,Dsd,0);
    if nbOUT<2 , return; else , num_OUT = num_OUT+1; end

    varargout{num_OUT} = Ts;
    if nbOUT<3 , return; else , num_OUT = num_OUT+1; end

    varargout{num_OUT} = Dsd;
    if nbOUT<4 , return; else , num_OUT = num_OUT+1; end
    lastOUT = 5;
	
else		% NEW VERSION.	
    if nargin==7
        % Wavelet packet decomposition of x.
        switch dim
          case 1 , Ts = wpdec(x,n,w,crit,par);
          case 2 , Ts = wpdec2(x,n,w,crit,par);
        end

    elseif strcmp(crit,'nobest') == 0
        % Update entropy.
        Ts = entrupd(Ts,crit,par);
    end
    if strcmp(crit,'nobest') == 0
        % Perform best tree.
        Ts = besttree(Ts);
    end

    % Wavelet packet coefficients thresholding.
    Tsd = wpthcoef(Ts,keepapp,sorh,par);

    % Wavelet packet reconstruction of xd.
    varargout{num_OUT} = wpcoef(Tsd,0);
    if nbOUT<2 , return; else , num_OUT = num_OUT+1; end

    varargout{num_OUT} = Tsd;
    if nbOUT<3 , return; else , num_OUT = num_OUT+1; end
    Ds  = Ts;
    Dsd = Tsd;
    lastOUT = 4;
end

% Compute L^2 recovery and compression scores.
% Extract final coefficients after thresholding.
if oldFlag
    cfs = wdatamgr('rallcfs',Dsd);
else
    cfs = read(Dsd,'allcfs');
end

% Compute compression score.
varargout{num_OUT} = 100*(length(find(cfs==0))/length(cfs));
if nbOUT<lastOUT , return; else , num_OUT = num_OUT+1; end

% Extract final coefficients before thresholding.
if oldFlag
    orcfs = wdatamgr('rallcfs',Ds);
else
    orcfs = read(Ds,'allcfs');
end

% Compute L^2 recovery score.
nc = norm(orcfs);
if nc<eps
    varargout{num_OUT} = 100;
else
    varargout{num_OUT} = 100*((norm(cfs)/nc)^2);
end
