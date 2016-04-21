function [rate, sm , convolution_coder,v34r, v34i] = v34param(rate_s, rate_r, convolution_coder, constellation_flag)
% V34PARAM calculate the parameters for V.34 modem configuration.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       [RATE, SM, CONVOLUTION_CODER, V34R, V34I] ...
%           = V34PARAM(RATE_S, RATE_R, CONVOLUTION_CODER, CONSTELLATION_FLAG)
%
%       RATE = V34PARAM defaults.
%       RATE_S : symbol translation rate.
%       RATE_R : bit translation rate.
%       CONVOLUTION_CODER : 1, 2, or 3, the convolution code 16, 32, or 64 state structure.
%       CONSTELLATION_FLAG : 1 for first quarter, for the caller's part.
%       CONSTELLATION_FLAG : 0 for entire map, for the answer's part.

%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.15 $

% parameter assignment
if nargin < 1
   rate_s = 3200; % you can choose the symbold rate from the mandatory
                         % rates of 2400, 3000, or 3200.
end;

if nargin < 2
   rate_r = 28800;  % Please look up the table 10/v.34 for valid
                         % data rate combination, which are:
                         % 2400, 4800, 7200, 9600, 12000, 14400, 16800, 19200, 
                         % 21600, 24000, 26400, and 28800.
end

if nargin < 3
   convolution_coder = 'v34cod16';   % choose of convolution code for trellis
                                     % code convolution. you can choose one of
                                     % the following: 'v34cod16', 'v34cod32',
                                     % 'v34cod64' please note that the 64 state
                                     % decode is very slow.
else
   if convolution_coder == 2
      convolution_coder = 'v34cod32';
   elseif convolution_coder == 3
      convolution_coder = 'v34cod64';
   else
      convolution_coder = 'v34cod16';
   end;
end;
if nargin < 4
    constellation_flag = 1;
end;

%this example simulate the primary channel only.
%this example has by-pass the signal testing hand-shaking circuits.
%this example has not included the simulation for the frame switching process.
%this 
%%%%%%%%calculation. Don't change here.
% generate the transfer function for the convolution code.

%eval(convolution_coder);
load_system(convolution_coder);

convolution_coder = simviter(convolution_coder);

% base on table 7/v.34
if rate_s == 2400
    rate_s_j = 7;
    rate_s_p = 12;
elseif rate_s == 2743
    rate_s_j = 8;
    rate_s_p = 12;
    error('Due to an absence of the frame switch circuit, this example cannot simulate your specified date rate.');
elseif rate_s == 2800
    rate_s_j = 7;
    rate_s_p = 14;
    if (rate_r ~= 16800) 
        error('Due to an absence of the frame switch circuit, this example cannot simulate your specified date rate.');
    end;
elseif rate_s == 3000
    rate_s_j = 7;
    rate_s_p = 15;
    if ~((rate_r == 12000) | (rate_r == 24000))
        error('Due to an absence of the frame switch circuit, this example cannot simulate your specified date rate.');
    end;
elseif rate_s == 3200
    rate_s_j = 7;
    rate_s_p = 16;
elseif rate_s == 3429
    rate_s_j = 8;
    rate_s_p = 15;
    error('Due to an absence of the frame switch circuit, this example cannot simulate your specified date rate.');
else
    disp('Illegal assignment for the symbol rate. Defaulting to 3200.')
    rate_s = 3200;
    rate_s_j = 7;
    rate_s_p = 16;
end
rate_s_n = floor(rate_r * .28 /rate_s_j);
rate_b   = ceil(rate_s_n /rate_s_p - eps);

if (rate_b <= 0) | (rate_b > 73)
    error('rate_r is not a valid number.');
else
    if rate_b <= 12
        K = 0;
    else
        rate_q = 0;
        rate_K = rate_b - 12;
        while (rate_K >= 32)
            rate_K = rate_K - 8;
            rate_q = rate_q + 1;
        end;
    end;
end;

rate_M = ceil(2^(rate_K/8));
rate_M_exp = max(round(1.25 * 2^(rate_K/8)), rate_M);
rate_L = 4 * rate_M * 2^rate_q;
rate_L_exp = 4 * rate_M_exp * 2^rate_q;

rate = [rate_s, rate_r,    rate_s_j, rate_s_p, rate_s_n, ... 
        rate_b, rate_q,    rate_K,   rate_M,   rate_M_exp, ...
        rate_L, rate_L_exp];

M = rate_M;
%calculate g2, g4, g8, z8, the shell mapping
sm = zeros(4, (M - 1) * 8 + 1); 
% g2
for i = 0 : 2 * (M - 1)
    sm(1, i+1) = M - abs(i - M + 1);
end;
% g4
for i = 0 : 4 * (M - 1)
    for j = 0 : i
        sm(2, i+1) = sm(2, i+1) + sm(1, j + 1) * sm(1, i - j + 1);
    end;
end;
% g8
for i = 0 : 8 * (M - 1)
    for j = 0 : i
        sm(3, i+1) = sm(3, i+1) + sm(2, j + 1) * sm(2, i - j + 1);
    end;
    sm(4, i+1) = sum(sm(3, [1 : i + 1])) - sm(3, i+1);
end;
s(4, 1) = 0;

%[v34r, v34i] = v34const(4*(2^(rate_q)+ceil(2+log(2^(rate_K+1))/log(8))*2^(rate_q)), 1);
[v34r, v34i] = v34const(4*(2^(rate_q) + (M-1)*2^(rate_q)), constellation_flag);
%end of the file.
