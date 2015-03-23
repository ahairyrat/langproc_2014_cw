#include "../includes/CodeGenerator.h"

CodeGenerator::CodeGenerator(std::string &outputFile) {
	(this->outputFileStream).open(outputFile.c_str(), std::ofstream::trunc);
}
;

CodeGenerator::~CodeGenerator() {
	(this->outputFileStream).close();
}
;

void CodeGenerator::write(ASM_T cmd, unsigned rt, unsigned r1, unsigned r2) {
	switch (cmd) {
	case LDR_ASM:
		outputFileStream << '\t' << "LDR R" << rt << ", [R" << r1 << ", #" << r2
				<< " ]" << std::endl;
		break;
	case STR_ASM:
		outputFileStream << '\t' << "STR R" << rt << ", [R" << r1 << ", #" << r2
				<< " ]" << std::endl;
		break;
	case MOV_ASM:
		outputFileStream << '\t' << "MOV R" << rt << ", R" << r1 << std::endl;
		break;
	case MOVI_ASM:
		outputFileStream << '\t' << "MOV R" << rt << ", #" << r1 << std::endl;
		break;
	case MOVILE_ASM:
		outputFileStream << '\t' << "MOVLE R" << rt << ", #" << r1 << std::endl;
		break;
	case MOVIGT_ASM:
		outputFileStream << '\t' << "MOVGT R" << rt << ", #" << r1 << std::endl;
		break;
	case MOVILT_ASM:
		outputFileStream << '\t' << "MOVLT R" << rt << ", #" << r1 << std::endl;
		break;
	case MOVIGE_ASM:
		outputFileStream << '\t' << "MOVGE R" << rt << ", #" << r1 << std::endl;
		break;
	case MOVIEQ_ASM:
		outputFileStream << '\t' << "MOVEQ R" << rt << ", #" << r1 << std::endl;
		break;
	case MOVINE_ASM:
		outputFileStream << '\t' << "MOVNE R" << rt << ", #" << r1 << std::endl;
		break;
	case ADD_ASM:
		outputFileStream << '\t' << "ADD R" << rt << ", R" << r1 << ", R" << r2
				<< std::endl;
		break;
	case SUB_ASM:
		outputFileStream << '\t' << "SUB R" << rt << ", R" << r1 << ", R" << r2
				<< std::endl;
		break;
	case MULT_ASM:
		outputFileStream << '\t' << "MUL R" << rt << ", R" << r1 << ", R" << r2
				<< std::endl;
		break;
	case MOD_ASM:
		outputFileStream << '\t' << "MOV R" << rt << ", R" << r1 << " MOD R" << r2
				<< std::endl;
		break;
	case DIV_ASM:
		outputFileStream << '\t' << "SDIV R" << rt << ", R" << r1 << ", R" << r2
				<< std::endl;
		break;
	case CMP_ASM:
		outputFileStream << '\t' << "CMP R" << rt << ", R" << r1 << std::endl;
		break;
	case CMPI_ASM:
		outputFileStream << '\t' << "CMP R" << rt << ", #" << r1 << std::endl;
		break;
	case MVN_ASM:
		outputFileStream << '\t' << "MVN R" << rt << ", R" << r1 << std::endl;
		break;
	case AND_ASM:
		outputFileStream << '\t' << "AND R" << rt << ", R" << r1 << ", R" << r2
				<< std::endl;
		break;
	case OR_ASM:
		outputFileStream << '\t' << "ORR R" << rt << ", R" << r1 << ", R" << r2
				<< std::endl;
	case XOR_ASM:
		outputFileStream << '\t' << "EOR R" << rt << ", R" << r1 << ", R" << r2
				<< std::endl;
		break;
	case MOVLSLI_ASM:
		outputFileStream << '\t' << "MOV R" << rt << ", R" << r1 << ", LSL #"
				<< r2 << std::endl;
		break;
	case MOVLSRI_ASM:
		outputFileStream << '\t' << "MOV R" << rt << ", R" << r1 << ", LSR #"
				<< r2 << std::endl;
		break;
	case MOVLSL_ASM:
		outputFileStream << '\t' << "MOV R" << rt << ", R" << r1 << ", LSL R"
				<< r2 << std::endl;
		break;
	case MOVLSR_ASM:
		outputFileStream << '\t' << "MOV R" << rt << ", R" << r1 << ", LSR R"
				<< r2 << std::endl;
		break;
	case LDMFD_ASM:
		outputFileStream << '\t' << "LDMFD R" << rt << "!, {R" << r1 << "}"
				<< std::endl;
		break;
	case STMFD_ASM:
		outputFileStream << '\t' << "STMFD R" << rt << "!, {R" << r1 << "}"
				<< std::endl;
		break;
	}
}
;

void CodeGenerator::writeLabel(std::string label) {
	outputFileStream << label << std::endl;
}
;

void CodeGenerator::writeBranch(ASM_T cmd, std::string label) {
	switch (cmd) {
	case B_ASM:
		outputFileStream << '\t' << "B " << label << std::endl;
		break;
	case BEQ_ASM:
		outputFileStream << '\t' << "BEQ " << label << std::endl;
		break;
	case BNE_ASM:
		outputFileStream << '\t' << "BNE " << label << std::endl;
		break;
	case BL_ASM:
		outputFileStream << '\t' << "BL " << label << std::endl;
		break;
	}
}
;

