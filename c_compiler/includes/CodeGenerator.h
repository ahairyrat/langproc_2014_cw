#ifndef __C_COMPILER_CODE_GENERATOR_H
#define	__C_COMPILER_CODE_GENERATOR_H

#include <fstream>

enum ASM_T {
	LDR_ASM,
	STR_ASM,
	MOV_ASM,
	MOVI_ASM,
	MULT_ASM,
	DIV_ASM,
	ADD_ASM,
	SUB_ASM,
	MOVIGT_ASM,
	MOVILE_ASM,
	CMP_ASM,
	CMPI_ASM,
	MOVIGE_ASM,
	MOVILT_ASM,
	MOVIEQ_ASM,
	MOVINE_ASM,
	MVN_ASM,
	AND_ASM,
	OR_ASM,
	XOR_ASM,
	MOVLSLI_ASM,
	MOVLSRI_ASM,
	MOVLSL_ASM,
	MOVLSR_ASM,
	B_ASM,
	BEQ_ASM,
	BNE_ASM,
	BL_ASM,
	LDMFD_ASM,
	STMFD_ASM
};

class CodeGenerator {
public:
	CodeGenerator(std::string &outputFile);
	virtual ~CodeGenerator();

	void write(ASM_T cmd, unsigned rt, unsigned r1, unsigned r2);
	
	void writeLabel(std::string label);
	
	void writeBranch(ASM_T cmd, std::string label);

private:
	std::ofstream outputFileStream;
};

#endif
