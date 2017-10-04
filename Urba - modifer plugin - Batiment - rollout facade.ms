
	
	
	
	
	
	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeurFacades "urba_editeurFacades" width:255 height:267
	(
		
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		include "$userScripts\cp - GLOBAL\Mgr - ListView.ms"
		

		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
		local m_cible			---  le plugin cilbé
		local m_facade
		local m_composant_courant
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ui  virtuel perso ---
		local m_titre		
		
		-- les fenetre secondaires ---
		local dialog_modele, dialog_longueurFixe
		
		--- images bouton fermer ---
		local murs_types 	= #("Gouttereaux + Pignons", "Gouttereaux", "Pignons")
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Pressé ----
										)
		
		
		local note_etagesMinMax = "\n0 : RdC\nValeurs négative pour compter les étages en descendant, à partir du dernier (-1: dernier étage)"
-- 		local note_etagesMinMax = ""
		
		local lv_mgr
		
		------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left

		ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	 
		
		
	edittext 'edt_nom_facade' "" pos:[7,25] width:200 height:16 align:#left
		
	spinner 'spn_etages' "" pos:[103,53] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_etagesMax' "" pos:[180,53] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		
		
	dropdownList 'ddl_murs' "" pos:[90,68] width:154 height:21 items:#("Gouttereaux + Pignons", "Gouttereaux", "Pignons") selection:3 align:#left
	label 'lbl_appliquerA' "Murs:" pos:[12,72] width:32 height:15 align:#left
		
	checkbutton 'chk_etagesMax' "" pos:[167,53] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
		
		
	listbox 'lbx_sequence' "" pos:[91,109] width:137 height:9 align:#left
-- 		dotNetControl 'lbx_sequence'	 "System.Windows.Forms.ListView" pos:[91,109] 	width:490 height:190 
		
	button 'btn_supprimer_composant' "-" pos:[228,217] width:16 height:16 toolTip:"Supprimer le composant" align:#left
		
	label 'lbl23' "Séquence:" pos:[11,90] width:52 height:15 align:#left
		
	button 'btn_enregistrer' "S" pos:[224,24] width:19 height:19 toolTip:"Sauvegarder preset." align:#left
	button 'btn_charger' "O" pos:[206,24] width:19 height:19 toolTip:"Ouvrir preset." align:#left
		
	button 'btn_monter' "/\\" pos:[-50,108] width:16 height:25 toolTip:"Monter le composant." align:#left
	button 'btn_descendre' "\/" pos:[228,132] width:16 height:25 toolTip:"Descendre le composant." align:#left
	dropdownList 'ddl_mode' "" pos:[90,88] width:154 height:21 items:#("Répéter", "Etrirer", "Centrer", "Espacer") selection:3 align:#left
	checkbutton 'chk_etages' "" pos:[90,53] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	
	button 'btn_ajouter_espacement' "Espacement" pos:[10,108] width:81 height:16 toolTip:"Ajouter un espacement. Mur plein de longueur varirable, répartis par facade, entre tous les espacement" align:#left
	button 'btn_ajouter_modele' "Modèle 3D" pos:[10,204] width:81 height:16 toolTip:"Ajouter un modèle 3D." align:#left
		
	button 'btn_annuler' "Annuler" pos:[127,242] width:118 height:21 align:#left
	button 'btn_valider' "Valider" pos:[10,242] width:118 height:21 align:#left
		
	label 'lbl95' "Etages:" pos:[12,54] width:43 height:15 align:#left
		
	button 'btn_ajouter_longueurFixe' "Longueur fixe" pos:[10,123] width:81 height:16 toolTip:"Ajouter un mur plein de longueur fixe." align:#left
		
	button 'btn_ajouter_fenetre' "Fenêtre" pos:[10,140] width:81 height:16 toolTip:"Ajouter un modèle 3D." align:#left
	button 'btn_ajouter_porte' "Porte" pos:[10,155] width:81 height:16 toolTip:"Ajouter un modèle 3D." align:#left
	button 'btn_ajouter_balcon' "Balcon" pos:[10,172] width:81 height:16 toolTip:"Ajouter un modèle 3D." align:#left
	button 'btn_ajouter_loggia' "Loggia" pos:[10,187] width:81 height:16 toolTip:"Ajouter un modèle 3D." align:#left

		
		------------  Fonctions	----------------------------------------------------------------------------------
		---- Gere l'état du bouton  -----
		fn etatBtnFermer		_etat =(
			case _etat of (
				#Repos : 	ui_btnFermer.bitmap = icos_fermer[1]	
				#Survol : 	ui_btnFermer.bitmap = icos_fermer[2]	
				#Press : 	ui_btnFermer.bitmap = icos_fermer[3]	
			)
		)
		fn actualiser = (
			
			edt_nom_facade.text 			= m_facade.nom
			
			chk_etages.checked				= m_facade.etages_use_min
			spn_etages.indeterminate 		= not m_facade.etages_use_min	
			spn_etages.enabled 				= m_facade.etages_use_min	
			if not spn_etages.indeterminate do
				spn_etages.value				= m_facade.etages_nbre_min
			
			chk_etagesMax.checked		= m_facade.etages_use_max
			spn_etagesMax.indeterminate = not m_facade.etages_use_max	
			spn_etagesMax.enabled		= m_facade.etages_use_max			
			if not spn_etagesMax.indeterminate do
				spn_etagesMax.value		= m_facade.etages_nbre_max	
			
			ddl_murs.selection 				= m_facade.murs
			ddl_mode.selection 				= m_facade.mode
			
			local itemsTmp = #()
			for comp in m_facade.sequence		do	(
				
				case comp.type of (
					#Espacement:		append itemsTmp "<--->"
					#LongueurFixe:	append itemsTmp ("|-----|    "	+ comp.longueur as string  + "cm" )
					#Modele:			append itemsTmp ("|  #  |    "	+ comp.nom )
					default:				append itemsTmp comp.nom
				)
				
			)
			lbx_sequence.items =  itemsTmp
			
			btn_supprimer_composant.enabled = lbx_sequence.selection != 0
			
			try dialog_modele.actualiser () 			catch ()
			try dialog_longueurFixe.actualiser () 	catch ()
		)
		
		
		
		
		fn redimensionnerFenetre 		_taille 	=(
			
			if 	_taille.x < 255 do 
				roll_urba_editeurFacades.width = _taille.x =  255
			if 	_taille.y < 255 do 
				roll_urba_editeurFacades.height = _taille.y =  255
			
			
			local largeur_btn 		= 17
			local largeur_bord 		= edt_nom_facade.pos.x
			
			ui_btnFermer.pos.x		= 	_taille.x - 20
			
			edt_nom_facade.width 	= 	_taille.x - ( 2* largeur_bord	+ 2 * largeur_btn   )
			btn_enregistrer.pos.x 	= 	edt_nom_facade.width 	+  edt_nom_facade.pos.x
			btn_charger.pos.x 		= 	largeur_btn 	+  btn_enregistrer.pos.x
			
			ddl_murs.width 			= 	ddl_mode.width  = 	_taille.x  - ( ddl_murs.pos.x + largeur_bord )
			lbx_sequence.width 		= ddl_murs.width 	 - largeur_btn
			
			lbx_sequence.height 	= _taille.y - ( lbx_sequence.pos.y + largeur_btn + 2 * largeur_bord )
			
			
			btn_annuler.pos.x		= _taille.x - (  118 + largeur_bord )
			btn_annuler.pos.y 		= btn_valider.pos.y 	= _taille.y - (  largeur_btn +  largeur_bord )
			
			btn_monter.pos.x			=	btn_descendre .pos.x		=	btn_supprimer_composant.pos.x 	= lbx_sequence.pos.x + lbx_sequence.width
			btn_supprimer_composant.pos.y 	= lbx_sequence.pos.y + lbx_sequence.height - 14
			
		)
		
		
		
		
		
		---- Initialisation de la fenetre  -----
		fn initialiser = (
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Bâtiment | Façade"
			m_titre.setCouleur (color 255 255 255 )
			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			
			
			-- la fenetre ----
			redimensionnerFenetre  (getDialogSize	roll_urba_editeurFacades)
			actualiser()
		)
		
		fn ouvrir_fenetre_modele 			=(
			
-- 			try destroyDialog  dialog_modele 			catch ()
-- 			try destroyDialog  dialog_longueurFixe 	catch ()
			
			--- import du rollout ----
			dialog_modele = include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout Modele.ms"
			
			---- creation de la fenetre ----
			createDialog dialog_modele 	style:			#(#style_resizing) 	\
													lockHeight:		true						\
													lockWidth:		true	
			
			---- initialisation de la fenetre ----
			dialog_modele.m_prt	 			= roll_urba_editeurFacades
			dialog_modele.m_cible 			= m_cible	
			dialog_modele.m_composant 	= m_composant_courant
			
			dialog_modele.initialiser ()
			
		)
		
		fn ouvrir_fenetre_longueurFixe 		=(

-- 			try destroyDialog  dialog_modele 			catch ()
-- 			try destroyDialog  dialog_longueurFixe 	catch ()
			
			--- import du rollout ----
			dialog_longueurFixe = include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout longueurFixe.ms"
			
			---- creation de la fenetre ----
			createDialog dialog_longueurFixe 	style:				#(#style_resizing) 	\
										lockHeight:		true							\
										lockWidth:		true	
			
			---- initialisation de la fenetre ----
			dialog_longueurFixe.m_prt	 	= roll_urba_editeurFacades
			dialog_longueurFixe.m_cible 	= m_cible	
			dialog_longueurFixe.m_composant 	= m_composant_courant		
			dialog_longueurFixe.initialiser ()
			
		)
		
		
		
		
		------------  Evenements	----------------------------------------------------------------------------------	
		
		
		---- rollout	--------------------------
		on roll_urba_editeurFacades resized 		_taille 	do	redimensionnerFenetre 	_taille
		on roll_urba_editeurFacades lbuttondown _pos 		do	m_drag.demarrer ()
		on roll_urba_editeurFacades lbuttonup 	_pos 		do	m_drag.arreter ()
		on roll_urba_editeurFacades mouseMove _pos 		do	m_drag.suivreSouris ()
		on roll_urba_editeurFacades close 						do	(			
					try destroyDialog  dialog_modele 			catch ()
					try destroyDialog  dialog_longueurFixe 	catch ()
				)		
		
		
		---- btn fermer	--------------------------
		on ui_btnFermer 	mouseover 		do	etatBtnFermer #Survol
		on ui_btnFermer 	mouseout 		do	etatBtnFermer #Repos
		on ui_btnFermer 	mouseDown 	do	etatBtnFermer #Press
		on ui_btnFermer 	mouseUp 		do	etatBtnFermer #Repos
		on ui_btnFermer 	click 				do	(
					m_prt.fermer 	m_cible
				)
		
		on btn_ajouter_fenetre pressed  do
		(
					
					)
		on btn_ajouter_porte pressed  do
		(
					
					)
		on btn_ajouter_balcon pressed  do
		(
					
					)
		on btn_ajouter_loggia pressed  do
		(
					
					)
		---- Interface	--------------------------
		on edt_nom_facade entered txt 	do
		(
					m_facade.nom 					=	txt		
					actualiser ()
				)
		on spn_etages changed val 	do
		(
					m_facade.etages_nbre_min 	= 	val
					actualiser ()
				)
		on spn_etagesMax changed val 	do
		(
					m_facade.etages_nbre_max 	= 	val
					actualiser ()
				)
		on ddl_murs selected sel	 do
		(
					m_facade.murs 	= 	sel
					actualiser ()
				)
		on chk_etagesMax changed state do
		(
					m_facade.etages_use_max 	= 	state		
					actualiser ()
				)
		on ddl_mode selected sel	 do
		(
					m_facade.mode 	= 	sel
					actualiser ()
				)
		on chk_etages changed state do
		(
					m_facade.etages_use_min 	= 	state		
					actualiser ()
				)
		
		
		
		
		--- sequence -----------------------
		on btn_monter 		pressed do (
					local id_orig = lbx_sequence.selection
					if id_orig >1 do (
						local itemTmp = m_facade.sequence[id_orig]
						deleteItem	m_facade.sequence	id_orig
						insertItem	itemTmp		m_facade.sequence	(id_orig-1)
						lbx_sequence.selection	-= 1
					)
					actualiser ()
				)
		
		on btn_descendre 	pressed do (
					local id_orig = lbx_sequence.selection
					if id_orig < m_facade.sequence.count do (
						local itemTmp = m_facade.sequence[id_orig]
						deleteItem	m_facade.sequence	id_orig
						insertItem	itemTmp		m_facade.sequence	(id_orig+1)
						lbx_sequence.selection	+= 1
					)
					actualiser ()
				)
		
		on btn_supprimer_composant 	pressed do (
					local id = lbx_sequence.selection
					if id != 0 do
						deleteItem	m_facade.sequence	id					
					actualiser ()
				)
		
		
		on lbx_sequence selected _sel 	do (
					m_composant_courant = m_facade.sequence[_sel]
					
					actualiser ()
				)
		on lbx_sequence 	doubleClicked 	_sel 	do (
					m_composant_courant = m_facade.sequence[_sel]	
					if m_composant_courant.type == #Modele then
						ouvrir_fenetre_modele 	()
					else if m_composant_courant.type ==#LongueurFixe then
						ouvrir_fenetre_longueurFixe()
					actualiser ()
				)
		
		on btn_ajouter_espacement pressed do
		(
					format "lbx_sequence.selection:%\n" lbx_sequence.selection
					m_composant_courant = m_prt.creer_composant		lbx_sequence.selection	 #Espacement		m_cible 
					actualiser()
					
					lbx_sequence.selection	+= 1
				)
		on btn_ajouter_modele pressed do
		(
					format "lbx_sequence.selection:%\n" lbx_sequence.selection
					m_composant_courant = m_prt.creer_composant		lbx_sequence.selection	 #Modele	m_cible
					actualiser()
					
					lbx_sequence.selection	+= 1
					
					ouvrir_fenetre_modele 	()
				)
		on btn_ajouter_longueurFixe pressed do
		(
					format "lbx_sequence.selection:%\n" lbx_sequence.selection
					m_composant_courant	= m_prt.creer_composant		lbx_sequence.selection	 #LongueurFixe	m_cible 
					actualiser()
					
					lbx_sequence.selection	+= 1
					
					ouvrir_fenetre_longueurFixe ()
				)
				
				
				
				
		---- Validation / Annulation	--------------------------
		on btn_annuler pressed do
		(
					m_prt.fermer m_cible
				)
		on btn_valider pressed do
		(
					m_prt.valider_facade 	m_cible
					m_prt.fermer m_cible 	quiet:true
				)
				
				
				
	) --- fin rollout --------------------
	
	
	
	
	
	
	
	
	
	
