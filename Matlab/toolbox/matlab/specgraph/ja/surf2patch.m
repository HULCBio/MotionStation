% SURF2PATCH   �T�[�t�F�X�f�[�^���p�b�`�f�[�^�ɕϊ�
% 
% FVC = SURF2PATCH(S) �́ASURFACE�I�u�W�F�N�g S �̊􉽊w�f�[�^�ƃJ���[
% �f�[�^��PATCH�`���ɕϊ����܂��B�\���� FVC �́A�p�b�`�f�[�^�̖ʁA���_�A
% �J���[���܂݁APATCH�R�}���h�ɒ��ړn�����Ƃ��ł��܂��B
% 
% FVC = SURF2PATCH(Z) �́AZData�s�� Z ����p�b�`�f�[�^���v�Z���܂��B
% 
% FVC = SURF2PATCH(Z,C) �́AZData�����Cdata�s�� Z ����� C ����p�b�`
% �f�[�^���v�Z���܂��B
% 
% FVC = SURF2PATCH(X,Y,Z) �́AXData�AYData�AZData�s�� X�AY�AZ ����p�b�`
% �f�[�^���v�Z���܂��B
% 
% FVC = SURF2PATCH(X,Y,Z,C) �́AXData�AYData�AZData�ACdata�s�� X�AY�A
% Z�AC ����p�b�`���v�Z���܂��B
% 
% FVC = SURF2PATCH(...,'triangles' )�́A�l�ӌ`�̑���ɎO�p�`�̖ʂ��쐬
% ���܂��B
% 
% [F�AV�AC] = SURF2PATCH(...) �́A�ʁA���_�A�J���[���\���̂̑����3��
% �z��ɏo�͂��܂��B
%
% ���1:
% 
%    [x y z] = sphere; 
%    patch(surf2patch(x,y,z,z)); 
%    shading faceted; view(3)
% 
% ���2:
%    s = surf(peaks);
%    pause;
%    patch(surf2patch(s));
%    delete(s);
%    shading faceted; view(3)
%
% �Q�l�FREDUCEPATCH, SHRINKFACES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:28 $
