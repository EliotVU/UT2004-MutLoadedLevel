/*==============================================================================
   MutLoadedLevel
   Home Repo: https://github.com/EliotVU/UT2004-MutLoadedLevel
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class LoadedRules extends GameRules;

/** Score might have been changed. So update the LoadedLevel reward. */
function bool CheckScore( PlayerReplicationInfo Scorer )
{
	if( Scorer != none && Controller(Scorer.Owner) != none && Controller(Scorer.Owner).Pawn != none )
	{
		MutLoadedLevel(Owner).CustomModifyPlayer( Controller(Scorer.Owner).Pawn );
	}
	return super.CheckScore( Scorer );
}