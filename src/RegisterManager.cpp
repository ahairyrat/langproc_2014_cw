#include "RegisterManager.h"
#include <iostream>

RegisterManager::RegisterManager(CodeGenerator *codeGenerator) :
		freeMemoryLoc(0) {
	this->codeGenerator = codeGenerator;

	for (int i = 0; i < NO_REGISTERS; i++) {
		InstructionData tempData;
		tempData.variableName = "";
		tempData.registerLocation = 0;
		tempData.memoryLocation = 0;
		ListNode tempNode;
		tempNode.valid = false;
		tempNode.TimeSinceUse = 0;
		tempNode.data = tempData;
		registers[i] = tempNode;
	}
}
;

RegisterManager::~RegisterManager() {

}
;

//Stoire the variable in the LRU register
unsigned RegisterManager::allocate(const std::string variableName) {
	int loc, reg;
	InstructionData data;
	//Check if the variable has already been allocated
	if ((reg = getRegister(variableName)) > -1) {
		increment(reg);
	}
	//If the variable is not in a register, it may be in memory
	else if ((loc = getMemory(variableName)) > -1) {
		//Extract currently stored  
		data = memory[loc].data;
		//If the previously allocated register is free, we may as well keep it consistent
		if (!registers[data.registerLocation].valid)
			reg = data.registerLocation;
		else
			reg = findLRU();
		//If another variable is using a register, store that one first
		if (registers[reg].valid)
			store(registers[reg], reg);
		//This will add the LOAD assembly instruction and remove data from memory list
		load(variableName, reg);
		registers[reg].valid = true;
		registers[reg].data = data;
		registers[reg].TimeSinceUse = 0;
		increment(reg);
	}
	//If the variable has not been previously allocated, we need to find  aplace to store it
	else {
		reg = findLRU();
		//If another variable is using a register, store that one first
		if (registers[reg].valid)
			store(registers[reg], reg);

		data.variableName = variableName;
		data.registerLocation = reg;
		data.memoryLocation = globalMemoryLocation;
		registers[reg].valid = true;
		registers[reg].data = data;
		registers[reg].TimeSinceUse = 0;
		increment(reg);
		globalMemoryLocation++;
	}
	return reg;
}
;

//Store the variable in a particular register, forcing that register to be stored if it already filled
unsigned RegisterManager::allocate(const std::string variableName, int regVal) {
	int loc, reg;
	InstructionData data;
	//Check if the variable has already been allocated
	if ((reg = getRegister(variableName)) > -1) {
		if (registers[regVal].valid)
			store(registers[regVal], regVal);
		codeGenerator->write(MOV_ASM, regVal, reg, 0);
		registers[regVal] = registers[reg];
		//free up the previous location
		registers[reg].valid = false;
		increment(regVal);
	}
	//If the variable is not in a register, it may be in memory
	else if ((loc = getMemory(variableName)) > -1) {
		//Extract currently stored  
		data = memory[loc].data;
		//If another variable is using a register, store that one first
		if (registers[regVal].valid)
			store(registers[regVal], regVal);
		//This will add the LOAD assembly instruction and remove data from memory list
		load(variableName, regVal);
		registers[regVal].valid = true;
		registers[regVal].data = data;
		registers[regVal].TimeSinceUse = 0;
		increment(regVal);
	}
	//If the variable has not been previously allocated, we need to store it
	else {
		reg = regVal;
		//If another variable is using a register, store that one first
		if (registers[reg].valid)
			store(registers[reg], reg);

		data.variableName = variableName;
		data.registerLocation = reg;
		data.memoryLocation = globalMemoryLocation;
		registers[reg].valid = true;
		registers[reg].data = data;
		registers[reg].TimeSinceUse = 0;
		increment(reg);
		globalMemoryLocation++;
	}
	return reg;
}
;

void RegisterManager::deallocate(const std::string variableName) {
	unsigned loc;

	if ((loc = getRegister(variableName)) != -1) {
		registers[loc].valid = false;
	} else {
		loc = getMemory(variableName);
		memory.erase(memory.begin() + loc);
	}
}
;

InstructionData* RegisterManager::get(const std::string variableName) {
	unsigned loc;
	if ((loc = getRegister(variableName)) > -1)
		return &(registers[loc].data);
	else if ((loc = getMemory(variableName)) > -1)
		return &(memory[loc].data);
	else
		throw new RegisterAllocationException;
}
;

int RegisterManager::getRegister(const std::string variableName) {
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		if (registers[i].data.variableName == variableName
				&& registers[i].valid) {
			return i;
		}
	return -1;
}
;

int RegisterManager::getMemory(const std::string variableName) {

	for (unsigned i = 0; i < memory.size(); i++)
		if (memory[i].data.variableName == variableName)
			return i;
	return -1;
}
;

void RegisterManager::store(const ListNode node, unsigned reg) {
	if (!node.valid)
		return;
	//Write the store instruction to fetch data from memory
	//the offset location is multiplied by 4 due to word and byte addressing 
	codeGenerator->write(STR_ASM, reg, 12, 4 * node.data.memoryLocation);
	ListNode storable = node;
	storable.TimeSinceUse = 0;
	memory.push_front(storable);
}
;

void RegisterManager::storeStack(const ListNode node, unsigned reg) {
	//Write the store instruction to fetch data from stack
	//the offset location is multiplied by 4 due to word and byte addressing 
	codeGenerator->write(STMFD_ASM, 13, reg, 0);
	ListNode storable = node;
	storable.TimeSinceUse = 0;
	stack.push_front(storable);
}
;

ListNode &RegisterManager::loadStack(unsigned reg) {

	ListNode node = stack.front();
	stack.pop_front();
	codeGenerator->write(LDMFD_ASM, 13, reg, 0);
	node.data.registerLocation = reg;
	registers[reg] = node;
}
;

ListNode &RegisterManager::loadStack(unsigned reg, std::string name) {

	ListNode node = stack.front();
	stack.pop_front();
	codeGenerator->write(LDMFD_ASM, 13, reg, 0);
	node.data.registerLocation = reg;
	node.data.variableName = name;
	registers[reg] = node;
}
;

/*	A function to load a varaible from memory into a register
 Will throw a MemoryAllocationException if the value cannot be found in memory
 */
void RegisterManager::load(const std::string variableName, unsigned reg) {
	int loc;
	if ((loc = getMemory(variableName)) <= -1)
		//Variable does not exist
		throw new MemoryAllocationException;
	//Write the load instruction to fetch data from memory
	//the offset location is multiplied by 4 due to word and byte addressing 
	codeGenerator->write(LDR_ASM, reg, 12,
			4 * (memory[loc].data.memoryLocation));
	memory.erase(memory.begin() + loc);
}
;

unsigned RegisterManager::findLRU() {
	int MaxTimeSinceUse = -1;
	unsigned LRURegister = 0;
	int CurrTimeSinceUse;
	for (unsigned i = 0; i < NO_REGISTERS; i++) {
		if (!registers[i].valid)
			return i;

		CurrTimeSinceUse = registers[i].TimeSinceUse;
		if (CurrTimeSinceUse > MaxTimeSinceUse) {
			LRURegister = i;
			MaxTimeSinceUse = CurrTimeSinceUse;
		}
	}
	return LRURegister;
}
;

void RegisterManager::increment(int reg) {
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		if (i == reg)
			registers[i].TimeSinceUse = 0;
		else
			registers[i].TimeSinceUse++;
}
;

void RegisterManager::printRegisters() {
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		std::cout << registers[i].data.variableName << ' '
				<< registers[i].TimeSinceUse << std::endl;
}
;

void RegisterManager::allocateSubroutine(std::vector<std::string> &parameters) {
	int i, reg;
	//Push register 4 - 11 onto the stack
	for (i = 4; i < NO_REGISTERS; i++)
		storeStack(registers[i], i);
	std::cout << stack.size() << std::endl;
	//Store the link register on the stack
	codeGenerator->write(STMFD_ASM, 13, 14, 0);
	//All parameters that cannot be stored in teh first four registers have to be stored on the stack
	for (i = parameters.size() - 1; i > 3; i--) {
		//Retrieve location of the parameter
		reg = allocate(parameters[i]);
		storeStack(registers[reg], reg);
	}
	//For all remaining parameters
	for (i = 0; i <= 3; i++) {
		if (i >= parameters.size())
			break;
		allocate(parameters[i], i);
	}
	//invalidate the registers pushed onto the stack
	invalidateLocalRegisters();
}
;

void RegisterManager::deallocateSubroutine() {
	for (int i = NO_REGISTERS - 1; i >= 4; i--)
		loadStack(i);
}
;

//Aliases the  firs four registers to allow parameters between functions
//All functions must be aliased or errors may occur when aliases are retrieved
void RegisterManager::aliasRegisters(std::vector<std::string> &alias) {
	if (alias.size() != 4)
		std::cout << "ERROR INVALID ALIAS" << std::endl;
	for (int i = 0; i < 4; i++) {
		this->alias[i].push_back(registers[i].data.variableName);
		registers[i].data.variableName = alias[i];

	}
}

void RegisterManager::restoreAliasRegisters() {
	for (int i = 0; i < 4; i++) {
		registers[i].data.variableName = (alias[i])[0];
		this->alias[i].pop_back();
	}
}

void RegisterManager::invalidateLocalRegisters() {
	for (int i = 4; i < NO_REGISTERS; i++)
		registers[i].valid = false;
}
