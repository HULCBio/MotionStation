function [inphh, quadd] = v34const(M, tp);
% V34CONST CCITT V.34 constellation standard.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       V34CONST plots a 1024 points QASK constellation. The circle ones
%       are first quarter constellations.
%
%       V34CONST(M) plots an M point constellation. M = 4 * X, where X is an
%       integer.
%
%       V34CONST(M, TYPE) plots an M point constellation with a specific type.
%       TYPE = 0, plot the constellation with binary numbering.
%       TYPE = 1, plot the first quarter.
%       TYPE = 2, plot the second quarter, which is a 90 degree shift of TYPE 1.
%       TYPE = 3, plot the third quarter, which is a 180 degree shift of TYPE 1.
%       TYPE = 4, plot the forth quarter, which is a 270 degree shift of TYPE 1.
%       TYPE = 5, plot the first quarter with binary numbering.
%       TYPE = 6, plot the second quarter with binary numbering.
%       TYPE = 7, plot the third quarter with binary numbering.
%       TYPE = 8, plot the forth quarter with binary numbering.

%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.13 $

indx = [0  1  2  3 4 5  6  7 8  9 10 11 12 13 14 15 16 17 18 19 20 21  22  23];
inph = [1 -3  1 -3 1 5 -3  5 5 -7  1 -7 -3 -7  5  1  9 -3  9 -7  5  9 -11   1];
quad = [1  1 -3 -3 5 1  5 -3 5  1 -7 -3 -7  5 -7  9  1  9 -3 -7  9  5   1 -11];

indx = [indx 24  25 26  27  28  29 30 31 32  33  34 35 36 37 38  39  40 41 42];
inph = [inph -7 -11  9  -3 -11   5  9  1 13 -11  -7 -3 13  5 13 -11   9 -7 13];
quad = [quad  9  -3 -7 -11   5 -11  9 13  1  -7 -11 13 -3 13  5   9 -11 13 -7];

indx = [indx  43  44  45  46  47 48 49  50  51  52  53 54  55 56  57 58 59  60];
inph = [inph -15   1 -15  -3 -11  9 13 -15   5 -15  -7  1 -11 17  13 -3 17 -15];
quad = [quad   1 -15  -3 -15 -11 13  9   5 -15  -7 -15 17  13  1 -11 17 -3   9];

indx = [indx  61 62 63 64 65 66  67  68  69  70 71 72  73  74  75  76  77  78];
inph = [inph   9  5 17 -7 13 17 -15 -11 -19   1  9 17 -19  -3 -19   5 -15  13];
quad = [quad -15 17  5 17 13 -7 -11 -15   1 -19 17  9  -3 -19   5 -19  13 -15];

indx = [indx  79  80  81  82  83  84  85  86  87  88  89  90  91  92  93  94];
inph = [inph -11 -19  17  -7   1 -19  21   9  -3  21 -15  13  17   5  21 -19];
quad = [quad  17  -7 -11 -19  21   9   1 -19  21  -3 -15  17  13  21   5 -11];

indx = [indx  95  96  97  98  99 100 101 102 103 104 105 106 107 108 109 110 111];
inph = [inph -11  -7  21 -15  17   9  21 -19 -23  13   1 -23  -3 -23   5 -11  21];
quad = [quad -19  21  -7  17 -15  21   9  13   1 -19 -23  -3 -23   5 -23  21 -11];

indx = [indx 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128];
inph = [inph  17 -23  -7 -19 -15  13  21 -23   9   1  25  -3  25   5 -19  25 -23];
quad = [quad  17  -7 -23 -15 -19  21  13   9 -23  25   1  25  -3  25  17   5 -11];

indx = [indx 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145];
inph = [inph  17 -11 -15  21  -7  25 -23  13   9  25 -19  17  21 -27   1 -27  -3];
quad = [quad -19 -23  21 -15  25  -7  13 -23  25   9 -19  21  17   1 -27  -3 -27];

indx = [indx 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162];
inph = [inph -11  25 -27 -23 -15   5 -27  -7  13  25 -19  21 -27   9 -23  17   1];
quad = [quad  25 -11   5 -15 -23 -27  -7 -27  25  13  21 -19   9 -27  17 -23  29];

indx = [indx 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179];
inph = [inph  29  -3 -15  29 -27  25 -11   5  29  21  -7  29 -23 -19 -27  13  17];
quad = [quad   1  29  25  -3 -11 -15 -27  29   5  21  29  -7 -19 -23  13 -27  25];

indx = [indx 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196];
inph = [inph  25   9  29 -27 -15 -11 -31  29   1 -23 -31  21  -3 -19 -31  25   5];
quad = [quad  17  29   9 -15 -27  29   1 -11 -31  21  -3 -23 -31  25   5 -19 -31];

indx = [indx 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213];
inph = [inph  13  29 -31  -7 -27  17 -31   9 -23 -15  21  25  29 -31 -11   1  33];
quad = [quad  29  13  -7 -31  17 -27   9 -31 -23  29  25  21 -15 -11 -31  33   1];

indx = [indx 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230];
inph = [inph -27 -19  -3  33   5  33  17  29 -31  13  -7  33 -23  25   9 -27  33];
quad = [quad -19 -27  33  -3  33   5  29  17  13 -31  33  -7  25 -23  33  21   9];

indx = [indx 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247];
inph = [inph  21 -31 -15 -19  29 -11  33 -35   1 -15 -35  17  -3 -35   5  13  33];
quad = [quad -27 -15 -31  29 -19  33 -11   1 -35  33  -3 -31 -35   5 -35  33  13];

indx = [indx 248 249 250 251 252 253 254 255];
inph = [inph -35  -7 -35   9  33 -35 -11 -31];
quad = [quad  -7 -35   9 -35 -15 -11 -35  17];
 
if nargin >= 1
    if M > 0
        M = ceil(M/4);
    else
        error('The points must be larger than zero.');
    end;
    if M > 256
        error('The maximum number is 1024.');
    end;
    inph = inph(1:M);
    quad = quad(1:M);
else
    M = 240; 
    inph = inph(1:M);
    quad = quad(1:M);
end;
inph3 = -inph;  quad3 = -quad;
inph4 = -quad;  quad4 = inph;
inph2 = quad;   quad2 = -inph;

if nargin < 2
  if nargout <= 0
    hh = plot(inph, quad, 'yo', inph2, quad2,'m+', inph3, quad3, 'cx', inph4, quad4, 'r*');
    hold on;
    plot([0 0],get(get(hh(1),'parent'),'Ylim'),'w-', get(get(hh(1),'parent'),'Ylim'),[0 0], 'w-');
    axis('equal')
    hold off    
  end
else
    if tp == 0
        tmp = fliplr(de2bi(indx(1:M)));
        [tmp_n, tmp_m] = size(tmp);
        tmp1 = ones(tmp_n, 1);
        tmp0 = zeros(tmp_n, 1);
        tmp = [tmp tmp0 tmp0; tmp tmp0 tmp1; tmp tmp1 tmp0; tmp tmp1 tmp1];
        [tmp_n, tmp_m] = size(tmp);
        inph = [inph; inph2; inph3; inph4];
        quad = [quad; quad2; quad3; quad4];
        inph = inph(:);
        quad = quad(:);
        if nargout <= 0
          modmap('qask/arb', inph, quad);
          hold on
          for i = 1 : tmp_n
            x = text(inph(i), quad(i), num2str(tmp(i, :)));
            set(x, 'Fontsize', 7);
          end;
          hold off
        end
    elseif nargout <= 0
      if tp == 1
        modmap('qask/arb', inph, quad);
      elseif tp == 2
        modmap('qask/arb', inph2, quad2);
      elseif tp == 3
        modmap('qask/arb', inph3, quad3);
      elseif tp == 4
        modmap('qask/arb', inph4, quad4);
      elseif tp > 4
        tmp = fliplr(de2bi(indx(1:M)));
        if tp == 5
        elseif tp == 6
            inph = inph2; quad = quad2;
        elseif tp == 7
            inph = inph3; quad = quad3;
        elseif tp == 8
            inph = inph4; quad = quad4;
        else
            error('Illegal type flag number.');
        end;
        modmap('qask/arb', inph, quad);
        hold on
        for i = 1 : M
            x = text(inph(i), quad(i), num2str(tmp(i, :)));
            set(x, 'Fontsize', 7);
        end;
        hold off
      else
        error('Illegal type flag number.')
      end;
    end;
end;

if nargout > 0
    inphh = inph;
    quadd = quad;
end;
