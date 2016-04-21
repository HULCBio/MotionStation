function [cplxconstpts, err] = tcmconstmapper(trellis, M, mod_type)
%TCMCONSTMAPPER Constellation points ordering for TCM 
%   [CPLXCONSTPTS, ERR] = TCMCONSTMAPPER(TRELLIS, M, 'MOD-TYPE') outputs
% complex constellation points ordered as required by TCM. The input 
% argument TRELLIS describes the generator trellis. M is the alphabet
% size and must be a power of two. The third argument is a string that refers 
% to the modulation type. The two supported modulation types are
% 'qam' and 'psk'.
%
% For example:
% constpts = tcmconstmapper(poly2trellis([1 3],[1 0 0; 0 5 2]), 8, 'psk')

%   Copyright 1996-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/07/30 02:48:39 $ 

constpts = [];
err.msg = [];
err.mmi = [];

%-- Error checks
if(nargin~=3)
    err.msg = ['Incorrect number of input arguments.'];
    err.mmi = 'comm:tcmconstmapper:numArg';
    return;
end

%-- Check trellis
[isok, msg] = istrellis(trellis);
if(~isok)
    err.msg = ['Invalid trellis structure. ' msg]; 
    err.mmi = 'commblks:tcmconstmapper:isTrellis';
    return;
end

%-- Check M
if(~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    err.msg = ['M must be a positive integer.'];
    err.mmi = 'comm:tcmconstmapper:Mreal';
    return;
end

if( ~isnumeric(M) || ceil(log2(M)) ~= log2(M))
    err.msg = ['M must be in the form of M = 2^K, where K is an integer.'];
    err.mmi = 'comm:tcmconstmapper:Mpow2';
    return;
end

%-- Check 'mod_type'
if(~(strcmp(mod_type,'qam') || strcmp(mod_type,'psk')))
    err.msg = ['Invalid modulation type specified.'];
    err.mmi = 'comm:tcmconstmapper:modtype';
    return;
end

%-- Do set partitioning
switch mod_type
    case 'psk'
        % Save the set-partitioned constellation points in constpts for 'psk'
        if(M==4)
            constpts = exp(2*pi*i*[0 2 1 3]/4);
        elseif(M==8)
            constpts = exp(2*pi*i*[0 4 2 6 1 5 3 7]/8);
        elseif(M==16)
            constpts = exp(2*pi*i*[0 8 4 12 2 10 6 14 1 9 5 13 3 11 7 15]/16);
        else
            err.msg = ['The value of M specified is unsupported.'];
            err.mmi = 'comm:tcmconstmapper:Munsupported';    
            return;
        end
    case 'qam'
        % Save the set-partitioned constellation points in constpts for 'qam'
        if(M==4)
            constpts = exp(2*pi*i*[0 2 1 3]/4);
        elseif(M==8)
            constpts = [-3+1i 1+1i -1-1i 3-1i -1+1i 3+1i -3-1i 1-1i];
        elseif(M==16)
            constpts = [-3+3i 1-1i -3-1i 1+3i -1+1i 3-3i -1-3i 3+1i -1+3i 3-1i -1-1i 3+3i -3+1i 1-3i -3-3i 1+1i];
        elseif(M==32)
            constpts = [-3+3i 1-1i -3-5i 5+3i -3-1i 5-1i 1+3i 1-5i -5-3i 3+5i -1+1i 3-3i -5+1i 3+1i -1+5i -1-3i -5-1i 3-1i -1+3i -1-5i -5+3i 3-5i -1-1i 3+3i -3+1i 5+1i 1+5i 1-3i -3+5i 5-3i -3-3i 1+1i];
        elseif(M==64)   
            constpts = [-7+7i 1-1i -7-1i 1+7i -3+3i 5-5i -3-5i 5+3i -3+7i 5-1i -3-1i 5+7i -7+3i 1-5i -7-5i 1+3i -5+5i 3-3i -5-3i 3+5i -1+1i 7-7i -1-7i 7+1i -1+5i 7-3i -1-3i 7+5i -5+1i 3-7i -5-7i 3+1i -5+7i 3-1i -5-1i 3+7i -1+3i 7-5i -1-5i 7+3i -1+7i 7-1i -1-1i 7+7i -5+3i 3-5i -5-5i 3+3i -7+5i 1-3i -7-3i 1+5i -3+1i 5-7i -3-7i 5+1i -3+5i 5-3i -3-3i 5+5i -7+1i 1-7i -7-7i 1+1i];
        else
            err.msg = ['The value of M specified is unsupported.'];
            err.mmi = 'comm:tcmconstmapper:Munsupported'; 
            return;
        end
    otherwise
        err.msg = ['Invalid modulation type specified.'];
        err.mmi = 'comm:tcmconstmapper:modtype';
        return;
end

outSym = trellis.numOutputSymbols;
if (outSym~=M)
    err.msg = ['Incorrect trellis specified for the chosen signal constellation set.'];
    err.mmi = 'comm:tcmconstmapper:MTrellisDimension';
else
    cplxconstpts = gentcmconstmapper(trellis, constpts);
end
        
% [EOF]