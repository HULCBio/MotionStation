% CLABEL   �R���^�[�v���b�g�̕W�����x��
% 
% CLABEL(CS,H) �́A�J�����g�̃R���^�[�v���b�g�ɕW�����x����t���܂��B
% ���x���́A��]����ăR���^�[���C���ɑ}������܂��BCS �� H �́A�R���^�[
% �s��̏o�͂� CONTOUR�ACONTOUR3�ACONTOURF ����o�͂����I�u�W�F�N�g��
% �n���h���ԍ��ł��B
%
% CLABEL(CS,H,V) �́A�x�N�g�� V �ŗ^������R���^�[���x���Ƀ��x����t��
% �܂��B�f�t�H���g�ł́A���ׂĂ̊��m�̃R���^�[�Ƀ��x����t���܂��B���x����
% �ʒu�́A�����_���ɑI������܂��B
%
% CLABEL(CS,H,'manual') �́A�}�E�X���N���b�N�����ʒu�ɃR���^�[���x����
% �t���܂��B���^�[���L�[�������ƁA���x���t�����I�����܂��B�}�E�X���g�p
% �ł��Ȃ��Ƃ��́A�R���^�[�̓��͂ɂ̓X�y�[�X�o�[���A�N���X�w�A�̈ړ��ɂ�
% ���L�[���g���Ă��������B
%
% CLABEL(CS) �܂��� CLABEL(CS,V) �܂��� CLABEL(CS,'manual') �́A��L��
% �悤�ɃR���^�[���x����t���܂����A���x���̓R���^�[��ɁA�ߖT�̕W����
% ���Ƀv���X�L���Ƃ��ĕ\������܂��B
%
% H = CLABEL(...) �́A�쐬���ꂽTEXT�I�u�W�F�N�g(LINE�̏ꍇ������)�̃n��
% �h���ԍ����o�͂��܂��BTEXT�I�u�W�F�N�g��UserData�v���p�e�B�́A�e���x��
% �̕W���l���܂݂܂��B
%
% CLABEL(...,'text property',property-value,...) �́A���x���̕�����̐ݒ�
% �ɁA�C�ӂ�TEXT�v���p�e�B/�l�̑g�ݍ��킹���g���܂��B
% 
% 1�̓��ʂȃv���p�e�B('LabelSpacing')�́A���x����(�_���ŕ\�킷)�̊Ԋu
% ��ݒ肷��̂Ɏg���܂��B�f�t�H���g��144�_�܂���2�C���`�̂ǂ��炩�ł��B
%
% R. Pawlowicz �̍쐬�����R�[�h���g���āA�C�����C���R���^�[���x�������
% �����܂��B
% 
% ���F
%  �@�@subplot(1,3,1), [cs,h] = contour(peaks); 
% �@�@ clabel(cs,h,'labelspacing',72)
%      subplot(1,3,2), cs = contour(peaks); clabel(cs)
%      subplot(1,3,3), [cs,h] = contour(peaks); 
%      clabel(cs,h,'fontsize',15,'color','r','rotation',0)
%
% �Q�l�FCONTOUR, CONTOUR3, CONTOURF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:39 $
