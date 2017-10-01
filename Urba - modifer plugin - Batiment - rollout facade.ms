
	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeurFacades "urba_editeurFacades" width:247 height:626
	(
		
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ctro des imgtags ---
		local m_titre
		
		local m_cible		-- le plus cilbé
--- images bouton fermer ---
		local murs_types 	= #("Gouttereaux + Pignons", "Gouttereaux", "Pignons")
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
										openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
										openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Pressé ----
										)
		------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left

		ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	 
		
		edittext 'edt_nom_facade' "" pos:[3,40] width:236 height:16 align:#left
		
		spinner 'spn_longueur' "" pos:[84,96] width:71 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		spinner 'spn_longueurMax' "" pos:[167,96] width:71 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		spinner 'spn_etages' "" pos:[84,111] width:71 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		spinner 'spn_etagesMax' "" pos:[167,111] width:71 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		
		
		dropdownList 'ddl_appliquerA' "" pos:[86,76] width:153 height:21 items:#("Gouttereaux + Pignons", "Gouttereaux", "Pignons") selection:3 align:#left
		label 'lbl_appliquerA' "Murs:" pos:[8,78] width:32 height:15 align:#left
		
		checkbox 'chk_longueurMax' "" pos:[157,98] width:12 height:12 align:#left
		checkbox 'chk_etagesMax' "" pos:[157,113] width:12 height:12 align:#left
		
		
		
		edittext 'edt_nom_composant' "" pos:[12,285] width:220 height:16 align:#left
		listbox 'lbx_composants' "" pos:[7,142] width:217 height:9 align:#left
		button 'btn_ajouter_composant' "+" pos:[194,127] width:16 height:16 align:#left
		button 'btn_supprimer_composant' "-" pos:[209,127] width:16 height:16 align:#left
		GroupBox 'grp3' "Propriétés composant :" pos:[7,269] width:232 height:328 align:#left
		spinner 'spn_longueur_composant' "" pos:[85,302] width:67 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		spinner 'spn_longueurMax_composant' "" pos:[165,302] width:67 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		checkbox 'chk_longueurMax_composant' "" pos:[155,304] width:12 height:12 align:#left
		listbox 'lbx_modeles' "" pos:[16,349] width:214 height:9 align:#left
		button 'btn_ajouter_modele' "+" pos:[200,334] width:16 height:16 align:#left
		button 'btn_supprimer_modele' "-" pos:[215,334] width:16 height:16 align:#left
		label 'lbl12' "Modèles:" pos:[17,334] width:53 height:15 align:#left
		
		label 'lbl23' "Séquence:" pos:[7,128] width:52 height:15 align:#left
		
		button 'btn_enregistrer' "Enregistrer sous" pos:[123,24] width:117 height:16 align:#left
		button 'btn_charger' "Charger" pos:[7,24] width:117 height:16 align:#left
		
		button 'btn_monter' "^" pos:[224,180] width:16 height:16 align:#left
		button 'btn_descendre' "v" pos:[224,195] width:16 height:16 align:#left
		edittext 'edt_fichier' "" pos:[89,553] width:100 height:16 align:#left
		label 'lbl_fichier' "Fichier:" pos:[25,553] width:40 height:15 align:#left
		spinner 'spn_proba_modele' "" pos:[95,488] width:71 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
		label 'lbl_proba_modele' "Probabilité:" pos:[25,488] width:58 height:15 align:#left
		dropdownList 'ddl_mode' "" pos:[86,56] width:153 height:21 items:#("Répéter", "Etrirer", "Centrer") selection:3 align:#left
		checkbox 'chk_longueur' "longueur:" pos:[6,97] width:62 height:14 align:#left
		checkbox 'chk_etages' "Etages:" pos:[6,112] width:52 height:14 align:#left
		label 'lbl_mode' "Mode:" pos:[8,61] width:33 height:15 align:#left
		checkbox 'chk_troncable' "Troncable" pos:[15,319] width:63 height:14 align:#left
		GroupBox 'grp_model' "Modèle :" pos:[16,472] width:213 height:120 align:#left
		button 'btn_from_fichier' "..." pos:[205,553] width:16 height:16 align:#left
		
		
		checkbox 'chk_longueur_compo' "longueur:" pos:[15,303] width:62 height:14 align:#left
		
		
		button 'btn_merge_modele' "Merge" pos:[127,507] width:52 height:16 align:#left
		pickbutton 'pck_model_scene' "Pick" pos:[76,507] width:52 height:16 align:#left
		
		
		
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
			
			local fcdTmp = m_prt.facade_courante
			
			edt_nom_facade.text 			= fcdTmp.nom
			
			spn_longueur.value				= fcdTmp.longueur_min
			spn_longueurMax.value			= fcdTmp.longueur_max
			spn_etages.value					= fcdTmp.etages_nbre_min
			spn_etagesMax.value			= fcdTmp.etages_nbre_max
			
			chk_longueur.checked			= fcdTmp.longueur_use
			chk_etages.checked				= fcdTmp.etages_use
			
			spn_longueurMax.enabled			= chk_longueur.checked
			spn_etagesMax.enabled			= chk_etages.checked
			
			chk_longueurMax.checked		= fcdTmp.longueur_use_max
			chk_etagesMax.checked		= fcdTmp.etages_use_max
			
-- 			chk_etages.enabled 				= fcdTmp.etages_use
-- 			chk_longueur.enabled 			= fcdTmp.longueur_use
			
			spn_longueur.enabled 			= chk_longueur.checked	
			spn_etages.enabled 				= chk_etages.checked	

			ddl_appliquerA.selection 		= fcdTmp.murs
			ddl_mode.selection 				= fcdTmp.mode
			
			spn_longueurMax.enabled		= chk_longueurMax.checked
			spn_etagesMax.enabled		= chk_etagesMax.checked
			
-- 			lbx_composants.items = for compo in m_prt.get_sequence_courante 	m_cible		collect compo.nom
			local enabled = lbx_composants.selection != 0 
			
			btn_monter.enabled = enabled
			btn_descendre.enabled = enabled
			
			btn_supprimer_composant.enabled = enabled
			grp3.enabled = enabled
			spn_longueur_composant.enabled = enabled
			spn_longueurMax_composant.enabled = enabled
			chk_longueurMax_composant.enabled = enabled
			
			lbx_modeles.enabled = enabled
			btn_ajouter_modele.enabled = enabled
			btn_supprimer_modele.enabled = enabled
			lbl12.enabled = enabled
			edt_nom_composant.enabled = enabled
			chk_troncable.enabled = enabled
			chk_longueur_compo.enabled = enabled
			chk_longueur_compo.enabled = enabled
			
			local compoTmp = m_prt.composant_courant
			if compoTmp != undefined then (
				spn_longueur_composant.Indeterminate 	= false
				spn_longueurMax_composant.Indeterminate = false
				
				edt_nom_composant.text 					= compoTmp.nom
				spn_longueur_composant.value 			= compoTmp.longueur
				chk_longueurMax_composant.state 	= compoTmp.longueur_maxEnable
				
				spn_longueurMax_composant.value	 	= compoTmp.longueur_max
				
				lbx_modeles.items = for modele in m_prt.get_modeles_courant 	m_cible		collect modele.nom
				
			) else (
				edt_nom_composant.text =""
				spn_longueur_composant.Indeterminate = true 
				spn_longueurMax_composant.Indeterminate = true
				chk_longueurMax_composant.triState	= 2
				
			)
			
			lbx_composants.items = for compo in m_prt.get_sequence_courante 	m_cible		collect compo.nom
			local enabled_model = lbx_composants.selection != 0
			
			grp_model.enabled = enabled_model
			spn_proba_modele.enabled = enabled_model
			
			lbl_fichier.enabled = enabled_model
			edt_fichier.enabled = enabled_model
			btn_from_fichier.enabled = enabled_model
-- 			pck_model_scene.enabled = enabled_model
			lbl_proba_modele.enabled = enabled_model
			
		)
		
		---- Initialisation de la fenetre  -----
		fn initialiser = (
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de façades"
			m_titre.setCouleur (color 255 255 255 )
-- 			m_titre.setCouleurFond ( color 200 200 200 )

			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			actualiser()

		)
		
		
		------------  Evenements	----------------------------------------------------------------------------------
		
		---- Fermer ----
		
		---- Drag ----
		
			
		
			
		
		on lbx_modeles	selected val do
			m_prt.afficher_modele		val 	m_cible
		
		
		
	
		on pck_model_scene 	picked _node do (
			format "pck_model_scene+++++++++++++++++++\n"
			m_prt.assigner_node 	_node	m_cible
		)
		on btn_merge_modele pressed do
	(
			m_prt.merge_modele		m_cible
		)
		
		
		
		
		
		on roll_urba_editeurFacades lbuttondown _pos 	do
			m_drag.demarrer ()
		on roll_urba_editeurFacades lbuttonup _pos 	do
			m_drag.arreter ()
		on roll_urba_editeurFacades mouseMove _pos 	do
			m_drag.suivreSouris ()
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
		on edt_nom_facade entered txt 	do
			m_prt.set_nom 		txt		m_cible
		on spn_longueur changed val do
		(
					m_prt.set_longueur			val		m_cible
					actualiser ()
				)
		on spn_longueurMax changed val do
		(
					m_prt.set_longueurMax			val		m_cible
					actualiser ()
				)
		on spn_etages changed val do
		(
					m_prt.set_etages			val		m_cible
					actualiser ()
				)
		on spn_etagesMax changed val do
		(
					m_prt.set_etagesMax			val		m_cible
					actualiser ()
				)
		on ddl_appliquerA selected arg do
		(
					m_prt.set_murs			arg		m_cible
					actualiser ()
				)
		on chk_longueurMax changed state do
		(
					m_prt.set_longueurMaxState			state		m_cible
					actualiser ()
				)
		on chk_etagesMax changed state do
		(
					m_prt.set_etagesMaxState			state		m_cible
					actualiser ()
				)
		on edt_nom_composant entered txt do
		(
					m_prt.set_nom_composants	txt		m_cible
					actualiser ()
				)
		on lbx_composants selected val do
		(
					m_prt.afficher_composant 	val 	m_cible
					actualiser ()
				)
		on btn_ajouter_composant pressed do
		(
					m_prt.ajouter_composant				m_cible
					actualiser ()
				)
		on btn_supprimer_composant pressed do
		(
					m_prt.supprimer_composant			lbx_composants.selection 		m_cible
					actualiser ()
				)
		on spn_longueur_composant changed val do
		(
					m_prt.set_longueur_composant			val		m_cible
					actualiser ()
				)
		on spn_longueurMax_composant changed val do
		(
					m_prt.set_longueurMax_composant				val		m_cible
					actualiser ()
				)
		on chk_longueurMax_composant changed state do
		(
					m_prt.set_longueurMax_composantState			state		m_cible
					actualiser ()
				)
		on btn_ajouter_modele pressed do
		(
					m_prt.ajouter_modele				state		m_cible
					actualiser ()
				)
		on btn_supprimer_modele pressed do
		(
					m_prt.supprimer_modele				state		m_cible
					actualiser ()
				)
		on btn_enregistrer pressed do
			m_prt.enregistrer  ()
		on btn_charger pressed do
		(
					m_prt.charger 	m_cible
					actualiser ()
				)
		on btn_monter pressed do
		(
		
					
					actualiser ()
				)
		on btn_descendre pressed do
		(
				
					actualiser ()
				)
		on ddl_mode selected val do
		(
					m_prt.set_mode 	val 	m_cible
					actualiser ()
				)
		on chk_longueur changed state do
		(
					m_prt.set_longueurState			state		m_cible
					actualiser ()
				)
		on chk_etages changed state do
		(
					m_prt.set_etagesState			state		m_cible
					actualiser ()
				)
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
			
