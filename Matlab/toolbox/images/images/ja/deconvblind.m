% DECONVBLIND Blind �f�R���{�����[�V�����A���S���Y�����g���āA�C���[�W��
% ��
% [J,PSF] = DECONVBLIND(I,INITPSF) �́A�Ŗޖ@�A���S���Y�����g���āA�C���[
% �W I �𕪉����A���ĉ����ꂽ�C���[�W J �ƍč\�����ꂽ�_�����x�֐� PSF ��
% �o�͂��܂��B���ʂ� PSF �́AINITPSF �Ɠ����T�C�Y�̐��̔z��ŁA���̘a��1
% �Ő��K�����Ă��܂��BPSF �̍č\���́A�������� INITPSF �̃T�C�Y�ɋ����e��
% ����A���̒l�ɂ͂��܂�e������܂���B
%   
% �č\�������ǂ��邽�߂ɁA�t���I�ȃp�����[�^���g�����Ƃ��ł��܂�(���Ԃ̃p
% �����[�^�����m�̏ꍇ�A[]���g���Ă�������)�B
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT,READOUT).
%
% PSF ��̕t���I�Ȑ���́A���[�U���p�ӂ����֐��o�R�Ŏg���܂��B
%   [J,PSF] = DECONVBLIND(...,FUN,P1,P2,...,PN)
%
% FUN (�I�v�V����) �́APSF ��̕t���I�Ȑ�����L�q����֐��ł��BFUN ���w��
% ����ɂ́A4�̕��@������܂��B���̕��@�́Afunction_handle�A�C�����C��
% �I�u�W�F�N�g�Ƃ��� @�A�֐����A�܂��́AMATLAB �\�����܂񂾕�������g����
% �@�ł��BFUN �́A�e�J��Ԃ��̍Ō�ŃR�[������܂��BFUN �́A�ŏ��̈�����
% ���ĕK��PSF ���g���A���̌�ŁA�t���I�ȃp�����[�^P1, P2, ..., PN���󂯓�
% ��邱�Ƃ��ł��܂��BFUN �́A��̈��� PSF �݂̂��o�͂��܂��B����́A
% INITPSF �Ɠ����傫���ŁA���ł��邱�ƂƁA���K���Ɋւ��鐧��𖞑����܂��B
%
% NUMIT (�I�v�V����) �́A�J��Ԃ��̍ő�񐔂ł�(�f�t�H���g 10)�B
%
% DAMPAR (�I�v�V����) �́A�_���s���O����������̂ŁA�C���[�W I �ƌ��ʂ�
% �C���[�W�̃X���b�V���z�[���h�΍�(�|�A�\���m�C�Y�̕W���΍��̍���)���w��
% ����z��ł��B�J��Ԃ��ɂ��A�I���W�i���̒l���� DAMPAR �l���ł̕΍���
% ���s�N�Z�������������܂��B����́A���̂悤�ȃs�N�Z�����ɐ�����m�C�Y
% ��ቺ�����A���̑��̕K�v�ȃC���[�W�̏ڍׂ�ۑ����܂��B�f�t�H���g��0(�_
% ���s���O�Ȃ�)�ł��B
%
% WEIGHT (�I�v�V����) �́A�J�����̒��̃��R�[�f�B���O�̎��𔽉f����悤��
% �e�s�N�Z���Ɋ��蓖�Ă܂��B�����s�N�Z���́A�[���̏d�ݒl�����蓖�Ă邱��
% �ŁA�r���ł��܂��B�ǂ��s�N�Z���ɏd��1�����蓖�Ă����ɁA���R�t�B�[��
% �h�␳�̑��ʂɏ]���āA�d�݂𒲐����邱�Ƃ��ł��܂��B�f�t�H���g�́A����
% �C���[�W I �Ɠ����傫���̒P�ʔz��ł��B
%
% READOUT (�I�v�V����) �́A�t���I�ȃm�C�Y(���Ƃ��΁A�o�b�N�O�����h�m�C�Y
% ��t�H�A�O�����h�m�C�Y)��o�͂��ꂽ�J�����m�C�Y�̕��U�ɑΉ������z���
% ���BREADOUT �́A�C���[�W�Ŏg���Ă���P�ʂŋL�q����܂��B�f�t�H���g��
% 0�ł��B
%
% �o�̓C���[�W J �́A�A���S���Y���̒��Ŏg���闣�U�t�[���G�ϊ����N����
% �郊���M���O���w�����Ă��邱�Ƃɒ��ӂ��Ă��������BDECONVBLIND ���R�[��
% ����O�ɁAI = EDGETAPER(I,PSF) ���g���āA�����M���O��ቺ�����Ă��������B% 
% DECONVBLIND �́A�O�����Ď��s���� DECONVBLIND �̌��ʂ��炻�̌�̃f�R��
% �{�����[�V�����̌v�Z���ăX�^�[�g�ł��邱�Ƃɒ��ӂ��Ă��������B���̃V��
% �^�b�N�X�����������邽�߁A���� I �� INITPSF ���A�Z���z�� {I} �� {INI-
% TPSF}�ɓn�����K�v������܂��B�����āA�o�� J �� PSF �̓Z���z��ɂȂ�A
% ���͔z��Ƃ��āA���� DECONVBLIND �R�[���̒��ɓn����܂��B���̓Z���z
% ��́A(�ŏ��̃R�[���Ƃ���)��̐��l�z��A�܂��́A(DECONVBLIND �̑O��
% ���s����̏o�͂����݂���ꍇ)4�̐��l�z����܂܂��邱�Ƃ��ł��܂��B�o
% �� J �́AJ{1}��I�CJ{2}�ލŐV�̌J��Ԃ��̌��ʂ̃C���[�W�AJ{3}�́A��O
% �̃C���[�W�AJ{4} �́A�J��Ԃ��A���S���Y���œ����I�Ɏg������̂ł��B
%
% �N���X�T�|�[�g
% -------------
% I �� INITPSF �́A�N���X uint8, uint16, double �̂����ꂩ�ł��BDAMPAR 
% �� READOUT �́A���̓C���[�W�Ɠ����N���X�ɂȂ�K�v������܂��B���̓�
% �� �́A�N���X double �ł��B�o�̓C���[�W J(�܂��́A�o�̓Z���̍ŏ��̔z
% ��)�́A���̓C���[�W I �Ɠ����N���X�ł��B�o�� PSF �́A�N���X double ��
% ���B
%
%   ���
%   -------
%      
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .0001;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      WT = zeros(size(I));WT(5:end-4,5:end-4) = 1;
%      INITPSF = ones(size(PSF));
%      FUN = inline('PSF + P1','PSF','P1');
%      [J P] = deconvblind(BlurredNoisy,INITPSF,20,10*sqrt(V),WT,FUN,0);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(PSF,[]);
%                     title('True PSF');
%      subplot(223);imshow(J);
%                     title('Deblured Image');
%      subplot(224);imshow(P,[]);
%                     title('Recovered PSF');
%
% �Q�l�FDECONVWNR, DECONVREG, DECONVLUCY, EDGETAPER, PADARRAY,
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
