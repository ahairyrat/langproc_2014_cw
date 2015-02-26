#include "RegisterManager.h"


RegisterManager::RegisterManager()
{
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		registers[i] = new std::list<ListNode>();
}


RegisterManager::~RegisterManager()
{
	for (unsigned i = 0; i < NO_REGISTERS; i++)
		delete registers[i];
}

unsigned RegisterManager::allocate(InstructionData data){
	unsigned reg = findLRU();
	store(reg, new ListNode{ data, 0 });
	return reg;
}

void RegisterManager::deallocate(InstructionData data){

}

void RegisterManager::store(unsigned reg, ListNode node){
	//TO-DO add STORE instruction here
	registers[reg]->push_front(node);
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
