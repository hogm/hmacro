#ifndef TSTMTSTYLE_H
#define TSTMTSTYLE_H

#define IDT_STR_LEN                32 /* 字下げ使用文字列の最大バイト数 */
/*
 * 整形後の文のスタイルを定義するデータ構造
 */
typedef struct {
	char szIdtStr[IDT_STR_LEN + 1];   /* インデントに使用する文字列。デフォルト値："\t" */
	unsigned iMinNumComma;            /* カンマで区切られる要素数。デフォルト値： 14  */
	unsigned iMinPartSize;            /* 括弧内のバイト数。デフォルト値： 50  */
	unsigned iStrLen;                 /* 整形後の文字列バイト数。最後のNULL文字は含まない */
} tStmtStyle
;

#endif /* TSTMTSTYLE_H */
