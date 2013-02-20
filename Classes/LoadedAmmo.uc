/*==============================================================================
   MutLoadedLevel
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class LoadedAmmo extends Info;

event PostBeginPlay()
{
	local WeaponFire WF;
	local int i;

	super.PostBeginPlay();

	for( i = 0; i < 2; ++ i )
	{
		WF = Weapon(Owner).GetFireMode( i );
		if( WF != none )
		{
			WF.AmmoPerFire = 0;
		}
	}
	Destroy();
}
