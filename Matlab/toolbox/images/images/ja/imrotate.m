% IMROTATE   �C���[�W�̉�]
%
% B = IMROTATE(A,ANGLE,METHOD) �́A�ݒ肵�����}�@���g���āA�C���[�W A 
% �𔽎��v����� ANGLE �x��]���܂��BMETHOD �́A����3�̒�����I��
% �ł��镶����ł��B
%
%        'nearest'  (�f�t�H���g) �ŋߖT�@
%
%        'bilinear'              Bilinear �@
%
%        'bicubic'               Bicubic �@
%
% ���� METHOD ���ȗ�����ƁAIMROTATE �̓f�t�H���g�� 'nearest' ���g����
% ���B�C���[�W�����v����ɉ�]������ɂ́A���̊p�x��ݒ肵�Ă��������B
%
% B = IMROTATE(A,ANGLE,METHOD,BBOX) �́A�C���[�W A �� ANGLE ������]��
% ���܂��B�C���[�W���� bounding �{�b�N�X�́A���� BBOX �Őݒ肳��A
% 'loose'�A�܂��́A'crop'�̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��BBBOX ���A
% 'loose'�̏ꍇ�AB �́A��]�����C���[�W�S�̂��ނ̂ŁA��ʂɂ́AA ���
% �傫���Ȃ�܂��BBBOX ���A'crop'�̏ꍇ�A��]�����C���[�W�̒������݂̂�
% ��܂�AA �Ɠ����T�C�Y�ɂȂ�܂��B���� BBOX ���ȗ�����ƁAIMROTATE 
% �́A�f�t�H���g�� 'loose' ���g���܂��B
%
% IMROTATE �́AB �̊O���ɕs�v�Ȓl�Ƃ���0��ݒ肵�܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�́Alogical�Auint8�Auint16�A�܂��́Adouble �̂������
% �N���X���T�|�[�g���Ă��܂��B�o�̓C���[�W�͓��̓C���[�W�Ɠ����N���X��
% �Ȃ�܂��B
% 
% ���
% ----
%        I = imread('ic.tif');
%        J = imrotate(I,-3,'bilinear','crop');
%        imshow(I), figure, imshow(J)
%
% �Q�l�FIMCROP, IMRESIZE, IMTRANSFORM, TFORMARRAY



%   Copyright 1993-2002 The MathWorks, Inc.  
