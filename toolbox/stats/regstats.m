function stats=regstats(responses,data,model,whichstats)
%REGSTATS Regression diagnostics for linear models.
%   REGSTATS(RESPONSES,DATA,MODEL) fits a multiple regression of the
%   measurements in the vector, RESPONSES, on the values in the matrix,
%   DATA. The function creates a UI that displays a group of checkboxes
%   that save diagnostic statistics to the base workspace using specified
%   variable names. MODEL controls the order of the regression model. By
%   default, REGSTATS uses a linear additive model with a constant term. 
%
%   MODEL can be following strings:
%   'linear'        - includes constant and linear terms
%   'interaction'   - includes constant, linear, and cross product terms.
%   'quadratic'     - interactions plus squared terms.
%   'purequadratic' - includes constant, linear and squared terms.
%
%   Alternatively, MODEL can be a matrix of model terms as accepted by
%   the X2FX function.  See X2FX for a description of this matrix and for
%   a description of the order in which terms appear.
%
%   STATS=REGSTATS(RESPONSES,DATA,MODEL,WHICHSTATS) creates an output
%   structure STATS containing the statistics listed in WHICHSTATS.
%   WHICHSTATS can be a single name such as 'leverage' or a cell array of
%   names such as {'leverage' 'standres' 'studres'}.  Valid names are:
%
%      Name          Meaning
%      'Q'           Q from the QR Decomposition of X
%      'R'           R from the QR Decomposition of X
%      'beta'        Regression Coefficients
%      'covb'        Covariance of Regression Coefficients
%      'yhat'        Fitted Values of the Response Data
%      'r'           Residuals
%      'mse'         Mean Squared Error
%      'leverage'    Leverage
%      'hatmat'      Hat (Projection) Matrix
%      's2_i'        Delete-1 Variance
%      'beta_i'      Delete-1 Coefficients
%      'standres'    Standardized Residuals
%      'studres'     Studentized Residuals
%      'dfbetas'     Scaled Change in Regression Coefficients
%      'dffit'       Change in Fitted Values
%      'dffits'      Scaled Change in Fitted Values
%      'covratio'    Change in Covariance
%      'cookd'       Cook's Distance
%      'tstat'       t Statistics for Coefficients
%      'fstat'       F Statistic
%      'all'         Create all of the above statistics
%
%   Example:  Plot residuals vs. fitted values for Hald data.
%      load hald
%      s = regstats(heat,ingredients,'linear',{'yhat','r'});
%      scatter(s.yhat,s.r)
%      xlabel('Fitted Values'); ylabel('Residuals');
%
%   See also LEVERAGE, STEPWISE, REGRESS.

%   References:
%   Belsley, D.A., E. Kuh, and R.E. Welsch (1980), Regression
%      Diagnostics, New York: Wiley.
%   Cook, R.D., and S. Weisberg (1982), Residuals and Influence
%      in Regression, New York: Wiley.
%   Goodall, C.R. (1993), Computation using the QR decomposition. 
%      Handbook in Statistics, Volume 9,  Statistical Computing
%      (C. R. Rao, ed.), Amsterdam, NL: Elsevier/North-Holland.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.27.4.3 $  $Date: 2004/04/01 16:24:00 $

if (nargout>0 || nargin>=4)
    action = 'batch';
else  
    action = 'start';
end

varnames = {'Q','R','beta','covb','yhat','r','mse','leverage','hatmat',...
            's2_i','beta_i','standres','studres','dfbetas','dffit',...
            'dffits','covratio','cookd', 'tstat', 'fstat'};

if (nargin<2)
   error('stats:regstats:TooFewInputs','At least two arguments are required.');
end
if nargin < 3
   model = 'linear';
end

% Check that the arguments are as expected, remove NaN.
[xr,xc] = size(data);
[yr,yc] = size(responses);
if (yr == 1), responses = responses'; yr = yc; yc = 1; end
if (xr == 1), data = data';           xr = xc; end
if (yr ~= xr)
   error('stats:regstats:InputSizeMismatch',...
         'RESPONSES and DATA must have the same number of rows.');
end
if (yc > 1)
   error('stats:regstats:InvalidData','RESPONSES must have a single column.');
end
bad = isnan(responses) | any(isnan(data),2);
if (any(bad))
   responses(bad) = [];
   data(bad,:) = [];
end

X = x2fx(data,model);
y = responses;

% Bring up "Export to Workspace" Dialog 
if strcmp(action,'start')
    labels = {'Q from QR Decomposition','R from QR Decomposition','Coefficients', ...
                 'Coefficient Covariance','Fitted Values', 'Residuals', ...
                 'Mean Square Error', 'Leverage','Hat Matrix','Delete-1 Variance', ...
                 'Delete-1 Coefficients','Standardized Residuals', ...
                 'Studentized Residuals','Change in Beta',...
                 'Change in Fitted Value','Scaled change in Fit', ...
                 'Change in Covariance','Cook''s Distance', ...
                 't Statistics', 'F Statistic'};
                 
    % Calculate all statistics 
    s = regstats(responses,data,model, 'all');
    
    items = {s.Q, s.R, s.beta, s.covb, s.yhat, s.r, s.mse, s.leverage, ...
             s.hatmat', s.s2_i, s.beta_i, s.standres, s.studres, s.dfbetas, ...
             s.dffit, s.dffits, s.covratio, s.cookd, s.tstat s.fstat};
                                 
    fh = @helpCallback;
    wintitle = 'Regstats Export to Workspace';
    hdialog = export2wsdlg(labels, varnames, items, wintitle, ...
                           false(1, 20), {fh});
    set(hdialog,'WindowStyle','normal');
else %  action = 'batch'
  idx = (1:20)';
  idxbool = false(size(idx));
  if ~iscell(whichstats), whichstats = {whichstats}; end
  for j=1:length(whichstats)
     snj = whichstats{j};
     if ~ischar(snj)
        error('stats:regstats:BadStats',...
              'WHICHSTATS argument must be one or more statistic names.');
     elseif isequal(snj,'all')
        idxbool(:) = 1;
        break;
     else
        k = find(strcmp(snj,varnames));
        if isempty(k)
           error('stats:regstats:BadStats',...
                 'Invalid statistic name ''%s''.',snj);
        else
           idxbool(k) = 1;
        end
     end
  end
  idx = idx(idxbool);
  if (length(idx) == 0), return, end
  [Q,R]=qr(X,0);
  beta = R\(Q'*y);
  yhat = X*beta;
  residuals = y - yhat;
  nobs = length(y);
  p = min(size(R));
  dfe = nobs-p;
  mse = sum(residuals.*residuals)./dfe;
  E = X/R;
  h = sum((E.*E)')';
  s_sqr_i = ((nobs-p)*mse - residuals.*residuals./(1-h))./(nobs-p-1);
  e_i = residuals./sqrt(s_sqr_i.*(1-h));
  ri = R\eye(p);
  xtxi = ri*ri';
  
  % Do one preliminary calculation
  if (any(idx == 11)) || (any(idx == 14))
     % Delete 1 coefficients. BETA_I
     stde = residuals./(1-h);
     stde = stde(:,ones(p,1));
     b_i = beta(:,ones(nobs,1)) - ri*(Q.*stde)';
  end

  % Store each requested statistic into the structure
  stats.source = 'regstats';
  if (any(idx == 1))  % Q from the QR decomposition of the X matrix.
	  stats.(varnames{1}) = Q;
  end
  if (any(idx == 2))  % R from the QR decomposition of the X matrix.
     stats.(varnames{2}) = R;
  end
  if (any(idx == 3))  % Coefficients.
     stats.(varnames{3}) = beta;
  end
  if (any(idx == 4))   % Covariance of the parameters.
     covb = xtxi*mse;
     stats.(varnames{4}) = covb;
  end
  if (any(idx == 5))  % Fitted values.
     if (any(bad)); yhat = fixrows(yhat, bad); end            
     stats.(varnames{5}) = yhat;
  end
  if (any(idx == 6))  % Residuals.
     tmp = residuals;
     if (any(bad)); tmp = fixrows(tmp, bad); end            
     stats.(varnames{6}) = tmp;
  end
  if (any(idx == 7))  % Mean squared error.
     stats.(varnames{7}) = mse;
  end
  if (any(idx == 8))  % Leverage.
     tmp = h;
     if (any(bad)); tmp = fixrows(tmp, bad); end            
     stats.(varnames{8}) = tmp;
  end
  if (any(idx == 9))  % Hat Matrix.
     stats.(varnames{9}) = Q*Q';
  end
  if (any(idx == 10)) % Delete 1 variance. S_I
     tmp = s_sqr_i;
     if (any(bad)); tmp = fixrows(tmp, bad); end            
     stats.(varnames{10}) = tmp;
  end
  if (any(idx == 11)) % Delete 1 coefficients. BETA_I
     stats.(varnames{11}) = b_i;
  end
  if (any(idx == 12)) % Standardized residuals.
     tmp = residuals./(sqrt(mse*(1-h)));
     if (any(bad)); tmp = fixrows(tmp, bad); end            
     stats.(varnames{12}) = tmp;
  end
  if (any(idx == 13)) % Studentized residuals. 
     tmp = e_i;
     if (any(bad)); tmp = fixrows(tmp, bad); end            
     stats.(varnames{13}) = tmp;
  end
  if (any(idx == 14)) % Scaled change in beta. DFBETAS
     b = beta(:,ones(nobs,1));
     s = sqrt(s_sqr_i(:,ones(p,1))');
     rtri = sqrt(diag(xtxi));
     rtri = rtri(:,ones(nobs,1));
     dfbeta = (b - b_i)./(s.*rtri);
     stats.(varnames{14}) = dfbeta;
  end
  if (any(idx == 15)) % Change in fitted values. DFFIT
     tmp = h.*residuals./(1-h);
     if (any(bad)); tmp = fixrows(tmp, bad); end            
     stats.(varnames{15}) = tmp;
  end
  if (any(idx == 16)) % Scaled change in fitted values. DFFITS
     tmp = sqrt(h./(1-h)).*e_i;
     if (any(bad)); tmp = fixrows(tmp, bad); end            
     stats.(varnames{16}) = tmp;
  end
  if (any(idx == 17)) %  Change in covariance. COVRATIO
     covr = 1 ./((((nobs-p-1+e_i.*e_i)./(nobs-p)).^p).*(1-h));
     if (any(bad)); covr = fixrows(covr, bad); end
     stats.(varnames{17}) = covr;
  end
  if (any(idx == 18)) %  Cook's Distance.
     d = residuals.*residuals.*(h./(1-h).^2)./(p*mse);
     if (any(bad)); d = fixrows(d, bad); end            
     stats.(varnames{18}) = d;
  end
  if (any(idx == 19)) %  t Statistics.
     d = struct;
     d.beta = beta;
     covb = xtxi*mse;
     d.se = sqrt(diag(covb));
     d.t = beta./d.se;
     d.pval = 2*(tcdf(-abs(d.t), dfe));
     d.dfe = dfe;
     stats.(varnames{19}) = d;
  end
  if (any(idx == 20)) %  F Statistic.
     d = struct;
     d.sse = dfe*mse;
     d.dfe = dfe;
     d.dfr = p-1;
     d.ssr = norm(yhat-mean(yhat))^2;
     d.f = (d.ssr/d.dfr)/(d.sse/d.dfe);
     d.pval = 1 - fcdf(d.f, d.dfr, d.dfe);
     stats.(varnames{20}) = d;
  end
  
end

%----------------------------------------------------------------------------
function helpCallback
% display help 

doc regstats

%----------------------------------------------------------------------------
function vv = fixrows(v, b)
% helper to extend v to original length, NaNs are given by b

vv = repmat(NaN, size(b));
vv(~b) = v;

