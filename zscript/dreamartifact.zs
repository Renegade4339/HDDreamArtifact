// ------------------------------------------------------------
// sheisc;h.prs[g;l.-
// ming;fd.rs[p,.doblesqui
// ------------------------------------------------------------

class DreamArtifact:HDPickup{
	default{
		//$Category "Items/Hideous Destructor/Magic"
		//$Title "Dream Artifact"
		//$Sprite "DRATA0"

		scale 1.5;
		-hdpickup.droptranslation
		-inventory.invbar
		-hdpickup.fitsinbackpack
		+hdpickup.notinpockets
		+HDPickup.NeverShowInPickupManager
		+bright
		inventory.pickupmessage "$PICKUP_CELESTE";
		inventory.icon "DRATA0";
		inventory.pickupsound "dreamartifact/pickup";
		hdpickup.bulk 0;
		height 32;
		radius 16;
		+nogravity;
		tag "$TAG_CELESTE";
		hdpickup.refid "grl";
	}
	bool dashed;
	bool doubledashed;
	bool candoubledash;
	int dashcd;
	uint ownertranslate;
	bool isgripping;
	int gripangle;
	int grippitch;

	void DoTheThing(){
		if(!dashed&&dashcd<1&&(owner&&owner.health>0)){
		ownertranslate=owner.translation;
		owner.A_SetTranslation("DashActive");
		owner.bbright=true;
		//if(!(owner.A_CheckFloor("null"))
		owner.vel=owner.vel+(cos(owner.pitch)*(cos(owner.angle),sin(owner.angle)),-sin(owner.pitch))*14;
		//else owner.vel=owner.vel+(cos(owner.pitch)*(cos(owner.angle),sin(owner.angle)),0)*8;
		if(candoubledash&&!doubledashed)owner.A_StartSound("dreamartifact/upgradeddash",CHAN_BODY,CHANF_OVERLAP);
		else owner.A_StartSound("dreamartifact/dash",CHAN_BODY,CHANF_OVERLAP);
		if(candoubledash&&!doubledashed)doubledashed=true;
		else if(!(candoubledash&&!doubledashed))dashed=true;
		dashcd=21;
		}
	}

	override void OwnerDied(){
		super.OwnerDied();
		//if(!owner)return;
		
		if(ownertranslate){owner.bbright=false;owner.translation=ownertranslate;}
		dashcd=0;
		dashed=false;
		doubledashed=false;
		
		hdplayercorpse hdc;
		thinkeriterator hdcorpse=ThinkerIterator.create("hdplayercorpse");
		while(hdc=hdplayercorpse(hdcorpse.next(true))){
			if((hdc.master==owner)&&hdc.getage()<5){
			if(ownertranslate)hdc.translation=ownertranslate;
			return;
			}
		}
	}

	override void Tick(){
		super.tick();
		if(!owner)return;
		
		cvar primarydashcolorcheck = cvar.GetCVar('hddreamartifact_primarydashcolor',owner.player);
		cvar secondarydashcolorcheck = cvar.GetCVar('hddreamartifact_secondarydashcolor',owner.player);
		color primarydashcolor = primarydashcolorcheck.GetString();
		color secondarydashcolor = secondarydashcolorcheck.GetString();
		cvar upgradedprimarydashcolorcheck = cvar.GetCVar('hddreamartifact_primarydashcolorupgraded',owner.player);
		cvar upgradedsecondarydashcolorcheck = cvar.GetCVar('hddreamartifact_secondarydashcolorupgraded',owner.player);
		color upgradedprimarydashcolor = upgradedprimarydashcolorcheck.GetString();
		color upgradedsecondarydashcolor = upgradedsecondarydashcolorcheck.GetString();
		let hdp = hdplayerpawn(owner);
		
		//wallclimb
		FLineTraceData WallData;
		if(!(owner.player && owner.player.cmd.buttons&BT_USER2)&&!(owner.player && owner.player.cmd.buttons&BT_ZOOM)&&!(owner.player && owner.player.cmd.buttons&BT_USE)){gripangle=owner.angle;grippitch=owner.pitch;}
			bool wall = owner.LineTrace(
				gripangle,
				33,
				grippitch,
				flags: TRF_NOSKY,
				offsetz: owner.height-12,
				data: WallData
			);
			
		//strafeclimbing
		vector2 leftclimbvel=angletovector((owner.angle+90),1);
		vector2 rightclimbvel=angletovector((owner.angle-90),1);

			if (
			(wall && WallData.HitType == TRACE_HitWall)
			&& (owner.player&&owner.player.cmd.buttons&BT_JUMP)
			&& (owner.player&&owner.player.cmd.buttons&BT_SPEED)
			&& (hdp.fatigue <= HDCONST_WALKFATIGUE)
			&& (hdp.stunned <= 0)
			&& (hdp.incapacitated <= 0)
			&& (dashcd<=18)
			)
			{
			if(owner.player&&owner.player.cmd.buttons&BT_FORWARD){owner.vel.z = 3; if(!random(0,8))hdp.fatigue++;}
			else if((owner.player&&owner.player.cmd.buttons&BT_BACK)&&!(floorz == owner.pos.z)){owner.vel.z = -3; if(!random(0,16))hdp.fatigue++;}
			else owner.vel.z = 0;
			if((owner.player&&owner.player.cmd.buttons&BT_MOVELEFT)&&!(floorz == owner.pos.z)){owner.vel.xy=leftclimbvel; if(!random(0,12))hdp.fatigue++;}
			else if((owner.player&&owner.player.cmd.buttons&BT_MOVERIGHT)&&!(floorz == owner.pos.z)){owner.vel.xy=rightclimbvel; if(!random(0,12))hdp.fatigue++;}
			else{
			owner.vel.x = 0;
			owner.vel.y = 0;
			}
			if(!random(0,32))hdp.fatigue++;
			if(hdp.fatigue > HDCONST_WALKFATIGUE){hdp.stunned += 40;hdp.fatigue+=20;}
			}
		
		//airdash
		if(dashcd>10){
			if(!(level.time&(1|2))){
			let blur=spawn("DashAfterimage",owner.pos,ALLOW_REPLACE);
				if(blur){
					blur.sprite=owner.sprite;
					if(owner.frame==5)blur.frame=4;
					else blur.frame=owner.frame;
					//blur.translation=owner.translation;
					blur.angle=owner.angle;
				}
			}
		if(!dashed&&doubledashed){
			for(int i; i<random(1,4); i++){
				owner.A_SpawnParticle(upgradedsecondarydashcolor,SPF_FULLBRIGHT|SPF_NOTIMEFREEZE,20,frandom(1,12),owner.angle,
					frandom(-owner.radius,owner.radius),
					frandom(-owner.radius,owner.radius),frandom(0,owner.height),
					0,0,0
					//owner.vel.x+frandom(-4,2),owner.vel.y+frandom(-4,2),owner.vel.z+frandom(-4,2)
				);
				owner.A_SpawnParticle(upgradedprimarydashcolor,SPF_FULLBRIGHT|SPF_NOTIMEFREEZE,20,frandom(1,12),owner.angle,
					frandom(-owner.radius,owner.radius),
					frandom(-owner.radius,owner.radius),frandom(0,owner.height),
					0,0,0
				);
			}
		}else{
			for(int i; i<random(1,4); i++){
				owner.A_SpawnParticle(secondarydashcolor,SPF_FULLBRIGHT|SPF_NOTIMEFREEZE,20,frandom(1,12),owner.angle,
					frandom(-owner.radius,owner.radius),
					frandom(-owner.radius,owner.radius),frandom(0,owner.height),
					0,0,0
					//owner.vel.x+frandom(-4,2),owner.vel.y+frandom(-4,2),owner.vel.z+frandom(-4,2)
				);
				owner.A_SpawnParticle(primarydashcolor,SPF_FULLBRIGHT|SPF_NOTIMEFREEZE,20,frandom(1,12),owner.angle,
					frandom(-owner.radius,owner.radius),
					frandom(-owner.radius,owner.radius),frandom(0,owner.height),
					0,0,0
				);
				}
			}
		}
		if(dashcd>1)dashcd--;
		if(dashcd==14){owner.bbright=false;owner.translation=ownertranslate;}
		if(dashcd==1)dashcd=0;
		if(owner.A_CheckFloor("null")&&dashcd<1){dashed=false;doubledashed=false;}
	}

	override void PostBeginPlay(){
		super.postbeginplay();
		if(!owner){return;}
		dashcd=0;
		dashed=false;
		if(hd_debug>=5)candoubledash=true;
		if(ownertranslate)owner.translation=ownertranslate;
	}

	states{
	spawn:
		DRAT ABC 3{
			double ud=frandom(-0.05,0.05);
			if(pos.z-floorz<4){
				ud=0.05;
			}
			else if(pos.z-floorz>28){
				ud=-0.05;
			}
			vel+=(0,0,ud);
		}
		DRAT D 6{
			double ud=frandom(-0.05,0.05);
			if(pos.z-floorz<4){
				ud=0.05;
			}
			else if(pos.z-floorz>28){
				ud=-0.05;
			}
			vel+=(0,0,ud);
		}
		DRAT EF 2{
			double ud=frandom(-0.05,0.05);
			if(pos.z-floorz<4){
				ud=0.05;
			}
			else if(pos.z-floorz>28){
				ud=-0.05;
			}
			vel+=(0,0,ud);
		}
		DRAT GHIJ 2{
			double ud=frandom(-0.05,0.05);
			if(pos.z-floorz<4){
				ud=0.05;
			}
			else if(pos.z-floorz>28){
				ud=-0.05;
			}
			vel+=(0,0,ud);
		}loop;
	}
}

class DashAfterimage:HDActor{
	default{
		+nointeraction
		+notimefreeze
		+bright
		alpha 1;
		renderstyle "add";
		translation "DashActive";
	}
	states{
	spawn:
		#### # 1 nodelay A_FadeOut(0.075);
		wait;
	}
}

class CelestialArtifact:HDPickup{
	default{
		//$Category "Items/Hideous Destructor/Magic"
		//$Title "Celestial Artifact"
		//$Sprite "CEATA0"

		scale 1.5;
		-hdpickup.droptranslation
		-inventory.invbar
		-hdpickup.fitsinbackpack
		+hdpickup.notinpockets
		+HDPickup.NeverShowInPickupManager
		inventory.pickupmessage "$PICKUP_CELESTE2";
		inventory.icon "CEATA0";
		inventory.pickupsound "dreamartifact/goldenrunstart";
		hdpickup.bulk 0;
		height 32;
		radius 16;
		inventory.maxamount 1;
		+nogravity;
		tag "$TAG_CELESTE2";
		hdpickup.refid "squ"; //ish
	}
	override void OwnerDied(){
		super.OwnerDied();
		owner.A_StartSound("dreamartifact/goldendeath",CHAN_VOICE,CHANF_LOCAL);
		owner.A_DropItem("CelestialArtifact");
		Destroy();
	}

	override void Tick(){
		super.tick();
		if(!owner||level.time>0){return;}
		owner.A_GiveInventory("DreamArtifact",1);
		DreamArtifact berry = DreamArtifact(owner.findinventory("DreamArtifact"));
		owner.A_StartSound("dreamartifact/goldenupgrade",CHAN_VOICE,CHANF_LOCAL);
		actor givingberry;
		if(berry)
			berry.candoubledash=true;
		destroy();
	}

	states{
	spawn:
		CEAT ABCDEF 4{
			double ud=frandom(-0.05,0.05);
			if(pos.z-floorz<4){
				ud=0.05;
			}
			else if(pos.z-floorz>28){
				ud=-0.05;
			}
			vel+=(0,0,ud);
		}
		CEAT # 0 A_Jump(32,"flash");
		loop;

	flash:
		CEAT GH 2 bright{
			double ud=frandom(-0.05,0.05);
			A_StartSound("dreamartifact/pulse",CHAN_BODY,CHANF_OVERLAP,pitch:0.7);
			if(pos.z-floorz<4){
				ud=0.05;
			}
			else if(pos.z-floorz>28){
				ud=-0.05;
			}
			vel+=(0,0,ud);
		}
		goto spawn;
	}
}

class HDDreamArtifactHandler:EventHandler{
	override void NetworkProcess(ConsoleEvent e){
		let ppp=hdplayerpawn(players[e.player].mo);
		if(!ppp)return;

		bool alive=
			!hdspectator(ppp)
			&&ppp.health>0
		;

		if(alive){
			if(e.name~=="hddreamdash")AirDash(ppp);
		}
		if(e.name~=="hddreamcolorreset")ResetColorCVARs(ppp);
	}

	void AirDash(hdplayerpawn ppp){
		let dpu=DreamArtifact(ppp.findinventory("DreamArtifact"));
		if(
			dpu
			&&ppp.player
		)dpu.DoTheThing();
	}

	void ResetColorCVARs(hdplayerpawn ppp){
		cvar primarydashcolorcheck = cvar.GetCVar('hddreamartifact_primarydashcolor',ppp.player);
		cvar secondarydashcolorcheck = cvar.GetCVar('hddreamartifact_secondarydashcolor',ppp.player);
		primarydashcolorcheck.ResetToDefault();
		secondarydashcolorcheck.ResetToDefault();
		primarydashcolorcheck.SetString("87 ce eb");
		secondarydashcolorcheck.SetString("ff ff ff");

		cvar upgradedprimarydashcolorcheck = cvar.GetCVar('hddreamartifact_primarydashcolorupgraded',ppp.player);
		cvar upgradedsecondarydashcolorcheck = cvar.GetCVar('hddreamartifact_secondarydashcolorupgraded',ppp.player);
		upgradedprimarydashcolorcheck.ResetToDefault();
		upgradedsecondarydashcolorcheck.ResetToDefault();
		upgradedprimarydashcolorcheck.SetString("d7 ab ff");
		upgradedsecondarydashcolorcheck.SetString("ff ff ff");
	}

	override void CheckReplacement(ReplaceEvent e)
	{
		if (!e.Replacement)
		{
			return;
		}

		switch (e.Replacement.GetClassName())
		{
			case 'HDSoulSphere':
				if (random[itemrand]() <= 16)
				{
					e.Replacement = "DreamArtifact";
				}else if (random[itemrand]() <= 8)
				{
					e.Replacement = "CelestialArtifact";
				}
				break;
		}
	}

	override void CheckReplacee(ReplacedEvent e)
	{
		switch (e.Replacement.GetClassName())
		{
			case 'DreamArtifact':
					e.Replacee = "Soulsphere";
				break;
			case 'CelestialArtifact':
					e.Replacee = "Soulsphere";
				break;
		}
	}
}

/*
class HDDreamArtifactGoldenRunHandler:StaticEventHandler{
	int goldenkills[7];

	override void WorldThingDied(WorldEvent e)
	{
		if (!e.Thing)
		{
			return;
		}
		for(int i=0;i<MAXPLAYERS;i++){
		playerinfo p = players[i];
		if(!(p&&p.mo&&p.mo.findinventory("DreamArtifact"))){console.printf("bleh");continue;}
		if(!(e.inflictor == p.mo))continue;
		DreamArtifact berry = DreamArtifact(e.inflictor.findinventory("DreamArtifact"));
		bool goldenrun;
		if(berry)goldenrun = berry.goldenrun;
		

		if(e.Inflictor && (p && p.mo && (e.inflictor == p.mo)) && berry && goldenrun)
			goldenkills[i]++;
		}
	}

	override void WorldLoaded(WorldEvent e){
		for(int i=0;i<MAXPLAYERS;i++){
		playerinfo p = players[i];
		console.printf("player "..i);
		if(!(p&&p.mo)){console.printf("bleh");continue;}
		let hdp=hdplayerpawn(p.mo);
		DreamArtifact berry = DreamArtifact(hdp.findinventory("DreamArtifact"));
		if(!berry){console.printf("berry not found..?");continue;}
		if(hdp && (berry && berry.goldenrun)&&e.IsSaveGame&&!hddreamartifact_forgivinggoldenrun&&!multiplayer){
		berry.goldenrun=false;
		hdp.A_Print("$HDDREAMARTIFACT_GOLDENRUNFAILSAVE");
		console.printf("bwah");
		}
		if(hdp && !random(0,3)&&!e.IsReopen&&!deathmatch&&!berry.candoubledash){
		berry.goldenrun=true;
		goldenkills[i]=0;
		hdp.A_Print("$HDDREAMARTIFACT_GOLDENRUNSTART");
		console.printf("bluh");
		}
		}
	}

	override void WorldUnloaded(WorldEvent e){
		if (!e.Thing)
		{
			return;
		}
		for(int i=0;i<MAXPLAYERS;i++){
		playerinfo p = players[i];
		console.printf("player "..i);
		if(!(p&&p.mo)){console.printf("bleh");continue;}
		let hdp=hdplayerpawn(p.mo);
		DreamArtifact berry = DreamArtifact(hdp.findinventory("DreamArtifact"));
		bool goldenrun;
		if(berry)goldenrun = berry.goldenrun;
		if(hdp && berry && goldenrun&&(goldenkills[i]>=10)){
			berry.candoubledash=true;
			hdp.A_StartSound("dreamartifact/goldenupgrade",CHAN_VOICE,CHANF_LOCAL);
			hdp.A_Print("$HDDREAMARTIFACT_GOLDENRUNSUCCESS");
		}
		}
	}
}
*/


