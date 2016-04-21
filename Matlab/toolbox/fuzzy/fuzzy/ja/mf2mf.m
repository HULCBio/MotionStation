% MF2MF メンバシップ関数間でのパラメータの交換
%
% 表示
% outParams = mf2mf(inParams,inType,outType)
%
% 詳細
% この関数は、パラメータの集合を使って、1つの組み込みのメンバシップ関数
% タイプを他のメンバシップ関数タイプへ変換します。mf2mf は、新しいメンバ
% シップ関数と古いメンバシップ関数共に、対称な点同志は、その関係を保つよ
% うにします。しかし、時として、この変換では情報を失うことになります。す
% なわち、出力パラメータをオリジナルのメンバシップ関数タイプに戻しても、
% 変換されたメンバシップ関数はオリジナルのものと同じようには見えません。% 
% mf2mf の入力引数は、つぎのとおりです。
% 
% inParams    :変換するメンバシップ関数のパラメータ
% inType      :変換するメンバシップ関数タイプに対する文字列名
% outType     :変換先の新しいメンバシップ関数に対する文字列名
%
% 例題
%     x = 0:0.1:5;
%     mfp1 = [1 2 3];
%     mfp2 = mf2mf(mfp1,'gbellmf','trimf');
%     plot(x,gbellmf(x,mfp1),x,trimf(x,mfp2))
%
% 参考    DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
