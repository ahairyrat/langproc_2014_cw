#ifndef __C_COMPILER_CODE_GENERATOR_H
#define	__C_COMPILER_CODE_GENERATOR_H

#include <fstream>

enum ASM_T {
	LDR_ASM, STR_ASM, MOV_ASM, MOVI_ASM, MULT_ASM, DIV_ASM, ADD_ASM, SUB_ASM
};

class CodeGenerator {
public:
	CodeGenerator(std::string &outputFile);
	virtual ~CodeGenerator();

	void write(ASM_T cmd, int rt, int r1, int r2);

private:
	std::ofstream outputFileStream;
};

#endif
