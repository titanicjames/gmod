-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Dynamite"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZpowderIgnitable=true
ENT.JModPreferredCarryAngles=Angle(-90,90,0)
ENT.JModEZstorable=true
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---

if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*15
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/mechanics/robotics/a2.mdl")
		self:SetModelScale(.25,0)
		self:SetMaterial("models/entities/mat_jack_dynamite")
		self:SetBodygroup(0,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.Fuze=100
		self:SetState(JMod.EZ_STATE_OFF)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:EmitSound("DryWall.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor()==self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(dmginfo:IsDamageType(DMG_BLAST))then DetChance=DetChance+Dmg/150 end
			if(math.Rand(0,1)<DetChance)then self:Detonate() end
		end
	end
	function ENT:Arm()
		if(self:GetState()==JMod.EZ_STATE_ARMED)then return end
		self:EmitSound("snds_jack_gmod/ignite.wav",60,100)
		timer.Simple(.5,function()
			if(IsValid(self))then self:SetState(JMod.EZ_STATE_ARMED) end
		end)
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		
		JMod.Owner(self,Dude)
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(JMod.Config.AltFunctionKey)
			if(State==JMod.EZ_STATE_OFF and Alt)then
				self:Arm()
				JMod.Hint(Dude, "fuse", self)
			end
			JMod.ThrowablePickup(Dude,self,500,250)
			if not Alt then JMod.Hint(Dude, "arm", self) end
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		JMod.Sploom(self.Owner or game.GetWorld(),SelfPos,115)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local Blam=EffectData()
		Blam:SetOrigin(SelfPos)
		Blam:SetScale(0.5)
		util.Effect("eff_jack_plastisplosion",Blam,true,true)
		util.ScreenShake(SelfPos,20,20,1,700)
		self:Remove()
	end
	function ENT:Think()
		local Time=CurTime()
		local state = self:GetState()
		if(state==JMod.EZ_STATE_ARMED)then
			local Fsh=EffectData()
			Fsh:SetOrigin(self:GetPos()+self:GetForward()*6)
			Fsh:SetScale(1)
			Fsh:SetNormal(self:GetForward())
			util.Effect("eff_jack_fuzeburn",Fsh,true,true)
			self.Entity:EmitSound("snd_jack_sss.wav",65,math.Rand(90,110))
			self.Fuze=self.Fuze-.7
			if(self.Fuze<=0)then self:Detonate();return end
			self:NextThink(Time+.05)
			return true
		end
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezdynamite","EZ Dynamite")
end