function [svout,w] = sigma(varargin)
%   SIGMA  Singular value plot of LTI models.
%
%   SIGMA(SYS) produces a singular value (SV) plot of the frequency 
%   response of the LTI model SYS (created with TF, ZPK, SS, or FRD).  
%   The frequency range and number of points are chosen automatically.  
%   See BODE for details on the notion of frequency in discrete time.
%
%   SIGMA(SYS,{WMIN,WMAX}) draws the SV plot for frequencies ranging
%   between WMIN and WMAX (in radian/second).
%
%   SIGMA(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the frequency response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   SIGMA(SYS,W,TYPE) or SIGMA(SYS,[],TYPE) draws the following
%   modified SV plots depending on the value of TYPE:
%          TYPE = 1     -->     SV of  inv(SYS)
%          TYPE = 2     -->     SV of  I + SYS
%          TYPE = 3     -->     SV of  I + inv(SYS) 
%   SYS should be a square system when using this syntax.
%
%   SIGMA(SYS1,SYS2,...,W,TYPE) draws the SV response of several LTI
%   models SYS1,SYS2,... on a single plot.  The arguments W and TYPE
%   are optional.  You can also specify a color, line style, and marker 
%   for each system, as in  sigma(sys1,'r',sys2,'y--',sys3,'gx').
%   
%   SV = SIGMA(SYS,W) and [SV,W] = SIGMA(SYS) return the singular 
%   values SV of the frequency response (along with the frequency 
%   vector W if unspecified).  No plot is drawn on the screen. 
%   The matrix SV has length(W) columns and SV(:,k) gives the
%   singular values (in descending order) at the frequency W(k).
%
%   For details on Robust Control Toolbox syntax, type HELP RSIGMA.
%
%   See also BODE, NICHOLS, NYQUIST, FREQRESP, LTIVIEW, LTIMODELS.
%
%	Andrew Grace  7-10-90
%	Revised ACWG 6-21-92
%	Revised by Richard Chiang 5-20-92
%	Revised by W.Wang 7-20-92
%       Revised P. Gahinet 5-7-96
%       Revised A. DiVergilio 6-16-00
%       Revised K. Subbarao 10-11-01
%	Copyright 1986-2004 The MathWorks, Inc. 
%	$Revision: 1.46.4.2 $  $Date: 2004/04/08 20:48:31 $
ni = nargin;
if ni==0,
   eval('exresp(''sigma'')')
   return
end

% Parse input list
try
   for ct = ni:-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys,SystemName,InputName,OutputName,PlotStyle,ExtraArgs] = ...
      rfinputs('sigma',ArgNames,varargin{:});
catch
   rethrow(lasterror)
end
[w,type] = deal(ExtraArgs{:});
nsys = length(sys);

% Handle various calling sequences
if nargout>0,  % Call with output arguments
   sys = sys{1};          % single model
   if (nsys>1 | ndims(sys)>2),
      error('SIGMA takes a single model when used with output arguments.')
   elseif isempty(w)
      w = 'decade';  % make sure to include decades for ROUNDFOCUS below
   end
   % Compute frequency response
   [sv,w] = LocalSigResp(sys,w,type);
   svout = sv.';
else
   % Singular Values plot
   % Create plot
   h = ltiplot(gca,'sigma',InputName,OutputName,cstprefs.tbxprefs);
   
   % Set global frequency focus for user-defined range/vector (specifies preferred limits)
   if iscell(w)
      h.setfocus([w{:}],'rad/sec')
   elseif ~isempty(w)
      w = unique(w); % (g212788)
      h.setfocus([w(1) w(end)],'rad/sec')
   end
   
   % Create responses
   NameForms = {'inv(%s)' , '1+%s' , '1+inv(%s)'};
   for ct=1:nsys
      src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
      r = h.addresponse(src);
      % Handle special types
      if type>0
         % Doctor response name
         r.Name = sprintf(NameForms{type},r.Name);
         src.Name = r.Name;  % used by data tips
         % Set DataFcn to compute SV's of inv(sys), 1+sys, or inv(1+sys)
         r.DataFcn = {@LocalSpecialTypeSigma src r w type};
      else
         r.DataFcn = {'sigma' src r w};
      end        
      % Styles and preferences
      initsysresp(r,'sigma',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h,'sigma');
   lticharmenu(h,m.Characteristics,'sigma');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sv,w,focus] = LocalSigResp(sys,w,type)

if ~isempty(w) & isnumeric(w)  % Supplied grid
   F = freqresp(sys,w);
   focus = [w(1),w(end)];
else
   ClipDecade = ischar(w);
   [m,p,w,FocusInfo] = genfresp(sys,4,w);
   focus = FocusInfo.Range(4,:);
   m = permute(m,[2 3 1]);
   p = permute(p,[2 3 1]);
   % Clip to FOCUS and make W(1) and W(end) entire decades
   if ClipDecade
      [w,m,p] = roundfocus('freq',focus,w,m,p);
   end
   F = m .* exp(1i*p);
end

% Generating Frequency Response from magnitude and phase
[ny,nu,lw] = size(F);
nsv = min(ny,nu);
sv = zeros(lw,nsv);
heye = eye(nu);
for ct = 1:lw,
   % Derive appropriate frequency response based on type
   switch type,
   case 2
      % Overwrite H with I+H
      F(:,:,ct) = heye + F(:,:,ct);
   case 3
      % Overwrite H with I+inv(H)
      F(:,:,ct) = heye + inv(F(:,:,ct));
   end    
   % Compute singular values
   F_ct = F(:,:,ct);
   if all(isfinite(F_ct(:))),
      sv(ct,:) = svd(F_ct)';
   else
      % Guard against Inf values
      sv(ct,:) = Inf;
   end
end
% Handle case TYPE=1 
if type==1,
   % Singular values of inv(SYS) are the reciprocals of those of SYS
   zsv = (sv==0);    % zero SV
   if any(zsv),
      warning('Frequency response is singular at some frequencies.')
   end
   sv(~zsv) = 1./sv(~zsv);
   sv(zsv) = Inf;
   sv = fliplr(sv);
end


function LocalSpecialTypeSigma(src,r,w,type)
% Computes singular value data for types 1,2,3
sys = src.Model;
Ts = sys.Ts;
Size = size(sys);
for ct=1:prod(Size(3:end))
   d = r.Data(ct);
   % Compute frequency response
   [d.SingularValues,d.Frequency,d.Focus] = LocalSigResp(sys(:,:,ct),w,type);
   d.Ts = Ts;
end
