% GET   AVIFILE プロパティの引用
%
% VALUE = GET(AVIOBJ,'PropertyName') は、AVIFILE オブジェクト AVIOBJ の
% 指定されたプロパティの値を出力します。  
%  
% GET は、AVIFILE オブジェクトの多くのプロパティ値を出力もしますが、
% いくつかのプロパティは、変更することができません。これらは、ADDFRAME 
% を使って付加されるフレームとして、自動的に更新されます。 
%
% 注意：
% この関数は、SUBSURF 用の補助関数で、ユーザが意識して使用するものでは
% ありません。AVIFILE オブジェクトの適切な値を読み込むには、構造体記法
% を使ってください。たとえば、つぎのようにします。:
%
%               value = obj.Fps;


%   Copyright 1984-2002 The MathWorks, Inc.
