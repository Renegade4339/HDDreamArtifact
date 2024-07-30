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
	int dashcd;
	uint ownertranslate;

	void DoTheThing(){
		if(!dashed&&dashcd<1&&(owner&&owner.health>0)){
		ownertranslate=owner.translation;
		owner.A_SetTranslation("DashActive");
		//if(!(owner.A_CheckFloor("null"))
		owner.vel=owner.vel+(cos(owner.pitch)*(cos(owner.angle),sin(owner.angle)),-sin(owner.pitch))*14;
		//else owner.vel=owner.vel+(cos(owner.pitch)*(cos(owner.angle),sin(owner.angle)),0)*8;
		owner.A_StartSound("dreamartifact/dash",CHAN_BODY,CHANF_OVERLAP);
		dashed=true;
		dashcd=21;
		}
	}

	override void OwnerDied(){
		super.OwnerDied();
		//if(!owner)return;
		
		if(ownertranslate)owner.translation=ownertranslate;
		dashcd=0;
		dashed=false;
	}

	override void Tick(){
		super.tick();
		if(!owner)return;
		
		cvar primarydashcolorcheck = cvar.GetCVar('hddreamartifact_primarydashcolor',owner.player);
		cvar secondarydashcolorcheck = cvar.GetCVar('hddreamartifact_secondarydashcolor',owner.player);
		color primarydashcolor = primarydashcolorcheck.GetString();
		color secondarydashcolor = secondarydashcolorcheck.GetString();
		let hdp = hdplayerpawn(owner);
		
		//wallclimb
		FLineTraceData WallData;
			bool wall = owner.LineTrace(
				owner.angle,
				33,
				owner.pitch,
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
		if(dashcd>1)dashcd--;
		if(dashcd==14)owner.translation=ownertranslate;
		if(dashcd==1)dashcd=0;
		if(owner.A_CheckFloor("null"))dashed=false;
	}

	override void PostBeginPlay(){
		super.postbeginplay();
		if(!owner){return;}
		dashcd=0;
		dashed=false;
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
		primarydashcolorcheck.SetString("87 ce eb");
		secondarydashcolorcheck.SetString("ff ff ff");
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
				if (random[itemrand]() <= 1)
				{
					e.Replacement = "DreamArtifact";
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
		}
	}
}


