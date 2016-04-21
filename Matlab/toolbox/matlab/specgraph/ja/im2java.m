%  IM2JAVA   イメージをJavaイメージに変換
%
% JIMAGE = IM2JAVA(I) は、強度イメージ I をJavaイメージクラス、
% java.awt.Imageに変換します。
%
% JIMAGE = IM2JAVA(X,MAP) は、カラーマップ MAP をもつインデックス付き
% イメージ X をJavaイメージクラス, java.awt.Imageに変換します。
%
% JIMAGE = IM2JAVA(RGB) は、RGBイメージ RGB をJavaイメージクラス, 
% java.awt.Imageに変換します。
%
% クラスのサポート
% ----------------
% 入力イメージは、クラスuint8, uint16, doubleのいずれかです。
%
% 注意
% ----  
% Javaは、uint8データがjava.awt.Imageのインスタンスを作成する必要があり
% ます。入力イメージのクラスがuint8の場合は、JIMAGE は同じuint8データを
% 含みます。入力イメージのクラスがdoubleまたはuint16の場合は、必要に
% 応じてデータを再スケーリングまたはオフセットし、im2java は等価はクラス
% uint8のイメージを作成してから、このuint8表現をjava.awt.Imageに変換します。
%
% 例題
% ----
% つぎの例題は、イメージをMATLABワークスペースに読み込み、im2java を使って
% Javaイメージクラスに変換します。.
%
%   I = imread('moon.tif');
%   javaImage = im2java(I);
%   frame = javax.swing.JFrame;
%   icon = javax.swing.ImageIcon(javaImage);
%   label = javax.swing.JLabel(icon);
%   frame.getContentPane.add(label);
%   frame.pack
%   frame.show


%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.3.4.1 $  $Date: 2004/04/28 02:05:13 $
