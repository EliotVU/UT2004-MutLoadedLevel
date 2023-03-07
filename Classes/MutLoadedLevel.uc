/*==============================================================================
   MutLoadedLevel
   Home Repo: https://github.com/EliotVU/UT2004-MutLoadedLevel
   Copyright (C) 2010 Eliot Van Uytfanghe

   This program is free software; you can redistribute and/or modify
   it under the terms of the Open Unreal Mod License version 1.1.
==============================================================================*/
class MutLoadedLevel extends Mutator
	config(MutLoadedLevel);

struct sInventoryCollection
{
	/** Required score to earn these inventories. Or greater if no equal is found. */
	var() config int ScoreReq;
	/** Rewarded inventory given if ScoreReq is met. */
	var() config array< class<Inventory> > Inventories;
};

/** All LoadedLevels in linear order. */
var() config array<sInventoryCollection> LoadedLevels;
var() config bool bUseKills;
var() config bool bBalanceWithDeaths;

var protected LoadedRules LR;

simulated event PostBeginPlay()
{
	local xPickupBase P;
	local WeaponLocker WL;

    super.PostBeginPlay();

	foreach AllActors( class'xPickupBase', P )
	{
		if( TournamentPickup(P.myPickUp) == none )
		{
			P.bHidden = true;
			if( P.myEmitter != none )
				P.myEmitter.Destroy();
		}
	}

	foreach AllActors( class'WeaponLocker', WL )
	{
		WL.GotoState( 'Disabled' );
	}

	if( Role == ROLE_Authority )
	{
		LR = Spawn( class'LoadedRules', self );
		Level.Game.AddGameModifier( LR );
	}
}

function ModifyPlayer( Pawn Other )
{
	super.ModifyPlayer( Other );

	CustomModifyPlayer( Other );
}

final function CustomModifyPlayer( Pawn Other )
{
	local int index, i;
	local Inventory Inv;

	if( Other != none && Other.PlayerReplicationInfo != none )
	{
		// delete every weapon
	  	while( Other.Inventory != none )
		{
			Inv = Other.Inventory;
			Inv.DetachFromPawn( Other );
			Other.DeleteInventory( Inv );
			if( Inv != none )
			{
				Inv.Destroy();
			}

			if( Other.Weapon == none )
			{
				Other.NextWeapon();
			}
		}

		// Find the suited LoadedLevel. Then give the player all the rewarded inventories/weapons
	  	index = FindLevel( Other.PlayerReplicationInfo );
  		for( i = 0; i < LoadedLevels[index].Inventories.Length; ++ i )
  		{
  			if( Class<Weapon>(LoadedLevels[index].Inventories[i]) != none )
  			{
  				Other.GiveWeapon( string(LoadedLevels[index].Inventories[i]) );
  			}
  			else Other.CreateInventory( string(LoadedLevels[index].Inventories[i]) );
  		}
	}
}

final function int FindLevel( PlayerReplicationInfo PRI )
{
	local int i, h, last;
	local float Score;

	if( bUseKills )
	{
		Score = PRI.Kills;
	}
	else
	{
		Score = PRI.Score;
	}

	if( bBalanceWithDeaths )
	{
		Score = Max( Score - PRI.Deaths, 0 );
	}

    h = -1;
	for( i = 0; i < LoadedLevels.Length; ++ i )
	{
    	if( Score >= LoadedLevels[i].ScoreReq && LoadedLevels[i].ScoreReq >= last )
    	{
    		h = i;
    		last = LoadedLevels[i].ScoreReq;
    	}
	}

	// Get the lowest one instead
	if( h == -1 )
	{
		h = 0;
		last = 0;
		for( i = 0; i < LoadedLevels.Length; ++ i )
		{
	    	if( Score <= LoadedLevels[i].ScoreReq && LoadedLevels[i].ScoreReq <= last )
	    	{
	    		h = i;
	    		last = LoadedLevels[i].ScoreReq;
	    	}
		}
	}
	return h;
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	// Disable any possible pickup except for TournamentPickups.
	if( Pickup(Other) != none && TournamentPickup(Other) == none )
	{
		if( Other.bStatic || Other.bNoDelete )
		{
			Other.GotoState( 'Disabled' );
		}
		else
		{
			return false;
		}
	}
	else if( Weapon(Other) != none ) // Every weapon shouldn't consume ammo
	{
		// Sets AmmoPerFire to zero once PostBeginPlay is called on the LoadedAmmo instance.
		// This is done this way due the FireModes being none at this point.
		Spawn( class'LoadedAmmo', Other );
	}

	bSuperRelevant = 0;
	return true;
}

event Destroyed()
{
	super.Destroyed();
	if( LR != none )
	{
		LR.Destroy();
	}
}

static function FillPlayInfo( PlayInfo PlayInfo )
{
	super.FillPlayInfo( PlayInfo );
	PlayInfo.AddSetting( default.RulesGroup, "bUseKills", "Use Kills count over Score", 0, 1, "Check" );
	PlayInfo.AddSetting( default.RulesGroup, "bBalanceWithDeaths", "Deaths affect Score", 0, 1, "Check" );
}

static event string GetDescriptionText( string PropertyName )
{
	switch( PropertyName )
	{
		case "bUseKills":
			return "LoadedLevel will be based by Kills count rather than by Score.";

		case "bBalanceWithDeaths":
			return "LoadedLevel will be decremented by Deaths count.";
	}
	return Super.GetDescriptionText( PropertyName );
}

defaultproperties
{
	FriendlyName="Loaded Level"
	Description="This mutator removes all the initial weapons you spawn with, except for the ShieldGun. Once a kill is made you will lose the ShieldGun and earn the AssaultRifle and so on. Once you suicide(or accident) you de-level meaning you'd lose the AssaultRifle and start again with the ShieldGun, you as well lose your score. Winning is not affected by this mutator. Created by Eliot Van Uytfanghe @ 2010."
	RulesGroup="MutLoadedLevel"
	Group="Arena"

	bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=true	// Only need simulated beginplay

	LoadedLevels(0)=(ScoreReq=0,Inventories=(class'ShieldGun'))
	LoadedLevels(1)=(ScoreReq=1,Inventories=(class'AssaultRifle'))
	LoadedLevels(2)=(ScoreReq=2,Inventories=(class'BioRifle'))
	LoadedLevels(3)=(ScoreReq=3,Inventories=(class'ShockRifle'))
	LoadedLevels(4)=(ScoreReq=4,Inventories=(class'LinkGun'))
	LoadedLevels(5)=(ScoreReq=5,Inventories=(class'MiniGun'))
	LoadedLevels(6)=(ScoreReq=6,Inventories=(class'FlakCannon'))
	LoadedLevels(7)=(ScoreReq=7,Inventories=(class'RocketLauncher'))
	LoadedLevels(8)=(ScoreReq=8,Inventories=(class'SniperRifle'))
	LoadedLevels(9)=(ScoreReq=9,Inventories=(class'SniperRifle',class'ShieldGun'))
	LoadedLevels(10)=(ScoreReq=10,Inventories=(class'SniperRifle',class'AssaultRifle'))
	LoadedLevels(11)=(ScoreReq=11,Inventories=(class'SniperRifle',class'BioRifle'))
	LoadedLevels(12)=(ScoreReq=12,Inventories=(class'SniperRifle',class'ShockRifle'))
	LoadedLevels(13)=(ScoreReq=13,Inventories=(class'SniperRifle',class'LinkGun'))
	LoadedLevels(14)=(ScoreReq=14,Inventories=(class'SniperRifle',class'MiniGun'))
	LoadedLevels(15)=(ScoreReq=15,Inventories=(class'SniperRifle',class'FlakCannon'))
	LoadedLevels(16)=(ScoreReq=16,Inventories=(class'SniperRifle',class'RocketLauncher'))
	LoadedLevels(17)=(ScoreReq=17,Inventories=(class'SniperRifle',class'RocketLauncher',class'ShieldGun'))
	LoadedLevels(18)=(ScoreReq=18,Inventories=(class'SniperRifle',class'RocketLauncher',class'AssaultRifle'))
	LoadedLevels(19)=(ScoreReq=19,Inventories=(class'SniperRifle',class'RocketLauncher',class'BioRifle'))
	LoadedLevels(20)=(ScoreReq=20,Inventories=(class'SniperRifle',class'RocketLauncher',class'ShockRifle'))
	LoadedLevels(21)=(ScoreReq=21,Inventories=(class'SniperRifle',class'RocketLauncher',class'LinkGun'))
	LoadedLevels(22)=(ScoreReq=22,Inventories=(class'SniperRifle',class'RocketLauncher',class'MiniGun'))
	LoadedLevels(23)=(ScoreReq=23,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon'))
	LoadedLevels(24)=(ScoreReq=24,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'ShieldGun'))
	LoadedLevels(25)=(ScoreReq=25,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'AssaultRifle'))
	LoadedLevels(26)=(ScoreReq=26,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'BioRifle'))
	LoadedLevels(27)=(ScoreReq=27,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'ShockRifle'))
	LoadedLevels(28)=(ScoreReq=28,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'LinkGun'))
	LoadedLevels(29)=(ScoreReq=29,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun'))
	LoadedLevels(30)=(ScoreReq=30,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'ShieldGun'))
	LoadedLevels(31)=(ScoreReq=31,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'AssaultRifle'))
	LoadedLevels(32)=(ScoreReq=32,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'BioRifle'))
	LoadedLevels(33)=(ScoreReq=33,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'ShockRifle'))
	LoadedLevels(34)=(ScoreReq=34,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun'))
	LoadedLevels(35)=(ScoreReq=35,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShieldGun'))
	LoadedLevels(36)=(ScoreReq=36,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'AssaultRifle'))
	LoadedLevels(37)=(ScoreReq=37,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'BioRifle'))
	LoadedLevels(38)=(ScoreReq=38,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShockRifle'))
	LoadedLevels(39)=(ScoreReq=39,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShockRifle',class'ShieldGun'))
	LoadedLevels(40)=(ScoreReq=40,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShockRifle',class'AssaultRifle'))
	LoadedLevels(41)=(ScoreReq=41,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShockRifle',class'BioRifle'))
	LoadedLevels(42)=(ScoreReq=42,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShockRifle',class'BioRifle',class'ShieldGun'))
	LoadedLevels(43)=(ScoreReq=43,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShockRifle',class'BioRifle',class'AssaultRifle'))
	LoadedLevels(44)=(ScoreReq=44,Inventories=(class'SniperRifle',class'RocketLauncher',class'FlakCannon',class'MiniGun',class'LinkGun',class'ShockRifle',class'BioRifle',class'AssaultRifle',class'ShieldGun'))
}