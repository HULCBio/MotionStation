function Anorm = crossdiv (c, b, dim)
%CROSSDIV   Orthogonal vector cross division.
%
%   If B and C are 3-element vectors (e.g. 3x1, 1x3, 1x1x3...):
%
%      Anorm = CROSSDIV(C, B) returns the orthogonal cross division 
%      C /o B. B and C must have the same size.
%
%   If B and C are N-D arrays containing more than one 3 element vector:
%
%      Anorm = CROSSDIV(C, B) returns the orthogonal cross divisions
%      performed on the vectors along the first dimension of length 3.
%      B and C must have the same size.
%   
%      Anorm = CROSSDIV(C, B, DIM) returns the orthogonal cross divisions
%      performed on the vectors along dimension DIM. B and C must have the
%      same size, and both SIZE(B,DIM) and SIZE(C,DIM) must be 3.
%
%   Two main kinds of vector cross divisions exist: indefinite (ICD) and 
%   definite (DCD). The orthogonal cross division (OCD) is the simplest 
%   form of DCD. DCDs allow to write in a short and elegant vectorial form 
%   equations such as those used to compute the point of application of a 
%   force based on dynamometric data (see equation 4 and examples). 
%   The definition of DCD is based on that of ICD. The symbol of the ICD 
%   is a double slash (//). As well as indefinite integrals yield infinite 
%   antiderivatives, ICDs yield infinite anticrossproducts (antiCPs). There 
%   are infinite vectors X meeting the condition X x B = C, all laying on a 
%   plane normal to C. If they include A, they are called the "antiCPs of 
%   A x B”, where A x B = C. These antiCPs are determined by C // B, 
%   defined as:            C // B = X = Anorm + Xpar                    (1)
%                           Anorm = B x C / (B * B)       (Orthogonal term)
%                            Xpar = S * B                   (Parallel term)
%   Each anticrossproduct X shares with A its component Anorm = Xnorm, 
%   normal to both B and C, and differs from the others only by Xpar, its 
%   component parallel to B. Since Anorm is unique, it can be determined as 
%   shown above. By definition, being Anorm normal to B, its magnitude is:
%                        |Anorm| = |A| * SIN(THETA)                     (2)
%   where THETA is the angle between A and B. Notice that, although Xpar is 
%   nonunique, it can be partially determined. Being it parallel to B, it 
%   is equal to S * B, where S is a scaling factor, called "cross division 
%   coefficient". Thus, the only fully undetermined and arbitrary value in 
%   1 is S. Luckily, in some cases S can be determined otherwise (see 
%   examples). In the definition of an ICD, S has the same role as the 
%   arbitrary integration constant in an indefinite integral.
%   The OCD is determined by arbitrarily setting S = 0, and is equal to the 
%   known and unique orthogonal term of an ICD:
%                      C /o B = Anorm = B x C / (B * B)                 (3)
%   The OCD is similar to a definite integral with variable upper limit, 
%   and null lower limit. When the value Sa for S uniquely identifying A in 
%   eq. 1 is known (see examples), A can be fully determined as follows:
%                     A = Anorm + Apar = C /o B + Sa * B                (4)
%   Warning:
%   By definition, in an ICD (C // B) the divisor (B) must be the second 
%   operand of a cross product (A x B = C). When you use as divisor the 
%   first operand (A) of the cross product, rather than the second, the ICD 
%   does not yield the expected set of anticrossproducts (X including B). 
%   Since A x B = - B x A, it yields the opposite set (–X including –B):
%                       C // A = - X = - (Bnorm + S * A)                (5)
%   Hence,                    C /o A = - Bnorm                          (6)
%
%   Examples:
%   If the moment of a force F applied at position P is P x F = M:
%      Pnorm =   CROSSDIV(M, F)            [from eq. 3, Pnorm =    M /o F ] 
%      Fnorm = - CROSSDIV(M, P)            [from eq. 6, Fnorm = - (M /o P)]
%   After computing Pnorm, you might be able to determine P, using eq. 4:
%      1) Sp = MAGN(Pnorm) / (TAN(THETA) * MAGN(F)),  P = Pnorm + Sp * F
%      2) Sp =           Ppar(i) / F(i),              P = Pnorm + Sp * F
%      3) Sp = (P(i) – Pnorm(i)) / F(i),              P = Pnorm + Sp * F
%         where F(i) must be a non-null scalar component (element) of F.
%
%   See also CROSS, DOT, OUTER, MAGN, UNIT.

% $ Version: 1.3 $
% CODE      by:                 Paolo de Leva (IUSM, Rome, IT) 2005 Nov 26
%           optimized by:       Code author                    2006 Mar 29
% COMMENTS  by:                 Code author                    2005 Sep 27
% OUTPUT    tested by:          Code author                    2005 Nov 26
% -------------------------------------------------------------------------

% NOTE: Function CROSS, called in step 1, will issue an error if:
%          1) B and C have different sizes
%          2) B and C have no dimension of length 3
%          3) SIZE(B,DIM) and SIZE(C,DIM) are not equal to 3

% Setting DIM if not supplied.
if nargin == 2
   first3 = find(size(b)==3, 1, 'first'); % First dimension of length 3
   dim = max([first3, 1]);            % If FIRST3 is empty, then DIM=1 and
end                                   % function CROSS will issue an error

% 1 - Cross product (B x C) and dot product (B * B)
%        NOTE: function CROSS checks the sizes of B and C
BcrossC = cross(b, c, dim); % Vector(s) aligned with Anorm
Bsquare = dot(b, b, dim);   % Squared magnitude(s) of B

% 2 - Cloning Bsquare N times along its singleton dimension DIM
N = size(b, dim);                   % Same as SIZE(C, DIM)
basize = [ones(1,dim-1), N, 1];     % Size of block array
Bsquare2 = repmat(Bsquare, basize); % BSQUARE2 has same size as B and C

% 3 - Orthogonal term of cross division C // B.
Anorm = BcrossC ./ Bsquare2;

% NOTE: For vectors with null magnitude, the latter divison (by zero) will
% cause MATLAB to issue a warning. The respective normalized vector will be
% composed of NaNs.
