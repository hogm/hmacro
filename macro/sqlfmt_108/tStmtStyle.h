#ifndef TSTMTSTYLE_H
#define TSTMTSTYLE_H

#define IDT_STR_LEN                32 /* �������g�p������̍ő�o�C�g�� */
/*
 * ���`��̕��̃X�^�C�����`����f�[�^�\��
 */
typedef struct {
	char szIdtStr[IDT_STR_LEN + 1];   /* �C���f���g�Ɏg�p���镶����B�f�t�H���g�l�F"\t" */
	unsigned iMinNumComma;            /* �J���}�ŋ�؂���v�f���B�f�t�H���g�l�F 14  */
	unsigned iMinPartSize;            /* ���ʓ��̃o�C�g���B�f�t�H���g�l�F 50  */
	unsigned iStrLen;                 /* ���`��̕�����o�C�g���B�Ō��NULL�����͊܂܂Ȃ� */
} tStmtStyle
;

#endif /* TSTMTSTYLE_H */
