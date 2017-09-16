/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	FENETRE TYPE	( sert de model de base, n'est pas import� dans le script )	
	sans barre de titre, draggable et bouton fermer
	
	Remplacer (ctr + h): 'urba_batiments' par:  'maFenetreAMoi'.
	il y a des parties a decommenter :"--- a d�commenter ---"
	Noms des variables 
	-	roll_urba_batiments :			le nom de la fenetre
	-	urba_batiments_pos :			le parametre des prefs stockant la pos de la fenetre
	-	urba_batiments_estOuvert :	le nom du parametre ouvert dans les preferences ( labib.prefs.fenetre. ' urba_batimentsOuvert )
	-	str_urba_batiments:			le nom de la struicture de controle de la fenetre
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale ( mise au propre du travail durant l'�t�)
	- Une interface souple et simple
########################################################################################################################*/

-- (




------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"

-- include "$userScripts\cp-Urba\Urba - Structures - 2.ms"
include "$userScripts\cp-Urba\Urba - Batiment - edition.ms"

------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_batiments "urba_batiments" width:279 height:230
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	local ui_parametres
	
	------------  UI	----------------------------------------------------------------------------------		

	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_batiment.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	button 'btn_supprimer_bat' "-" pos:[244,22] width:21 height:21 align:#left
	button 'btn_ajouter_bat' "+" pos:[224,22] width:21 height:21 align:#left
	dropdownList 'ddl_bats' "" pos:[9,22] width:216 height:21 align:#left
	
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
-- 	ImgTag 'ui_log' "" pos:[8,43] width:66 height:18 align:#left
	
	
	edittext 'edt_bat_nom' "" pos:[115,47] width:147 height:16 align:#left
	label 'lbl_elem_nom' "Nom:" pos:[12,47] width:25 height:15 align:#left
	
	spinner 'spn_etages_min' "" pos:[117,111] width:145 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_elem_largeur' "Nbr. min.:" pos:[29,110] width:46 height:15 align:#left
	
	
	spinner 'spn_etages_max' "" pos:[117,126] width:145 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl14' "Nbr. max.:" pos:[29,125] width:51 height:15 align:#left
-- 	spinner 'spn_surf_min' "" pos:[117,64] width:128 height:16 range:[0,1e+13,0] scale:1 align:#left
-- 	label 'lbl_surf_min' "Surface min.:" pos:[29,64] width:68 height:15 align:#left
	spinner 'spn_etages_hauteur' "" pos:[117,141] width:145 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl18' "Hauteur:" pos:[29,140] width:44 height:15 align:#left
	spinner 'spn_rdc_hauteur' "" pos:[117,180] width:145 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl19' "Hauteur:" pos:[29,179] width:46 height:15 align:#left
-- 	label 'lbl20' "Sous-bassement:" pos:[12,229] width:90 height:15 align:#left
-- 	label 'lbl21' "m�" pos:[247,64] width:19 height:15 align:#left
	dropdownList 'ddl_toiture' "" pos:[119,67] width:144 height:21 align:#left
	label 'lbl22' "Toiture:" pos:[12,73] width:38 height:15 align:#left
	dropdownList 'ddl_etages' "" pos:[119,91] width:144 height:21 align:#left
	label 'lbl23' "Etages:" pos:[12,97] width:38 height:15 align:#left
	dropdownList 'ddl_rdc' "" pos:[119,160] width:144 height:21 align:#left
	label 'lbl24' "RdC:" pos:[12,166] width:25 height:15 align:#left
-- 	spinner 'spn_surf_max' "" pos:[117,79] width:128 height:16 range:[0,1e+13,0] scale:1 align:#left
-- 	label 'lbl_surf_max' "Surface max.:" pos:[29,78] width:68 height:15 align:#left
-- 	label 'lbl26' "m�" pos:[248,78] width:19 height:15 align:#left
-- 	spinner 'spn_ssBassement_hauteur' "" pos:[117,243] width:145 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
-- 	label 'lbl27' "Hauteur:" pos:[29,242] width:55 height:15 align:#left

	/*
	spinner 'spn_surf_min' "" pos:[117,64] width:128 height:16 range:[0,1e+13,0] scale:1 align:#left
	
	label 'lbl_surf_min' "Surface min.:" pos:[29,64] width:68 height:15 align:#left
	label 'lbl21' "m�" pos:[247,64] width:19 height:15 align:#left
	
	spinner 'spn_surf_max' "" pos:[117,79] width:128 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl_surf_max' "Surface max.:" pos:[29,78] width:68 height:15 align:#left
	label 'lbl26' "m�" pos:[248,78] width:19 height:15 align:#left
	*/
	------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'�tat du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	
	fn actualiser = (
		
		--- liste des bats -----
		local listTmp =#()
		for bat in m_prt.presets.get () do
			append listTmp bat.nom
		ddl_bats.items = listTmp
		
		---parametres -----
		local enable_ui = true
		if m_prt.batCourant != undefined then (
			edt_bat_nom.text 				= m_prt.batCourant.nom
-- 			spn_surf_min.value 				= m_prt.batCourant.surf_min
-- 			spn_surf_max.value 				= m_prt.batCourant.surf_max
			spn_etages_min.value 			= m_prt.batCourant.etages_min
			spn_etages_max.value			= m_prt.batCourant.etages_max
			spn_etages_hauteur.value 	= m_prt.batCourant.etages_hauteur
			spn_rdc_hauteur.value 			= m_prt.batCourant.rdc_hauteur
-- 			ddl_toiture....		= m_prt.batCourant.toiture_type
-- 			ddl_etages..... 	= m_prt.batCourant.etages_type
-- 			ddl_rdc.....	 		= m_prt.batCourant.rdc_type
			
			
		) else (
			enable_ui = false
			edt_bat_nom.text 				= ""
-- 			spn_surf_min.value 				= 0
-- 			spn_surf_max.value 				= 0
			spn_etages_min.value 			= 0
			spn_etages_max.value			= 0
			spn_etages_hauteur.value 	= 0
			spn_rdc_hauteur.value 			= 0
		)
		for ui in ui_parametres do
			ui.enabled = enable_ui
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		ui_parametres = #(btn_supprimer_bat, edt_bat_nom, lbl_elem_nom , spn_etages_min, lbl_elem_largeur, spn_etages_max, lbl14,   spn_etages_hauteur, lbl18, spn_rdc_hauteur,
		lbl19, ddl_toiture, lbl22, ddl_etages, lbl23, ddl_rdc, lbl24 )

		
		
		
		m_drag 		= str_drag 	m_prt:roll_urba_batiments		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | B�timents"
		m_titre.setCouleur (color 255	255	255)

		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	
	
	
		---- Drag ----
	
	---- Fermer ----
	
	on btn_ajouter_bat 		pressed 	do 	m_prt.creer_nouveau ()
	on btn_supprimer_bat 	pressed 	do 	m_prt.supprimer_batiment ddl_bats.selection
	
	on edt_bat_nom 		entered  	txt 		do 	m_prt.changerNom		txt
	
	on spn_etages_min 			changed 	val	do 	m_prt.changer_etagesMin			val
	on spn_etages_max 		changed 	val	do 	m_prt.changer_etagesMax			val
	on spn_etages_hauteur 	changed 	val	do 	m_prt.changer_etagesHauteur	val
	on spn_rdc_hauteur 		changed 	val	do 	m_prt.changer_rdcHauteur			val
	
	
	on btn_edit pressed  do m_prt.edition.ouvrir ()
	
	
	on ddl_bats 				selected  	val 	do 	m_prt.selectionner_id 	val
	
	
	
	
	
	
	
	on roll_urba_batiments lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_batiments lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_batiments mouseMove _pos 	do
		m_drag.suivreSouris ()
	
	
	
	---- Fermer ----
	on ui_btnFermer mouseover do
		etatBtnFermer #Survol
	on ui_btnFermer mouseout do
		etatBtnFermer #Repos
	on ui_btnFermer mouseDown do
		etatBtnFermer #Press
	on ui_btnFermer mouseUp do
		etatBtnFermer #Repos	
	on ui_btnFermer click do
		m_prt.fermer ()
	
)

------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_urba_batiments (
	----------------------------------------------------------------------------------------------------------
	------------  Membres	----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	
		------------	STRUCTURES DIVERSES 		------------------------------------------------------------------------------------------
	public
		---- le struct principale parent ----
		m_urba,
	
		---- le manager de presets ----
		presets = str_presetsMGR 	preset_type:	str_urba_preset_batiment	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"Bat",
		
		---- la batiment actuelement selectionn�e ----
		batCourant,

		
		------------	UI		------------------------------------------------------------------------------------------
	public
		m_estOuvert 			= false,
		---- pointeurs ----
		m_dialog				= roll_urba_batiments ,		---- le rollout ----
		m_dialogPos 		= [100,100],
		
		col_fenetreFond	= color 68  68 68, 	----  ----
		col_fenetreTxt		= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer 	= #(	openBitMap ico_btnFermer_R ,		-- Repos ----
										openBitMap ico_btnFermer_S ,		-- Survol ----
										openBitMap ico_btnFermer_P 			-- Press� ----
									),
		
	----------------------------------------------------------------------------------------------------------
	------------  Fonctions	------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	
	public
	------------	UI		------------------------------------------------------------------------------------------
		fn actualiser 	= if m_estOuvert do m_dialog.actualiser (),
		fn selectionner 	_preset 	=(
			local id_preset = presets.trouver_ID 	_preset
			batCourant = _preset
			m_dialog.ddl_bats.selection = id_preset
			actualiser ()
		),
		fn selectionner_id 	_id =(
			if _id >0 do (
				batCourant = presets.get_preset		_id
				m_dialog.ddl_bats.selection = _id
			)
			actualiser ()
		),
		fn estOuvert = m_estOuvert,
			
		---- fenetre -----
		fn ouvrir 	pos:	=(			
			m_estOuvert 		= true
			if pos != unsupplied do	m_dialogPos = pos
				
			---- creation de la fenetre ----
			createDialog m_dialog 	bgcolor:				col_fenetreFond 		\
											fgcolor:				col_fenetreTxt 		\
											style:				#(#style_resizing) 	\
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
			--- pour selectionner un premier �l�ment
			if ( presets.get () ).count >0 do selectionner_id 1
			
			actualiser ()
			
		),
		
		fn fermer  =(	
			m_estOuvert 		= false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fen�tre ----
			try destroydialog m_dialog catch ()
			
		),
		
		
									
	------------	Manager des batiments		------------------------------------------------------------------------------------------
		fn creer_nouveau =(
			presets.creer_preset ()
			if not m_estOuvert do ouvrir ()
			selectionner_id (presets.get()).count
			actualiser()
		),
		fn supprimer_batiment 	_id	 =(
			local presetAVirer = presets.get_preset		_id
			
			--- on check si il y a des ville possedant ce batiment
			local villesAyantCeBatiment = #()
			for ville in m_urba.villes.presets.get () do
				if m_urba.villes.a_batiment	ville	presetAVirer.idUnique do 
					append villesAyantCeBatiment ville
			
			
			
			if querybox ( "Supprimer d�finitivement: " + presetAVirer.nom + " ?\n" +  villesAyantCeBatiment.count as string + " ville(s) ont ce b�timent." ) do (
				presets.supprimer _id
				
				for ville in villesAyantCeBatiment do( 
					local idAVirer = 	findItem ville.batiments	presetAVirer.idUnique
					m_urba.villes.retirer_batimentID	idAVirer
				)
	-- 			local _idUnique = villeCourante.batiments [_id]
-- 				deleteItem	villeCourante.batiments 	_id
-- 				deleteItem	villeCourante.probabilites 	_id
					
				
				selectionner_id 	( m_dialog.ddl_bats.selection - 1 )
			)
			actualiser ()
			m_urba.actualiser ()
		),
		
		
		fn changerNom 	_nvNom =(
			batCourant.nom = _nvNom
			presets.sauvegarder		batCourant
			actualiser ()
			m_urba.villes.actualiser ()
		),
		
		fn changer_etagesMin 	_val	 =(
			batCourant.etages_min = _val
			presets.sauvegarder		batCourant
			actualiser ()
			m_urba.actualiser ()
		),
		fn changer_etagesMax 	_val	 =(
			batCourant.etages_max = _val
			presets.sauvegarder		batCourant
			actualiser ()
			m_urba.actualiser ()
		),
		fn changer_etagesHauteur 	_val	 =(
			batCourant.etages_hauteur = _val
			presets.sauvegarder		batCourant
			actualiser ()
			m_urba.actualiser ()
		),
		fn changer_rdcHauteur 	_val	 =(
			batCourant.rdc_hauteur = _val
			presets.sauvegarder		batCourant
			actualiser ()
			m_urba.actualiser ()
		)
		
	/* 
	surf_min			= 	50.,
	surf_max 		= 	350.,
	
	toiture_type		=	"",
	
	etages_type		=	"",
	etages_min			= 	50,
	etages_max 		= 	350,
	etages_hauteur 	= 	250,
	
	rdc_type			=	"",
	rdc_hauteur 		= 	300 */
)





