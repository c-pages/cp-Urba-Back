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




parameters params_global rollout:roll_global			(
	
	------- AXE PRINCIPAL	------------------
	mtrx_axePrincipal		type:#matrix3	
	BB_axePrincipal		type:#point3Tab		tabSize:2			tabSizeVariable:false
	rotation_axeP			type:#float				default:0.			ui:spn_rotation_axeP
	
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
	
	
	niveaux_hauteur	type: #float 		default:250.	ui:spn_hauteur
	niveaux_nbre		type: #integer		default:1		ui:spn_nbres
	
)
parameters params_infos rollout:roll_infos			(
	
	surface			type: #float 		default:0.	
	
	------- AFFICHAGE 		 ------------------
	affiche_axe					type:#boolean			default:false	ui:ckb_axe
	affiche_trace				type:#boolean			default:false	ui:ckb_trace
	affiche_gouttereaux		type:#boolean			default:false	ui:ckb_gouttereaux
	affiche_pignons			type:#boolean			default:false	ui:ckb_pignons
-- 		affiche_longueurSegts	type:#boolean			default:false	ui:ckb_longueurSegts
	
	cache_geometrie			type:#boolean			default:false	ui:ckb_geometrie
)

parameters params_facades 	rollout:roll_facades			(
)

parameters params_toiture rollout:roll_toiture			(
	
-- 	toit_nbrePentes	type: #radiobtnIndex 	default:2		ui:rdo_pentes
	toit_pente			type: #float 				default:20		ui:spn_pente
	toit_type			type: #integer 			default:3		ui:ddl_toiture
	toit_hauteur		type: #float 				default:20.		ui:spn_toit_hauteur
	
)
/* parameters params_affichage rollout:roll_affichage			(
	
)
 */

-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  ----------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------------------------

rollout roll_global "Global" width:247 height:172
(
	
	fn shape_filt 		obj = superclassof obj == shape
	
	pickbutton 'btn_pick_trace' "Pick shape" pos:[10,13] width:156 height:21 filter:shape_filt align:#left
	
	checkbox 'chk_optimiser' "Optimiser" pos:[10,64] width:62 height:13 align:#left
	
	checkbox 'chk_ortho' "Orthonorm." pos:[10,34] width:76 height:13 align:#left
	spinner 'spn_optimiser' "" pos:[87,63] width:80 height:16 range:[0,40,0] align:#left
	checkbox 'chk_souder' "Souder" pos:[10,49] width:55 height:13 align:#left
	spinner 'spn_souder' "" pos:[87,48] width:80 height:16 range:[0,100,0] type:#worldunits align:#left
	spinner 'spn_ortho' "" pos:[87,33] width:80 height:16 range:[0,100,0] type:#float align:#left
	
	spinner 'spn_rotation_axeP' "" pos:[87,119] width:85 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	label 'lbl_axeP' "Orientation:" pos:[5,120] width:59 height:15 align:#left
	button 'btn_rotation' "+90°" pos:[89,134] width:42 height:16 align:#left
	button 'btn_rotation_inv' "-90°" pos:[130,134] width:42 height:16 align:#left	
	
	
	
	
	
	
	GroupBox 'grp9' "Tracé:" pos:[4,0] width:168 height:85 align:#left
	
		
	label 'lbl_nbre' "Nbre. d'étages:" pos:[5,90] width:79 height:15 align:#left
	spinner 'spn_nbres' "" pos:[87,89] width:85 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	

	spinner 'spn_hauteur' "" pos:[87,104] width:85 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Htr. des étages:" pos:[5,105] width:76 height:15 align:#left
	
	
	
	
	
	fn actualiser =(
		
		
		spn_hauteur.enabled 			= a_un_trace
		lbl_hauteur.enabled 				= a_un_trace
		
		
		chk_optimiser.enabled 		= a_un_trace
		chk_ortho.enabled 			= a_un_trace
		chk_souder.enabled 			= a_un_trace
		
		spn_optimiser.enabled = trace_optimiser
		spn_souder.enabled = trace_souder
		spn_ortho.enabled = trace_ortho
		btn_rotation.enabled 			= a_un_trace
		btn_rotation_inv.enabled 		= a_un_trace
		spn_rotation_axeP.enabled 	= a_un_trace
		lbl_axeP.enabled 					= a_un_trace
	)
	
	on spn_hauteur changed  arg do 
		creerBatiment ()
	on spn_nbres changed  arg do 
		creerBatiment ()
			
	on btn_rotation_inv  	pressed  do (
		rotation_axeP -= 90
		tourner_axeP ()
	)
	on btn_rotation 			pressed  do  (
		rotation_axeP += 90
		tourner_axeP ()
	)
	on spn_rotation_axeP changed  arg do (
		tourner_axeP ()
	)
	on btn_pick_trace picked _nvtrace 	do	(
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
rollout roll_facades "Façades" width:266 height:297	rolledUp:false
(
	multiListBox 'lbx_facades' "" pos:[5,15] width:165 height:9 align:#left 
 
	button 'btn_ajouterFacade' "+" pos:[141,-1] width:16 height:16 align:#left
	
	button 'btn_supprimerFacade' "-" pos:[156,-1] width:16 height:16 align:#left
	label 'lbl_composants' "Composants:" pos:[5,0] width:70 height:15 align:#left
	
	GroupBox 'grp_prop' "Propriétés" pos:[5,143] width:165 height:146 align:#left
	checkbox 'chk_repetable' "Répétable" pos:[11,232] width:71 height:14 align:#left
	checkbox 'chk_etirable' "Etirable" pos:[88,232] width:75 height:14 align:#left
	spinner 'spn_proba' "" pos:[87,216] width:80 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
	label 'lbl_proba' "Probabilité:" pos:[11,216] width:67 height:15 align:#left
	
	spinner 'spn_largeur' "" pos:[87,156] width:80 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_largeur' "Largeur (min):" pos:[11,156] width:73 height:15 align:#left
	spinner 'spn_largeurMax' "" pos:[87,171] width:80 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_etages' "" pos:[87,186] width:80 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_etages' "Etages (min):" pos:[11,186] width:71 height:15 align:#left
	spinner 'spn_etagesMax' "" pos:[87,201] width:80 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	
	
	
	dropdownList 'ddl_appliquerA' "" pos:[11,262] width:153 height:21 selection:3 align:#left  items:murs_types
	label 'lbl_appliquerA' "Appliquer à:" pos:[11,247] width:111 height:15 align:#left
	
	checkbox 'chk_largeur' "max.:" pos:[11,171] width:69 height:14 align:#left
	checkbox 'chk_etages' "max.:" pos:[11,201] width:71 height:14 align:#left
	
	
	
	fn actualiser =(
		
		enabled = a_un_trace
		
		
		
		
		lbx_facades.enabled 			= enabled
		btn_ajouterFacade.enabled 	= enabled
		btn_supprimerFacade.enabled = enabled
		lbl_composants.enabled 				= enabled
		
		enabled = lbx_facades.selection.count != 0
		
		grp_prop.enabled 			= enabled
		spn_proba.enabled 			= enabled
		lbl_proba.enabled 			= enabled
		chk_repetable.enabled 			= enabled
		chk_etirable.enabled 			= enabled
		lbl_largeur.enabled 			= enabled
		spn_etages.enabled 			= enabled
		spn_etagesMax.enabled 			= enabled
		chk_etages.enabled 			= enabled
		spn_largeurMax.enabled 			= enabled
		lbl_etages.enabled 			= enabled
		chk_largeur.enabled 			= enabled
		grp_prop.enabled 				= enabled
		spn_largeur.enabled 				= enabled
		lbl_largeur.enabled 				= enabled
		spn_largeurMax.enabled 		= enabled
		
		chk_repetable.enabled 			= enabled
		chk_etirable.enabled 			= enabled
		spn_proba.enabled 				= enabled
		
		
		ddl_appliquerA.enabled 				= enabled
		lbl_appliquerA.enabled 		= enabled
		
		--- les presets facades ----------
		local listTmp =#()
		local presetsFacades = urba.facades.presets.get ()
		for preset in presetsFacades do
			append listTmp preset.nom
		
	)
	
	on roll_facades open do
		actualiser()
	
)

rollout roll_toiture "Toiture" width:236 height:418
(
	dropdownList 'ddl_toiture' "" pos:[88,1] width:85 height:21 items:#("Plate", "Acrotère", "1 pan", "2 pans") align:#left
	label 'lbl_facade' "Toiture:" pos:[5,7] width:38 height:15 align:#left
-- 	radiobuttons 'rdo_pentes' "" pos:[89,52] width:29 height:32 labels:#("1", "2") align:#left
	spinner 'spn_toit_hauteur' "" pos:[87,21] width:85 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Hauteur:" pos:[5,22] width:45 height:15 align:#left
	spinner 'spn_pente' "" pos:[87,36] width:85 height:16 range:[0,80,20] type:#float scale:1 align:#left
	label 'lbl_pente' "Pente(°):" pos:[5,37] width:45 height:15 align:#left
-- 	label 'lbl5' "Pentes:" pos:[5,52] width:45 height:15 align:#left
	
	multiListBox 'lbx_facades' "" pos:[5,67] width:165 height:9 align:#left 
 
 
	button 'btn_ajouterFacade' "+" pos:[141,51] width:16 height:16 align:#left
	
	button 'btn_supprimerFacade' "-" pos:[156,51] width:16 height:16 align:#left
-- 	label 'lbl_facades' "Facades:" pos:[5,2] width:45 height:15 align:#left
	
	GroupBox 'grp_prop' "Propriétés" pos:[5,195] width:165 height:41 align:#left
	label 'lbl_composants' "Composants:" pos:[5,52] width:64 height:15 align:#left
	
	
	
	fn actualiser =(
		
-- 		lbl12.enabled 			= a_un_trace
		ddl_toiture.enabled 			= a_un_trace
		lbl_facade.enabled 			= a_un_trace
-- 		rdo_pentes.enabled 			= a_un_trace
		spn_toit_hauteur.enabled 	= a_un_trace
		lbl_hauteur.enabled 			= a_un_trace
		spn_pente.enabled 			= a_un_trace
		lbl_pente.enabled 			= a_un_trace
		lbl_composants.enabled 	= a_un_trace
		
		btn_ajouterFacade.enabled 	= a_un_trace
		btn_supprimerFacade.enabled 	= a_un_trace
		grp_prop.enabled 	= a_un_trace
		lbx_facades.enabled 	= a_un_trace
		
		
		if a_un_trace do (
-- 			rdo_pentes.enabled 					= ddl_toiture.selection == 3
			spn_pente.enabled 					= ddl_toiture.selection >= 3
			lbl_pente.enabled 					= ddl_toiture.selection >= 3
		)
	)
	
	
	
	on roll_toiture open do
		actualiser()
	on ddl_toiture selected sel 	do
	(
				actualiser	()
				creerBatiment ()
			)
	on spn_toit_hauteur changed val 	do
		creerBatiment ()
	on spn_pente changed val 	do
		creerBatiment ()
)
rollout roll_presets "Presets" width:235 height:205	rolledUp:true
(
	
	fn shape_filt 		obj = superclassof obj == shape
	
	button 'btn_enregistrer' "Enregistrer" pos:[88,2] width:85 height:16 align:#left		
		
		
	button 'btn_charger' "Charger" pos:[5,2] width:85 height:16 align:#left
	button 'btn_coller' "Coller" pos:[88,17] width:85 height:16 align:#left
	button 'btn_copier' "Copier" pos:[5,17] width:85 height:16 align:#left
	
	
	fn actualiser =(
		btn_coller.enabled 		= a_un_trace and urba_clipboard_batiment != ""
		btn_copier.enabled 			= a_un_trace
		btn_enregistrer.enabled 		= a_un_trace
		btn_charger.enabled 			= a_un_trace
		
	)
	
	
	
	
	on roll_presets open do actualiser ()

	on btn_enregistrer pressed do
		presets.enregistrer 	this
	on btn_charger pressed do
	(
			presets.charger 		this
			creerBatiment ()
			actualiser_rollouts()
		)
	on btn_coller pressed do
	(
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
rollout roll_infos "Infos" width:191 height:142	rolledUp:true
(
	label 'lbl16' "Surface:" pos:[5,69] width:43 height:14 align:#left
	label 'lbl_surface' "" pos:[85,69] width:78 height:16 align:#left 
 
 

	label 'lbl1_tracePts' "Tracé (origin.):" pos:[5,84] width:70 height:14 align:#left
	label 'lbl_tracePts_val' "" pos:[85,84] width:78 height:16 align:#left 
 
 

	label 'lbl1_tracePts_opt' "Tracé (optim.):" pos:[5,99] width:69 height:14 align:#left
	label 'lbl_tracePts_opt_val' "" pos:[85,99] width:78 height:16 align:#left 
 
 
	checkbutton 'ckb_axe' "Axe" pos:[10,14] width:75 height:16 align:#left	 --highlightColor:[200,200,100]
	 --highlightColor:[200,200,100]
	checkbutton 'ckb_trace' "Points" pos:[84,14] width:75 height:16 align:#left --highlightColor:[170,170,170]
 --highlightColor:[170,170,170]
	checkbutton 'ckb_pignons' "Pignons" pos:[84,29] width:75 height:16 align:#left		 --highlightColor:[130,130,250]
		 --highlightColor:[130,130,250]
	checkbutton 'ckb_gouttereaux' "Gouttereaux" pos:[10,29] width:75 height:16 align:#left --highlightColor:[250,100,100]
 --highlightColor:[250,100,100]
-- 		checkbutton 'ckb_longueurSegts' "Long. façades" pos:[5,32] width:80 height:16 align:#left --highlightColor:[170,170,170]
	checkbutton 'ckb_geometrie' "Cacher géom." pos:[10,44] width:75 height:16 highlightColor:(color 255 0 0) align:#left
	
	
	
	
	
-- 		on ckb_longueurSegts 	changed state 		do	VP_toggle ()
	groupBox 'grp30' "Viewport:" pos:[5,1] width:158 height:63 align:#left
	
	
	fn actualiser =(
		
		ckb_axe.enabled 					= a_un_trace
		ckb_trace.enabled 				= a_un_trace
		ckb_pignons.enabled 			= a_un_trace
		ckb_gouttereaux.enabled 		= a_un_trace
		ckb_geometrie.enabled 			= a_un_trace
		grp30.enabled 			= a_un_trace
		
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
	
	
	
	
	on ckb_geometrie 		changed state 		do 		actualiser_cacherGeo ()
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
	on roll_infos open do actualiser ()
	on roll_infos close do (
		cache_geometrie = false 
		actualiser_cacherGeo ()
	)
	
	
	on ckb_axe changed state 		do
		VP_toggle ()
	on ckb_trace changed state 		do
		VP_toggle ()
	on ckb_pignons changed state 		do
	(
			VP_toggle ()
			actualiser ()
		)
	on ckb_gouttereaux changed state 		do
	(
			VP_toggle ()
			actualiser ()
		)
	on ckb_geometrie changed state 		do
		actualiser_cacherGeo ()
)
rollout roll_aPropos "A propos" width:162 height:64 	rolledUp:true
(
	label 'lbl_axeP' "Urba | V0.1  |" pos:[5,2]  align:#left
	HyperLink 'hpl1' "Christophe Pagès" pos:[76,2] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	HyperLink 'hpl2' "GitHub" pos:[127,17] address:"https://github.com/c-pages/cp-Urba" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	label 'lbl6' "2017" pos:[5,17] align:#left
)

/* 
parameters params_TEST rollout:roll_TEST			(
	
	------- AFFICHAGE 		 ------------------
	modelesEnregistres		type:#string			default:""	
	
)
rollout roll_TEST "TEST" width:162 height:58
(
	pickbutton 'btn1' "piquer" 
 
	button 'btn2' "recreer" 
 
	on btn1 picked obj do
(
	modelesEnregistres = nodeScanner.get_datas 	obj
	)
	on btn2 pressed  do
(
	nodeScanner.creer_objet 	modelesEnregistres
	)
)

 */


















