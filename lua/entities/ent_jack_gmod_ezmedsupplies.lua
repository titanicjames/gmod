-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Medical Supplies Box"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="medsupplies"
ENT.JModPreferredCarryAngles=Angle(-90,0,0)
ENT.MaxResource=JMod_EZmedSupplyBoxSize
ENT.Model="models/kali/props/cases/hard case b.mdl"
ENT.Material="models/kali/props/cases/hardcase/jardcase_b"
ENT.ModelScale=.5
ENT.Mass=30
ENT.ImpactNoise1="drywall.ImpactHard"
ENT.ImpactNoise2="Weapon.ImpactSoft"
ENT.DamageThreshold=140
ENT.BreakNoise="Metal_Box.Break"
ENT.PropModels={
	"models/items/healthkit.mdl",
	"models/healthvial.mdl",
	"models/items/medjit_medium.mdl",
	"models/items/medjit_small.mdl",
	"models/weapons/w_models/w_bonesaw.mdl", -- todo: missing texture
	"models/bandages.mdl"
}
---
if(SERVER)then
	function ENT:FlingProp(mdl)
		local Prop=ents.Create("prop_physics")
		Prop:SetPos(self:GetPos())
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:SetModelScale(.5,0)
		Prop:Spawn()
		Prop:Activate()
		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop,self)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity((VectorRand()+Vector(0,0,1)):GetNormalized()*math.Rand(100,300))
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,1000))
		SafeRemoveEntityDelayed(Prop,math.Rand(5,10))
	end
	function ENT:UseEffect(pos,ent)
		for i=1,4 do self:FlingProp(table.Random(self.PropModels)) end
		local effectdata=EffectData()
		effectdata:SetOrigin(pos+VectorRand())
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(1,2)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
	end
elseif(CLIENT)then
	local TxtCol=Color(20,20,20,230)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Parts=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			Ang:RotateAroundAxis(Ang:Up(),180)
			cam.Start3D2D(Pos+Up*9+Forward*3.4,Ang,.028)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText("EZ MEDICAL SUPPLIES","JMod-Stencil",0,50,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Parts.." UNITS","JMod-Stencil",0,100,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end