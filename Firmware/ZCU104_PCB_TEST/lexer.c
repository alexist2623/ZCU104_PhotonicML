#include "zcu104pcbtest.h"

/*****************************************************************************/
/**
*
* This function returns integer parameter from string format
* of "CMD#PARAMTER1#PARAMETER2#..."
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
int64_t get_param(char *inst, int64_t start_index, int64_t end_index){
	int64_t pos1 = 0;
	int64_t pos2 = 0;
	int64_t num = 0;
	char temp_str[1024] = {'\0'};

	pos1 = string_count(inst,start_index,'#')+1; // 1 is added elimniate '#' from string
	pos2 = string_count(inst,end_index,'#');	 // inst[pos1:pos2] = "NUMBER#"

	/*
	 * temp_str = "NUMBER\0". Note that temp_str is only valid in this function scope
	 */
	substring(temp_str,inst,pos1,pos2);
	num = string2int64(temp_str);				 // num = NUMBER

	return num;
}
