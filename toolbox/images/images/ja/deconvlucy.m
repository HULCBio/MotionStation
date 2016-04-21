% DECONVLUCY Lucy-Richardson �A���S���Y�����g���āA�C���[�W�̍č\�� 
% J = DECONVLUCY(I,PSF) �́ALucy-Richardson �A���S���Y�����g���āA�C���[
% �W I �𕪉����A���ĉ����ꂽ�C���[�W J ���o�͂��܂��B�C���[�W I ���^�̃C
% ���[�W�Ɠ_�����x�֐� PSF �Ƃ̃R���{�����[�V������(�\���Ƃ���)�m�C�Y��
% �t�����邱�Ƃɂ��쐬���Ă���ƍl���Ă��܂��B
%
% �č\���̎������ǂ��邽�߂ɁA���̕t���I�ȃp�����[�^��n�����Ƃ��ł���
% ���B(���Ԃ̃p�����[�^�����m�̏ꍇ�A[]���g���܂�)
%   J = DECONVLUCY(I,PSF,NUMIT)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR,WEIGHT)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT,SUBSMPL), where
%
%   NUMIT   (�I�v�V����) �́A�J��Ԃ��ő�� (�f�t�H���g��10)
%
% DAMPAR (�I�v�V����) �́A�_���s���O����������̂ŁA�C���[�W I �ƌ��ʂ̃C
% ���[�W�̃X���b�V���z�[���h�΍�(�|�A�\���m�C�Y�̕W���΍��̍���)���w�肷
% ��z��ł��B�J��Ԃ��ɂ��A�I���W�i���̒l���� DAMPAR �l���ł̕΍�����
% �s�N�Z�������������܂��B����́A���̂悤�ȃs�N�Z�����ɐ�����m�C�Y��
% �ቺ�����A���̑��̕K�v�ȃC���[�W�̏ڍׂ�ۑ����܂��B�f�t�H���g��0(�_��
% �s���O�Ȃ�)�ł��B
%
% WEIGHT (�I�v�V����) �́A�J�����̒��̃��R�[�f�B���O�̎��𔽉f����悤��
% �e�s�N�Z���Ɋ��蓖�Ă܂��B�����s�N�Z���́A�[���̏d�ݒl�����蓖�Ă邱��
% �ŁA�r���ł��܂��B�ǂ��s�N�Z���ɏd��1�����蓖�Ă����ɁA���R�t�B�[
% ���h�␳�̑��ʂɏ]���āA�d�݂𒲐����邱�Ƃ��ł��܂��B�f�t�H���g�́A��
% �̓C���[�W I �Ɠ����傫���̒P�ʔz��ł��B
%
% READOUT (�I�v�V����) �́A�t���I�ȃm�C�Y(���Ƃ��΁A�o�b�N�O�����h�m�C�Y
% ��t�H�A�O�����h�m�C�Y)��o�͂��ꂽ�J�����m�C�Y�̕��U�ɑΉ������z���
% ���BREADOUT �́A�C���[�W�Ŏg���Ă���P�ʂŋL�q����܂��B�f�t�H���g��
% 0�ł��B
%
% SUBSMPL (�I�v�V����) �́A�T�u�T���v�����O���`���APSF ���C���[�W��� 
% SUBSMPL �{�A�ׂ����O���b�h��ŗ^������ꍇ�Ɏg���܂��B�f�t�H���g��
% 1�ł��B
%
% �o�̓C���[�W J �́A�A���S���Y���̒��Ŏg���闣�U�t�[���G�ϊ����N������
% �����M���O���w�����Ă��邱�Ƃɒ��ӂ��Ă��������BDECONVLUCY ���R�[������
% �O�ɁAI = EDGETAPER(I,PSF) ���g���āA�����M���O��ቺ�����Ă��������B
%
% DECONVLUCY�́A�O�����Ď��s���� DECONVLUCY �̌��ʂ��炻�̌�̃f�R���{��
% ���[�V�����̌v�Z���ăX�^�[�g�ł��邱�Ƃɒ��ӂ��Ă��������B���̃V���^�b
% �N�X�����������邽�߁A���� I �� INITPSF ���A�Z���z�� {I} �� {INITPSF}
% �ɓn�����K�v������܂��B�����āA�o�� J �� PSF �̓Z���z��ɂȂ�A����
% �z��Ƃ��āA���� DECONVLUCY �R�[���̒��ɓn����܂��B���̓Z���z��́A
% (�ŏ��̃R�[���Ƃ���)��̐��l�z��A�܂��́A(DECONVLUCY �̑O�̎��s����
% �̏o�͂����݂���ꍇ)4�̐��l�z����܂܂��邱�Ƃ��ł��܂��B�o�� J �́A
% J{1}��I�CJ{2}�ލŐV�̌J��Ԃ��̌��ʂ̃C���[�W�AJ{3}�́A��O�̃C���[
% �W�AJ{4} �́A�J��Ԃ��A���S���Y���œ����I�Ɏg������̂ł��B
%
% �N���X�T�|�[�g
% -------------
% I �� PSF �́A�N���X uint8, uint16, double �̂����ꂩ�ł��BDAMPAR ��
% READOUT �́A���̓C���[�W�Ɠ����N���X�ɂȂ�K�v������܂��B���̓��� �́A
% �N���X double �ł��B�o�̓C���[�W J(�܂��́A�o�̓Z���̍ŏ��̔z��)�́A��
% �̓C���[�W I �Ɠ����N���X�ł��B
%
% ���
% -------
%
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .0001;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      WT = zeros(size(I));WT(5:end-4,5:end-4) = 1;
%      J1 = deconvlucy(BlurredNoisy,PSF);
%      J2 = deconvlucy(BlurredNoisy,PSF,20,sqrt(V));
%      J3 = deconvlucy(BlurredNoisy,PSF,20,sqrt(V),WT);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(J1);
%                     title('deconvlucy(A,PSF)');
%      subplot(223);imshow(J2);
%                     title('deconvlucy(A,PSF,NI,DP)');
%      subplot(224);imshow(J3);
%                     title('deconvlucy(A,PSF,NI,DP,WT)');
%
% �Q�l�FDECONVWNR, DECONVREG, DECONVBLIND, EDGETAPER, PADARRAY, 
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
