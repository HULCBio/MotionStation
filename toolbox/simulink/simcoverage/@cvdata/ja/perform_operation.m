% PERFORM_OPERATION - cvdata オブジェクト上のバイナリ操作からデータを生成
%
% METRICSTRUCT = PERFORM_OPERATION(LHS_CVDATA,RHS_CVDATA,OPSTR) は、
% cvdata オブジェクト LHS_CVDATA と RHS_CVDATA 内のそのままの実行回数で
% 実行した形式 u=f(lhs,rhs) 内の文字列 OPSTR として表されるデータ操作
% です。各測定から実行回数が総計され、測定を収集したものから METRICSTRUCT
% が出力されます。


%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
