#include "RegisterManager.h"

RegisterManager::RegisterManager()
{
	for (int i = 0; i < NO_REGISTERS; i++)
		registers[i] = { false, *(InstructionData*)nullptr, 0 };
}


RegisterManager::~RegisterManager()
{

}

unsigned RegisterManager::allocate(const std::string variableName){
	int loc;
	InstructionData data;
	unsigned reg;
	//Check if the variable has already been allocated
	if ((loc = getRegister(variableName)) > -1)
		return loc;
	//If the variable is not in a register, it may be in memory
	else if ((loc = getMemory(variableName)) > -1)
	{
		//Extract currently stored  
		data = memory[loc].data;
		//If the previously allocated register is free, we may as well keep it consistent
		if (!registers[data.registerLocation].valid)
			reg = data.registerLocation;
		else
			reg = findLRU();;
		//This will add the LOAD assembly instruction and remove data from memory list
		load(variableName, reg);
	}
	else{
		reg = findLRU();
		data = { variableName, reg, 0 };
	}
	store(registers[reg], reg);
	registers[reg] = { true, data, 0 };
	return reg;
}

void RegisterManager::deallocate(const std::string variableName){
	unsigned loc;
	try{
		loc = getRegister(variableName);
		registers[loc].valid = false;
	}
	catch (RegisterAllocationException)
	{
		loc = getMemory(variableName);
		memory.erase(memory.begin() + loc);
	}
}


InstructionData* RegisterManager::get(const std::string variableName){
	unsigned loc;
	if ((loc = getRegister(variableName)) > -1)
		return &(registers[loc].data);
	else if ((loc = getMemory(variableName)) > -1)
		return &(memory[loc].data);
	else
		throw new RegisterAllocationException;
}

int RegisterManager::getRegister(const std::string variableName){
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		if (registers[i].data.variableName == variableName)
			return i;
	return -1;
}

int RegisterManager::getMemory(const std::string variableName){

	for (unsigned i = 0; i < memory.size(); i++)
		if (memory[i].data.variableName == variableName)
			return i;
	return -1;
}

void RegisterManager::store(const ListNode node, unsigned reg){
	if (!node.valid)
		return;
	//TO-DO add STORE instruction here
	ListNode storable = node;
	storable.TimeSinceUse = 0;
	//storable.data.memoryLocation = getFreeMemoryLoc();
	memory.push_front(storable);
}

/*	A function to load a varaible from memory into a register
	Will throw a MemoryAllocationException if the value cannot be found in memory
*/
void RegisterManager::load(const std::string variableName, unsigned reg){
	//TO-DO add LOAD instruction here
	int loc;
	if ((loc = getMemory(variableName)) <= -1)
		throw new MemoryAllocationException;
	memory.erase(memory.begin()+loc);
	allocate(variableName);
}

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
}
