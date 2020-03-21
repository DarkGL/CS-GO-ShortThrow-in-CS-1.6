#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

new const s_szModels[][] =
{
	"models/w_hegrenade.mdl",
	"models/w_flashbang.mdl",
	"models/w_smokegrenade.mdl"
}

new const s_szClassNames[][] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade"
}

new const grenadeClassName[] = "grenade";

new bool:gbShortThrow[ MAX_PLAYERS ];

new cvBlow,
     cvMultiplier;

const m_pPlayer  = 	41;
const XoCGrenade = 	4;

public plugin_init()
{
	register_plugin("Short Nade", "1.0", "Grzyboo")
	
	cvBlow = register_cvar("amx_shortnade_blow", "1.0");
	cvMultiplier = register_cvar("amx_shortnade_multiplier", "0.5");
	
	for( new iPosition = 0; iPosition < sizeof s_szClassNames; iPosition++ ){
		RegisterHam(Ham_Weapon_PrimaryAttack, s_szClassNames[ iPosition ], "fwPrimaryAttack", true );
		RegisterHam(Ham_Weapon_SecondaryAttack, s_szClassNames[ iPosition ], "fwSecondaryAttack", true );
	}
	
	register_forward(FM_SetModel, 	"fwSetmodel");
}

public fwPrimaryAttack(const grenadeEntity){
	if( !pev_valid( grenadeEntity ) ){
		return HAM_IGNORED;
	}
	
	new id = get_pdata_cbase(grenadeEntity, m_pPlayer, XoCGrenade);
	
	gbShortThrow[id] = false;
	
	return HAM_IGNORED;
}

public fwSecondaryAttack(const grenadeEntity){
	if( !pev_valid( grenadeEntity ) ){
		return HAM_IGNORED;
	}
	
	new id = get_pdata_cbase(grenadeEntity, m_pPlayer, XoCGrenade);
			
	gbShortThrow[id] = true;
	
	ExecuteHam(Ham_Weapon_PrimaryAttack, grenadeEntity);
	
	return HAM_IGNORED;
}

public fwSetmodel(iEntity, sModel[]){
	
	static szClassName[ 64 ];
	
	if( !pev_valid( iEntity ) ){
		return FMRES_IGNORED;
	}
	
	pev( iEntity , pev_classname , szClassName , charsmax( szClassName ) );
	
	if( !equal( grenadeClassName , szClassName ) ){
		return FMRES_IGNORED;
	}
	
	for(new i=0; i<sizeof s_szModels; ++i)
	{
		if(equal(sModel, s_szModels[i]))
		{
			new id = pev(iEntity, pev_owner);
			
			if(!is_user_connected(id))
				return FMRES_IGNORED;
			
			if(gbShortThrow[id])
			{
				DecreaseSpeed(iEntity);
				gbShortThrow[id] = false;
				return FMRES_IGNORED;
			}
		}
	}
	
	return FMRES_IGNORED;
}

public DecreaseSpeed(iEntity){
	
	static Float: fVec[ 3 ];
	static Float: fOrigin[ 3 ];
	static Float: fDmgTime;
	
	new 	Float: fBlowTime = get_pcvar_float( cvBlow ),
		Float: fMultipler = get_pcvar_float( cvMultiplier );
	
	pev(iEntity, pev_velocity, fVec);
	pev(iEntity, pev_origin, fOrigin );
	pev(iEntity, pev_dmgtime, fDmgTime);
	
	xs_vec_mul_scalar( fVec , fMultipler , fVec );
	
	set_pev(iEntity, pev_velocity, fVec);
	
	fOrigin[ 2 ] -= 24.0;
	
	set_pev(iEntity, pev_origin, fOrigin );
	
	if(fBlowTime > 1.0 || fBlowTime < 0.1){
		set_pcvar_float(cvBlow, 1.0);
		
		fBlowTime = 1.0;
	}
	
	fDmgTime -= get_gametime();
	
	set_pev(iEntity, pev_dmgtime, get_gametime() + (fDmgTime * fBlowTime));
}
