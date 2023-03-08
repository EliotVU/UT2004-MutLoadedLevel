# MutLoadedLevel

[![GitHub all releases](https://img.shields.io/github/downloads/EliotVU/UT2004-MutLoadedLevel/total)](https://github.com/EliotVU/UT2004-MutLoadedLevel/releases)

MutLoadedLevel is a mutator that brings **Gun Game** to Unreal Tournament 2004 but with a twist! 

- [x] Infinite ammo
- [x] All pickups/weapons in the map will be removed or disabled
- [x] Players will start with the ShieldGun and advance through loadouts based on their acquired score
  - ShieldGun > AssaultRifle > BioRifle > ShockRifle > LinkGun > MiniGun > FlakCannon > RocketLauncher > SniperRifle
  - SniperRifle and ShieldGun > SniperRifle and AssaultRifle, and so on...
- [x] Every time a player acquires a new score, a new loadout will be given to the player based on that score
- [x] The scoring system will be inherited from the current game mode
  - [x] Players will de-level if they lose score points, for instance a player can lose score if eliminated by self-damage
- [x] Configurable, options to change the scoring rules as well as the loadouts can be changed in the [MutLoadedLevel.ini](Configs/MutLoadedLevel.ini) file

The mutator name was named after the built-in console-command cheat `Loaded`.

## Installation

```ini
MutLoadedLevel.MutLoadedLevel
```

## Building and Dependencies

**EditPackages**

```ini
EditPackages=MutLoadedLevel
```
