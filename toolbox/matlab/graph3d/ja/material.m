% MATERIAL   物体反射モード
% 
% MATERIAL は、SURFACEおよびPATCHオブジェクトの表面の反射のプロパティ
% を制御します。SURFACEとPATCHオブジェクトは、関数 SURF、MESH、PCOLOR、
% FILL、FILL3 で作成されます。
%
% MATERIAL SHINY は､オブジェクトをshinyにします。
% MATERIAL DULL は、オブジェクトをdullにします。
% MATERIAL METAL は、オブジェクトをメタリックにします。
% 
% MATERIAL([ka kd ks]) は、オブジェクトの周囲光/拡散光/鏡面光の強度を
% 設定します。
% 
% MATERIAL([ka kd ks n]) は、オブジェクトの周囲光/拡散光/鏡面光の強度
% と、オブジェクトの鏡面光の指数を設定します。
% 
% MATERIAL([ka kd ks n sc]) は、オブジェクトの周囲光/拡散光/鏡面光の
% 強度と、鏡面光の指数と、オブジェクトの鏡面色の反射率を設定します。
% 
% MATERIAL DEFAULT は、周囲光/拡散光/鏡面光の強度、鏡面光の指数、
% オブジェクトの鏡面色の反射率をデフォルトに設定します。 
%
% 参考：LIGHT, LIGHTING


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:55:04 $
