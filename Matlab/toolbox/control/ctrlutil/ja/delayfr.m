% DELAYFR   �A���n�̒x������V�X�e���̎��g������
%
% G = DELAYFR(DT,S) �́A������ I/O �̒x�ꂪ DT �����A������ LTI ���f��
% �̕��f���g���x�N�g�� S �ł̎��g���������v�Z���܂��B
%
%    y(1) = exp(-s*DT(1,1))*u(1) + exp(-s*DT(1,2))*u(2) + ...
%    y(2) = exp(-s*DT(2,1))*u(1) + exp(-s*DT(2,2))*u(2) + ...
%      ...
%
% �s�� DT �́A�e��/�o�͂̑g�ɑ΂���x�ꎞ�Ԃ�ݒ肵�܂��BNY �o�́ANU 
% ���́ANW �̎��g���_�̏ꍇ�A�o�� G �́ANY x NU x NW �̑傫���̔z���
% �Ȃ�܂��B
%
% �Q�l : FREQRESP.


%    Author: P. Gahinet, 7-96
%    Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:31 $
