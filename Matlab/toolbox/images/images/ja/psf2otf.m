% PSF2OTF �@�_�����x�֐������w�`�B�֐��ɕϊ�
% OTF = PSF2OTF(PSF) �́A�_�����x�֐�(PSF)�z��̍����t�[���G�ϊ����v�Z
% ���A���w�`�B�֐�(OFT)�z����쐬���܂��B����́APSF �̒��S�̃Y���ɂ��
% �e�����󂯂܂���B�f�t�H���g�ŁAOTF �z��́APSF �z��Ɠ����T�C�Y�ł��B
% 
% OTF = PSF2OTF(PSF,OUTSIZE) �́APSF �z����A�w�肵���T�C�Y OUTSIZE �� 
% OTF �z��ɕϊ����܂��BOUTSIZE �́A�C�ӂ̎����ŁAPSF �z��T�C�Y��菬��
% ���͂Ȃ�܂���B
%
% OTF ���APSF �̒��S���Y���邱�Ƃɉe�����󂯂Ȃ����Ƃ��m���߂�ɂ́AOUT-
% SIZE �Ɏw�肵�������ƈ�v����悤�ɁAPSF2OTF �́APSF �z��Ƀ[����t����
% �܂��B�����āA���S�̃s�N�Z�����A(1,1) �̈ʒu�ɒB����܂ŁAPSF �z�����
% ��I�ɃV�t�g���܂��B
%
% ���̊֐��́A���Z���AFFT ���܂�ł���ꍇ�A�C���[�W�̃R���{�����[�V����
% /�f�R���{�����[�V�����Ɏg���邱�Ƃɒ��ӂ��Ă��������B
%
% �N���X�T�|�[�g
% -------------
% PSF �́A��X�p�[�X�A���l�z��ŁAOTF �́A�N���X double �ł��B
%
% ���
% -------
%      PSF  = fspecial('gaussian',13,1);
%      OTF  = psf2otf(PSF,[31 31]); % PSF --> OTF
%      subplot(1,2,1); surf(PSF); title('PSF');
%      axis square; axis tight
%      subplot(1,2,2); surf(abs(OTF)); title('corresponding |OTF|');
%      axis square; axis tight
%
% �Q�l�F OTF2PSF, CIRCSHIFT, PADARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.  
