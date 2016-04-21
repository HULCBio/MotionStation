% FREESERIAL    シリアルポート上のMATLABホールドを解除
%
% FREESERIAL は、すべてのシリアルポートのMATLABのホールド状態を開放し
% ます。
%
% FREESERIAL('PORT') は、指定したポート PORT 上のMATLABのホールド状
% 態を開放します。PORT は、文字列からなるセル配列です。
%
% FREESERIAL(OBJ) は、シリアルポートオブジェクトに関連するポート上の
% MATLABのホールド状態を開放します。OBJ は、シリアルポートオブジェクトの
% 配列でも構いません。
%   
% シリアルポートオブジェクトが、開放されたのままのポートに接続しようとするとき
% にはエラーが出力されます。FCLOSE コマンドは、シリアルポートからシリアル
% ポートオブジェクトを切断する場合に使われます。
%
% FREESERIAL は、シリアルポートオブジェクトがそのポートに接続された後で、
% 他のアプリケーションからシリアルポートに接続する必要があり、MATLABを
% 終了したくない場合にのみ利用されます。
% 
% 注意：この関数は、Windows プラットフォームでのみ使われます。
%  
% 例題:
%      freeserial('COM1');
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, '*IDN?')
%      idn = fscanf(s);
%      fclose(s)
%      freeserial(s)
%
% 参考：INSTRUMENT/FCLOSE.


%    MP 4-11-00
%    Copyright 1999-2002 The MathWorks, Inc. 
