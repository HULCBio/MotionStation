% CFIT は、CFIT オブジェクトを作成します。
% CFIT(MODEL,COEFF1,COEFF2,COEFF3,...) は、MODEL と COEFF 値から CFIT 
% オブジェクトを作成します。
%
% ユーザは、FIT コマンドを使って、CFIT オブジェクトを作成します。
% ユーザは、CFIT コンストラクタを直接コールする必要はありません。
%
% 例題：
%     ftobj = fittype('a*x^2+b*exp(x)');
%     cfobj = fit(x,y,ftobj);
%
% 参考   FIT

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
