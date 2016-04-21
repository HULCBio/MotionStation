function y = sosfilt(SOS, x)
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/dsp/sosfilt.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/03/21 22:07:32 $

eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(isfloat(SOS), 'error', ['Function ''sosfilt'' is not defined for values of class ''' class(SOS) '''.']);

if ((size(SOS,1) > 1) && (size(SOS,2)>1))
    eml_assert(size(SOS, 2) == 6,'error','Size of SOS matrix must be Mx6.');
else
    eml_assert(length(SOS(:)) == 6,'error','Size of SOS matrix must be Mx6.');
end 

RTN = 0;
eml_ignore('d = pwd;');
eml_ignore('cd(fullfile(matlabroot,''toolbox'',''signal'',''signal''));');
eml_ignore([...
    ' y = sosfilt(SOS,x);',10 ...
]);
eml_ignore('RTN = 1;');
eml_ignore('cd(d);');
if RTN, return; end

if isempty(x)  
    % when input is empty, output is the same as input. 
    y = x;
else
    if (size(x,1) == 1) && (size(x,2) > 1) % x is a row vector
        xused = x.';
    else
        xused = x;
    end
    numSamps = size(xused,1);
    numChans = size(xused,2);
    outCplx = ~(isreal(xused) && isreal(SOS));
    switch class(xused)
        case 'single'
            eml_cdecl(yused, 'single', outCplx, size(xused));
        case 'double'
            eml_cdecl(yused, 'double', outCplx, size(xused));
    end

    if ((size(SOS,1) > 1) && (size(SOS,2)>1))
        numSections = size(SOS, 1);
        % size of state vector 'z' is numSection*2. 
        if (outCplx)
            z = complex(zeros(numChans*numSections*2, 1),zeros(numChans*numSections*2, 1));
        else
            z = zeros(numChans*numSections*2, 1);
        end
        if (isreal(SOS))
            a0inv = zeros(numSections,1);
        else
            a0inv = complex(zeros(numSections,1),zeros(numSections,1));            
        end

        for i = 1:numSections
            if (SOS(i,4) == 1)
                a0inv(i) = 1;
            else
                a0inv(i) = 1/SOS(i, 4);
            end
        end
        switch class(xused)
            case 'single'
                SOSused = SOS.';
                if (isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_RR(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);
                elseif (~isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_RC(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);                    
                elseif (isreal(SOS) && ~isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_CR(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);                    
                else
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_CC(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);                    
                end
            case 'double'
                SOSused = SOS.';
                if (isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_DD(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);
                elseif (~isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_DZ(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);
                elseif (isreal(SOS) && ~isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_ZD(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);
                else
                    cc.MWDSP_BQ6_DF2T_1fpf_Nsos_ZZ(xused,eml_wref(yused),z, eml_wref(SOSused), a0inv, numSamps, numChans, numSections);
                end
        end
    else
        if (outCplx)
            z = complex(zeros(numChans*2, 1),zeros(numChans*2, 1));
        else
            z = zeros(numChans*2, 1);
        end
        if (isreal(SOS))
            if (SOS(4) ~= 1)
                a0inv = 1/SOS(4);
            else
                a0inv = 1;
            end
        else
            if (SOS(4) ~= 1)
                a0inv = 1/SOS(4);
            else
                a0inv = complex(1,0);
            end
        end

        switch class(xused)
            case 'single'
                if (isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_RR(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                elseif (~isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_RC(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                elseif (isreal(SOS) && ~isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_CR(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                else
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_CC(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                end
            case 'double'
                if (isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_DD(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                elseif (~isreal(SOS) && isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_DZ(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                elseif (isreal(SOS) && ~isreal(xused))
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_ZD(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                else 
                    cc.MWDSP_BQ6_DF2T_1fpf_1sos_ZZ(xused,eml_wref(yused),z, SOS, a0inv, numSamps, numChans);
                end
        end
    end
    if (size(x,1) == 1) && (size(x,2) > 1) % x is a row vector
        y = yused.';
    else
        y = yused;
    end
    
end
