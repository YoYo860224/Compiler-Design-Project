#ifndef SYMBOL_H
#define SYMBOL_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int create();
int lookup(char* s);
int insert(char* s);
int dump();

#endif