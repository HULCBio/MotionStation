% NLPARCI   ����`���f���̃p�����[�^�̐M�����
%
% CI = NLPARCI(BETA,RESID,J) �́A���ł̎c���̓��a RESID �� ���R�r�A��
% �s�� J ��^���āA����`�ŏ����p�����[�^���� BETA �ł�95%�̐M����� 
% CI ���o�͂��܂��B
% 
% �M����Ԃ̌v�Z�́AJ �̍s���� BETA �̒�����蒷���ꍇ�A�L���ł��B
% 
% NLPARCI �́A���͂Ƃ��āANLINFIT �̏o�͂��g���܂��B
% 
% ���F
%      [beta,resid,J]=nlinfit(input,output,'f',betainit);
%      ci = nlparci(beta,resid,J);
% 
% �Q�l : NLINFIT.


%   Bradley Jones 1-28-94
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:14:09 $
