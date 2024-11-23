#include "ej1.h"

string_proc_list* string_proc_list_create(){
    // 16 = sizeof(string_proc_list)
    string_proc_list* res = (string_proc_list*)malloc(16);
    res->first=NULL;
    res->last=NULL;
    return res;
}

string_proc_node* string_proc_node_create_asm(uint8_t type, char* hash){
    string_proc_node* res = (string_proc_node*)malloc(sizeof(string_proc_node));
    res->type = type;
    res->hash = hash;
    res->previous = NULL;
    res->next = NULL;
    return res;
}

char* string_proc_list_concat(string_proc_list* list, uint8_t type , char* hash){
	string_proc_node* it = list->first;
	while(it != NULL){
		if(it->type == type){
			hash = str_concat(hash, it->hash);
		}
		it = it->next;
	}
	return hash;
}
