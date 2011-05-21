// e_plc_ou_dmheal

void main() { 

	object oUser = GetLastUsedBy();
	ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(999), oUser); 

}