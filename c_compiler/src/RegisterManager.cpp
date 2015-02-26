#include "RegisterManager.h"

#include <exception>

RegisterManager::RegisterManager()
{
	for (int i = 0; i < NO_REGISTERS; i++)
		registers[i] = { false, *(InstructionData*)nullptr, 0 };
}


RegisterManager::~RegisterManager()
{

}

unsigned RegisterManager::allocate(std::string variableName){
	unsigned reg = findLRU();
	InstructionData data = { variableName, 0, -1 };
	store(reg, registers[reg]);
	registers[reg] = {true, data, 0 };
	return reg;
}

unsigned RegisterManager::allocate(std::string variableName, int value){
	unsigned reg = findLRU();
	InstructionData data = { variableName, 0, value };
	store(reg, registers[reg]);
	registers[reg] = { true, data, 0 };
	return reg;
}

void RegisterManager::deallocate(std::string variableName){
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		if (registers[i].data.variableName == variableName)
		{
			registers[i].valid = false;
			return;
		}
	std::list<ListNode>::const_iterator end = memory.end();
	std::list<ListNode>::const_iterator item = std::find(memory.begin(), end,);	//TO-DO add search aparameter without knowing value
	if (item == end)
		throw new M;	//TO-DO throw correct exception for no memory allocated to variable
}

void RegisterManager::store(unsigned reg, const ListNode node){
	//TO-DO add STORE instruction here
}

unsigned RegisterManager::findLRU(){
	int MaxTimeSinceUse = -1;
	int LRURegister = -1;
	int CurrTimeSinceUse;
	for (unsigned i = 0; i < NO_REGISTERS; i++)
	{
		if (registers[i]->empty())
			return i;

		CurrTimeSinceUse = registers[i]->front().TimeSinceUse;
		if (CurrTimeSinceUse > MaxTimeSinceUse) 
		{
			LRURegister = i;
			MaxTimeSinceUse = CurrTimeSinceUse;
		}
	}
	return LRURegister;
}
