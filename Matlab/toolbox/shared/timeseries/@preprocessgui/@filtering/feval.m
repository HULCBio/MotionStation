function datasetout = feval(h,dataset)
%FEVAL
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:35 $

data = dataset.Data;
t = dataset.Time;
s = size(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Detrending %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(h.Detrendactive,'on')
    detrendeddata = data;
    for col=1:s(2)
        x = data(:,col);
        nanvals = isnan(x);
        % Less than two non-nan samples - do nothing
        if sum(~nanvals)<2
            detrendeddata(:,col) = x;
            break
        end
        
        % Detrend data without NaNs
        if strcmp(h.Detrendtype,'line')
           detrendeddata(~nanvals,col) = detrend(x(~nanvals));
        else
           detrendeddata(~nanvals,col) = detrend(x(~nanvals),'constant');
        end
        
        % Put the NaNs back
        detrendeddata(nanvals,col) = NaN;
    end
    data = detrendeddata;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Filtering %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(h.Filteractive,'on') 
	s = size(data);
	
	% Find uniform times. Assume time is ordered and increasing
	samp = min(diff(t));
	samp = (t(end)-t(1))/max(floor((t(end)-t(1))/samp),1);
	tsamp = t(1):samp:t(end);

	for col=1:s(2)
           x = data(:,col);
           nanvals = isnan(x);
	
           % Interpolate input data
           % If there are < 2 non-nan values give up
           if sum(~nanvals)<2
               break
           end
           % First and last values must not be NaN or interp1 will return
           % NaNs. Replace x(1) by the first non NaN value, replace x(end)
           % by the last non NaN value
           if isnan(x(1))
               x(1) = x(min(find(~nanvals)));
               nanvals(1) = false;
           end
           if isnan(x(end))
               x(end) = x(max(find(~nanvals)));
               nanvals(end) = false;
           end           
           xsamp = interp1(t(~nanvals),x(~nanvals),tsamp);
	
           % Filter interpolated data on eqiv discrete time sys
           if strcmp(h.Filter,'transfer')
               ysamp = filter(localc2d(h.Bcoeffs,samp),localc2d(h.Acoeffs,samp),xsamp);
           elseif strcmp(h.Filter,'firstord')
               ysamp = filter(localc2d(1,samp),localc2d([1 h.Timeconst],samp),xsamp);
           elseif strcmp(h.Filter,'ideal')
               ysamp = localideal(h.range,xsamp,samp,strcmp(h.Band,'pass'));
           end
               
           % Resample back to former time vector and remove missing vals
           data(:,col) = interp1(tsamp,ysamp,t);
           data(nanvals,col) = NaN;
	end        
end

datasetout = preprocessgui.dataset(data,t);
    

function Adisc = localc2d(A,samp)

% Convert A(s) to discrete time using (1-z^-1)/Ts
Adisc = zeros(1,length(A));
Adisc(1) = A(1);
backdiff = 1;
for k=2:length(A)
    backdiff = conv([1 -1],backdiff);
    Adisc(1:k) = Adisc(1:k)+backdiff*A(k)/samp^(k-1);
end
               

function y = localideal(range,x,samp,pass)

% Convert frequency range to radians per sample and cutoff above the Nyquist
% frequency
if length(range)~=2
    y = x;
    return
end
range = min(2*pi*samp*range,pi);

% Find the fft and freq vector
ftx = fft(x);
N = length(x);
f = linspace(0,(N-1)/N*2*pi,N);

% Find the frequencies within the specified range
I = (f>=range(1)) & (f<=range(2));

% Enforse symetry above the Nyquist freq for *non zero* freq  to ensure a 
% real inverse fft
I([false I(end:-1:2)]) = true;

% Zero out excluded frequencies
if pass
   ftx(~I) = 0;
else
   ftx(I) = 0;
end

% Do not return very small imaginary parts
y = real(ifft(ftx));

