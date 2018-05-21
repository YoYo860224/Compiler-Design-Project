#ifndef SYMBOL_H
#define SYMBOL_H

#include <string>
#include <vector>
#include <iostream>
#include <stdlib.h>
#include <stdio.h>

enum TYPE
{
	T_NONE,
	T_INT,
	T_FLOAT,
	T_BOOL,
	T_STRING,
	T_404
};

typedef union{
	int intVal;
	float floatVal;
	bool boolVal;
	char* stringVal;

	int* intArr;
	float* floatArr;
	bool* boolArr;
	char** stringArr;
} variableData;

typedef struct variableEntry{
	std::string name;
	int type;
	bool isInit;
	bool isConst;
	bool isArr;
	bool isFn;
	int arrSize;
	union {
		variableData data;
	};
} variableEntry;

// Some make variableEntry methon.
variableEntry ve_fn(std::string name, int type);
variableEntry ve_basic(std::string name, int type, bool isConst);
variableEntry ve_basic_notInit(std::string name, int type, bool isConst);
variableEntry ve_arr(std::string name, int type, bool isConst, int arrSize);

// Per table, store their name and variableEntry array.
typedef struct{
	std::string scopeName;
	std::vector<variableEntry> variableEntries;
} symbolTable;

class symbolTables
{
private:
	std::vector<symbolTable> tables;					// stack of symbolTable
public:
	symbolTables();

	int push_table(std::string name);					// Push table.
	int update_tableName(std::string name);				// Ppdate top table name.
	int pop_table();									// Pop out and show.
	int show_topTable();								// Show top table.

	int addVariable(variableEntry var);					// Add variableEntry to top table.
	int editVariable(variableEntry var);				// Edit same name variableEntry in top table.
	int forPreloadFN(int type);							// For function, edit its type.

	variableEntry lookup(std::string name);				// Look up from top table to bottom.
	variableEntry lookupForNowScope(std::string name);	// Look up top table.
};

#endif