% CONTOUR   �R���^�[�v���b�g
% 
% CONTOUR(Z) �́A�s��Z�̃R���^�[�v���b�g��`�悵�܂��BZ �̒l�́A���ʂ���
% �̍����Ƃ��Ĉ����܂��B�R���^�[�v���b�g�́A�l V �ɑ΂��� Z �̃��x��
% �̋Ȑ��ł��B�l V �ɑI������܂��BCONTOUR(X,Y,Z) �ł́AX �� Y �́A
% �T�[�t�F�X�� (x,y) ���W���ASURF �̂悤�Ɏw�肵�܂��B
% 
% CONTOUR(Z,N) �� CONTOUR(X,Y,Z,N) �́AN �̃R���^�[���C�����A�����I��
% �l��ύX���Ȃ���`�悵�܂��B
% 
% CONTOUR(Z,V) �� CONTOUR(X,Y,Z,V) �́A�x�N�g�� V �Ŏw�肵���l�ɃR��
% �^�[���C�������ALENGTH(V) ���x���̃R���^�[���C����`�悵�܂��B���x�� 
% v �̒P��̃R���^�[���v�Z���邽�߂ɂ́ACONTOUR(Z,[v v]) �܂���
% CONTOUR(X,Y,Z,[v v]) ���g�p���Ă��������B [C,H] = CONTOUR(...) �́A
% CONTOURC �ŋL�q�����悤�ɁA�R���^�[�s�� C �ƁAcontour�O���[�v�I�u�W�F�N�g
% �̃n���h���ԍ�����Ȃ��x�N�g�� H �����C�����ɏo�͂��܂��B�����͋��ɁA
% CLABEL �ɑ΂�����͂Ƃ��Ďg�����Ƃ��ł��܂��B
%
% ���ʌ݊���
% CONTOUR('v6',...) �́AMATLAB 6.5����т���ȑO�̃o�[�W�����Ƃ̌݊���
% �̂��߁Acontour�O���[�v�I�u�W�F�N�g�̑����patch�I�u�W�F�N�g���쐬
% ���܂��B
%  
% �R���^�[�́A�ʏ�J�����g�̃J���[�}�b�v�Ɋ�Â��ăJ���[�����O����APATCH
% �I�u�W�F�N�g�Ƃ��ĕ`�悳��܂��B�w�肵���J���[�ƃ��C���^�C�v�����R��
% �^�[��`�悷�邽�߂ɂ́A�V���^�b�N�XCONTOUR(...,'LINESPEC') ���g���āA
% ���̋�����ύX�ł��܂��B
%
% ��L��CONTOUR�ւ̓��͂́A�R���^�[�I�u�W�F�N�g�̃v���p�e�B���w�肷�邽��
% �Ƀv���p�e�B�ƒl�̑g�𑱂��邱�Ƃ��ł��܂��B
%
% ���̃R�}���h�́AR. Pawlowicz���L�q�����R�[�h���g�p���A�p�����g���b�N��
% �T�[�t�F�X�ƃC�����C���R���^�[���x���������܂��B
%
% ���:
%      [c,h] = contour(peaks); clabel(c,h), colorbar
%
% �Q�l�FCONTOUR3, CONTOURF, CLABEL, COLORBAR.


%   Copyright 1984-2002 The MathWorks, Inc. 
