#include "zcu104irq.h"

/*****************************************************************************/
/**
*
* This function returns integer of string value
*
* @param	char * str : address of number string
*
* @return	int64_t : integer value of string
*
* @note		None.
*
******************************************************************************/

int64_t string2int64(char* str){
	int64_t num = 0;
	int i = 0;

	/*
	 * Case of hexadecimal where string starts with "0x" or "0X"
	 */
	if( str[0] == '0' && (str[1] == 'x' || str[1] == 'X')){
		i=2;
		while( str[i] != '\0'){
			if( '0' <= str[i] && str[i] <= '9' ) num = num*16 + (str[i]-'0');
			else if( 'A' <= str[i] && str[i] <= 'F' ) num = num*16 + (str[i]-'A')+10;
			else if( 'a' <= str[i] && str[i] <= 'f' ) num = num*16 + (str[i]-'a')+10;
			else{
				xil_printf("TYPE ERROR\r\n");
				return 0;
			}
			i++;
		}
	}
	/*
	 * Case of decimal
	 */
	else{
		while( str[i] != '\0'){
			if( str[i] < '0' || str[i] > '9'){
				xil_printf("TYPE ERROR\r\n");
				return 0;
			}
			num = num*10 + (str[i]-'0');
			i++;
		}
	}

	return num;
}

/*****************************************************************************/
/**
*
* This function returns index of string where character 'spc' appears with
* dedicated number in str
*
* @param	char * str  : string which you want to analyze
* 			int64_t pos : position where you want end analye
* 			char spc    : character which you want to find
*
* @return	int64_t 	: position of character which you want to find.
* 						  It returns -1 when there is no character you are
* 						  looking for
*
* @note		None.
*
******************************************************************************/

int64_t string_count(char* str, int64_t pos, char spc){
	int64_t i = 0, num = 0;

	while( *(str+i) != '\0'){
		if( *(str+i) == spc) num++;
		if( num == pos ) return i;
		i++;
	}

	return -1;
}
/*****************************************************************************/
/**
*
* This function returns string with start index and end inedx
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
char * substring(char * str_dest,char * str,int64_t start,int64_t end){
	int64_t i = 0;

	for( i = 0; i < end-start;i++){
		*(str_dest+i) = *(str+start+i);
	}

	*(str_dest+end-start) = '\0';

	return str_dest;
}
/*****************************************************************************/
/**
*
* This function converts integer(decimal) value to string
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
char * int642str(int64_t val, char * str_dest){
	int64_t temp_val = val;
	int64_t i = 0;
	int64_t len = 0;
	char inverse_str[1024];

	while(temp_val != 0 ){
		*(inverse_str+i) = (temp_val % 10)  + '0';
		temp_val = temp_val / 10;
		i++;
	}
	*(str_dest + i) = '\0';
	i--;
	len = i;

	while(i >= 0){
		*(str_dest + i) = inverse_str[len-i];
		i--;
	}
	return str_dest;
}
/*****************************************************************************/
/**
*
* This function compare which string is longer
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
int64_t wolc_strcmp(char * str1, char * str2){
	int64_t i = 0;
	while( (str1[i] != '\0') && (str2[i] != '\0') ){
		i++;
	}
	return (str1[i] - str2[i]);
}
