/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale
	
##########################################################################################################################
	
	Plugin Batiment - les rolllouts du plug --------------------
	
##########################################################################################################################

	NOTES :
	
##########################################################################################################################
	
	todo:
	- gerer les unité des parametre (pour le calcul ou  l'affichage des longueurpar ex..)
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [23/09/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/




parameters params_main rollout:roll_params			(
	
	------- AXE PRINCIPAL	------------------
	mtrx_axePrincipal		type:#matrix3	
	BB_axePrincipal		type:#point3Tab		tabSize:2			tabSizeVariable:false
	rotation_axeP			type:#float				default:0.			ui:spn_rotation_axeP
	
	facades_murs			type:#integer		default:1				ui:ddl_appliquerA
)		
parameters params_trace rollout:roll_trace			(

	------- tracés			------------------
	a_un_trace			type:#boolean			default:false
	
	trace_original		type:#point3Tab 		tabSize:0 			tabSizeVariable:true
	trace					type:#point3Tab 		tabSize:0 			tabSizeVariable:true
	
	trace_optimiser	type:#boolean			default:false		ui:chk_optimiser
	trace_souder		type:#boolean			default:false		ui:chk_souder
	trace_ortho		type:#boolean			default:false		ui:chk_ortho
	
	seuil_optimiser		type:#float				default:20.			ui:spn_optimiser
	seuil_souder		type:#float				default:30.			ui:spn_souder
	seuil_ortho			type:#float				default:100.		ui:spn_ortho
	
	-------  	murs		------------------
	idtrace_pignons			type:#intTab 			tabSize:0 			tabSizeVariable:true
	idtrace_gouttereaux		type:#intTab	 		tabSize:0 			tabSizeVariable:true
	
)
parameters params_infos rollout:roll_infos			(
	
	surface			type: #float 		default:0.	
)
parameters params_rdc rollout:roll_rdc			(
	
	rdc_hauteur	type: #float 		default:250.	ui:spn_hauteur
-- 		rdc_murs		type:#integer		default:1		ui:ddl_appliquerA
)
parameters params_etages rollout:roll_etages			(
	
	etages_hauteur	type: #float 		default:250.	ui:spn_hauteur
	etages_nbre		type: #integer		default:1		ui:spn_nbres
-- 		etages_murs		type:#integer		default:1		ui:ddl_appliquerA
	
)
parameters params_toiture rollout:roll_toiture			(
	
	toit_nbrePentes	type: #radiobtnIndex 	default:2		ui:rdo_pentes
	toit_pente			type: #float 				default:20		ui:spn_pente
	toit_type			type: #integer 			default:3		ui:ddl_toiture
	toit_hauteur		type: #float 				default:20.		ui:spn_toit_hauteur
	
)
parameters params_affichage rollout:roll_affichage			(
	
	------- AFFICHAGE 		 ------------------
	affiche_axe					type:#boolean			default:false	ui:ckb_axe
	affiche_trace				type:#boolean			default:false	ui:ckb_trace
	affiche_gouttereaux		type:#boolean			default:false	ui:ckb_gouttereaux
	affiche_pignons			type:#boolean			default:false	ui:ckb_pignons
-- 		affiche_longueurSegts	type:#boolean			default:false	ui:ckb_longueurSegts
	
	cache_geometrie			type:#boolean			default:false	ui:ckb_geometrie
)


-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  ----------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------------------------
rollout roll_aPropos "A propos" width:162 height:64
(
	label 'lbl_axeP' "Urba V0.0   |" pos:[5,2]  align:#left
	HyperLink 'hpl1' "Christophe Pagès" pos:[76,2] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	HyperLink 'hpl2' "GitHub" pos:[127,17] address:"https://github.com/c-pages/cp-Urba" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	label 'lbl6' "09 | 2017" pos:[5,17] align:#left
)
rollout roll_trace "Tracé"   rolledUp:false
(
	
	fn shape_filt 		obj = superclassof obj == shape
	
	pickbutton 'btn_pick_trace' "Pick shape" pos:[5,2] width:165 height:21 filter:shape_filt align:#left
	
	checkbox 'chk_optimiser' "Optimiser" pos:[5,58] width:66 height:13 align:#left
	
	checkbox 'chk_ortho' "Orthogon." pos:[5,28] width:80 height:13 align:#left
	spinner 'spn_optimiser' "" pos:[85,58] width:86 height:16 	range:[0,40,0] 	 align:#left
	checkbox 'chk_souder' "Souder" pos:[5,43] width:66 height:13 align:#left
	spinner 'spn_souder' "" pos:[85,43] width:86 height:16 range:[0,100,0] type:#worldunits align:#left
	spinner 'spn_ortho' "" pos:[85,28] width:86 height:16 range:[0,100,0] type:#float align:#left
	
	fn actualiser =(
		
		chk_optimiser.enabled 		= a_un_trace
		chk_ortho.enabled 			= a_un_trace
		chk_souder.enabled 			= a_un_trace
		
		spn_optimiser.enabled = trace_optimiser
		spn_souder.enabled = trace_souder
		spn_ortho.enabled = trace_ortho
		
	)
	
	
			
	
	on roll_trace open do
		actualiser ()
	on btn_pick_trace picked 	_nvtrace 	do
	(
-- 		$.pos = [0,0,0]
		set_trace	_nvtrace	$
		creerBatiment ()
		redrawviews ()
	)
	on chk_optimiser changed state do
	(
			optimiser_trace ()
		actualiser ()
			)
	on chk_ortho changed state do
	(		
			optimiser_trace ()
		actualiser ()
			)
	on spn_optimiser changed val 	do
		optimiser_trace ()
	on chk_souder changed state do
	(		
			optimiser_trace ()
			actualiser ()
		)
	on spn_souder changed val 	do
		optimiser_trace ()
	on spn_ortho changed val 	do
		optimiser_trace ()
)
rollout roll_params "Global" width:235 height:205
(
	
	fn shape_filt 		obj = superclassof obj == shape
	
	button 'btn_enregistrer' "Enregistrer" pos:[87,18] width:77 height:16 align:#left		
		
	button 'btn_charger' "Charger" pos:[11,18] width:77 height:16 align:#left
	GroupBox 'grp_presets' "Presets" pos:[5,3] width:165 height:52 align:#left
	button 'btn_coller' "Coller" pos:[87,33] width:77 height:16 align:#left
	button 'btn_copier' "Copier" pos:[11,33] width:77 height:16 align:#left
	
	spinner 'spn_rotation_axeP' "" pos:[5,72] width:115 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	label 'lbl_axeP' "Orientation:" pos:[5,57] width:113 height:15 align:#left
	button 'btn_rotation' "+90" pos:[120,72] width:25 height:16 align:#left
	button 'btn_rotation_inv' "-90" pos:[144,72] width:25 height:16 align:#left	
	
	dropdownList 'ddl_appliquerA' "" pos:[5,108] width:165 height:21 selection:3 align:#left  items:murs_types
	label 'lbl_appliquerA' "Appliquer Façades sur:" pos:[5,93] width:111 height:15 align:#left
	
	
	fn actualiser =(
		btn_coller.enabled 		= a_un_trace and urba_clipboard_batiment != ""
		btn_copier.enabled 			= a_un_trace
		btn_enregistrer.enabled 		= a_un_trace
		btn_charger.enabled 			= a_un_trace
		grp_presets.enabled 			= a_un_trace
		
		btn_rotation.enabled 			= a_un_trace
		btn_rotation_inv.enabled 		= a_un_trace
		spn_rotation_axeP.enabled 	= a_un_trace
		lbl_axeP.enabled 					= a_un_trace
		ddl_appliquerA.enabled 			= a_un_trace		
		lbl_appliquerA.enabled 			= a_un_trace
	)
	
	
	
	
			

	on roll_params open do
		actualiser ()
	on btn_enregistrer pressed do
		presets.enregistrer 	this
	on btn_charger pressed do
	(
			presets.charger 		this
			creerBatiment ()
			actualiser_rollouts()
		)
	on btn_rotation pressed do
	(
				rotation_axeP += 90
				if rotation_axeP>360 do rotation_axeP = 360
				tourner_axeP 	()
			)
	on btn_rotation_inv pressed do
	(
				rotation_axeP += -90
				if rotation_axeP<-360 do rotation_axeP = -360
				tourner_axeP 	()
			)
	on spn_rotation_axeP changed val 	do
		tourner_axeP 	()
	on btn_coller pressed do (
			presets.coller 	this 
			creerBatiment ()
			actualiser_rollouts()
		
	)
	on btn_copier pressed do
	(
			presets.copier 	this 
			actualiser()
-- 			presets.charger 		this
		)
)
rollout roll_rdc "RdC"  rolledUp:true
(
	dropdownList 'ddl_facades' "" pos:[51,16] width:99 height:21 align:#left
	checkbutton 'ckb_ouvrirFacades' "F" pos:[149,16] width:21 height:21 align:#left
	label 'lbl_facade' "Façade:" pos:[5,20] width:38 height:15 align:#left
	spinner 'spn_hauteur' "" pos:[50,1] width:118 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hateur' "Hauteur:" pos:[5,1] width:45 height:15 align:#left
	
	
	
	fn actualiser =(
		
		
		ddl_facades.enabled 			= a_un_trace
		ckb_ouvrirFacades.enabled 	= a_un_trace
		lbl_facade.enabled 				= a_un_trace
		spn_hauteur.enabled 			= a_un_trace
		lbl_hateur.enabled 				= a_un_trace
		
		
		
		--- les presets facades ----------
		local listTmp =#()
		local presetsFacades = urba.facades.presets.get ()
		for preset in presetsFacades do
			append listTmp preset.nom
		ddl_facades.items = listTmp
		ckb_ouvrirFacades.checked = urba.facades.estOuvert ()
	)
	
	
	on roll_rdc open do
		actualiser()
	on ckb_ouvrirFacades changed state 		do
	(
				urba.facades.toggle_ouvrir ()
				roll_etages.actualiser ()
			)
	on spn_hauteur changed val 	do
		creerBatiment ()
)
rollout roll_etages "Etages"  rolledUp:true
(
	dropdownList 'ddl_facades' "" pos:[51,32] width:99 height:21 align:#left
	checkbutton 'ckb_ouvrirFacades' "F" pos:[149,32] width:21 height:21 align:#left
	label 'lbl_facade' "Façade:" pos:[5,36] width:38 height:15 align:#left
	label 'lbl_nbre' "Nbre.:" pos:[5,1] width:38 height:15 align:#left
	spinner 'spn_nbres' "" pos:[50,2] width:118 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	
	spinner 'spn_hauteur' "" pos:[50,17] width:118 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Hauteur:" pos:[5,17] width:45 height:15 align:#left
	
	
	fn actualiser =(
		local enabled = a_un_trace
		if etages_nbre != 0 then (
			
			--- les presets facades ----------
			local listTmp =#()
			local presetsFacades = urba.facades.presets.get ()
			for preset in presetsFacades do
				append listTmp preset.nom
			ddl_facades.items = listTmp
			
			ckb_ouvrirFacades.checked = urba.facades.estOuvert ()
		
		) else (
			enabled = false
			ddl_facades.selection = 0
		)
		
		lbl_nbre.enabled 					=	enabled
		spn_nbres.enabled 				=	enabled
		ddl_facades.enabled 			=	enabled
		lbl_facade.enabled 				= enabled
		spn_hauteur.enabled 			= enabled
		lbl_hauteur.enabled 				= enabled
		ckb_ouvrirFacades.enabled 	= enabled
		
		
	)
	
	
	on roll_etages open do
		actualiser()
	on ckb_ouvrirFacades changed state 		do
	(
				urba.facades.toggle_ouvrir ()
				roll_rdc.actualiser ()
			)
	on spn_nbres changed val 	do (
		creerBatiment ()
		actualiser ()
	)
	on spn_hauteur changed val 	do
		creerBatiment ()
)
rollout roll_toiture "Toiture" rolledUp:true
(
	dropdownList 'ddl_toiture' "" pos:[51,1] width:118 height:21 items:#("Plate", "Acrotère", "Pentes") align:#left
	label 'lbl_facade' "Toiture:" pos:[5,5] width:38 height:15 align:#left
	radiobuttons 'rdo_pentes' "" pos:[50,52] width:29 height:16 labels:#("1", "2") align:#left
	spinner 'spn_toit_hauteur' "" pos:[50,21] width:118 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Hauteur:" pos:[5,21] width:45 height:15 align:#left
	spinner 'spn_pente' "" pos:[50,36] width:95 height:16 range:[0,80,20] type:#float scale:1 align:#left
	label 'lbl_pente' "Pente:" pos:[5,37] width:45 height:15 align:#left
	label 'lbl5' "Pentes:" pos:[5,52] width:45 height:15 align:#left
	label 'lbl12' "deg." pos:[146,38] width:24 height:15 align:#left
	
	fn actualiser =(
		
		lbl12.enabled 			= a_un_trace
		ddl_toiture.enabled 			= a_un_trace
		lbl_facade.enabled 			= a_un_trace
		rdo_pentes.enabled 			= a_un_trace
		spn_toit_hauteur.enabled 	= a_un_trace
		lbl_hauteur.enabled 			= a_un_trace
		spn_pente.enabled 			= a_un_trace
		lbl_pente.enabled 			= a_un_trace
		lbl5.enabled 					= a_un_trace
		
		if a_un_trace do (
			rdo_pentes.enabled 					= ddl_toiture.selection == 3
			spn_pente.enabled 					= ddl_toiture.selection == 3
			lbl_pente.enabled 					= ddl_toiture.selection == 3
		)
	)
	
	
	
	on roll_toiture open do
		actualiser()
	on ddl_toiture selected sel 	do
	(
				actualiser	()
				creerBatiment ()
			)
	on rdo_pentes changed stat 	do
		creerBatiment ()
	on spn_toit_hauteur changed val 	do
		creerBatiment ()
	on spn_pente changed val 	do
		creerBatiment ()
)
rollout roll_affichage "Affichage"  rolledUp:true
(
	checkbutton 'ckb_axe' "Axe" pos:[5,2] width:80 height:16 align:#left	 --highlightColor:[200,200,100]
	checkbutton 'ckb_trace' "Points du tracé" pos:[83,2] width:80 height:16 align:#left --highlightColor:[170,170,170]
	checkbutton 'ckb_pignons' "Pignons" pos:[84,17] width:80 height:16 align:#left		 --highlightColor:[130,130,250]
	checkbutton 'ckb_gouttereaux' "Gouttereaux" pos:[5,17] width:80 height:16 align:#left --highlightColor:[250,100,100]
-- 		checkbutton 'ckb_longueurSegts' "Long. façades" pos:[5,32] width:80 height:16 align:#left --highlightColor:[170,170,170]
	checkbutton 'ckb_geometrie' "Cacher géom." pos:[5,47] width:80 height:16 align:#left highlightColor:red
	
	
	fn actualiser = (

		ckb_axe.enabled 			= a_un_trace
		ckb_trace.enabled 	= a_un_trace
		ckb_pignons.enabled 			= a_un_trace
		ckb_gouttereaux.enabled 	= a_un_trace
		ckb_geometrie.enabled 			= a_un_trace
	)
	
	
	
	on ckb_geometrie 		changed state 		do 		toggle_cacherGeo ()
	on ckb_axe 				changed state 		do 		VP_toggle ()
	on ckb_trace 				changed state 		do	VP_toggle ()
	on ckb_pignons 			changed state 		do	(
		VP_toggle ()
		actualiser ()
	)
	on ckb_gouttereaux 	changed state 		do	(
		VP_toggle ()
		actualiser ()
	)
-- 		on ckb_longueurSegts 	changed state 		do	VP_toggle ()
	on roll_affichage open do actualiser ()
	
	
)
rollout roll_infos "Infos" 	rolledUp:true
(
	label 'lbl16' "Surface:" pos:[4,2] width:43 height:14 align:#left
	label 'lbl_surface' "" pos:[85,2] width:103 height:16 align:#left 

	label 'lbl1_tracePts' "Tracé (origin.):" pos:[4,17] width:70 height:14 align:#left
	label 'lbl_tracePts_val' "" pos:[85,17] width:103 height:16 align:#left 

	label 'lbl1_tracePts_opt' "Tracé (optim.):" pos:[4,32] width:69 height:14 align:#left
	label 'lbl_tracePts_opt_val' "" pos:[85,32] width:103 height:16 align:#left 

	
	
	fn actualiser =(
		
		lbl16.enabled 			= a_un_trace
		lbl_surface.enabled 			= a_un_trace
		lbl1_tracePts.enabled 			= a_un_trace
		lbl_tracePts_val.enabled 			= a_un_trace
		lbl1_tracePts_opt.enabled 			= a_un_trace
		lbl_tracePts_opt_val.enabled 			= a_un_trace
		if a_un_trace do (
			lbl_surface.text = ( surface / 10000 ) as string + " m²"
			lbl_tracePts_val.text = trace_original.count as string + " pts."
			lbl_tracePts_opt_val.text = trace.count as string + " pts."
		)
	)
	
	on roll_infos open do
		actualiser()
)































