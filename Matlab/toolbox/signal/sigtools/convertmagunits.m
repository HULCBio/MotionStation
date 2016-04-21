function val = convertmagunits(val, source, target, band)
%CONVERTMAGUNITS   Convert magnitude values to different units
%   CONVERTMAGUNITS(VAL, SRC, TRG, BAND) Convert VAL from SRC units to TRG
%   units in the filter band BAND.  SRC and TRG can be 'linear', 'squared'
%   or 'db'.  BAND can be 'pass' or 'stop'.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:31 $

error(nargchk(4,4,nargin));

banderr.message    = sprintf('''%s'' is an unknown band, specify ''pass'' or ''stop''.', band);
banderr.identifier = generatemsgid('unknownBand');
targerr.message    = sprintf('''%s'' is an unknown target, specify ''linear'', ''squared'' or ''db''.', target);
targerr.identifier = generatemsgid('unknownTarget');

known = false;

switch source
    case 'linear'
        switch target
            case 'linear'
                % NO OP, same target as source.
            case 'db'
                switch band
                    case 'pass', val = 20*log10((1+val)/(1-val));
                    case 'stop', val = -20*log10(val);
                    otherwise,   error(banderr);
                end
            case 'squared'
                switch band
                    case 'pass', val = ((1-val)/(1+val))^2;
                    case 'stop', val = val^2;
                    otherwise,   error(banderr);
                end
            otherwise
                error(targerr);
        end
    case 'squared'
        switch target
            case 'squared'
                % NO OP, same target as source
            case 'db'
                switch band
                    case {'pass', 'stop'}, val = 10*log10(1/val);
                    otherwise,             error(banderr);
                end
            case 'linear'
                switch band
                    case 'pass', val = (1-sqrt(val))/(1+sqrt(val));
                    case 'stop', val = sqrt(val);
                    otherwise,   error(banderr);
                end
            otherwise
                error(targerr);
        end
    case 'db'
        switch target
            case 'db'
                % NO OP, same target as source
            case 'squared'
                switch band
                    case {'pass', 'stop'}, val = 1/(10^(val/10));
                    otherwise,             error(banderr);
                end
            case 'linear'
                switch band
                    case 'pass', val = (10^(val/20) - 1)/(10^(val/20) + 1);
                    case 'stop', val = 10^(-val/20);
                    otherwise,   error(banderr);
                end
            otherwise
                error(targerr)
        end
    otherwise
        error(generatemsgid('unknownSource'), ...
            '''%s'' is an unknown source, specify ''linear'', ''squared'' or ''db''.', source);
end

% [EOF]
