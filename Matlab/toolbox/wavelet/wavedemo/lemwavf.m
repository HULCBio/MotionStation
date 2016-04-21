function F = lemwavf(wname)
%LEMWAVF Lemarie wavelet filters.
%   F = LEMWAVF(W) returns the scaling filter
%   associated with Lemarie wavelet specified
%   by the string W, where W = 'lemN'.
%   Possible values for N are:
%          N = 1, 2, 3, 4 or 5.
%   N.B:
%      Using the MATLAB Extended Symbolic Toolbox
%      possible values of N are positive integers.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $ $Date: 2004/03/15 22:37:24 $

if ischar(wname) && ~isempty(wname)
        lw = length(wname); ab = abs(wname);
        ii = lw+1; 
        while (47<ab(ii-1)) && (ab(ii-1)<58) , ii = ii-1; end
        num = wstr2num(wname(ii:lw));
else
        num = wname;
end
if isempty(num) || any(num < 1) || any(num ~= fix(num))
        error('*** Invalid wavelet number ! ***');
end

switch num
    case 1
F = [...
   0.46069299844871   0.53391629051346   0.03930700681965  -0.03391629578182 ...
	];

    case 2
F = [...
   0.31555164655258   0.59149765057882   0.20045477817080  -0.10034811856888 ...
  -0.01528128420694   0.00846362066021  -0.00072514051618   0.00038684732960 ...
        ];

    case 3
F = [...
   0.23108942231941   0.56838231367966   0.33173980738190  -0.09447000132310 ...
  -0.06203683305244   0.02661631105889  -0.00209952890579   0.00001769381066 ...
   0.00128429679795  -0.00053703458679   0.00002283826072  -0.00000928544107 ...
        ];

    case 4
F = [...
   0.17565337503255   0.52257484913870   0.42429244721660  -0.04601056550580 ...
  -0.11292720306517   0.03198741803409   0.00813124691980  -0.00743764392677 ...
   0.00548090619143  -0.00140066128481  -0.00054200083128   0.00025607264164 ...
  -0.00008795126642   0.00003025515674  -0.00000082014466   0.00000027569334 ...
        ];

    case 5
F = [...
   0.13807658847623   0.47310642622099   0.48217097800239   0.02112933622031 ...
  -0.15081998732499   0.01935767268926   0.02716532750995  -0.01588522540421 ...
   0.00671209165995   0.00120022744496  -0.00321203819186   0.00115266788547 ...
  -0.00018266213413  -0.00002953360842   0.00008433396295  -0.00002997969339 ...
   0.00000534552866  -0.00000159098026   0.00000003069431  -0.00000000895816 ...
        ];

    otherwise
        % compute bernstein polynomial of order 4*num-1.
        % requires the Extended Symbolic Toolbox.
        if ~exist('maple')
                msg = '*** The Extended Symbolic Toolbox is required ***';
                error(msg);
        end
        order = 4*num-1;
        mpa('ord',order);
        maple('readlib(bernstein):');
        maple('f:=proc(t) if t<1/4 then 0 else if t >3/4 then 1 else 2*t-1/2 fi fi end:');
        cfs = maple('bernstein(ord,f,(1+x)/2);');
        ber = sym2poly(cfs);

        r = roots(ber);
        v = r-sqrt(r.^2-1);
        ind = find(abs(v)>1);
        if ~isempty(ind)
            v(ind)=ones(size(ind))./v(ind);
        end
        F = real(poly(v));
        F = F/sum(F);
end
