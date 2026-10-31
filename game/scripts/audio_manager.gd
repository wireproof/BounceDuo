class_name AudioManager
extends Node

enum SFX{
	Collect, 
	Secondary, 
	Death, 
}

func play_sfx(sound: SFX):
	match sound:
		SFX.Collect:
			$CollectPlayer.play()
		SFX.Secondary:
			$SecondaryPlayer.play()
		SFX.Death:
			$DeathPlayer.play()
