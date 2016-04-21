% CUBICI2   3点と1つの勾配から最適ステップを決定
% 
% STEP = CUBICI2(c,f,x)
% 
% P(x(1:3)) = f(1:3) と p'(0) = c を満足するキュービック p(x) を求めます。
% 最適子が正の場合、p(x) の最適子を出力します。最適子が負の場合、QUAD1 
% をコールします。


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2003/05/01 13:01:11 $
%   Andy Grace 7-9-90, C. Moler 2-26-99.
