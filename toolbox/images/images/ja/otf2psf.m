% OTF2PSF ���w�`�B�֐���_�����x�֐��ɕϊ� 
% PSF = OTF2PSF(OTF) �́A���w�`�B�֐�(OTF)�z��̋t�����t�[���G�ϊ�(IFFT)
% ���v�Z���A���_�𒆐S�Ƃ����_�����x�֐�(PSF)���쐬���܂��B�f�t�H���g��
% �́APSF �� OTF �Ɠ����T�C�Y�ł��B
%
% PSF = OTF2PSF(OTF,OUTSIZE) �́A�w�肵���T�C�Y OUTSIZE �� PSF �z��ɁA
% OTF �z���ϊ����܂��BOUTSIZE �́A�C�ӂ̎����ŁAOTF �z��̃T�C�Y��
% ���Ă͂����܂���B
%
% PSF �̒��S�����_�ɔz�u����ɂ́AOTF2PSF �́A�o�͔z��̒l���A(1,1)�v�f
% ���A���S�̈ʒu�ɒB����悤�ɏ���I�ɃV�t�g���܂��B�����āA���ʂ��AOUT-
% SIZE �Őݒ肳�ꂽ�����Ɉ�v����悤�ɒ��o���܂��B
%
% ���̊֐��́A���Z���AFFT ���܂�ł���ꍇ�A�C���[�W�̃R���{�����[�V��
% ��/�f�R���{�����[�V�����Ɏg���邱�Ƃɒ��ӂ��Ă��������B
%
% �N���X�T�|�[�g
% -------------
% OTF �́A�C�ӂ̔�X�p�[�X�A���l�z��ŁAPSF �̓N���X double �ł��B
%
% ���
% -------
%      PSF  = fspecial('gaussian',13,1);
%      OTF  = psf2otf(PSF,[31 31]); % PSF --> OTF
%      PSF2 = otf2psf(OTF,size(PSF)); % OTF --> PSF2
%      subplot(1,2,1); surf(abs(OTF)); title('|OTF|');
%      axis square; axis tight
%      subplot(1,2,2); surf(PSF2); title('corresponding PSF');
%      axis square; axis tight
%       
% �Q�l�F PSF2OTF, CIRCSHIFT, PADARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.  
