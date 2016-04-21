% FUNCTION   MATLAB Compiler プラグマ
% 
% ステートメント
%     %#function
% は、関数を定義する M-ファイル内に記述されます。
% % 記号から始まるため、MATLABインタプリタは、コメントと解釈します。
% しかし、MATLAB Compilerの MCC では、これはコードが FEVAL ステートメント
% を利用して、設定された関数を直接または間接に呼び出すことを意味します。
% Compilerは、その後、これらの関数を生成コード内の FEVAL を利用して呼び
% 出される関数のテーブルに追加します。
%
% 参考 : INBOUNDS, REALONLY, IVDEP.


% $Revision: 1.8.4.1 $  $Date: 2003/06/25 14:31:11 $
% Copyright 1984-2002 The MathWorks, Inc.
