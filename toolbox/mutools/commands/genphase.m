% function resp = genphase(d,discflg)
%
%   Uses the complex-cepstrum (Oppenheim & Schafer, Digital
%   Signal Processing, pg 501) to generate a complex
%   frequency response, RESP, whose magnitude is equal to
%   the real, positive response D, but whose phase corresponds
%   to a stable, minimum phase function. Both D and RESP are
%   VARYING matrices.
%
%   If DISCFLG==1 (default=0) then all frequency data is
%   interpreted as unit disk data, and RESP should be interpreted
%   as discrete-time.  If DISCFLG==0, then the frequency data is
%   interpreted as imaginary axis, and RESP is interpreted as
%   continuous time.
%
%   See also: FITMAG, FITSYS, MAGFIT and MSF.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function resp = genphase(d,discflg)
  if nargin == 0
    disp(['usage: resp = genphase(d)']);
    return
  end
  [dtype,drows,dcols,dnum] = minfo(d);
  if dtype ~= 'vary' | drows ~= 1 | dcols ~= 1
    error('data should be a 1x1, varying matrix')
    return
  end

  if nargin==1
        discflg = [];
  end

  if isempty(discflg)
        discflg = 0;
  else
        discflg = discflg(1);
        if discflg~=1
                discflg=0;
        end
  end

  magorig = abs(d(1:dnum,1).');          %ROW vector
  omegaorig = d(1:dnum,2).';        %ROW vector
  if any(diff(omegaorig)<=0)
    error('frequency data should be monotonically increasing')
    return
  end
  if discflg==0
        pw = sqrt(omegaorig(dnum)*omegaorig(1));
        [come,mag] = flatten(omegaorig,magorig);
        capt = 1/pw;
        tcomes = capt*capt*(come .^2);            % top half disk
        % warp the frequencies around the disk
        % domeorig has values between 0 and pi
        domeorig = acos( (1 - tcomes) ./ ( 1 + tcomes) ); % top half disk
  else
        domeorig = omegaorig;
        mag = magorig;
  end
  lowf=domeorig(1);
  highf = domeorig(length(domeorig));
  if lowf < 0 | highf > pi
    if discflg==0
        error('Frequency range should be on nonnegative imaginary')
        return
    else
        error('Frequency range should be on top of disc')
        return
    end
  end

  smgap = min([lowf pi-highf]);
  if smgap==0
    npts = 4096;
    hnpts = 2048;
  else
    nn = ceil( (log(2*pi/smgap))/log(2) );
    npts = 2*(2^nn);
    hnpts = 2^nn;
    if npts < 4096
        npts = 4096;
        hnpts = 2048;
    end
    if npts > 17000
        disp(['GENPHASE: large frequency range - calculation may be slow!'])
    end
  end

% interpolate the frequency and magnitude data to
%    hnpts points linearly spaced around top half of disk

  lindomee = (pi/hnpts)*(0:hnpts-1);
  [lindome,linmag] = terpol(domeorig,mag,hnpts);

% duplicate data around disk

  dome = [lindome (2*pi)-fliplr(lindome)];          %all disk
  mag = [linmag  fliplr(linmag)];                   %all disk

% complex cepstrum to get min-phase

  ymag = log( mag .^2 );
  ycc = ifft(ymag);                              % 2^N
  nptso2 = npts/2;                               % 2^(N-1)
  xcc = ycc(1:nptso2);                           % 2^(N-1)
  xcc(1) = xcc(1)/2;                             % halve it at 0
  xhat = exp(fft(xcc));                          % 2^(N-1)
  domeg = dome(1:2:nptso2-1);                    % 2^(N-2)
  xhat = xhat(1:nptso2/2);                       % 2^(N-2)
% interpolate back to original frequency data
  [compd] = terpolb(domeg,xhat,domeorig);

  if discflg==0
        resp = vpck(compd.',omegaorig.');
  else
        resp = vpck(compd.',domeorig);
  end