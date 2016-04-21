% DECONVREG �������t�B���^���g���āA�C���[�W�̍č\��
% J = DECONVREG(I,PSF) �́A�������t�B���^�A���S���Y�����g���āA�C���[�W 
% I �𕪉����A���ĉ����ꂽ�C���[�W J ���o�͂��܂��B����́A�C���[�W I 
% �́A�^�̃C���[�W�Ɠ_�����x�֐� PSF ���R���{�����[�V�������A�m�C�Y��t
% ���������̂ƍl���܂��B�A���S���Y���́A���肵���C���[�W�Ɛ^�̃C���[�W��
% �Ԃ̍����A�C���[�W�̕�������ύX�����Ȃ������̂��ƂŁA�ŏ����덷�̈�
% ���Ő���t���œK���ɂȂ�܂��B
%
% �č\���̎������ǂ��邽�߂ɁA���̕t���I�ȃp�����[�^��n�����Ƃ��ł���
% ���B(���Ԃ̃p�����[�^�����m�̏ꍇ�A[]���g���܂�)
%   J = DECONVREG(I,PSF,NP)
%   J = DECONVREG(I,PSF,NP,LRANGE)
%   J = DECONVREG(I,PSF,NP,LRANGE,REGOP), �����ŁA
%
%   NP     (�I�v�V����) �́A�t���m�C�Y�̃p���[�ł��B�f�t�H���g��0�ł��B
%
% LRANGE (�I�v�V����) �́A�œK�������߂邽�߂ɃT�[�`����͈͂��w�肷��x
% �N�g���ł��B�A���S���Y���́A�����W LRANGE ���ŁA�œK Lagrange �搔 LAG-
% RA �����߂܂��BLRANGE ���X�J���̏ꍇ�ALAGRA���^�����ALRANGE �Ɠ�����
% �Ȃ�Ɖ��肵�܂��B���̂��߂ɁANP �l�́A��������܂��B�f�t�H���g�́A[1e-9
% 1e9]�ł��B
%
% REGOP  (�I�v�V����) �́A�f�R���{�����[�V�����ɐ�����ۂ����������Z�q��
% ���B�C���[�W�̕�������ێ������܂܁ALaplacian ���������Z�q���A�f�t�H��
% �g�Ŏg���܂��BREGOP �z�񎟌��́A�C���[�W�̎����ȉ��ŁA����V���O���g
% ���łȂ������́APSF �̃V���O���g���łȂ������ɑΉ�����K�v������܂��B
%
% [J, LAGRA] = DECONVREG(I,PSF,...) �́A�č\�����ꂽ�C���[�W J �ɉ����A
% Lagrange �搔�̒l LAGRA ���o�͂��܂��B
%
% �o�̓C���[�W J �́A�A���S���Y���̒��Ŏg���闣�U�t�[���G�ϊ����N������
% �����M���O���w�����Ă��邱�Ƃɒ��ӂ��Ă��������BDECONVREG ���R�[������
% �O�ɁAI = EDGETAPER(I,PSF) ���g���āA�����M���O��ቺ�����Ă��������B
%
% �N���X�T�|�[�g
% -------------
% I �� PSF �́A�N���X uint8, uint16, double �̂����ꂩ�ł��A���̓��͂́A
% �N���X double �ŁAJ �� I �Ɠ����N���X�ł��B
%
% ���
% -------
%
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .01;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      NP = V*prod(size(I));% �m�C�Y�̃p���[
%      [J LAGRA] = deconvreg(BlurredNoisy,PSF,NP);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(J);
%                     title('[J LAGRA] = deconvreg(A,PSF,NP)');
%      subplot(223);imshow(deconvreg(BlurredNoisy,PSF,[],LAGRA/10));
%                     title('deconvreg(A,PSF,[],0.1*LAGRA)');
%      subplot(224);imshow(deconvreg(BlurredNoisy,PSF,[],LAGRA*10));
%                     title('deconvreg(A,PSF,[],10*LAGRA)');
%
% �Q�l�FDECONVWNR, DECONVLUCY, DECONVBLIND, EDGETAPER, PADARRAY, 
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
