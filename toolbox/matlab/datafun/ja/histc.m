% HISTC   �q�X�g�O�����̓x���̃J�E���g
% 
% N = HISTC(X,EDGES)�́A�x�N�g��X�ɑ΂��āA�x�N�g��EDGES(�d�����܂ޑ���
% �֐��l)���̗v�f�Ԃɂ��Ă͂܂�X���̒l�̌����J�E���g���܂��BN�́A����
% ��̃J�E���g�l���܂�LENGTH(EDGES)�̃x�N�g���ł��B 
%
% N(k)�́AEDGES(k) < =  X(i) < EDGES(k+1)�̏ꍇ�A�l X(i)���J�E���g���܂��B
% �Ō�̃r���́AEDGES(end)�ƈ�v����X�̔C�ӂ̒l���J�E���g���܂��BEDGES��
% �̒l�ȊO�̒l�́A�J�E���g����܂���B���ׂĂ̔�NaN�̒l���܂߂邽�߂ɂ́A
% EDGES�̐ݒ�ɁA-inf�A����сAinf���g���Ă��������B
%
% �s��ɑ΂��āAHISTC(X,EDGES)�́A��q�X�g�O�����̃J�E���g�̍s��ł��BN
% �����z��ɑ΂��āAHISTC(X,EDGES)�́A�ŏ���1�łȂ������ɑ΂��đ�����s
% ���܂��B
%
% HISTC(X,EDGES,DIM)�́A����DIM�ɑ΂��đ�����s���܂��B
%
% [N,BIN] = HISTC(X,...)�́A�C���f�b�N�X�s��BIN���o�͂��܂��BX���x�N�g��
% �̏ꍇ�AN(K) = SUM(BIN =  = K)�ł��BBIN�́A�͈͊O�̒l�ɑ΂��Ă̓[����
% ���BX��m�sn��s��̏ꍇ�A���̂悤�ɂȂ�܂��B
% 
%   for j = 1:n�AN(K,j) = SUM(BIN(:,j) =  = K); end
%
% �q�X�g�O�������v���b�g���邽�߂ɂ́ABAR(X,N,'histc')���g���Ă��������B
% 
% ���:
%    histc(pascal(3),1:6)�́A���̔z����o�͂��܂��B 
%       [3 1 1;
%        0 1 0;
%        0 1 1;
%        0 0 0;
%        0 0 0;
%        0 0 1]
%
% �Q�l�FHIST.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $
%   Implemented in a MATLAB mex file.
