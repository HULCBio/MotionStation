% RADON   Radon �ϊ�
%
% �֐� RADON �́A�ݒ肵���p�x�̔��a�����ɃC���[�W���x�𓊉e���� 
% Radon �ϊ����v�Z���܂��B
%
% R = RADON(I,THETA) �́A�p�x THETA �x�ɑ΂��鋭�x�C���[�W I �� Rad-
% on �ϊ����o�͂��܂��BTHETA ���X�J���̏ꍇ�A���� R �́ATHETA �x�ɑ�
% ���� Radon �ϊ����܂ޗ�x�N�g���ɂȂ�܂��BTHETA ���x�N�g���̏�
% ���A���̗v�f�ɑ΂��āA1��Radon �ϊ��̌��ʂ��Ƃ���s��ɂȂ��
% ���BTHETA ���ȗ�����ƁA�f�t�H���g��0:179���g���܂��B
%
% [R,Xp] = RADON(...) �́AR �̊e�s�ɑΉ����锼�a�����̍��W(�x)���x�N
% �g�� Xp �ɏo�͂��܂��B
%
% �N���X�T�|�[�g
% -------------
% I �́Adouble�Alogical�A�܂��́A�C�ӂ̐����N���X���T�|�[�g���Ă��܂��B
% ���̂��ׂĂ̓��́A�o�͂́A�N���X double �ł��B�ǂ̓��͂ł��X�p�[�X��
% �Ȃ�܂���B
%
% ����
% ----
% Xp �ɏo�͂���锼�a�����̍��W�́Ax ���ɉ������l�ł��B����́Ax ��
% ���甽���v����� THETA �x��]���������ł��B�����̎��̌��_�́A�C
% ���[�W�̒��S�s�N�Z���ŁA�f�t�H���g�ł́A
%
%        floor((size(I)+1)/2)
%
% �ł��B���Ƃ��΁A20�s30��̑傫���̃C���[�W�ł́A���S�s�N�Z����
% (10,15) �ł��B
%
% ���
% ----
%       I = zeros(100,100);
%       I(25:75, 25:75) = 1;
%       theta = 0:180;
%       [R,xp] = radon(I,theta);
%       imshow(theta,xp,R,[],'n')
%       xlabel('\theta (degrees)')
%       ylabel('x''')
%       colormap(hot), colorbar
%
% �Q�l�FIRADON, PHANTOM



%   This number is sufficient to compute the projection at unit
%   intervals, even along the diagonal.
