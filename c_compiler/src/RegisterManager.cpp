#include "../includes/RegisterManager.h"
#include <iostream>

RegisterManager::RegisterManager()
{
	freeMemoryLoc = 0;
	for (int i = 0; i < NO_REGISTERS; i++)
	{
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
};


RegisterManager::~RegisterManager()
{

};

unsigned RegisterManager::allocate(const std::string variableName){
	int loc, reg;
	InstructionData data;
	//Check if the variable has already been allocated
	if ((reg = getRegister(variableName)) > -1)
	{
		increment(reg);
	}
	//If the variable is not in a register, it may be in memory
	else if ((loc = getMemory(variableName)) > -1)
	{
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
		//load(variableName, reg);
		registers[reg].valid = true;
		registers[reg].data = data;
		registers[reg].TimeSinceUse = 0;
		increment(reg);
	}
	//If the variable has not been previously allocated, we need to find  aplace to store it
	else{
		reg = findLRU();
		//If another variable is using a register, store that one first
		if (registers[reg].valid)
			store(registers[reg], reg);
		
		data.variableName = variableName;
		data.registerLocation = reg;
		data.memoryLocation = 0;
		registers[reg].valid = true;
		registers[reg].data = data;
		registers[reg].TimeSinceUse = 0;
		increment(reg);
	}
	return reg;
};

void RegisterManager::deallocate(const std::string variableName){
	unsigned loc;

	if((loc = getRegister(variableName)) != -1){
		registers[loc].valid = false;
	}
	else{
		loc = getMemory(variableName);
		memory.erase(memory.begin() + loc);
	}
};


InstructionData* RegisterManager::get(const std::string variableName){
	unsigned loc;
	if ((loc = getRegister(variableName)) > -1)
		return &(registers[loc].data);
	else if ((loc = getMemory(variableName)) > -1)
		return &(memory[loc].data);
	else
		throw new RegisterAllocationException;
};

int RegisterManager::getRegister(const std::string variableName){
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		if (registers[i].data.variableName == variableName)
		{
			return i;
		}
	return -1;
};

int RegisterManager::getMemory(const std::string variableName){

	for (unsigned i = 0; i < memory.size(); i++)
		if (memory[i].data.variableName == variableName)
			return i;
	return -1;
};

void RegisterManager::store(const ListNode node, unsigned reg){
	if (!node.valid)
		return;
	//Write the load instruction to fetch data from memory
	//the offset location is multiplied by 4 due to word and byte addressing 
	//codeGenerator.write(STORE_ASM, reg, 4*node.data.memoryLocation);
	ListNode storable = node;
	storable.TimeSinceUse = 0;
	//storable.data.memoryLocation = getFreeMemoryLoc();
	memory.push_front(storable);
};

/*	A function to load a varaible from memory into a register
	Will throw a MemoryAllocationException if the value cannot be found in memory
*/
void RegisterManager::load(const std::string variableName, unsigned reg){
	int loc;
	if ((loc = getMemory(variableName)) <= -1)
		//Variable does not exist
		throw new MemoryAllocationException;
	reg = allocate(variableName);
	//Write the load instruction to fetch data from memory
	//the offset location is multiplied by 4 due to word and byte addressing 
	//codeGenerator.write(LOAD_ASM, reg, 4*loc);
	memory.erase(memory.begin()+loc);
};

unsigned RegisterManager::findLRU(){
	int MaxTimeSinceUse = -1;
	unsigned LRURegister = 0;
	int CurrTimeSinceUse;
	for (unsigned i = 0; i < NO_REGISTERS; i++)
	{
		if (!registers[i].valid)
			return i;

		CurrTimeSinceUse = registers[i].TimeSinceUse;
		if (CurrTimeSinceUse > MaxTimeSinceUse)
		{
			LRURegister = i;
			MaxTimeSinceUse = CurrTimeSinceUse;
		}
	}
	return LRURegister;
};

void RegisterManager::increment(int reg)
{
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		if(i == reg)
			registers[i].TimeSinceUse = 0;
		else
			registers[i].TimeSinceUse++;
};

void RegisterManager::printRegisters()
{
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		std::cout << registers[i].data.variableName << ' ' << registers[i].TimeSinceUse << std::endl;
};