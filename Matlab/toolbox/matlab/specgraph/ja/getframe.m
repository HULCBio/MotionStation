% GETFRAME   ���[�r�[�t���[���̎��o��
% 
% GETFRAME �́A���[�r�[�t���[�����o�͂��܂��B�t���[���́A�J�����g����
% �X�i�b�v�V���b�g�ł��BGETFRAME �́AMOVIE���g���ăv���C�o�b�N���邽�߂�
% ���[�r�[�z����W�߂邽�߂ɁAFOR���[�v���ɒu����܂��B���Ƃ��΁A
%
%    for j = 1:n
%       plot_command
%       M(j) = getframe;
%    end
%    movie(M)
%
% GETFRAME(H) �́AH ��figure�܂���axis�̃n���h���ԍ��̂Ƃ��A�I�u�W�F�N�g 
% H ����t���[�������o���܂��B
% GETFRAME(H,RECT) �́A�r�b�g�}�b�v�̃R�s�[�����邽�߂ɁA�I�u�W�F�N�g 
% H �̍���������A�s�N�Z���P�ʂŒ����`���w�肵�܂��B
%
% F = GETFRAME(...) ��"cdata"�� "colormap" �̃t�B�[���h�����\���̂�
% ���[�r�[�t���[�����o�͂��܂��B�C���[�W�f�[�^�́Auint8�̍s��ŁAcolormap
% �͔{���x�̍s��Ƃ��Ē�`����܂��BF.cdata�́A����-��-3�ŁAF.colormap��
% TrueColor�O���t�B�b�N�𗘗p�ł���V�X�e���ł͋�s��ɂȂ�܂��B���Ƃ���:
% 
%    getframe(gcf);
%    colormap(f.colormap);
%    image(f.cdata);
%
% �Q�l�FMOVIE, MOVIEIN, IMAGE, IM2FRAME, FRAME2IM.


%   Copyright 1984-2002 The MathWorks, Inc. 
