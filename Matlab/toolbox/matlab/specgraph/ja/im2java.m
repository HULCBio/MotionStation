%  IM2JAVA   �C���[�W��Java�C���[�W�ɕϊ�
%
% JIMAGE = IM2JAVA(I) �́A���x�C���[�W I ��Java�C���[�W�N���X�A
% java.awt.Image�ɕϊ����܂��B
%
% JIMAGE = IM2JAVA(X,MAP) �́A�J���[�}�b�v MAP �����C���f�b�N�X�t��
% �C���[�W X ��Java�C���[�W�N���X, java.awt.Image�ɕϊ����܂��B
%
% JIMAGE = IM2JAVA(RGB) �́ARGB�C���[�W RGB ��Java�C���[�W�N���X, 
% java.awt.Image�ɕϊ����܂��B
%
% �N���X�̃T�|�[�g
% ----------------
% ���̓C���[�W�́A�N���Xuint8, uint16, double�̂����ꂩ�ł��B
%
% ����
% ----  
% Java�́Auint8�f�[�^��java.awt.Image�̃C���X�^���X���쐬����K�v������
% �܂��B���̓C���[�W�̃N���X��uint8�̏ꍇ�́AJIMAGE �͓���uint8�f�[�^��
% �܂݂܂��B���̓C���[�W�̃N���X��double�܂���uint16�̏ꍇ�́A�K�v��
% �����ăf�[�^���ăX�P�[�����O�܂��̓I�t�Z�b�g���Aim2java �͓����̓N���X
% uint8�̃C���[�W���쐬���Ă���A����uint8�\����java.awt.Image�ɕϊ����܂��B
%
% ���
% ----
% ���̗��́A�C���[�W��MATLAB���[�N�X�y�[�X�ɓǂݍ��݁Aim2java ���g����
% Java�C���[�W�N���X�ɕϊ����܂��B.
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
